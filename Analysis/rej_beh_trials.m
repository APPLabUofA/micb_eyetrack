function [out_soa,out_respond,out_angle,accuracy,direction,incor_gabor,out_RT,turn_trials] =...
     rej_beh_trials(exp,ALLEEG)
% Must load data using load_EEGdata_micb.m for function to work.
% ALLEEG structure should contain all the subjects' data.
% Returns behavioral information on each trial with trials rejected during
% the EEG pre-processing pipeline removed. 

% -------------------------------------------------------------------------
% /////////////////////////////////////////////////////////////////////////
% -------------------------------------------------------------------------
%% Remove rejected trials
% Get BEH data for trials excluding trials that were rejected in the EEG
% preprocessing of the epochs
out_soa = cell(length(exp.participants),1); %pre-allocate
out_respond = cell(length(exp.participants),1); %pre-allocate
out_angle = cell(length(exp.participants),1); %pre-allocate
accuracy = cell(length(exp.participants),1); %pre-allocate
direction = cell(length(exp.participants),1); %pre-allocate
incor_gabor = cell(length(exp.participants),1); %pre-allocate
out_RT = cell(length(exp.participants),1); %pre-allocate
turn_trials = cell(length(exp.participants),1); %pre-allocate
for i_part = 1:length(exp.participants)
    [n,m] = size(ALLEEG(i_part).rejtrial);
    % Get list of rejected trials
    pip = 1;
    for ni = 1:n %for when there are more than 1 column
        for mi = 1:m
            if ~isempty(ALLEEG(i_part).rejtrial(ni,mi).ids)
                rejlist{pip} = ALLEEG(i_part).rejtrial(ni,mi).ids;
                pip = 1 + pip;
            end
        end
        clear mi
    end
    if pip > 1 %if trials were rejected
        out_soa_temp = ALLEEG(i_part).beh.out_soa; %start with all trials
        out_responded_temp = ALLEEG(i_part).beh.responded; %start with all trials
        out_angle_temp = ALLEEG(i_part).beh.out_angle; %start with all trials
        out_accuracy_temp = ALLEEG(i_part).beh.accuracy; %start with all trials
        out_direction_temp = ALLEEG(i_part).beh.direction; %start with all trials
        out_incor_gabor_temp = ALLEEG(i_part).beh.incor_gabor; %start with all trials
        out_RT_temp = ALLEEG(i_part).beh.out_RT; %start with all trials
        out_turn_trials_temp = ALLEEG(i_part).beh.turn_trials; %start with all trials
        % each set of rejected trials needs to be removed in order
        % sequentially
        for mi = 1:length(rejlist)
            tmplist = [rejlist{mi}];
            out_soa_temp(tmplist) = []; %removes the trials
            out_responded_temp(tmplist) = []; %removes the trials
            out_angle_temp(tmplist) = []; %removes the trials
            out_accuracy_temp(tmplist) = []; %removes the trials
            out_direction_temp(tmplist) = []; %removes the trials
            out_incor_gabor_temp(tmplist) = []; %removes the trials
            out_RT_temp(tmplist) = []; %removes the trials
            out_turn_trials_temp(tmplist) = []; %removes the trials
            clear tmplist
        end
        clear mi
    elseif pip == 1 %if no trials were rejected, rejlist variable not created
        out_soa_temp = ALLEEG(i_part).beh.out_soa;
        out_responded_temp = ALLEEG(i_part).beh.responded;
        out_angle_temp = ALLEEG(i_part).beh.out_angle;
        out_accuracy_temp = ALLEEG(i_part).beh.accuracy;
        out_direction_temp = ALLEEG(i_part).beh.direction;
        out_incor_gabor_temp = ALLEEG(i_part).beh.incor_gabor;
        out_RT_temp = ALLEEG(i_part).beh.out_RT;
        out_turn_trials_temp = ALLEEG(i_part).beh.turn_trials;
    end
    % create variable with selected BEH 
    out_soa{i_part} = out_soa_temp;
    out_respond{i_part} = out_responded_temp;
    out_angle{i_part} = out_angle_temp;
    accuracy{i_part} = out_accuracy_temp;
    direction{i_part} = out_direction_temp;
    incor_gabor{i_part} = out_incor_gabor_temp;
    out_RT{i_part} = out_RT_temp;
    turn_trials{i_part} = out_turn_trials_temp;
    
    clear rejlist n m pip ni
    % clears variables that end/begin with...
    clear -regexp \<sgnrank_ _temp\>

end
clear i_part

% -------------------------------------------------------------------------
% /////////////////////////////////////////////////////////////////////////
% -------------------------------------------------------------------------