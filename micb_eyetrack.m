% Motion-Induced Change Blindness, 
% Developed by Richard Yao
% Modified by Katherine Wood 
% Modified by Kyle Mathewson 
% Modified by Sarah Sheldon

%to test asynchrony between change and motion change

% /////////////////////////////////////////////////////////////////////////
%
% ==== TRIGGERS ====
%
% Start eye tracker: 90
% End eye tracker: 99
% Break: 2
% 
% -- Turn Trials --
% Trial start (fixation): soas+10 (3,5,7,9,10,11,13,15,17)
% Stimulus change: 
%   Movement & Gabor: soas+21 (14,16,18,20,21,22,24,26,28)
%   Movement:         soas+30 (23,25,27,29,30,31,33,35,37)
%   Gabor:            soas+41 (34,36,38,40,41,42,44,46,48)
% Response screen: soas+50 (43,45,47,49,50,51,53,55,57)  
% Response:
%   Correct: soas+61 (54,56,58,60,61,62,64,66,68)
%   Incorrect: soas+70 (63,65,67,69,70,71,73,75,77)
%   Timed out: soas+81 (74,76,78,80,81,82,84,86,88)
%
% -- Straight Trials --
% Trial start (fixation): soas+110 (103,105,107,109,110,111,113,115,117)
% Stimulus change: 
%   Movement & Gabor: soas+121 (114,116,118,120,121,122,124,126,128)
%   Movement:         soas+130 (123,125,127,129,130,131,133,135,137)
%   Gabor:            soas+141 (134,136,138,140,141,142,144,146,148)
% Response screen: soas+150 (143,145,147,149,150,151,153,155,157)  
% Response:
%   Correct: soas+161 (154,156,158,160,161,162,164,166,168)
%   Incorrect: soas+170 (163,165,167,169,170,171,173,175,177)
%   Timed out: soas+181 (174,176,178,180,181,182,184,186,188)
% 
% /////////////////////////////////////////////////////////////////////////



clear all
Screen('Preference', 'SkipSyncTests', 1)
Priority(2);
clc;
seed = ceil(sum(clock)*1000);
% rand('twister',seed);
rng(seed,'twister'); %updated syntax for new matlab versions

global w bgcolor rect gaborPatch arrayRects rotation centerOfArray ...
    direction movementIncrement fixationSize fixationColor fixationRect

% /////////////////////////////////////////////////////////////////////////
%% Input
Info.number = input('Participant Number:','s');
Info.date = datestr(now,30); % 'dd-mmm-yyyy HH:MM:SS' 
% output file will be named after the inputs
Filename = [Info.number '--' Info.date '_data.mat'];

% /////////////////////////////////////////////////////////////////////////
%% Basic parameters
bgcolor = [128 128 128];
[w rect] = Screen('OpenWindow',0,bgcolor);
xc = rect(3)./2;
yc = rect(4)./2;
xBorder = round(rect(3)./6);
yBorder = round(rect(4)./6);
textSize = round(rect(4)*.02);
Screen('TextSize',w,textSize);
directionNames = {'Right' 'Left'};

% Get presentation timing information
refresh = Screen('GetFlipInterval',w); % Get flip refresh rate
slack = refresh/2; % Divide by 2 to get slack

% fixation parameters
fixationPause = .5;
fixationColor = [0 0 0];
fixationSize = 2;

% gabor array parameters
numberOfGabors = 8;
arrayCenters = zeros(numberOfGabors,2);
r = round(rect(4)./10);
g = round(.8*r);
gaborSize = g;

% stimulus motion parameters
movementSpeed = 3;
rotationSize = 30;

% trial parameters
practiceTrials = 20; %was 30
breakEvery = 48; %so equal # trials per block (5 blocks at reps = 5 & 6 blocks at reps = 6)
timeLimit = 5;
feedbackPause = .5;

%pick soas
% soas = sort([-7:2:7,0]); %for different SOAs
soas = 0; %for gabor rotation happening only when their is a change in direction
nsoas = length(soas);

