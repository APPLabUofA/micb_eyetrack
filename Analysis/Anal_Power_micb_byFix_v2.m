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




% /////////////////////////////////////////////////////////////////////////
% /////////////////////////////////////////////////////////////////////////
%% Adjust trial number of beh data if data was loaded
% Remove trials from the behavioral data that were rejected during EEG
% processing
[out_soa,out_respond,out_angle,accuracy,direction,incor_gabor,out_RT,turn_trials] =...
     rej_beh_trials(exp,ALLEEG);
 

% |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
%% Load previously processed target-aligned epoch data
% data has been converted to log scale
all_ersp_Z = struct2cell(load('micb_pwrZ_v1.mat'));  %gets loaded as a struct
all_ersp_Z = all_ersp_Z{1};
load('micb_pwrZ_v1.mat')

% Load general EEG data
load('ALLEEG_filt_byTargets_v3_sm.mat');
EEG = pop_loadset('EEG_filt_v3_data.set');

% Load settings
load('byFix_v5_Settings.mat');


eeglab redraw




% #########################################################################
% /////////////////////////////////////////////////////////////////////////
%% Create log scaled raw ERS values
% /////////////////////////////////////////////////////////////////////////
% #########################################################################

% --For data with targets--
all_erspN = cell(length(exp.participants),length(exp.singletrialselecs),length(exp.setname)); %pre-allocate
for i_part = 1:length(exp.participants) % --
    for ii = 1:length(exp.singletrialselecs)
        i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
        for i_set = 1:length(exp.setname)
            % all_ersp is (participant x electrode x set).trials(freq x time x trial)
            tmp_ersp = abs(all_ersp{i_part,i_elect,i_set});
            for i_trial = 1:size(tmp_ersp,3)
                all_erspN{i_part,i_elect,i_set}.trials(:,:,i_trial) = 10*log10(tmp_ersp(:,:,i_trial)); %dB converted
            end
            clear i_trial
        end
        clear i_set
    end
    clear ii i_elect tmp_ersp
end
clear i_part

%change freq spacing to log
freqs_log = logspace(log10(min(freqs)),log10(max(freqs)),length(freqs));


% #########################################################################
% /////////////////////////////////////////////////////////////////////////
%%                      Standardize Power
% /////////////////////////////////////////////////////////////////////////
% #########################################################################

all_ersp_Z = cell(length(exp.participants),length(exp.singletrialselecs),length(exp.setname)); %pre-allocate
% Change power to z-score values per person per electrode
for i_part = 1:length(exp.participants)
    % Get power across trials
    for ii = 1:length(exp.singletrialselecs)
        i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
        part_ersp = cell(1,length(exp.setname)); %pre-allocate
        for i_set = 1:length(exp.setname) %get data from all sets into one variable
            % all_ersp is (participant x electrode x set).trials(freq x time x trial)
            part_ersp{i_set} = all_erspN{i_part,i_elect,i_set}.trials; %get single subject's power data
        end
        clear i_set
        
%         all_ersp_Z{i_part,i_elect,i_set}.trials = normalize(part_ersp,3,'zscore','robust');
        tmp_ersp = cat(3,part_ersp{1:end}); %cat trials across sets (better for normalization & comparing pre-stimulus activity)
        tmp_Z = (tmp_ersp - mean(tmp_ersp(:))) / std(tmp_ersp(:));
        clear part_ersp tmp_ersp
        %separate the trials by type/set again
        for i_set = 1:length(exp.setname) 
            num = size(all_erspN{i_part,i_elect,i_set}.trials,3); %get # of trials in set
            all_ersp_Z{i_part,i_elect,i_set}.trials = tmp_Z(:,:,1:num);
            tmp_Z(:,:,1:num) = []; %deletes trials that had just been allocated to all_ersp_Z
            clear num
        end
        clear tmp_Z i_set
    end
    clear ii i_elect
end
clear i_part






% #########################################################################
% /////////////////////////////////////////////////////////////////////////
%% ######################## ERS ###########################################
% /////////////////////////////////////////////////////////////////////////
% #########################################################################

