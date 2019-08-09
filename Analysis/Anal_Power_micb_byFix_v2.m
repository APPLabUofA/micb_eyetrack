% |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
%                             INFORMATION
% |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

% SPECTOGRAM
% A spectogram is a 3d figure that plots time on the x-axis, frequency on the 
% y-axis, and shows you the power or phase-locking value for each point. 
% We compute spectograms if we have power and phase information, averaged 
% across trials, for at least one electrode. 
% This can help us understand the changes of power and phase throughout the 
% trial.

% |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

% Variables working with:
% ersp(i_sub,i_cond,i_perm,i_chan,:,:)
% itc(i_sub,i_cond,i_perm,i_chan,:,:)
% powbase,times,freqs

% The variables ersp and itc will be a 6D variable: 
% (participants x sets x events x electrodes x frequencies x timepoints)

% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% period = 1/EEG.srate; 
% time (in s) = [EEG.event.latency]*period
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




% #########################################################################
% /////////////////////////////////////////////////////////////////////////
%% Create log scaled raw ERS values
% /////////////////////////////////////////////////////////////////////////
% #########################################################################

% --For data with targets--
all_erspN = cell(length(exp.participants),length(exp.singletrialselecs)); %pre-allocate
for i_part = 1:length(exp.participants) % --
    for ii = 1:length(exp.singletrialselecs)
        i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
        % all_ersp is (participant x electrode).trials(freq x time x trial)
        tmp_ersp = abs(all_ersp{i_part,i_elect});
        for i_trial = 1:size(tmp_ersp,3)
            all_erspN{i_part,i_elect}.trials(:,:,i_trial) = 10*log10(tmp_ersp(:,:,i_trial)); %dB converted
        end
        clear i_trial
    end
    clear ii i_elect tmp_ersp
end
clear i_part


% #########################################################################
% /////////////////////////////////////////////////////////////////////////
%%                      Standardize Power
% /////////////////////////////////////////////////////////////////////////
% #########################################################################

all_ersp_Z = cell(length(exp.participants),length(exp.singletrialselecs)); %pre-allocate
% Change power to z-score values per person
for i_part = 1:length(exp.participants)
    % Get power across trials
    for ii = 1:length(exp.singletrialselecs)
        i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
        % all_ersp is (participant x electrode).trials(freq x time x trial)
        part_ersp = all_erspN{i_part,i_elect}.trials; %get single subject's baseline corrected power
%         all_ersp_Z{i_part,i_elect}.trials = normalize(part_ersp,3,'zscore','robust');
        all_ersp_Z{i_part,i_elect}.trials = (part_ersp - mean(part_ersp(:))) / std(part_ersp(:));
        clear part_ersp i_elect
    end
    clear ii
end
clear i_part



% /////////////////////////////////////////////////////////////////////////
% /////////////////////////////////////////////////////////////////////////

% Remove trials from the behavioral data that were rejected during EEG
% processing
[out_soa,out_respond,out_angle,accuracy,direction,incor_gabor,out_RT,turn_trials] =...
     rej_beh_trials(exp,ALLEEG);
 
 % /////////////////////////////////////////////////////////////////////////
% /////////////////////////////////////////////////////////////////////////


% #########################################################################
% /////////////////////////////////////////////////////////////////////////
%% ######################## ERS ###########################################
% /////////////////////////////////////////////////////////////////////////
% #########################################################################

% Create ERS by errors
pwr_out_T_cor = cell(1,length(exp.singletrialselecs)); %pre-allocate
pwr_out_T_inc = cell(1,length(exp.singletrialselecs)); %pre-allocate
pwr_out_S = cell(1,length(exp.singletrialselecs)); %pre-allocate
for i_part = 1:length(exp.participants)
    
    % Calculate power
    for ii = 1:length(exp.singletrialselecs)
        i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
        
        % all_ersp is (participant x electrode).trials(freq x time x trial)
        part_ersp = all_ersp_Z{i_part,i_elect}.trials; %get single subject's baseline corrected power
        
        % Get correct turn trials
        pwr_out_T_cor{1,i_elect}(i_part,:,:) = squeeze(mean(part_ersp(:,:,...
            (turn_trials{i_part}==1 & accuracy{i_part}==1) ),3));
        
        % Get incorrect turn trials
        pwr_out_T_inc{1,i_elect}(i_part,:,:) = squeeze(mean(part_ersp(:,:,...
            (turn_trials{i_part}==1 & accuracy{i_part}==0) ),3));
        
        % Get straight trials
        pwr_out_S{1,i_elect}(i_part,:,:) = squeeze(mean(part_ersp(:,:,(turn_trials{i_part}==0)),3));
        
        clear part_ersp i_elect
    end
