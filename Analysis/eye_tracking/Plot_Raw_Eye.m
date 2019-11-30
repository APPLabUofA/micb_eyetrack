%% Created by Eden Redman 2019

% created around participant 016 in the 2019 micb study at the Attention
% Perception and Performance lab at the University of Alberta
% specific server location
%     M:\Data\micb_eyetrack
%     |---beh
%     |   |---016--20190722T123854_data_noSOA.mat
%     |---EEG
%     |   |---016_noSOA.eeg
%     |   |---016_noSOA.vhdr
%     |   |---016_noSOA.vmrk
%     |---eye
%         |---016.csv

%% Notes for Eden

% go back and add in an interpolated time index of each given eye point, so we can later on
% look at time locked eye movements with ensured specificity 
    % otherwise on trials that are above the required threshold, yet still have some 
    % missing eye points we get time shifted eye points (they look they are
    % moving their eyes faster than they actually were)

% need to change the buffer to after thresholding, so as to not
% affect actual:expected eye point ratio thresholding 

%% Embedded Vamp (EEG) triggers

% Start eye tracker:      90
% End eye tracker:        99
% Break:                  2
% 
% -- Turn Trials --
% Trial start (fixation): 10
% Stimulus change: 
%   Movement & Gabor:     21
%   Movement:             30
%   Gabor:                41
% Response screen:        50  
% Response:
%   Correct:              61 
%   Incorrect:            70
%   Timed out:            81
%
% -- Straight Trials --
% Trial start (fixation): 110 
% Stimulus change: 
%   Movement & Gabor:     121 
%   Movement:             130
%   Gabor:                141 
% Response screen:        150  
% Response:
%   Correct:              161 
%   Incorrect:            170
%   Timed out:            181 

%% Trial Type Groupings for Analysis
%%%%%  Experimental
    % 1 - all turn
    % 2 - leftward turn down
    % 3 - leftward turn up
    % 4 - rightward turn down
    % 5 - rightward turn up
%%%%%  Control
    % 6 - all straight
    % 7 - rightward straight
    % 8 - leftward straight

%% Set Variables
exp.participants = {'016'};
exp.name = '_noSOA';
pract_num = 22; % number of practice trials
exp_num = 288; % number of experimental trials;
eye_times = 2; % number of seconds from the start of each event we are looking at
eye_res = 90; % Hz of eye tracker
eye_points = eye_times*eye_res; % number of expected eye tracking data points per epoch
eye_thresh = .8; % threshold ratio of required eye points to expected eye points