% Create ERS by trial type
% all_ersp_Z is (participant x electrode x set).trials(freq x time x trial)
pwr_out_T_cor = cell(1,length(exp.singletrialselecs)); %pre-allocate
pwr_out_T_inc = cell(1,length(exp.singletrialselecs)); %pre-allocate
pwr_out_S = cell(1,length(exp.singletrialselecs)); %pre-allocate
for i_part = 1:length(exp.participants)
    
    % Calculate power
    for ii = 1:length(exp.singletrialselecs)
        i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
        
        % Get correct turn trials
        pwr_out_T_cor{1,i_elect}(i_part,:,:) = squeeze(mean(all_ersp_Z{i_part,i_elect,1}.trials,3));
        % Get incorrect turn trials
        pwr_out_T_inc{1,i_elect}(i_part,:,:) = squeeze(mean(all_ersp_Z{i_part,i_elect,2}.trials,3));
        % Get straight trials
        pwr_out_S{1,i_elect}(i_part,:,:) = squeeze(mean(all_ersp_Z{i_part,i_elect,3}.trials,3));
        
        clear part_ersp i_elect
    end
end
clear ii i_part

% /////////////////////////////////////////////////////////////////////////
% #########################################################################
%% Gets a count of trials
trl_count(:,1) = cellfun(@numel,outT_c_RT); %correct turn trials
trl_count(:,2) = cellfun(@numel,outT_i_RT); %incorrect turn trials
trl_count(:,3) = cellfun(@numel,outS_RT); %straight trials
% trl_count(:,4) = cell2mat({ALLEEG(1:end).trials}); %total trial count

% #########################################################################
% /////////////////////////////////////////////////////////////////////////
% #########################################################################



% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
%% Plot spectogram of entire trial timecourse across subjects &&
% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

