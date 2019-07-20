function [out_soa,out_responded,out_angle] = rej_beh_trials(exp,ALLEEG)
% Must load data using LoadProcData_OrientWheel.m for function to work.
% ALLEEG structure should contain all the subjects' data.
% Returns degree response error on each trial with trials rejected during
% the EEG pre-processing pipeline removed. 
% Returns parameters from fitting the response errors to the mixed model.


% -------------------------------------------------------------------------
% /////////////////////////////////////////////////////////////////////////
% -------------------------------------------------------------------------
%% Remove rejected trials
% Get BEH data for trials excluding trials that were rejected in the EEG
% preprocessing of the epochs
out_soa = cell(length(exp.participants),1); %pre-allocate
out_responded = cell(length(exp.participants),1); %pre-allocate
out_angle = cell(length(exp.participants),1); %pre-allocate
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
        % each set of rejected trials needs to be removed in order
        % sequentially
        for mi = 1:length(rejlist)
            tmplist = [rejlist{mi}];
            out_soa_temp(tmplist) = []; %removes the trials
            out_responded_temp(tmplist) = []; %removes the trials
            out_angle_temp(tmplist) = []; %removes the trials
            clear tmplist
        end
        clear mi
    elseif pip == 1 %if no trials were rejected, rejlist variable not created
        out_soa_temp = ALLEEG(i_part).beh.out_soa;
        out_responded_temp = ALLEEG(i_part).beh.responded;
        out_angle_temp = ALLEEG(i_part).beh.out_angle;
    end
    % create variable with selected BEH 
    out_soa{i_part} = out_soa_temp;
    out_responded{i_part} = out_responded_temp;
    out_angle{i_part} = out_angle_temp;
    
    clear rejlist n m pip ni out_soa_temp out_responded_temp out_angle_temp
end
clear i_part

% -------------------------------------------------------------------------
% /////////////////////////////////////////////////////////////////////////
% -------------------------------------------------------------------------