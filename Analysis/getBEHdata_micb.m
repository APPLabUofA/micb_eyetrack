function [out_soa,responded,out_angle,accuracy,direction,incorrect_gabor,out_RT,turn_trials,eventtrack] =...
    getBEHdata_micb(part_name)


%Find output filename
Filename = dir(['M:\Data\micb_eyetrack\beh\' part_name '*']);

%% Save data
load(['M:\Data\micb_eyetrack\beh\' Filename.name]);

% Remove trials where response timed out
accuracy = out_accuracy(out_accuracy ~= 2);
direction = out_direction(out_accuracy ~= 2); %0 = towards right
incorrect_gabor = out_incorrect_gabor(out_accuracy ~= 2);
out_RT = out_RT(out_accuracy ~= 2);
turn_trials = turn_trials(out_accuracy ~= 2);
out_soa = out_soa(out_accuracy ~= 2);
responded = responded(out_accuracy ~= 2);
out_angle = out_angle(out_accuracy ~= 2);