% Raw ERS plots
for ii = 1:length(exp.singletrialselecs)
% for ii = 1:5
%     
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
    title(['Flexion Correct: ' exp.singtrlelec_name{ii}],'FontSize',14);   
    set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
    line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([1925 1925],[min(freqs) max(freqs)],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for end of trial
    ylim([3 40]); yticks(5:5:40)
    xlim([-300 max(times)]); xticks(-300:300:1800)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
    % Plot incorrect turn trials
    subplot(1,3,2)
    imagesc(times,freqs,plot_ers_T_inc,CLim);
    title(['Flexion Incorrect: ' exp.singtrlelec_name{ii}],'FontSize',14);   
    set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
    line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([1925 1925],[min(freqs) max(freqs)],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for end of trial
    ylim([3 40]); yticks(5:5:40)
    xlim([-300 max(times)]); xticks(-300:300:1800)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
    % Plot straight trials
    subplot(1,3,3)
    imagesc(times,freqs,plot_ers_S,CLim);
    title(['Control: ' exp.singtrlelec_name{ii}],'FontSize',14);   
    set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
    line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([1925 1925],[min(freqs) max(freqs)],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for end of trial
    ylim([3 40]); yticks(5:5:40)
    xlim([-300 max(times)]); xticks(-300:300:1800)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
%     savefig(['M:\Analysis\OrientWheel\Figures\SpecPlot_Z_sm_v2_' exp.singtrlelec_name{ii}])
   
    clear plot_ers_S plot_ers_T_cor plot_ers_T_inc CLim t
end
clear ii i_elect

% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% Difference ERS plots
% for ii = 1:length(exp.singletrialselecs)
for ii = 1:5
    i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
    
    %mean across subjects
    plot_ers_T_cor = squeeze(mean(pwr_out_T_cor{1,i_elect}(:,:,:),1)); %correct turn trials
    plot_ers_T_inc = squeeze(mean(pwr_out_T_inc{1,i_elect}(:,:,:),1)); %incorrect turn trials
    plot_ers_S = squeeze(mean(pwr_out_S{1,i_elect}(:,:,:),1)); %straight trials
    
    CLim = [-0.4 0.4]; %set power scale of plot
    
    figure('Position', [1 1 1685 405]); colormap('jet') %open a new figure
    
    % Plot Correct-Incorrect Turn Trials
    subplot(1,3,1)
    imagesc(times,freqs,plot_ers_T_cor-plot_ers_T_inc,CLim);
    title(['Correct-Incorrect Flexion: ' exp.singtrlelec_name{ii}],'FontSize',14);   
    set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
    line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([1925 1925],[min(freqs) max(freqs)],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for end of trial
    ylim([3 40]); yticks(5:5:40)
    xlim([-300 max(times)]); xticks(-300:300:1800)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca); 
    t.Ticks = [CLim(1):0.1:CLim(2)]; %make sure colorbar contains ticks
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
    % Plot Correct Turn - Control Trials
    subplot(1,3,2)
    imagesc(times,freqs,plot_ers_T_cor-plot_ers_S,CLim);
    title(['Correct Flexion-Control: ' exp.singtrlelec_name{ii}],'FontSize',14); 
    set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
    line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([1925 1925],[min(freqs) max(freqs)],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for end of trial    ylim([3 40]); yticks(5:5:40)
    xlim([-300 max(times)]); xticks(-300:300:1800)
    ylim([3 40]); yticks(5:5:40)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca); 
    t.Ticks = [CLim(1):0.1:CLim(2)]; %make sure colorbar contains ticks
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
    % Plot Incorrect Turn - Control Trials
    subplot(1,3,3)
    imagesc(times,freqs,plot_ers_T_inc-plot_ers_S,CLim);
    title(['Incorrect Flexion-Control: ' exp.singtrlelec_name{ii}],'FontSize',14);   
    set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
    line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([1925 1925],[min(freqs) max(freqs)],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for end of trial
    ylim([3 40]); yticks(5:5:40)
    xlim([-300 max(times)]); xticks(-300:300:1800)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca); 
    t.Ticks = [CLim(1):0.1:CLim(2)]; %make sure colorbar contains ticks
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
%     savefig(['M:\Analysis\OrientWheel\Figures\SpectPlots\SpecPlot_DifZ_sm_v2_' exp.singtrlelec_name{ii}])
%     savefig(['C:\Users\ssshe\Documents\MathLab\OrientWheel\Figures\SpectPlots\SpecPlot_DifZ_sm_v3_' exp.singtrlelec_name{ii}])
    
    clear plot_ers_S plot_ers_T_cor plot_ers_T_inc CLim t
end
clear ii i_elect

% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------



% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
%% Plot spectogram of pre-rotation time across subjects &&
% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

% Raw ERS plots
% for ii = 1:length(exp.singletrialselecs)
for ii = 1:5
%     
    i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
    
    %mean across subjects
    plot_ers_T_cor = squeeze(mean(pwr_out_T_cor{1,i_elect}(:,:,:),1)); %correct turn trials
    plot_ers_T_inc = squeeze(mean(pwr_out_T_inc{1,i_elect}(:,:,:),1)); %incorrect turn trials
    plot_ers_S = squeeze(mean(pwr_out_S{1,i_elect}(:,:,:),1)); %straight trials
    
    CLim = [-1.5 1.5]; %set power scale of plot
    
    figure('Position', [1 1 1685 405]); colormap('hot') %open a new figure
    
    % Plot correct turn trials
    subplot(1,3,1)
    imagesc(times,freqs,plot_ers_T_cor,CLim);
    title(['Flexion Correct: ' exp.singtrlelec_name{ii}],'FontSize',14);   
    set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
%     line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    ylim([3 40]); yticks(5:5:40)
    xlim([-400 1092]); xticks(-400:200:1000)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
    % Plot incorrect turn trials
    subplot(1,3,2)
    imagesc(times,freqs,plot_ers_T_inc,CLim);
    title(['Flexion Incorrect: ' exp.singtrlelec_name{ii}],'FontSize',14);   
    set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
%     line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    ylim([3 40]); yticks(5:5:40)
    xlim([-400 1092]); xticks(-400:200:1000)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
    % Plot straight trials
    subplot(1,3,3)
    imagesc(times,freqs,plot_ers_S,CLim);
    title(['Control: ' exp.singtrlelec_name{ii}],'FontSize',14);   
    set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
%     line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    ylim([3 40]); yticks(5:5:40)
    xlim([-400 1092]); xticks(-400:200:1000)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca);
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
%     savefig(['M:\Analysis\OrientWheel\Figures\SpecPlot_Z_sm_v2_' exp.singtrlelec_name{ii}])
   
    clear plot_ers_S plot_ers_T_cor plot_ers_T_inc CLim t
end
clear ii i_elect

% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% Difference ERS plots
CLim = [-0.06 0.06]; %set power scale of plot
cmap = redblue(64); %create colormap colors
% for ii = 1:length(exp.singletrialselecs)
for ii = 1:5
    i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
    
    %mean across subjects
    plot_ers_T_cor = squeeze(mean(pwr_out_T_cor{1,i_elect}(:,:,:),1)); %correct turn trials
    plot_ers_T_inc = squeeze(mean(pwr_out_T_inc{1,i_elect}(:,:,:),1)); %incorrect turn trials
    plot_ers_S = squeeze(mean(pwr_out_S{1,i_elect}(:,:,:),1)); %straight trials
    
    ctick = CLim(1):0.02:CLim(2); %ticks on the colorbar
    
%     figure('Position', [1 1 1685 405]); colormap('jet') %open a new figure
    figure; colormap(cmap)
    
    % Plot Correct-Incorrect Turn Trials
%     subplot(1,3,1)
    imagesc(times,freqs,plot_ers_T_cor-plot_ers_T_inc,CLim);
    title(['Correct-Incorrect Flexion: ' exp.singtrlelec_name{ii}],'FontSize',14);   
    set(gca,'Ydir','Normal')
   line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
%     line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    ylim([3 40]); yticks(5:5:40)
    set(gca,'FontSize',12); %increase font size of axis
    xlim([-400 1092]); xticks(-400:200:1000)
    set(gca,'FontSize',12); %increase font size of axis
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    t = colorbar('peer',gca); 
    t.Ticks = ctick; %make sure colorbar contains ticks
    set(get(t,'ylabel'),'String', 'Standardized Power');
    
    % Plot Correct Turn - Control Trials
%     subplot(1,3,2)
%     imagesc(times,freqs,plot_ers_T_cor-plot_ers_S,CLim);
%     title(['Correct Flexion-Control: ' exp.singtrlelec_name{ii}],'FontSize',14); 
%     set(gca,'Ydir','Normal')
%     line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
% %     line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
%     ylim([3 40]); yticks(5:5:40)
%     xlim([-400 1092]); xticks(-400:200:1000)
%     ylabel('Freqency (Hz)'); xlabel('Time (ms)');
%     t = colorbar('peer',gca); 
%     t.Ticks = ctick; %make sure colorbar contains ticks
%     set(get(t,'ylabel'),'String', 'Standardized Power');
%     
%     % Plot Incorrect Turn - Control Trials
%     subplot(1,3,3)
%     imagesc(times,freqs,plot_ers_T_inc-plot_ers_S,CLim);
%     title(['Incorrect Flexion-Control: ' exp.singtrlelec_name{ii}],'FontSize',14);   
%     set(gca,'Ydir','Normal')
%     line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
% %     line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
%     ylim([3 40]); yticks(5:5:40)
%     xlim([-400 1092]); xticks(-400:200:1000)
%     ylabel('Freqency (Hz)'); xlabel('Time (ms)');
%     t = colorbar('peer',gca); 
%     t.Ticks = ctick; %make sure colorbar contains ticks
%     set(get(t,'ylabel'),'String', 'Standardized Power');
 
    clear plot_ers_S plot_ers_T_cor plot_ers_T_inc t
end
clear ii i_elect ctick CLim zero_loc cmap

% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% Grand Mean Difference ERS plot
% for ii = 1:length(exp.singletrialselecs)
for ii = 1:5
    i_elect = exp.singletrialselecs(ii); %for doing only a selection of electrodes
    %mean across subjects
    grand_ers_T_cor(i_elect,:,:) = squeeze(mean(pwr_out_T_cor{1,i_elect}(:,:,:),1)); %correct turn trials
    grand_ers_T_inc(i_elect,:,:) = squeeze(mean(pwr_out_T_inc{1,i_elect}(:,:,:),1)); %incorrect turn trials
    grand_ers_S(i_elect,:,:) = squeeze(mean(pwr_out_S{1,i_elect}(:,:,:),1)); %straight trials
end
clear ii i_elect


CLim = [-0.06 0.06]; %set power scale of plot
cmap = redblue(64); %create colormap colors
ctick = CLim(1):0.02:CLim(2); %ticks on the colorbar
figure; colormap(cmap)

% Plot Correct-Incorrect Turn Trials
plot_T = squeeze(mean(grand_ers_T_cor,1));
plot_T2 = squeeze(mean(grand_ers_T_inc,1));
imagesc(times,freqs,plot_T-plot_T2,CLim);
title(['Correct-Incorrect Flexion: Grand Mean'],'FontSize',14);   
set(gca,'Ydir','Normal')
line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
% line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
ylim([3 40]); yticks(5:5:40)
set(gca,'FontSize',12); %increase font size of axis
xlim([-400 1092]); xticks(-400:200:1000)
set(gca,'FontSize',12); %increase font size of axis
ylabel('Freqency (Hz)'); xlabel('Time (ms)');
t = colorbar('peer',gca); 
t.Ticks = ctick; %make sure colorbar contains ticks
set(get(t,'ylabel'),'String', 'Standardized Power');

clear ctick CLim zero_loc cmap grand_ers_T_cor grand_ers_T_inc grand_ers_S t plot_T plot_T2
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
























