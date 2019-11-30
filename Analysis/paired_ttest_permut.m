


voxel_pval = 0.05;
mcc_voxel_pval = 0.05; % mcc = multiple comparisons correction
n_permutes = 1000; %number of permutations

n = 35; %number of subjects
num_frex = 51; %number of frequencies

time1 = -400; time2 = 1092; %select time range to test
time_window = find(times>time1,1)-1:find(times>time2,1)-1;
time_plot = times(time_window); %time variable for plotting
nTimepoints = length(time_window); %number of timepoints
% nTimepoints = 300; %number of timepoints

cmap = redblue(64); %create colormap colors

% for ii = 1:length(exp.singletrialselecs)
for ii = 1:5

    i_elect = exp.electrode(ii); %get electrode number

    % Put power data into one variable
    %     subject x frequence x time
%     tmp_eegpwr = cat(1,pwr_out_T_cor{1,i_elect},pwr_out_T_inc{1,i_elect});
    tmp_eegpwr = cat(1,pwr_out_T_cor{1,i_elect}(:,:,time_window),pwr_out_T_inc{1,i_elect}(:,:,time_window));

    % Logical to select data for t-test computation
    real_condition_mapping = [-ones(1,n) ones(1,n)];

    % compute actual paired t-test of difference
    % note. one-sample test of difference is = to paired t-test
    tnum   = squeeze(mean(tmp_eegpwr(real_condition_mapping==-1,:,:),1) - mean(tmp_eegpwr(real_condition_mapping==1,:,:),1));
    tdenom = squeeze(std((tmp_eegpwr(real_condition_mapping==-1,:,:) - tmp_eegpwr(real_condition_mapping==1,:,:)),[],1) ./ sqrt(n));
    real_t = tnum./tdenom;
    clear tnum tdenom

    % initialize null hypothesis matrices
    permuted_tvals  = zeros(n_permutes,num_frex,nTimepoints);
    max_pixel_pvals = zeros(n_permutes,2);
    max_clust_info  = zeros(n_permutes,1);

    % generate pixel-specific null hypothesis parameter distributions
    for permi = 1:n_permutes
    %     fake_condition_mapping = sign(randn(n*2,1));
        fake_condition_mapping = real_condition_mapping(randperm(n*2)); %need equal number of data points in both groups

        % compute t-map of null hypothesis
        tnum   = squeeze(mean(tmp_eegpwr(fake_condition_mapping==-1,:,:),1) - mean(tmp_eegpwr(fake_condition_mapping==1,:,:),1));
        tdenom = squeeze(std((tmp_eegpwr(fake_condition_mapping==-1,:,:) - tmp_eegpwr(fake_condition_mapping==1,:,:)),[],1) ./ sqrt(n));
        tmap   = tnum./tdenom;

        % save all permuted values
        permuted_tvals(permi,:,:) = tmap;

        % save maximum pixel values
        max_pixel_pvals(permi,:) = [ min(tmap(:)) max(tmap(:)) ];
        
        clear tnum tdenom fake_condition_mapping
    end
    clear permi

    % now compute Z-map
    zmap = (real_t-squeeze(mean(permuted_tvals,1)))./squeeze(std(permuted_tvals));
% 
%     figure; colormap(cmap)
%     contourf(time_plot,freqs,zmap,40,'linecolor','none')
%     axis square
%     set(gca,'clim',[-3 3])
%     title(['Unthresholded Z map: ' exp.singtrlelec_name{ii}],'FontSize',14);  
%     set(gca,'Ydir','Normal')
%     line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
% %     line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
% %     line([1925 1925],[min(freqs) max(freqs)],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for end of trial
%     ylim([3 40]); yticks(5:5:40)
% %     xlim([-300 max(times)]); xticks(-300:300:1800)
%     xlim([-400 1092]); xticks(-400:200:1000)
%     ylabel('Freqency (Hz)'); xlabel('Time (ms)');
%     % t = colorbar('peer',gca);
%     % set(get(t,'ylabel'),'String', 'Standardized Power');
% 
% 
%     % apply uncorrected threshold
%     figure; colormap(cmap)
%     contourf(time_plot,freqs,zmap,40,'linecolor','none')
%     zmapthresh = zmap;
%     zmapthresh(abs(zmapthresh)<norminv(1-voxel_pval))=false;
%     zmapthresh=logical(zmapthresh);
%     hold on
%     contour(time_plot,freqs,zmapthresh,1,'linecolor','k')
%     axis square
%     set(gca,'clim',[-3 3])
%     title(['Unthresholded Z map: ' exp.singtrlelec_name{ii}],'FontSize',14);  
%     set(gca,'Ydir','Normal')
%     line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
% %     line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
% %     line([1925 1925],[min(freqs) max(freqs)],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for end of trial
%     ylim([3 40]); yticks(5:5:40)
% %     xlim([-300 max(times)]); xticks(-300:300:1800)
%     xlim([-400 1092]); xticks(-400:200:1000)
%     ylabel('Freqency (Hz)'); xlabel('Time (ms)');
%     % t = colorbar('peer',gca);
%     % set(get(t,'ylabel'),'String', 'Standardized Power');



    % apply pixel-level corrected threshold
    lower_threshold = prctile(max_pixel_pvals(:,1),    mcc_voxel_pval*100/2);
    upper_threshold = prctile(max_pixel_pvals(:,2),100-mcc_voxel_pval*100/2);

    zmapthresh = zmap;
    zmapthresh(zmapthresh>lower_threshold & zmapthresh<upper_threshold)=0;
    
    figure; colormap(cmap)
    contourf(time_plot,freqs,zmapthresh,40,'linecolor','none')
    axis square
    set(gca,'clim',[-3 3])
    title(['Pixel-corrected Z map: ' exp.singtrlelec_name{ii}],'FontSize',14);  
    set(gca,'Ydir','Normal')
    line([0 0],[min(freqs) max(freqs)],'Color','k','LineStyle','--','LineWidth',1.5) %vertical line
%     line([1092 1092],[min(freqs) max(freqs)],'LineStyle',':','LineWidth',1.5) %vertical line for gabor change
%     line([1925 1925],[min(freqs) max(freqs)],'color','r','LineStyle','--','LineWidth',1.5)  %vertical line for end of trial
    ylim([3 40]); yticks(5:5:40)
%     xlim([-300 max(times)]); xticks(-300:300:1800)
    xlim([-400 1092]); xticks(-400:200:1000)
    ylabel('Freqency (Hz)'); xlabel('Time (ms)');
    % t = colorbar('peer',gca);
    % set(get(t,'ylabel'),'String', 'Standardized Power');


    clear tmp_eegpwr lower_threshold upper_threshold zmap zmapthresh tmap permuted_tvals...
        permuted_tvals max_pixel_pvals max_clust_info real_t
end
clear ii n_permutes i_elect t voxel_pval mcc_voxel_pval n time1 time2 time_plot time_window












