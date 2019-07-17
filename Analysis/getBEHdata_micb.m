function [out_soa,responded,out_angle] = getBEHdata_micb(part_name)


%Find output filename
Filename = dir(['M:\Experiments\micb_eyetrack\Data\beh\' part_name '*']);

%% Save data
load(['M:\Experiments\micb_eyetrack\Data\beh\' Filename.name]);

% Remove practice trials from behavioral data
out_soa = out_soa((practiceTrials+1):totalTrials);
responded = responded((practiceTrials+1):totalTrials);
out_angle = out_angle((practiceTrials+1):totalTrials);