%% Load in Eye Data
eye_struct = csvread(strcat('M:\Experiments\micb_eyetrack\Data\eye\', exp.participants{1}, '.csv'),1,0);
start_time = eye_struct(1,1);
eye_struct(:,1) = eye_struct(:,1) - start_time;
figure;
scatter(eye_struct(:,2),eye_struct(:,3),10)

%% Load in EEG Data
% exp.eeg_pathname = 'M:\Experiments\micb_eyetrack\Data\EEG';
exp.eeg_pathname = 'M:\Data\micb_eyetrack\EEG';
exp.electrode_locs = 'EOG_18_electrode_micb.ced';

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG=pop_loadbv(exp.eeg_pathname, [exp.participants{1} exp.name '.vhdr']);
EEG=pop_chanedit(EEG, 'load',{exp.electrode_locs 'filetype' 'autodetect'});

%% Load in Behavioural Data 
path = dir(strcat('M:\Data\micb_eyetrack\beh\',strcat(exp.participants{1},'*.*')));
load([strcat('M:\Data\micb_eyetrack\beh\',path.name)]);

%% Alignment of All Data Streams (Beh, EEG, eye) into one Structure
% Align the eye tracking data to the EEG by adding the latency of the Start
% eye tracker event 'S199' to every eye tracker point
    if EEG.event(2).type ~= "S199"
        error('ERROR - starting trigger not present at expected index')
    end
    EEG_offset = EEG.event(2).latency;
    eye_struct(:,1) = round(eye_struct(:,1) + EEG_offset); % rounded to the nearest integer (millisecond)

    % Cycle through the eye events and pull out trial starts
    % threshold and keep eye event trains that meet the required ratio of expected trials - number of expected data points in the epoch

    allevents = length(EEG.event);
    EEG.eye_events = []; % structure for eye events
    EEG.del_events = [];
    temp_eye_event_count = 1; % all type-matching eye event trains
    eye_event_count = 1; % all temp event trains that meet threshold requirements
    del_event_count = 1;

    for i_event = 1:allevents
        if EEG.event(i_event).type == "S 10" || EEG.event(i_event).type == "S110"
            if EEG.event(i_event).type == "S 10"
                EEG.temp_eye_events(temp_eye_event_count).exp = 1;
            else
                EEG.temp_eye_events(temp_eye_event_count).exp = 0;
            end
            latency = EEG.event(i_event).latency;
            [num,index] = min(abs(eye_struct(:,1)-latency));
            EEG.temp_eye_events(temp_eye_event_count).latency = latency;
            EEG.temp_eye_events(temp_eye_event_count).type = EEG.event(i_event).type;
            [num2,index_stop] = min(abs(eye_struct(:,1)-(latency+eye_times*1000)));
            EEG.temp_eye_events(temp_eye_event_count).coordinates = eye_struct(index:index_stop-1,2:3);
            eye_length = length(EEG.temp_eye_events(temp_eye_event_count).coordinates);
            if eye_length < eye_points
                EEG.temp_eye_events(temp_eye_event_count).coordinates(eye_length:180,1:2) = 0;
            end
            EEG.temp_eye_events(temp_eye_event_count).jitter = [num,num2];
            % actualize threshold and exclude the practice trials
            if temp_eye_event_count > pract_num
                temp_ratio = length(EEG.temp_eye_events(temp_eye_event_count).coordinates)/eye_points;
                if temp_ratio < eye_thresh
                    EEG.del_events(1,del_event_count) = eye_event_count;
                    EEG.del_events(2,del_event_count) = temp_ratio;
                    del_event_count = del_event_count + 1;
                end
                EEG.eye_events(eye_event_count).latency = EEG.temp_eye_events(temp_eye_event_count).latency;
                EEG.eye_events(eye_event_count).type = EEG.temp_eye_events(temp_eye_event_count).type;
                EEG.eye_events(eye_event_count).coordinates = EEG.temp_eye_events(temp_eye_event_count).coordinates;
                EEG.eye_events(eye_event_count).jitter = EEG.temp_eye_events(temp_eye_event_count).jitter;
                EEG.eye_events(eye_event_count).exp = EEG.temp_eye_events(temp_eye_event_count).exp;
                eye_event_count = eye_event_count + 1;
            end
            temp_eye_event_count = temp_eye_event_count + 1;
        end
    end 

    %% add in other trial info from beh file
    for i_event = 1:exp_num
        EEG.eye_events(i_event).changed_gabor = trialList(i_event,1);
        EEG.eye_events(i_event).change_dir = trialList(i_event,2);
        EEG.eye_events(i_event).direction = trialList(i_event,3);
        EEG.eye_events(i_event).accuracy = out_accuracy(i_event);
    end

    %% take out subpar eye events
    for i_event = 0:exp_num
        if ismember(exp_num-i_event,EEG.del_events) 
            EEG.eye_events(exp_num-i_event) = []; % moving from the end to  beginning so that taking them out doesn't mess the index of the others to be removed
        end
    end
    eye_event_count = exp_num - del_event_count;
    print("removing subthreshold eye events")
    
    %% Center Align Plots on Averages (X and Y taken independently)
    
    % find middle by the average horizontal and average vertical values of ALL
    % within threshold trials
    % comparing across participants may require aligning to middle as opposed to
    % absolute screen dimensions
    
    coord_X = [];
    coord_Y = [];
    
    for eye_event = 1:length(EEG.eye_events)
        coord_X = cat(1,coord_X,EEG.eye_events(eye_event).coordinates(:,1));
        coord_Y = cat(1,coord_Y,EEG.eye_events(eye_event).coordinates(:,2));
    end
    
    buffer = 500;
    center_X = round(mean(coord_X));
    X_top = center_X + buffer;
    X_bottom = center_X - buffer;
    center_Y = round(mean(coord_Y));
    Y_left = center_Y - buffer;
    Y_right = center_Y + buffer;
    
    %% Single Point plot exclusions based off of center_X and center_Y
    exclu_x = [center_X - round(3*center_X/5), center_X + round(3*center_X/5)];
    exclu_y = [center_Y - round(3*center_Y/5), center_Y + round(3*center_Y/5)];


%% Linear plot of all Control Events
figure;
for i_event = 1:eye_event_count
    if EEG.eye_events(i_event).exp == 0 && EEG.eye_events(i_event).direction == 0 ||EEG.eye_events(i_event).exp == 0 && EEG.eye_events(i_event).direction == 1
        x = EEG.eye_events(i_event).coordinates(:,1);
        y = EEG.eye_events(i_event).coordinates(:,2);
        for eye_point = 0:eye_points-1  
            if x(eye_points-eye_pointe)<exclu_x(1) || x(eye_points-eye_point)>exclu_x(2) || y(eye_points-eye_point)<exclu_y(1) || y(eye_points-eye_point)>exclu_y(2)                
                x(eye_points-eye_point) = [];
                y(eye_points-eye_point) = [];
            end
        end
        line(x,y)
    end
end
xlabel('X')
ylabel('Y')
title('Linear plot of all Control Events')
xlim([X_bottom,X_top])
ylim([Y_left,Y_right])

%% Linear plot of all Experimental Events
figure;
for i_event = 1:eye_event_count
    if EEG.eye_events(i_event).exp == 1 && EEG.eye_events(i_event).direction == 0 || EEG.eye_events(i_event).exp == 1 && EEG.eye_events(i_event).direction == 1
        x = EEG.eye_events(i_event).coordinates(:,1);
        y = EEG.eye_events(i_event).coordinates(:,2);
        for eye_point = 0:eye_points-1  
            if x(eye_points-eye_point)<exclu_x(1) || x(eye_points-eye_point)>exclu_x(2) || y(eye_points-eye_point)<exclu_y(1) || y(eye_points-eye_point)>exclu_y(2)                
                x(eye_points-eye_point) = [];
                y(eye_points-eye_point) = [];
            end
        end
        line(x,y)
    end
end
xlabel('X')
ylabel('Y')
title('Linear plot of all Experimental Events')
xlim([X_bottom,X_top])
ylim([Y_left,Y_right])

%% Plot Linear Regression of Linear (Control) Events
figure;
for i_event = 1:eye_event_count
    if EEG.eye_events(i_event).exp == 0 && EEG.eye_events(i_event).direction == 0
        c = polyfit(EEG.eye_events(i_event).coordinates(:,1),EEG.eye_events(i_event).coordinates(:,2),1); % Fit line to data using polyfit
%             disp(['Equation is y = ' num2str(c(1)) '*x + ' num2str(c(2))]) % Display evaluated equation y = m*x + b
        y_est = polyval(c,EEG.eye_events(i_event).coordinates(:,1)); % Evaluate fit equation using polyval
        hold on % Add trend line to plot
        plot(EEG.eye_events(i_event).coordinates(:,1),y_est,'LineWidth',2) % 'r--'
%         hold off
        % plot with index denoted by colour to be able to distinguish
        % directionality on flat trials
        % ViewPixx parameters 2160 x 1200
%         xlim([0,2160])
%         ylim([0,1200])
        xlabel('X')
        ylabel('Y')
        title('Control Trials - Linear Regression')
    end
end
%% Plot polynomial Regression of Turn (Experimental) Events
figure;
for i_event = 1:eye_event_count
    if EEG.eye_events(i_event).exp == 1 && EEG.eye_events(i_event).direction == 1 && EEG.eye_events(eye_event).change_dir == 90
        c = polyfit(EEG.eye_events(i_event).coordinates(:,1),EEG.eye_events(i_event).coordinates(:,2),2); % Fit line to data using polyfit
%             disp(['Equation is y = ' num2str(c(1)) '*x + ' num2str(c(2))]) % Display evaluated equation y = m*x + b
        y_est = polyval(c,EEG.eye_events(i_event).coordinates(:,1)); % Evaluate fit equation using polyval
        hold on % Add trend line to plot
        plot(EEG.eye_events(i_event).coordinates(:,1),y_est,'LineWidth',2) % 'r--'
%         if ismember(0,EEG.eye_events(i_event).coordinates(:,1)) == 0
%             plot(EEG.eye_events(i_event).coordinates(:,1),y_est,'LineWidth',2) % 'r--'
%         end
        xlabel('X')
        ylabel('Y')
        title('Experimental Trials - Parabolic Regression')
    end
end

%% Plot Single Events (Scatter)
figure;
plot_num = 9; % how many to plot - use 'length(EEG.eye_events)' to plot all
widthHeight = ceil(sqrt(plot_num));
x = linspace(0,1,eye_times);
for i_event = 1:plot_num
    subplot(widthHeight,widthHeight,i_event); 
        scatter(EEG.eye_events(i_event).coordinates(:,1),EEG.eye_events(i_event).coordinates(:,2),10,[linspace(0,1,180)])
        % plot with index denoted by colour to be able to distinguish
        % directionality on flat trials
        % ViewPixx parameters 2160 x 1200
        xlim([0,2160])
        ylim([0,1200])
        xlabel('X')
        ylabel('Y')
        title(strcat('Eye Event Num', num2str(i_event)))
        labels = {'Beginning','Middle','End'};
%         lcolorbar(labels,'fontweight','bold');
end

%% Plot Single Events (Line)
figure;
plot_num = 9; % how many to plot - use 'length(EEG.eye_events)' to plot all
widthHeight = ceil(sqrt(plot_num));
x = linspace(0,1,eye_times);
for i_event = 1:plot_num
    subplot(widthHeight,widthHeight,i_event); 
        line(EEG.eye_events(i_event).coordinates(:,1),EEG.eye_events(i_event).coordinates(:,2))
        % plot with index denoted by colour to be able to distinguish
        % directionality on flat trials
        % ViewPixx parameters 2160 x 1200
        xlim([0,2160])
        ylim([0,1200])
        xlabel('X')
        ylabel('Y')
        title(strcat('Eye Event Num', num2str(i_event)))
        labels = {'Beginning','Middle','End'};
%         lcolorbar(labels,'fontweight','bold');
end

%% Heat Maps

    %% Combine all Coordinates of a all 8 trial types
    figure;
    X = [coord_X, coord_Y];
    hist3(X,'Ctrs',{X_bottom:25:X_top Y_left:25:Y_right},'CDataMode','auto','FaceColor','interp') %1600 960 'Nbins',[100 100],
    xlabel('X')
    ylabel('Y')
    colorbar
    view(2)

    %% Histogram and Intensity Histogram PLots
    figure;
    hist3([coord_X, coord_Y],{X_bottom:25:X_top Y_left:25:Y_right})
    hold on;
    N =  hist3([coord_X, coord_Y]);

    N_pcolor = N';
    N_pcolor(size(N_pcolor,1)+1,size(N_pcolor,2)+1) = 0;
    xl = linspace(min(coord_X),max(coord_X),size(N_pcolor,2)); % Columns of N_pcolor
    yl = linspace(min(coord_Y),max(coord_Y),size(N_pcolor,1)); % Rows of N_pcolor

    h = pcolor(xl,yl,N_pcolor);
    colormap('hot') % Change color scheme 
    colorbar % Display colorbar
    h.ZData = -max(N_pcolor(:))*ones(size(N_pcolor));
    ax = gca;
    ax.ZTick(ax.ZTick < 0) = [];
    title('Eye Fixation Location Histogram and Intensity Map');
    
    %% Linear regression 
    
    % Control 
    scatter(coord_X,coord_Y)
    plot(coord_X,coord_Y,'LineWidth',2)
    
    % Fit line to data using polyfit
    c = polyfit(x,y,1);
    % Display evaluated equation y = m*x + b
    disp(['Equation is y = ' num2str(c(1)) '*x + ' num2str(c(2))])
    % Evaluate fit equation using polyval
    y_est = polyval(c,x);
    % Add trend line to plot
    hold on
    plot(x,y_est,'r--','LineWidth',2)
    hold off

    % Experimental
    
%% Derives averages at each time point for each of the following groupings of data
    
    % 1 - all turn (exp) (derived using midlines as absolute 0 references)
    % 2 - leftward turn down
    % 3 - leftward turn up
    % 4 - rightward turn down
    % 5 - rightward turn up
    % 6 - all straight (non-exp) (derived using midlines as absolute 0 references)
    % 7 - rightward straight
    % 8 - leftward straight
    
    % can decrease the size of the following script by ~5 by the following
        % 1. namespace the booleans for differentiating trial types in a containers.Map
        % 2. throwing time_X_x(s) & time_Y_y(s) into a single EEG structure - done
        % 3. container.Maps namespacing for EEG.eye_avg structs  
        %% 1 - all turn (exp) 
        temp = [];
        EEG.cat_eye.time_1_x = [];
        EEG.cat_eye.time_1_y = [];
        turn_count = 1;
        for eye_point = 1:eye_points % cycles throuh each of the 180 eye points
            for eye_event = 1:eye_event_count % for each eye point, find matching eye events
                if EEG.eye_events(eye_event).exp == 1 % for each match - add x and y to temp list in position count
                    temp(turn_count,1) = EEG.eye_events(eye_event).coordinates(eye_point,1);
                    temp(turn_count,2) = EEG.eye_events(eye_event).coordinates(eye_point,2);
                    EEG.cat_eye.time_1_x = cat(1,EEG.cat_eye.time_1_x,EEG.eye_events(eye_event).coordinates(eye_point,1));
                    EEG.cat_eye.time_1_y = cat(1,EEG.cat_eye.time_1_y,EEG.eye_events(eye_event).coordinates(eye_point,2));
                    turn_count = turn_count + 1;
                end
            end
            EEG.eye_avg(eye_point).turn_sum = [mean(temp(:,1)),mean(temp(:,2))];
            EEG.eye_avg(eye_point).turn_std = [std(temp(:,1)),std(temp(:,2))];
            temp = [];
            turn_count = 1;
        end
        
        figure;
        X = [EEG.cat_eye.time_1_x, EEG.cat_eye.time_1_y];
        hist3(X,'Ctrs',{X_bottom:25:X_top Y_left:25:Y_right},'CDataMode','auto','FaceColor','interp') %1600 960 'Nbins',[100 100],
        xlabel('X')
        ylabel('Y')
        colorbar
        view(2)

        %% 2 - leftward turn down
        temp = [];
        EEG.cat_eye.time_2_x = [];
        EEG.cat_eye.time_2_y = [];
        turn_count = 1;
        for eye_point = 1:eye_points
            for eye_event = 1:eye_event_count
                if EEG.eye_events(eye_event).exp == 1 && EEG.eye_events(eye_event).direction == 1 && EEG.eye_events(eye_event).change_dir == 90
                    temp(turn_count,1) = EEG.eye_events(eye_event).coordinates(eye_point,1);
                    temp(turn_count,2) = EEG.eye_events(eye_event).coordinates(eye_point,2);
                    EEG.cat_eye.time_2_x = cat(1,EEG.cat_eye.time_2_x,EEG.eye_events(eye_event).coordinates(eye_point,1));
                    EEG.cat_eye.time_2_y = cat(1,EEG.cat_eye.time_2_y,EEG.eye_events(eye_event).coordinates(eye_point,2));
                end
            end
            EEG.eye_avg(eye_point).right_up_sum = [mean(temp(:,1)),mean(temp(:,2))];
            EEG.eye_avg(eye_point).right_up_std = [std(temp(:,1)),std(temp(:,2))];

            temp = [];
        end
        
        figure;
        X = [EEG.cat_eye.time_2_x, EEG.cat_eye.time_2_y];
        hist3(X,'Ctrs',{X_bottom:25:X_top Y_left:25:Y_right},'CDataMode','auto','FaceColor','interp') %1600 960 'Nbins',[100 100],
        xlabel('X')
        ylabel('Y')
        colorbar
        view(2)
        
        %% 3 - leftward turn up
        temp = [];
        EEG.cat_eye.time_3_x = [];
        EEG.cat_eye.time_3_y = [];
        turn_count = 1;
        for eye_point = 1:eye_points
            for eye_event = 1:eye_event_count
                if EEG.eye_events(eye_event).exp == 1 && EEG.eye_events(eye_event).direction == 1 && EEG.eye_events(eye_event).change_dir == 270
                    temp(turn_count,1) = EEG.eye_events(eye_event).coordinates(eye_point,1);
                    temp(turn_count,2) = EEG.eye_events(eye_event).coordinates(eye_point,2);
                    EEG.cat_eye.time_3_x = cat(1,EEG.cat_eye.time_3_x,EEG.eye_events(eye_event).coordinates(eye_point,1));
                    EEG.cat_eye.time_3_y = cat(1,EEG.cat_eye.time_3_y,EEG.eye_events(eye_event).coordinates(eye_point,2));
                end
            end
            EEG.eye_avg(eye_point).right_down_sum = [mean(temp(:,1)),mean(temp(:,2))];
            EEG.eye_avg(eye_point).right_down_std = [std(temp(:,1)),std(temp(:,2))];
            temp = [];
        end
        
        figure;
        X = [EEG.cat_eye.time_3_x, EEG.cat_eye.time_3_y];
        hist3(X,'Ctrs',{X_bottom:25:X_top Y_left:25:Y_right},'CDataMode','auto','FaceColor','interp') %1600 960 'Nbins',[100 100],
        xlabel('X')
        ylabel('Y')
        colorbar
        view(2)
        
        %% 4 - rightward turn down
        temp = [];
        EEG.cat_eye.time_4_x = [];
        EEG.cat_eye.time_4_y = [];
        turn_count = 1;
        for eye_point = 1:eye_points
            for eye_event = 1:eye_event_count
                if EEG.eye_events(eye_event).exp == 1 && EEG.eye_events(eye_event).direction == 0 && EEG.eye_events(eye_event).change_dir == 270
                    temp(turn_count,1) = EEG.eye_events(eye_event).coordinates(eye_point,1);
                    temp(turn_count,2) = EEG.eye_events(eye_event).coordinates(eye_point,2);
                    EEG.cat_eye.time_4_x = cat(1,EEG.cat_eye.time_4_x,EEG.eye_events(eye_event).coordinates(eye_point,1));
                    EEG.cat_eye.time_4_y = cat(1,EEG.cat_eye.time_4_y,EEG.eye_events(eye_event).coordinates(eye_point,2));
                end
            end
            EEG.eye_avg(eye_point).left_up_sum = [eye_point,mean(temp(:,1)),mean(temp(:,2))];
            EEG.eye_avg(eye_point).left_up_std = [std(temp(:,1)),std(temp(:,2))];
            temp = [];
        end
        
        figure;
        X = [EEG.cat_eye.time_4_x, EEG.cat_eye.time_4_y];
        hist3(X,'Ctrs',{X_bottom:25:X_top Y_left:25:Y_right},'CDataMode','auto','FaceColor','interp') %1600 960 'Nbins',[100 100],
        xlabel('X')
        ylabel('Y')
        colorbar
        view(2)
        
        
        %% 5 - rightward turn up
        temp = [];
        EEG.cat_eye.time_5_x = [];
        EEG.cat_eye.time_5_y = [];
        turn_count = 1;
        for eye_point = 1:eye_points
            for eye_event = 1:eye_event_count
                if EEG.eye_events(eye_event).exp == 1 && EEG.eye_events(eye_event).direction == 0 && EEG.eye_events(eye_event).change_dir == 90
                    temp(turn_count,1) = EEG.eye_events(eye_event).coordinates(eye_point,1);
                    temp(turn_count,2) = EEG.eye_events(eye_event).coordinates(eye_point,2);
                    EEG.cat_eye.time_5_x = cat(1,EEG.cat_eye.time_5_x,EEG.eye_events(eye_event).coordinates(eye_point,1));
                    EEG.cat_eye.time_5_y = cat(1,EEG.cat_eye.time_5_y,EEG.eye_events(eye_event).coordinates(eye_point,2));
                end
            end
            EEG.eye_avg(eye_point).left_down_sum = [eye_point,mean(temp(:,1)),mean(temp(:,2))];
            EEG.eye_avg(eye_point).left_down_std = [std(temp(:,1)),std(temp(:,2))];
            temp = [];
        end

        figure;
        X = [EEG.cat_eye.time_5_x, EEG.cat_eye.time_5_y];
        hist3(X,'Ctrs',{X_bottom:25:X_top Y_left:25:Y_right},'CDataMode','auto','FaceColor','interp') %1600 960 'Nbins',[100 100],
        xlabel('X')
        ylabel('Y')
        colorbar
        view(2)
        

        %% 6 - all straight (non-exp) (derived using midlines as absolute 0 references)
        temp = [];
        EEG.cat_eye.time_6_x = [];
        EEG.cat_eye.time_6_y = [];
        turn_count = 1;
        for eye_point = 1:eye_points
            for eye_event = 1:eye_event_count
                if EEG.eye_events(eye_event).exp == 0
                    temp(turn_count,1) = EEG.eye_events(eye_event).coordinates(eye_point,1);
                    temp(turn_count,2) = EEG.eye_events(eye_event).coordinates(eye_point,2);
                    EEG.cat_eye.time_6_x = cat(1,EEG.cat_eye.time_6_x,EEG.eye_events(eye_event).coordinates(eye_point,1));
                    EEG.cat_eye.time_6_y = cat(1,EEG.cat_eye.time_6_y,EEG.eye_events(eye_event).coordinates(eye_point,2));
                end
            end
            EEG.eye_avg(eye_point).straight_sum = [eye_point,mean(temp(:,1)),mean(temp(:,2))];
            EEG.eye_avg(eye_point).straight_std = [std(temp(:,1)),std(temp(:,2))];
            temp = [];
        end
        
        figure;
        X = [EEG.cat_eye.time_6_x, EEG.cat_eye.time_6_y];
        hist3(X,'Ctrs',{X_bottom:25:X_top Y_left:25:Y_right},'CDataMode','auto','FaceColor','interp') %1600 960 'Nbins',[100 100],
        xlabel('X')
        ylabel('Y')
        colorbar
        view(2)
        
        %% 7 - rightward straight
        temp = [];
        EEG.cat_eye.time_7_x = [];
        EEG.cat_eye.time_7_y = [];
        turn_count = 1;
        for eye_point = 1:eye_points
            for eye_event = 1:eye_event_count
                if EEG.eye_events(eye_event).exp == 0 && EEG.eye_events(eye_event).direction == 0 
                    temp(turn_count,1) = EEG.eye_events(eye_event).coordinates(eye_point,1);
                    temp(turn_count,2) = EEG.eye_events(eye_event).coordinates(eye_point,2);
                    EEG.cat_eye.time_7_x = cat(1,EEG.cat_eye.time_7_x,EEG.eye_events(eye_event).coordinates(eye_point,1));
                    EEG.cat_eye.time_7_y = cat(1,EEG.cat_eye.time_7_y,EEG.eye_events(eye_event).coordinates(eye_point,2));
                end
            end
            EEG.eye_avg(eye_point).right_str_sum = [eye_point,mean(temp(:,1)),mean(temp(:,2))];
            EEG.eye_avg(eye_point).right_str_std = [std(temp(:,1)),std(temp(:,2))];
            temp = [];
        end
        
        figure;
        X = [EEG.cat_eye.time_7_x, EEG.cat_eye.time_7_y];
        hist3(X,'Ctrs',{X_bottom:25:X_top Y_left:25:Y_right},'CDataMode','auto','FaceColor','interp') %1600 960 'Nbins',[100 100],
        xlabel('X')
        ylabel('Y')
        colorbar
        view(2)
        
        %% 8 - leftward straight
        temp = [];
        EEG.cat_eye.time_8_x = [];
        EEG.cat_eye.time_8_y = [];        
        turn_count = 1;
        figure;
        hold on;
        for eye_point = 1:eye_points
            for eye_event = 1:eye_event_count
                if EEG.eye_events(eye_event).exp == 0 && EEG.eye_events(eye_event).direction == 1
                    temp(turn_count,1) = EEG.eye_events(eye_event).coordinates(eye_point,1);
                    temp(turn_count,2) = EEG.eye_events(eye_event).coordinates(eye_point,2);
                    EEG.cat_eye.time_8_x = cat(1,EEG.cat_eye.time_8_x,EEG.eye_events(eye_event).coordinates(eye_point,1));
                    EEG.cat_eye.time_8_y = cat(1,EEG.cat_eye.time_8_y,EEG.eye_events(eye_event).coordinates(eye_point,2));
                    turn_count = turn_count + 1;
                end
            end
            EEG.eye_avg(eye_point).left_str_sum = [eye_point,mean(temp(:,1)),mean(temp(:,2))];
            EEG.eye_avg(eye_point).left_str_std = [std(temp(:,1)),std(temp(:,2))];
            temp = [];
            turn_count = 1;
        end
        hold off;
        
        figure;
        X = [EEG.cat_eye.time_8_x, EEG.cat_eye.time_8_y];
        hist3(X,'Ctrs',{X_bottom:25:X_top Y_left:25:Y_right},'CDataMode','auto','FaceColor','interp') %1600 960 'Nbins',[100 100],
        xlabel('X')
        ylabel('Y')
        colorbar
        view(2)
        