end
clear ii i_part

% /////////////////////////////////////////////////////////////////////////
% #########################################################################
%% Gets a count of trials
err_trl_count(:,1) = cellfun(@numel,x_errdeg_m); %small errors
err_trl_count(:,2) = cellfun(@numel,n_errdeg_m); %large errors
% err_trl_count(:,3) = cell2mat({ALLEEG(1:end).trials}); %total trial count

% #########################################################################
% /////////////////////////////////////////////////////////////////////////
% #########################################################################

% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
%% Plot spectogram across subjects &&
% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

% Raw ERS plots
% for ii = 1:length(exp.singletrialselecs)
for ii = 1:5
    
    i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
    
    %mean across subjects
    plot_ers_T_cor = squeeze(mean(pwr_out_T_cor{1,i_elect}(:,:,:),1)); %correct turn trials
    plot_ers_T_inc = squeeze(mean(pwr_out_T_inc{1,i_elect}(:,:,:),1)); %incorrect turn trials
    plot_ers_S = squeeze(mean(pwr_out_S{1,i_elect}(:,:,:),1)); %straight trials
    
    CLim = [-1.5 1.5]; %set power scale of plot
    
    % Plot correct turn trials
    figure('Position', [1 1 1685 405]); colormap('jet') %open a new figure
    subplot(1,3,1)
    imagesc(times,freqs,plot_ers_T_cor,CLim);
    title(['Flexion Correct: ' exp.singtrlelec_name{ii}]); set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
    line([1092 1092],[ymin ymax],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([2042 2042],[ymin ymax],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for response screen
    ylim([3 40]); yticks(5:5:40)
    xlim([-400 2200]); xticks(-400:400:2200)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
    % Plot incorrect turn trials
    subplot(1,3,2)
    imagesc(times,freqs,plot_ers_T_inc,CLim);
    title(['Flexion Incorrect: ' exp.singtrlelec_name{ii}]); set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
    line([1092 1092],[ymin ymax],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([2042 2042],[ymin ymax],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for response screen
    ylim([3 40]); yticks(5:5:40)
    xlim([-400 2200]); xticks(-400:400:2200)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
    % Plot straight trials
    subplot(1,3,3)
    imagesc(times,freqs,plot_ers_S,CLim);
    title(['Control: ' exp.singtrlelec_name{ii}]); set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
    line([1092 1092],[ymin ymax],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([2042 2042],[ymin ymax],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for response screen
    ylim([3 40]); yticks(5:5:40)
    xlim([-400 2200]); xticks(-400:200:2200)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
%     savefig(['M:\Analysis\OrientWheel\Figures\SpecPlot_Z_sm_v2_' exp.singtrlelec_name{ii}])
   
    clear plot_ers_S plot_ers_T_cor plot_ers_T_inc CLim t
end
clear ii i_elect

% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% Difference ERS plots
for ii = 1:length(exp.singletrialselecs)
% for ii = 1:5
    i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
    %mean across subjects
    plot_ers_x = squeeze(mean(x_pwr{1,i_elect}(:,:,:),1)); %small errors
    plot_ers_n = squeeze(mean(n_pwr{1,i_elect}(:,:,:),1)); %large errors
    
    CLim = [-0.3 0.3]; %set power scale of plot
    
    % Plot Accurate-Guesses
    figure; colormap('jet') %open a new figure
    imagesc(times,freqs,plot_ers_x-plot_ers_n,CLim);
    title(['Accurate-Guesses: ' exp.singtrlelec_name{ii}]); set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
    line([567 567],[min(freqs) max(freqs)],'color','m','LineStyle','--','LineWidth',1.5)  %vertical line for response screen onset
    ylim([3 40]); yticks(5:5:40)
    xlim([-700 800]); xticks(-600:200:800)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
%     t = colorbar('peer',gca); 
%     t.Ticks = [-0.3:0.1:0.3]; %make sure colorbar contains ticks
%     set(get(t,'ylabel'),'String', 'Standardized Power');
    
%     savefig(['M:\Analysis\OrientWheel\Figures\SpectPlots\SpecPlot_DifZ_sm_v2_' exp.singtrlelec_name{ii}])
    savefig(['C:\Users\ssshe\Documents\MathLab\OrientWheel\Figures\SpectPlots\SpecPlot_DifZ_sm_v3_' exp.singtrlelec_name{ii}])
    
    clear plot_ers_x plot_ers_n CLim t
end
clear ii i_elect

% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


