% /////////////////////////////////////////////////////////////////////////
%% Read in image
Screen('BlendFunction',w,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
[gaborMatrix map alpha] = imread('single_gabor_75px.png');
gaborMatrix(:,:,4) = alpha(:,:);
gaborPatch = Screen('MakeTexture',w,gaborMatrix);

% /////////////////////////////////////////////////////////////////////////
%% Counterbalancing
reps = 6; % Number of reps per angle condition per direction
% reps = 4; % Number of reps per angle condition per direction
trialList = [repmat(1:numberOfGabors,1,3*reps);...  %list of which target
    zeros(1,numberOfGabors*reps) ...  %list of which angle (%270 left, 90 Right, 0 straight)
    repmat(90,1,numberOfGabors*reps)...
    repmat(270,1,numberOfGabors*reps)];
%list of which direction
trialList = [trialList trialList; ...
        zeros(1,numberOfGabors*3*reps) ones(1,numberOfGabors*3*reps)]; 
trialList = trialList(:,randperm(length(trialList)));
practiceList = trialList(:,randperm(length(trialList)));
trialList = trialList';
practiceList = practiceList';
totalTrials = length(trialList);

% /////////////////////////////////////////////////////////////////////////
%% Array Center Points
for i = 1:numberOfGabors
    arrayCenters(i,1) = r*cos((i-1)*(2*pi/numberOfGabors));
    arrayCenters(i,2) = r*sin((i-1)*(2*pi/numberOfGabors));
end
arrayCenters = round(arrayCenters);
centeredRects = [arrayCenters arrayCenters] + ...
        round(repmat([xc-g/2 yc-g/2 xc+g/2 yc+g/2],numberOfGabors,1));
centeredRects = centeredRects';

% /////////////////////////////////////////////////////////////////////////
%% Set-up Output Variables
out_soa = [];
out_direction = []; 
out_angle = [];  
out_accuracy = [];
out_RT = [];
out_rotation = cell(1,length(trialList)); %pre-allocate

% /////////////////////////////////////////////////////////////////////////
% /////////////////////////////////////////////////////////////////////////
%% Triggers for EEG
% /////////////////////////////////////////////////////////////////////////
% /////////////////////////////////////////////////////////////////////////
%% ----Set up parallel port
addpath M:\Experiments\matlab\ParallelPorts
%initialize the inpoutx64 low-level I/O driver
config_io;
%optional step: verify that the inpoutx64 driver was successfully installed
global cogent;
if( cogent.io.status ~= 0 )
   error('inp/outp installation failed');
end
%write a value to the default LPT1 printer output port (at 0x378)
address_eeg = hex2dec('B010');

outp(address_eeg,0);  %set pins to zero  

% /////////////////////////////////////////////////////////////////////////
%% ----Trigger Stimulus
trigger_size = [0 0 1 1];

qq = 1; %for recording timing of events in matlab

% /////////////////////////////////////////////////////////////////////////
% /////////////////////////////////////////////////////////////////////////
%% Instructions for experimenter
Screen('FillRect',w,bgcolor);
DrawFormattedText(w,'Calibrated? Start EEG Recording and Press the SPACE BAR','center','center',[]);
Screen('FillRect',w,Vpixx2Vamp(0),trigger_size);
Screen('Flip',w)

KbWait;

Screen('FillRect',w,bgcolor);
Screen('FillRect',w,Vpixx2Vamp(90),trigger_size);
eyetrack_on = Screen('Flip',w);
% system('C:\Users\user\Downloads\CoreSDK\CoreSDK\samples\Streams\Interaction_Streams_101\bin\Debug\Interaction_Streams_101.exe &');
system('M:\Experiments\micb_eyetrack\CoreSDK\CoreSDK\samples\Streams\Interaction_Streams_101\bin\Debug\Interaction_Streams_101.exe &');
eyetrack_on2 = GetSecs;

WaitSecs(2);

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% /////////////////////////////////////////////////////////////////////////
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%% Instructions for subject %%
Screen('FillRect',w,bgcolor);
DrawFormattedText(w,'In the following task, you will follow, with your eyes, an array of striped patches moving across the screen.\n\nOn EVERY TRIAL, one of the patches will rotate slightly while moving with its neighbors. When prompted, you will have to click on the patch that rotated.\n\nWe are testing what conditions make that rotation harder or easier to see, so do not be surprised if you did not see any rotation. Just do your best and take a guess if you are unsure.\n\nThe task is easiest if you follow the dot that appears at the middle of the array, so follow that with your eyes on each trial.\n\n\nLet the experimenter know if you have any questions.\n\nClick the mouse to start the practice trials.','center','center',[]);
Screen('FillRect',w,Vpixx2Vamp(0),trigger_size);
Screen('Flip',w)
GetClicks(w);
WaitSecs(1.25);

% /////////////////////////////////////////////////////////////////////////
%% ---- Experiment ----
% /////////////////////////////////////////////////////////////////////////
for k = -(practiceTrials+1):length(trialList)
    fprintf(num2str(k))
    fprintf('\n')
    %pick SOA
    this_soa = soas(randi(nsoas));

    %Trial type
    if k < 0
        direction = practiceList(-k,3);
        target = practiceList(-k,1);
        angle = practiceList(-k,2);
        trialNum = 'Practice';
        %trial type trigger
        if angle ~= 0 %turn
            trig = 10 + this_soa; %(3,5,7,9,10,11,13,15,17)
        elseif angle == 0 %straight
            trig = 110 + this_soa; %(103,105,107,109,110,111,113,115,117)
        end
    elseif k == 0
        direction = practiceList(practiceTrials,3);
        target = practiceList(practiceTrials,1);
        angle = practiceList(practiceTrials,2);
        trialNum = 'Practice';
        %trial type trigger
        if angle ~= 0 %turn
            trig = 10 + this_soa; %(3,5,7,9,10,11,13,15,17)
        elseif angle == 0 %straight
            trig = 110 + this_soa; %(103,105,107,109,110,111,113,115,117)
        end
    else
        direction = trialList(k,3);
        target = trialList(k,1);
        angle = trialList(k,2);
        trialNum = num2str(k);
        %trial type trigger
        if angle ~= 0 %turn
            trig = 10 + this_soa; %(3,5,7,9,10,11,13,15,17)
        elseif angle == 0 %straight
            trig = 110 + this_soa; %(103,105,107,109,110,111,113,115,117)
        end
    end

    %Stimuli bounds
    arrayRects = [arrayCenters arrayCenters] + ...
                round(repmat([g/2+r-g/2 yc-g/2 g/2+r+g/2 yc+g/2],numberOfGabors,1));
    if direction
        arrayRects = arrayRects + repmat([-(2*r+g)+rect(3)-xBorder 0],numberOfGabors,2);
    else
        arrayRects = arrayRects + repmat([xBorder 0],numberOfGabors,2);
    end
    arrayRects = arrayRects';

% /////////////////////////////////////////////////////////////////////////
    %% Gabors
    rotation = round(rand(1, numberOfGabors) * 360);
    if k >= 1
        out_rotation{k} = rotation;
    end
    gaborPatch = Screen('MakeTexture',w,gaborMatrix);

    %%%%%%%%
    %%%%%%%%
    %%%%%%%%

% /////////////////////////////////////////////////////////////////////////    
    %% STIMULUS CODE %%
    HideCursor
    
    motion_changePoint = xc;
    motion_flexion_height = yc;

    %%%
    gabor_soa_frames = this_soa; % negative before motion 
    %%%

    gabor_soa_frames = -gabor_soa_frames; %switch sign
    gabor_changePoint = gabor_soa_frames * 3; % moves three pixels on each frame
    
    trialOver = 0;
    motionOver = 0; % motion change
    gaborOver = 0; % gabor change
    movementIncrement = repmat([movementSpeed 0 movementSpeed 0],numberOfGabors,1)';
    
    DrawStim(trig,trigger_size) % draw stimulus screen
    % --track timing of events in matlab--
    eventtrack(qq,1) = trig;
    eventtrack(qq,2) = GetSecs();
    qq = qq + 1;
    % ------------------------------------
    WaitSecs(fixationPause); 

    while ~trialOver

        % check if reached the edge and set flag
        if max(arrayRects(3, :)) > rect(3)-xBorder || ...
                max(arrayRects(4, :)) > rect(4)-yBorder || ...
                min(arrayRects(3, :)) < xBorder || ...
                min(arrayRects(4, :)) < yBorder
            trialOver = 1;
        end

        % check for first motion change point, change, and flag
        motion_howfar = ((-1) ^ (direction+1)) * (centerOfArray(1) - motion_changePoint) + ...
                        (-1) * abs(centerOfArray(2) - motion_flexion_height);
        if motion_howfar < 1 & ~motionOver
            motionOver = 1;
            % Change movement direction
            movementIncrement = repmat(movementSpeed.*[cosd(angle) ...
                                    sind(angle) cosd(angle) sind(angle)], ...
                                    numberOfGabors, 1)';
        end

        % check for gabor change point, change, and flag
        gabor_howfar = ((-1) ^ (direction+1)) * (centerOfArray(1) - motion_changePoint) + ...
                       (-1) * abs(centerOfArray(2) - motion_flexion_height);
        if gabor_howfar < gabor_changePoint & ~gaborOver
            gaborOver = 1;
            %Change Gabor angle
            rotation(target) = rotation(target) + rotationSize;
        end

        % Make triggers specific to the movement events
        if (motion_howfar < 1 & ~motionOver) && (gabor_howfar < gabor_changePoint & ~gaborOver)
            MoveStim()
            if angle ~= 0 %turn
                DrawStim((21 + this_soa),trigger_size)  %(14,16,18,20,21,22,24,26,28)
                % --track timing of events in matlab--
                eventtrack(qq,1) = (21 + this_soa);
                eventtrack(qq,2) = GetSecs();
                qq = qq + 1;
                % ------------------------------------
            elseif angle == 0 %straight
                DrawStim((121 + this_soa),trigger_size) %(114,116,118,120,121,122,124,126,128)
                % --track timing of events in matlab--
                eventtrack(qq,1) = (121 + this_soa);
                eventtrack(qq,2) = GetSecs();
                qq = qq + 1;
                % ------------------------------------
            end
        elseif motion_howfar < 1 & ~motionOver
            MoveStim()
            if angle ~= 0 %turn
                DrawStim((30 + this_soa),trigger_size)  %(23,25,27,29,30,31,33,35,37)
                % --track timing of events in matlab--
                eventtrack(qq,1) = (30 + this_soa);
                eventtrack(qq,2) = GetSecs();
                qq = qq + 1;
                % ------------------------------------
            elseif angle == 0 %straight
                DrawStim((130 + this_soa),trigger_size) %(123,125,127,129,130,131,133,135,137)
                % --track timing of events in matlab--
                eventtrack(qq,1) = (130 + this_soa);
                eventtrack(qq,2) = GetSecs();
                qq = qq + 1;
                % ------------------------------------
            end
        elseif gabor_howfar < gabor_changePoint & ~gaborOver
            MoveStim()
            if angle ~= 0 %turn
                DrawStim((41 + this_soa),trigger_size)  %(34,36,38,40,41,42,44,46,48)
                % --track timing of events in matlab--
                eventtrack(qq,1) = (41 + this_soa);
                eventtrack(qq,2) = GetSecs();
                qq = qq + 1;
                % ------------------------------------
            elseif angle == 0 %straight
                DrawStim((141 + this_soa),trigger_size) %(134,136,138,140,141,142,144,146,148)
                % --track timing of events in matlab--
                eventtrack(qq,1) = (141 + this_soa);
                eventtrack(qq,2) = GetSecs();
                qq = qq + 1;
                % ------------------------------------
            end 
        else
            MoveStim()
            DrawStim(0,trigger_size) %don't want triggers every movement
        end
        
%         MoveStim()
%         DrawStim(0) %don't want triggers every movement
    end


    %%%%%%%%
    %%%%%%%%
    %%%%%%%%

% /////////////////////////////////////////////////////////////////////////    
    %% Probe %%
    Screen('FillRect',w,bgcolor,rect);
    Screen('FillRect',w,Vpixx2Vamp(0),trigger_size);
    Screen('Flip',w);
    WaitSecs(.1);
    
    ShowCursor('Arrow');
    SetMouse(xc,yc)
    
    Screen('FillRect',w,bgcolor,rect);
    DrawFormattedText(w,'Click the patch that rotated:','center',yc-r-g);
    Screen('DrawTextures',w,gaborPatch,[],centeredRects,rotation);
    Screen('FillOval',w,fixationColor,[xc-fixationSize yc-fixationSize xc+fixationSize yc+fixationSize]);
    if angle ~= 0 %turn
        Screen('FillRect',w,Vpixx2Vamp((50 + this_soa)),trigger_size); %(43,45,47,49,50,51,53,55,57)
        Screen('Flip',w);
        % --track timing of events in matlab--
        eventtrack(qq,1) = (50 + this_soa);
        eventtrack(qq,2) = GetSecs();
        qq = qq + 1;
        % ------------------------------------
    elseif angle == 0 %straight
        Screen('FillRect',w,Vpixx2Vamp((150 + this_soa)),trigger_size); %(143,145,147,149,150,151,153,155,157)
        Screen('Flip',w);
        % --track timing of events in matlab--
        eventtrack(qq,1) = (150 + this_soa);
        eventtrack(qq,2) = GetSecs();
        qq = qq + 1;
        % ------------------------------------
    end     
%     Screen('Flip',w);
    
    accuracy = 2;
    startTime = GetSecs;
    clicked = 0;
    while GetSecs-startTime<timeLimit && ~clicked
        [x y buttons] = GetMouse;
        if any(buttons)
            clicked = 1;
            timesUp = 1;
        end
    end

    incorrectRect = centeredRects(:,:);
    correctRect = centeredRects(:,target);
    correctRect = correctRect';
    gabor_press = 0;
  
    if clicked==1&&x>=correctRect(1)&&x<=correctRect(3)&&y>=correctRect(2)&&y<=correctRect(4)
        accuracy = 1;
        Screen('FillRect',w,bgcolor,rect);
        DrawFormattedText(w,'Correct!','center','center');
        RT = GetSecs-startTime;
        if angle ~= 0 %turn
            Screen('FillRect',w,Vpixx2Vamp((61 + this_soa)),trigger_size); %(54,56,58,60,61,62,64,66,68)
            Screen('Flip',w);
            % --track timing of events in matlab--
            eventtrack(qq,1) = (61 + this_soa);
            eventtrack(qq,2) = GetSecs();
            qq = qq + 1;
            % ------------------------------------
        elseif angle == 0 %straight
            Screen('FillRect',w,Vpixx2Vamp((161 + this_soa)),trigger_size); %(154,156,158,160,161,162,164,166,168)
            Screen('Flip',w);
            % --track timing of events in matlab--
            eventtrack(qq,1) = (161 + this_soa);
            eventtrack(qq,2) = GetSecs();
            qq = qq + 1;
            % ------------------------------------
        end     
%         Screen('Flip',w);
    elseif clicked==1
        for i = 1:length(incorrectRect)
            if x>=incorrectRect(1,i)&&x<=incorrectRect(3,i)&&y>=incorrectRect(2,i)&&y<=incorrectRect(4,i)%%%                
                accuracy = 0;
                gabor_press = 1;
                Screen('FillRect',w,bgcolor,rect);
                DrawFormattedText(w,'Incorrect patch','center','center');
                RT = GetSecs-startTime;
                if angle ~= 0 %turn
                    Screen('FillRect',w,Vpixx2Vamp((70 + this_soa)),trigger_size); %(63,65,67,69,70,71,73,75,77)
                    Screen('Flip',w);
                    % --track timing of events in matlab--
                    eventtrack(qq,1) = (70 + this_soa);
                    eventtrack(qq,2) = GetSecs();
                    qq = qq + 1;
                    % ------------------------------------
                elseif angle == 0 %straight
                    Screen('FillRect',w,Vpixx2Vamp((170 + this_soa)),trigger_size); %(163,165,167,169,170,171,173,175,177)
                    Screen('Flip',w);
                    % --track timing of events in matlab--
                    eventtrack(qq,1) = (170 + this_soa);
                    eventtrack(qq,2) = GetSecs();
                    qq = qq + 1;
                    % ------------------------------------
                end
%                 Screen('Flip',w);
                break
            end
        end
        if gabor_press == 0
%             accuracy = -1;
            accuracy = 0;
            Screen('FillRect',w,bgcolor,rect);
            DrawFormattedText(w,'Incorrect patch','center','center'); %%%Please Click on a Gabor
            RT = GetSecs-startTime;
            if angle ~= 0 %turn
                Screen('FillRect',w,Vpixx2Vamp((70 + this_soa)),trigger_size); %(63,65,67,69,70,71,73,75,77)
                Screen('Flip',w);
                % --track timing of events in matlab--
                eventtrack(qq,1) = (70 + this_soa);
                eventtrack(qq,2) = GetSecs();
                qq = qq + 1;
                % ------------------------------------
            elseif angle == 0 %straight
                Screen('FillRect',w,Vpixx2Vamp((170 + this_soa)),trigger_size); %(163,165,167,169,170,171,173,175,177)
                Screen('Flip',w);
                % --track timing of events in matlab--
                eventtrack(qq,1) = (170 + this_soa);
                eventtrack(qq,2) = GetSecs();
                qq = qq + 1;
                % ------------------------------------
            end
%             Screen('Flip',w);
        end
    elseif clicked == 0
        Screen('FillRect',w,bgcolor,rect);
        DrawFormattedText(w,'Please respond more quickly','center','center');
        if angle ~= 0 %turn
            Screen('FillRect',w,Vpixx2Vamp((81 + this_soa)),trigger_size); %(74,76,78,80,81,82,84,86,88)
            Screen('Flip',w);
            % --track timing of events in matlab--
            eventtrack(qq,1) = (81 + this_soa);
            eventtrack(qq,2) = GetSecs();
            qq = qq + 1;
            % ------------------------------------
        elseif angle == 0 %straight
            Screen('FillRect',w,Vpixx2Vamp((181 + this_soa)),trigger_size); %(174,176,178,180,181,182,184,186,188)
            Screen('Flip',w);
            % --track timing of events in matlab--
            eventtrack(qq,1) = (181 + this_soa);
            eventtrack(qq,2) = GetSecs();
            qq = qq + 1;
            % ------------------------------------
        end
%         Screen('Flip',w);
        accuracy = 2;
        RT = timeLimit;
    end
    
    WaitSecs(feedbackPause);
    Screen('FillRect',w,bgcolor,rect);
    Screen('FillRect',w,Vpixx2Vamp(0),trigger_size);
    Screen('flip',w);
    
    %//////////////////////////////////////////////////////////////////////
    if k==0 %end of practice trials
        Screen('FillRect',w,bgcolor);
        DrawFormattedText(w,'You have completed the practice trials\n\nLet the experimenter know you if you have questions.','center','center',[]);
        Screen('FillRect',w,Vpixx2Vamp(0),trigger_size);
        Screen('Flip',w)
        GetClicks(w);
        WaitSecs(0.05);
        
        Screen('FillRect',w,bgcolor);
        DrawFormattedText(w,'When you are ready to start the experiment, click the mouse to continue.','center','center',[]);
        Screen('FillRect',w,Vpixx2Vamp(0),trigger_size);
        Screen('Flip',w)
        GetClicks(w);
        WaitSecs(0.05);
        
    elseif k>0 %save data of experimental trials
        out_soa = [out_soa this_soa];
        out_direction = [out_direction direction]; 
        out_angle = [out_angle angle];  %270 left, 90 Right, 0 straight
        out_accuracy = [out_accuracy accuracy];
        out_RT = [out_RT RT];
        if accuracy == 0
            out_incorrect_gabor(k) = i; %% adds value i to the incorrect gabor array at trial k
        else
            out_incorrect_gabor(k) = NaN; %so dim matches other out_ variables
        end
    end
    %//////////////////////////////////////////////////////////////////////
    %% Break %%
    % k>0 so don't break during practice or at end of practice &
    % k~=totalTrials so break screen does not show up at end of experiment
    if k>0 && k~=totalTrials && mod(k,breakEvery)==0 %whenever k trials is divisible w/out remainder by breakEvery
        Screen('FillRect',w,bgcolor);
        DrawFormattedText(w,'Feel free to take a break at this time\n\nWhen you are ready, click the mouse to continue.','center','center',[]);
        Screen('FillRect',w,Vpixx2Vamp(2),trigger_size);
        Screen('Flip',w)
        % --track timing of events in matlab--
        eventtrack(qq,1) = 2;
        eventtrack(qq,2) = GetSecs();
        qq = qq + 1;
        % ------------------------------------
        GetClicks(w);
        WaitSecs(1.25);
    end
    %//////////////////////////////////////////////////////////////////////

    Screen('Close');  
end
% /////////////////////////////////////////////////////////////////////////
% -------------------------------------------------------------------------
% ------------------------------- END TASK -------------------------------- 
% -------------------------------------------------------------------------
% /////////////////////////////////////////////////////////////////////////

Screen('FillRect',w,bgcolor);
DrawFormattedText(w,'You are done!!\n\nPress any Key and then call the experimenter.','center','center',[]);
Screen('FillRect',w,Vpixx2Vamp(99),trigger_size);
eyetrack_end = Screen('Flip',w);
KbWait;
eyetrack_end2 = GetSecs; 


fclose('all');
Screen('CloseAll');
ShowCursor;
sca;

%clearing unneeded variables from workspace before saving
clear i accuracy RT x y timesUp clicked angle this_soa gabor_press

% /////////////////////////////////////////////////////////////////////////
turn_trials = out_angle ~= 0;
control_trials = out_angle == 0;
responded = out_accuracy ~= 2; %select only trials with a response

isoa = 0;
for this_soa = soas
    isoa = isoa + 1;
    temp_turn = out_accuracy(out_soa == this_soa & responded & turn_trials);
    turn_out(isoa) = sum(temp_turn)/length(temp_turn);
    temp_cont = out_accuracy(out_soa == this_soa & responded & control_trials);
    control_out(isoa) = sum(temp_cont)/length(temp_cont);
end

% /////////////////////////////////////////////////////////////////////////
%% Save data
save(Filename)
% /////////////////////////////////////////////////////////////////////////
%% Plot results
figure; 
plot(soas,turn_out,'r',soas,control_out,'b'); 
legend({'Flexion','Control'});
xlim([min(soas) max(soas)]); xticks(min(soas):1:max(soas))
xlabel('Gabor Change First < ------ SOA (frames) ------ > Gabor Change After')
ylabel('Detection Proportion')
ylim([.01 1.05])

% Save figure
savefig([Info.number '--' Info.date '_plot'])

% /////////////////////////////////////////////////////////////////////////

function MoveStim()
    global arrayRects direction movementIncrement
    arrayRects = arrayRects + ((-1)^direction)*movementIncrement;
end

function DrawStim(num,trigger_size) 
    global w bgcolor rect gaborPatch arrayRects rotation centerOfArray fixationSize fixationColor fixationRect
    Screen('FillRect',w,bgcolor,rect);  
    Screen('DrawTextures',w,gaborPatch,[],arrayRects,rotation); 
    centerOfArray = [(min(arrayRects(1,:))+max(arrayRects(3,:)))/2 (min(arrayRects(2,:))+max(arrayRects(4,:)))/2];
    fixationRect = round([centerOfArray(1)-fixationSize centerOfArray(2)-fixationSize centerOfArray(1)+fixationSize centerOfArray(2)+fixationSize]);
    Screen('FillOval',w,fixationColor,fixationRect); 
    Screen('FillRect',w,Vpixx2Vamp(num),trigger_size);
    Screen('Flip',w);
end








