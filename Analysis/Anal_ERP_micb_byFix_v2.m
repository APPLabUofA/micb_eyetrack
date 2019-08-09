


% /////////////////////////////////////////////////////////////////////////
% /////////////////////////////////////////////////////////////////////////

% List of electrodes to make ERPs
elect_erp = [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18];
el_erp_names = {'Oz';'Pz';'Cz';'FCz';'Fz';'O1';'O2';'P3';'P4';'P7';'P8';'CP1';'CP2';'C5';'C6';'F3';'F4'};


% List electrodes to get ERP topograph plots (need all of them) 
elect_erp = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];
el_erp_names = {'M2';'Oz';'Pz';'Cz';'FCz';'Fz';'O1';'O2';'P3';'P4';'P7';'P8';...
    'CP1';'CP2';'C5';'C6';'F3';'F4';'VEOG';'HEOG'};

% /////////////////////////////////////////////////////////////////////////
% /////////////////////////////////////////////////////////////////////////

% Remove trials from the behavioral data that were rejected during EEG
% processing
[out_soa,out_respond,out_angle,accuracy,direction,incor_gabor,out_RT,turn_trials] =...
     rej_beh_trials(exp,ALLEEG);


% /////////////////////////////////////////////////////////////////////////
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%%                 ERPs by Trial Type - Mean
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
% /////////////////////////////////////////////////////////////////////////

% Create ERPs by trial type
erp_out_T = NaN(length(exp.participants),length(elect_erp),length(EEG.times)); %pre-allocate
erp_out_S = NaN(length(exp.participants),length(elect_erp),length(EEG.times)); %pre-allocate
erp_out_T_cor = NaN(length(exp.participants),length(elect_erp),length(ALLEEG(1).times)); %pre-allocate
erp_out_T_inc = NaN(length(exp.participants),length(elect_erp),length(ALLEEG(1).times)); %pre-allocate
for i_part = 1:length(ALLEEG) 
        
    for ii = 1:length(elect_erp) %loop through electrodes
        i_elect = elect_erp(ii); %for doing only a selection of electrodes
        
        % Turn trial ERPs
        erp_out_T(i_part,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,turn_trials{i_part}),3));
        erp_out_T_cor(i_part,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,...
            (turn_trials{i_part} & accuracy{i_part}==1)),3));
        erp_out_T_inc(i_part,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,...
            (turn_trials{i_part} & accuracy{i_part}==0)),3));
        
        % Straight trial ERPs
        erp_out_S(i_part,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,turn_trials{i_part}==0),3));
        
    end
    clear ii i_elect
            
end
clear i_part


% /////////////////////////////////////////////////////////////////////////
% /////////////////////////////////////////////////////////////////////////




% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% ::::::::::::::::::  Plot the ERPs by electrode  :::::::::::::::::::::::::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% ------------------------------------------------------------------------- 
% average across subjects
erp_out_byerr(:,:,1) = squeeze(mean(erp_out_T(:,:,:),1)); %turn trials
erp_out_byerr(:,:,2) = squeeze(mean(erp_out_S(:,:,:),1)); %straight trials
erp_out_byerr(:,:,3) = squeeze(mean((erp_out_T(:,:,:)-erp_out_S(:,:,:)),1)); %difference
erp_out_byerr(:,:,4) = squeeze(mean(erp_out_T_cor(:,:,:),1)); %turn trials correct
erp_out_byerr(:,:,5) = squeeze(mean(erp_out_T_inc(:,:,:),1)); %turn trials incorrect
% ------------------------------------------------------------------------- 


% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Plot by small and large error trials & difference ERP
% for ii = 1:8
for ii = 1:length(elect_erp)    
    i_elect = elect_erp(ii); %for doing only a selection of electrodes
%     i_elect = ii; %selection done when making ERPs

    % get axes limits
    ymin = floor(min([erp_out_byerr(i_elect,:,1) erp_out_byerr(i_elect,:,2)]));
    ymax = ceil(max([erp_out_byerr(i_elect,:,1) erp_out_byerr(i_elect,:,2)]));
%     ymin = -10; ymax = 5;
    xmin = -400; xmax = 2200;
    
    figure
    %Turn trials
    plot(EEG.times,erp_out_byerr(i_elect,:,1),'color',[0.14 0.93 0.9],'LineWidth',1.5)
    hold on
    %Straight trials
    plot(EEG.times,erp_out_byerr(i_elect,:,2),'-.m','LineWidth',1.5)
    hold on
    %difference
