


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
erp_out_T = NaN(length(exp.participants),length(elect_erp),length(ALLEEG(1).times)); %pre-allocate
erp_out_S = NaN(length(exp.participants),length(elect_erp),length(ALLEEG(1).times)); %pre-allocate
erp_out_T_cor = NaN(length(exp.participants),length(elect_erp),length(ALLEEG(1).times)); %pre-allocate
erp_out_T_inc = NaN(length(exp.participants),length(elect_erp),length(ALLEEG(1).times)); %pre-allocate
outT_accuracy = cell(length(exp.participants),1); %pre-allocate
outS_accuracy = cell(length(exp.participants),1); %pre-allocate
jj = 0; %counter for turn trials
jk = 0; %counter for straight trials
for i_part = 1:length(ALLEEG) 
        
        if strcmpi(ALLEEG(i_part).condition,'T') %Get turn trials
            jj = jj + 1;
            for ii = 1:length(elect_erp) %loop through electrodes
                i_elect = elect_erp(ii); %for doing only a selection of electrodes
                erp_out_T(jj,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,:),3));
                outT_accuracy{jj} = accuracy{jj}(turn_trials{jj});
                erp_out_T_cor(jj,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,outT_accuracy{jj}==1),3));
                erp_out_T_inc(jj,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,outT_accuracy{jj}==0),3));
            end
            clear ii i_elect
            
        elseif strcmpi(ALLEEG(i_part).condition,'S') %Get straight trials
            jk = jk + 1;
            for ii = 1:length(elect_erp) %loop through electrodes
                i_elect = elect_erp(ii); %for doing only a selection of electrodes
                erp_out_S(jk,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,:),3));
                outS_accuracy{jk} = accuracy{jk}(turn_trials{jk}==0);
            end
            clear ii i_elect
        end
end
clear i_part jj jk


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
    %turn trials
    plot(ALLEEG(1).times,erp_out_byerr(i_elect,:,1),'color',[0.14 0.93 0.9],'LineWidth',1.5)
    hold on
    %straight trials
    plot(ALLEEG(1).times,erp_out_byerr(i_elect,:,2),'-.m','LineWidth',1.5)
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
    legend({'Flexion','Straight'},'Location','best');
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
    ymin = -8; ymax = 8;
    xmin = -400; xmax = 2200;
    
    figure('Color',[1 1 1]);
%     figure; 
    boundedline(ALLEEG(1).times,erp_out_byerr(i_elect,:,4),squeeze(std(erp_out_T_cor(:,i_elect,:),[],1))./sqrt(length(exp.participants)),'b',...
            ALLEEG(1).times,erp_out_byerr(i_elect,:,5),squeeze(std(erp_out_T_inc(:,i_elect,:),[],1))./sqrt(length(exp.participants)),'g--',...
            ALLEEG(1).times,erp_out_byerr(i_elect,:,2),squeeze(std(erp_out_S(:,i_elect,:),[],1))./sqrt(length(exp.participants)),'m');
    hold on
    
    ax.Color = 'none';
    line([xmin xmax],[0 0],'color','k','LineWidth',1.5) %horizontal line
    line([0 0],[ymin ymax],'color','k','LineWidth',1.5) %vertical line
    line([1092 1092],[ymin ymax],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
    line([2041 2041],[ymin ymax],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for response screen
    
    %reverse y-axis so negative is up
    set(gca,'ydir','reverse'); 
    %axes limits
    xlim([xmin xmax]); ylim([ymin ymax])
    %axes labels
    xlabel('Time (ms)'); ylabel('Voltage (uV)'); 
    xticks(xmin:400:xmax); yticks(ymin:2:ymax) 
    
    title([el_erp_names{ii} ': ERPs by Trial Type']);    
    legend({'Flexion-Correct','Flexion-Incorrect','Straight'},'Location','best');
    
    clear ymin ymax
end
clear ii xmax xmin    






clear erp_out_byerr





















