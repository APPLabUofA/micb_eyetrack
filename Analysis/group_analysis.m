
ccc
% sub_nums = {'001', '002', '003', '004', '005', '006', '007', '008',...
% 			'009', '010', '011', '012', '013', '014', '015', '016',...
%             '017', '018', '019', '020', '021', '022', '023', '024',...
%             '025', '026', '027', '028'};

sub_nums = exp.participants;

nsubs = length(sub_nums);

figure('Position',[25,25,1000,1000]); 
widthHeight = ceil(sqrt(nsubs));



for i_sub = 1:nsubs 
	current_sub = sub_nums{i_sub};

	%Find output filename
	Filename = dir(['M:\Data\micb_eyetrack\beh\' current_sub '*']);

	%% Save data
	load(['M:\Data\micb_eyetrack\beh\' Filename.name]);

	if i_sub == 1 % make output variables here once loaded first file
		turn_group = zeros(nsubs,1);
		control_group = zeros(nsubs,1);
	end

	%% Plot results
% 	subplot(widthHeight,widthHeight,i_sub); 
% 		plot(soas,turn_out,'r',soas,control_out,'b'); 
% 			legend({'Flexion','Control'});
% 			xlim([min(soas) max(soas)]); 
% 			set(gca,'XTick',min(soas):1:max(soas))
% 			xlabel('Gabor First < -- SOA (frames) -- > Gabor After')
% 			ylabel('Detection Proportion')
% 			ylim([.01 1.05])
% 			title(current_sub)

	turn_group(i_sub,:) = turn_out;
	control_group(i_sub,:) = control_out;

end


%% Plot Grand Average results
figure;
	boundedline(soas, mean(turn_group,1), std(turn_group,[],1) / sqrt(nsubs),'r', ...
		soas, mean(control_group,1), std(control_group,[],1) / sqrt(nsubs),'b');
	legend({'Flexion','Control'});
	xlim([min(soas) max(soas)]); 
	set(gca,'XTick',min(soas):1:max(soas))
	xlabel('Gabor Change First < ------ SOA (frames) ------ > Gabor Change After')
	ylabel('Detection Proportion')
	ylim([.01 1.05])
	title('Grand Average')
    
    
bar_vals = [mean(turn_group,1) mean(control_group,1)];
bar_errs = [std(turn_group,[],1) / sqrt(nsubs) ...
            std(control_group,[],1) / sqrt(nsubs)];        
% Bar graph
figure; barweb(bar_vals, bar_errs); 
ylabel('Proportion Correct'); 
% ylim([0 1.2]);
% ylim([-0.1 0.3]);
% ylim([-1 0]);
legend('Flexion','Control');
    
    

bar_vals = [mean(turn_C_groupRT,1) mean(turn_I_groupRT,1) mean(control_groupRT,1)];
bar_errs = [std(turn_C_groupRT,[],1) / sqrt(nsubs)...
            std(turn_I_groupRT,[],1) / sqrt(nsubs)...
            std(control_groupRT,[],1) / sqrt(nsubs)];        
% Bar graph
figure; barweb(bar_vals, bar_errs); 
ylabel('Reaction Time'); 
% ylim([0 1.2]);
% ylim([-0.1 0.3]);
% ylim([-1 0]);
legend('Flexion-Correct','Flexion-Incorrect','Control');
    
    
    