%     plot(EEG.times,erp_out_byerr(i_elect,:,3),'color',[0 1 0.5],'LineWidth',1)
%     hold on
    
    line([xmin xmax],[0 0],'color','k','LineWidth',1.5) %horizontal line
    line([0 0],[ymin ymax],'color','k','LineWidth',1.5) %vertical line
    line([1092 1092],[ymin ymax],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([2041 2041],[ymin ymax],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for response screen
    
    %reverse y-axis so negative is up
    set(gca,'ydir','reverse'); 
    %axes limits
    xlim([xmin xmax]); ylim([ymin ymax]);
    xticks(xmin:400:xmax); yticks(ymin:2:ymax)
    %axes labels
    xlabel('Time (ms)'); ylabel('Voltage (uV)');
    
    title([el_erp_names{ii} ': ERPs by Trial Type']); 
    legend({'Flexion','Control'},'Location','best');
%     legend({'Flexion','Straight','Diff: F-S'},'Location','best');
    
    clear ymin ymax
end
clear ii xmax xmin


% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Plot ERPs with error bars
for ii = 1:length(elect_erp) 
% for ii = 1:5 
    i_elect = elect_erp(ii); %for doing only a selection of electrodes
%     i_elect = ii; %selection done when making ERPs

    % get axes limits
    ymin = -10; ymax = 11;
    xmin = -400; xmax = 2200;
    
    figure('Color',[1 1 1],'Position',[680 678 789 420]); 
%     figure;
    boundedline(ALLEEG(1).times,erp_out_byerr(i_elect,:,4),squeeze(std(erp_out_T_cor(:,i_elect,:),[],1))./sqrt(length(exp.participants)),'b',...
            ALLEEG(1).times,erp_out_byerr(i_elect,:,5),squeeze(std(erp_out_T_inc(:,i_elect,:),[],1))./sqrt(length(exp.participants)),'g--',...
            ALLEEG(1).times,erp_out_byerr(i_elect,:,2),squeeze(std(erp_out_S(:,i_elect,:),[],1))./sqrt(length(exp.participants)),'m');
    hold on
    
    line([xmin xmax],[0 0],'color','k','LineWidth',1.5) %horizontal line
    line([0 0],[ymin ymax],'color','k','LineWidth',1.5) %vertical line
    line([1092 1092],[ymin ymax],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([2042 2042],[ymin ymax],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for response screen
    
    %reverse y-axis so negative is up
    set(gca,'ydir','reverse'); 
    %axes limits
    xlim([xmin xmax]); ylim([ymin ymax])
    %axes labels
    xlabel('Time (ms)'); ylabel('Voltage (uV)'); 
    xticks(xmin:200:xmax); yticks(ymin:2:10) 
    
    title([el_erp_names{ii} ': ERPs by Trial Type']);    
    legend({'Flexion-Correct','Flexion-Incorrect','Control'},'Location','best');
    
    clear ymin ymax
end
clear ii xmax xmin    


clear erp_out_byerr


% /////////////////////////////////////////////////////////////////////////
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%% '''''''''''''''''''''''    Topographys     '''''''''''''''''''''''''''''
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
% /////////////////////////////////////////////////////////////////////////


% List electrodes to get ERP topograph plots (need all of them) 
elect_erp = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18];
el_erp_names = {'M2';'Oz';'Pz';'Cz';'FCz';'Fz';'O1';'O2';'P3';'P4';'P7';'P8';...
    'CP1';'CP2';'C5';'C6';'F3';'F4'};

% ------------------------------------------------------------------------- 
% average across subjects
erp_out_byerr(:,:,1) = squeeze(mean(erp_out_S(:,:,:),1)); %straight trials
erp_out_byerr(:,:,2) = squeeze(mean(erp_out_T_cor(:,:,:),1)); %turn trials correct
erp_out_byerr(:,:,3) = squeeze(mean(erp_out_T_inc(:,:,:),1)); %turn trials incorrect
% ------------------------------------------------------------------------- 


% Set the range of time to consider
% tWin{1} = [50 150];
% tWin{2} = [150 250];
% tWin{3} = [250 350];
% tWin{4} = [350 450];
% tWin{5} = [450 550];

tWin{1} = [1090 1200];
tWin{2} = [1200 1300];
tWin{3} = [1300 1400];
tWin{4} = [1400 1500];
tWin{5} = [1500 1600];
tWin{6} = [1600 1700];

CLims1 = [-9 9]; %range in microvolts
nconds = 3; %number of plots
conds = {'Flexion-Correct','Flexion-Incorrect','Straight'}; %labels for plots

for tw_i = 1:length(tWin) %loop through several time windows 
 
    itWin = tWin{tw_i}; %select each time range if looping
    %this code finds the times you want from the timess variable
    time_window = find(EEG.times>= itWin(1),1):find(EEG.times>= itWin(2),1)-1;
    
    figure('Color',[1 1 1],'Position',[1 1 941 349]);

    for i_cond = 1:nconds %loop through conditions to make plot of each        
        subtightplot(1,3,i_cond,[0.02,0.02],[0.05,0.07],[0.05,0.05]);
        set(gca,'Color',[1 1 1]);
        
        temp = mean(erp_out_byerr(:,time_window,i_cond),2)'; %ERP within time window
        temp(1) = NaN; %so M2 is not included
        
        if i_cond == 4 %for making topography from conditon differences
            CLims = [-4 4]; %need smaller scale
            topoplot(temp,ALLEEG(1).chanlocs,'whitebk','on','plotrad',0.6,'maplimits',CLims,...
                'plotchans',elect_erp,'emarker',{'.','k',11,1})
    %         topoplot(temp,EEG.chanlocs,'whitebk','on',0.6,'maplimits',...
    %             'plotchans',elect_erp,'emarker',{'.','k',11,1})
        else
            topoplot(temp,ALLEEG(1).chanlocs,'whitebk','on','plotrad',0.6,'maplimits',CLims1,...
            'plotchans',elect_erp,'emarker',{'.','k',11,1})
        end
        title(conds{i_cond});
        t = colorbar('peer',gca);
        set(get(t,'ylabel'),'String', 'Voltage (uV)');
        clear temp
    end
    
    % Overall subplot title
    supertitle([num2str(itWin(1)) ' to ' num2str(itWin(2)) ' ms'],...
        'FontSize',10.5)
    
%     savefig(['M:\Personal_Folders\Sarah\Manuscripts\Orientation_Wheel\Figures\ERP_sm_' num2str(itWin(1)) ' to ' num2str(itWin(2)) ' ms'])
    
    clear itWin time_window i_cond

end
clear tw_i nconds conds tWin CLims CLims1 t




% Difference topplots -----------------------------------------------------

% ------------------------------------------------------------------------- 
% Average across subjects by errors
erp_out_diff(:,:,1) = squeeze(mean((erp_out_T_cor(:,:,:)-erp_out_T_inc(:,:,:)),1)); %turn correct - incorrect
erp_out_diff(:,:,2) = squeeze(mean((erp_out_T_cor(:,:,:)-erp_out_S(:,:,:)),1)); %turn correct - straight
erp_out_diff(:,:,3) = squeeze(mean((erp_out_T_inc(:,:,:)-erp_out_S(:,:,:)),1)); %turn incorrect - straight
% ------------------------------------------------------------------------- 


% Set the range of time to consider
tWin{1} = [1090 1200];
tWin{2} = [1200 1400];
tWin{3} = [1400 1600];
tWin{4} = [1600 2000];

% tWin{1} = [1090 1200];
% tWin{2} = [1200 1300];
% tWin{3} = [1300 1400];
% tWin{4} = [1400 1500];
% tWin{5} = [1500 1600];
% tWin{6} = [1600 1700];

% tWin{1} = [300 350];

CLims1 = [-5 5]; %range in microvolts
nconds = 3; %number of plots
conds = {'Flexion Correct-Incorrect';'Flexion Correct-Straight';'Flexion Incorrect-Straight'}; %labels for plots
for tw_i = 1:length(tWin) %loop through several time windows 
 
    itWin = tWin{tw_i}; %select each time range if looping
    %this code finds the times you want from the timess variable
    time_window = find(EEG.times>= itWin(1),1):find(EEG.times>= itWin(2),1)-1;
    
    figure('Color',[1 1 1],'Position',[1 1 941 349]);

    for i_cond = 1:nconds %loop through conditions to make plot of each        
        subtightplot(1,3,i_cond,[0.02,0.02],[0.05,0.07],[0.05,0.05]);
        set(gca,'Color',[1 1 1]);
        
        temp = mean(erp_out_diff(:,time_window,i_cond),2)'; %ERP within time window
        temp(1) = NaN; %so M2 is not included
        
        if i_cond == 4 %for making topography from conditon differences
            CLims = [-4 4]; %need smaller scale
            topoplot(temp,ALLEEG(1).chanlocs,'whitebk','on','plotrad',0.6,'maplimits',CLims,...
                'plotchans',elect_erp,'emarker',{'.','k',11,1})
    %         topoplot(temp,EEG.chanlocs,'whitebk','on',0.6,'maplimits',...
    %             'plotchans',elect_erp,'emarker',{'.','k',11,1})
        else
            topoplot(temp,ALLEEG(1).chanlocs,'whitebk','on','plotrad',0.6,'maplimits',CLims1,...
            'plotchans',elect_erp,'emarker',{'.','k',11,1})
        end
        title(conds{i_cond});
        t = colorbar('peer',gca);
        set(get(t,'ylabel'),'String', 'Voltage (uV)');
        clear temp
    end
    
    % Overall subplot title
    supertitle([num2str(itWin(1)) ' to ' num2str(itWin(2)) ' ms'],...
        'FontSize',10.5)
    
%     savefig(['M:\Personal_Folders\Sarah\Manuscripts\Orientation_Wheel\Figures\ERP_Diff_sm_' num2str(itWin(1)) ' to ' num2str(itWin(2)) ' ms'])
    
    clear itWin time_window i_cond

end
clear tw_i nconds conds tWin CLims CLims1 t time1 time2 i_elect






















