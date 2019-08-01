


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
jj = 0; %counter for turn trials
jk = 0; %counter for straight trials
for i_part = 1:length(ALLEEG) 
        
        if strcmpi(ALLEEG(i_part).condition,'T') %Get turn trials
            jj = jj + 1;
            for ii = 1:length(elect_erp) %loop through electrodes
                i_elect = elect_erp(ii); %for doing only a selection of electrodes
                erp_out_T(jj,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,:),3));
            end
            clear ii i_elect
            
        elseif strcmpi(ALLEEG(i_part).condition,'S') %Get straight trials
            jk = jk + 1;
            for ii = 1:length(elect_erp) %loop through electrodes
                i_elect = elect_erp(ii); %for doing only a selection of electrodes
                erp_out_S(jk,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,:),3));
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
erp_out_byerr(:,:,1) = squeeze(mean(erp_out_T(:,:,:),1)); %small errors
erp_out_byerr(:,:,2) = squeeze(mean(erp_out_S(:,:,:),1)); %large errors
erp_out_byerr(:,:,3) = squeeze(mean((erp_out_T(:,:,:)-erp_out_S(:,:,:)),1)); %difference
% ------------------------------------------------------------------------- 


% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Plot by small and large error trials & difference ERP
% for ii = 1:8
for ii = 1:length(elect_erp)    
%     i_elect = elect_erp(ii); %for doing only a selection of electrodes
    i_elect = ii; %selection done when making ERPs
    % get axes limits
%     ymin = floor(min([erp_out_byerr(i_elect,:,1) erp_out_byerr(i_elect,:,2)]));
%     ymax = ceil(max([erp_out_byerr(i_elect,:,1) erp_out_byerr(i_elect,:,2)]));
    ymin = -10; ymax = 5;
    xmin = -400; xmax = 3500;
    
    figure
    %small errors
    plot(EEG.times,erp_out_byerr(i_elect,:,1),'color',[0.14 0.93 0.9],'LineWidth',1.5)
    hold on
    %large errors
    plot(EEG.times,erp_out_byerr(i_elect,:,2),'-.m','LineWidth',1.5)
    hold on
    %difference
    plot(EEG.times,erp_out_byerr(i_elect,:,3),'color',[0 1 0.5],'LineWidth',1)
    hold on
    line([xmin xmax],[0 0],'color','k','LineWidth',1.5) %horizontal line
    line([0 0],[ymin ymax],'color','k','LineWidth',1.5) %vertical line
    line([1876 1876],[ymin ymax],'LineStyle',':','LineWidth',1.5) %vertical line for mask onset
    line([3359 3359],[ymin ymax],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for color wheel onse
    set(gca,'ydir','reverse'); xlim([xmin xmax]); ylim([ymin ymax])
    
    title([el_erp_names{ii} ': ERPs by Response Error']); 
    xlabel('Time (ms)'); ylabel('Voltage (uV)'); xticks(xmin:200:xmax);
    legend({'Turn','Straight','Diff: T-S'},'Location','best');
    clear ymin ymax
end
clear ii xmax xmin


% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Plot ERPs with error bars
for ii = 1:length(elect_erp) 
% for ii = 1:5 
%     i_elect = elect_erp(ii); %for doing only a selection of electrodes
    i_elect = ii; %selection done when making ERPs
    % get axes limits
    ymin = -10; ymax = 8;
    xmin = -400; xmax = 3500;
    
    figure('Color',[1 1 1]); 
    boundedline(EEG.times,erp_out_byerr(i_elect,:,1),squeeze(std(erp_out_T(:,i_elect,:),[],1))./sqrt(length(exp.participants)),'b',...
            EEG.times,erp_out_byerr(i_elect,:,2),squeeze(std(erp_out_S(:,i_elect,:),[],1))./sqrt(length(exp.participants)),'m');
    hold on
    line([xmin xmax],[0 0],'color','k','LineWidth',1.5) %horizontal line
    line([0 0],[ymin ymax],'color','k','LineWidth',1.5) %vertical line
    line([1876 1876],[ymin ymax],'LineStyle',':','LineWidth',1.5) %vertical line for mask onset
    line([3359 3359],[ymin ymax],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for color wheel onse
    set(gca,'ydir','reverse'); xlim([xmin xmax]); ylim([ymin ymax])
    
    title([el_erp_names{ii} ': ERPs by Response Error']); 
    xlabel('Time (ms)'); ylabel('Voltage (uV)'); 
    xticks(xmin:400:xmax); yticks(ymin:2:ymax)    
        
    legend({'Turn','Straight'},'Location','best');
end
clear ii xmax xmin    






clear erp_out_byerr





















