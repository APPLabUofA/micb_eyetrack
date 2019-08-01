function [out_soa,responded,out_angle,accuracy,direction,incorrect_gabor,out_RT,turn_trials,eventtrack] =...
    getBEHdata_micb(part_name)


%Find output filename
Filename = dir(['M:\Data\micb_eyetrack\beh\' part_name '*']);

%% Save data
load(['M:\Data\micb_eyetrack\beh\' Filename.name]);

% Remove practice trials from behavioral data 
% (there are 22 practice trials, but no included in this data anyways)
% out_soa = out_soa((practiceTrials+2):totalTrials);
% responded = responded((practiceTrials+2):totalTrials);
% out_angle = out_angle((practiceTrials+2):totalTrials);
accuracy = out_accuracy;
direction = out_direction; %0 = towards right
incorrect_gabor = out_incorrect_gabor;
% out_RT = out_RT((practiceTrials+1):totalTrials);
% turn_trials = turn_trials((practiceTrials+1):totalTrials);














