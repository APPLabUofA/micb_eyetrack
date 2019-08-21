

ccc
% sub_nums = {'001', '002', '003', '004', '005', '006', '007', '008',...
% 			'009', '010', '011', '012', '013', '014', '015', '016',...
%             '017', '018', '019', '020', '021', '022', '023', '024',...
%             '025', '026', '027', '028'};
sub_nums = {'015', '016',...
            '017', '018', '019', '020', '021', '022', '023', '024',...
            '025', '026', '027', '028'};
			
nsubs = length(sub_nums);

%% Accuracy
figure('Position',[25,25,1000,1000]); 
widthHeight = ceil(sqrt(nsubs));

for i_sub = 1:nsubs 
	current_sub = sub_nums{i_sub};

	%Find output filename
	Filename = dir(['M:\Data\micb_eyetrack\beh\' current_sub '*']);

	% Save data
	load(['M:\Data\micb_eyetrack\beh\' Filename.name]);

	if i_sub == 1 % make output variables here once loaded first file
		turn_group = zeros(nsubs,length(soas));
		control_group = zeros(nsubs,length(soas));
	end

	% Plot results
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
    
    isoa = 0;
    for this_soa = 0
        isoa = isoa + 1;
        temp_turn = out_RT(out_soa == this_soa & responded & turn_trials);
        turn_outRT(isoa) = mean(temp_turn);
        temp_cont = out_RT(out_soa == this_soa & responded & control_trials);
        control_out(isoa) = mean(temp_cont);
        clear temp_turn temp_cont
    end

end

% Plot Grand Average results
figure;
	boundedline(soas, mean(turn_group,1), std(turn_group,[],1) / sqrt(nsubs),'r', ...
		soas, mean(control_group,1), std(control_group,[],1) / sqrt(nsubs),'b');
	legend({'Flexion','Control'});
	xlim([min(soas) max(soas)]); 
	set(gca,'XTick',min(soas):1:max(soas))
% 	xlabel('Gabor Change First < ------ SOA (frames) ------ > Gabor Change After')
	ylabel('Detection Proportion')
	ylim([.01 1.05])
	title('Grand Average')

%% RT
figure('Position',[25,25,1000,1000]); 
widthHeight = ceil(sqrt(nsubs));

for i_sub = 1:nsubs 
	current_sub = sub_nums{i_sub};

	%Find output filename
	Filename = dir(['M:\Data\micb_eyetrack\beh\' current_sub '*']);

	% Save data
	load(['M:\Data\micb_eyetrack\beh\' Filename.name]);

    if i_sub == 1 % make output variables here once loaded first file
		turn_groupRT = zeros(nsubs,length(soas));
		control_groupRT = zeros(nsubs,length(soas));
    end
    
    isoa = 0;
    for this_soa = soas
        isoa = isoa + 1;
        temp_turn = out_RT(out_soa == this_soa & responded & turn_trials & out_accuracy);
        turn_C_outRT(isoa) = mean(temp_turn);
        temp_turnI = out_RT(out_soa == this_soa & responded & turn_trials & out_accuracy==0);
        turn_I_outRT(isoa) = mean(temp_turnI);
        temp_cont = out_RT(out_soa == this_soa & responded & control_trials);
        control_outRT(isoa) = mean(temp_cont);
        clear temp_turn temp_cont temp_turnI
    end
    
    % Plot results
% 	subplot(widthHeight,widthHeight,i_sub); 
% 		plot(soas,turn_outRT,'r',soas,control_outRT,'b'); 
% 			legend({'Flexion','Control'});
% 			xlim([min(soas) max(soas)]); 
% 			set(gca,'XTick',min(soas):1:max(soas))
% 			xlabel('Gabor First < -- SOA (frames) -- > Gabor After')
% 			ylabel('Reaction Time')
% 			ylim([.4 1.8])
% 			title(current_sub)
            
    turn_C_groupRT(i_sub,:) = turn_C_outRT;
    turn_I_groupRT(i_sub,:) = turn_I_outRT;
	control_groupRT(i_sub,:) = control_outRT;
    
    clear turn_C_outRT turn_I_outRT control_outRT

end

% Plot Grand Average results
figure;
	boundedline(soas, mean(turn_groupRT,1), std(turn_groupRT,[],1) / sqrt(nsubs),'r', ...
		soas, mean(control_groupRT,1), std(control_groupRT,[],1) / sqrt(nsubs),'b');
	legend({'Flexion','Control'});
	xlim([min(soas) max(soas)]); 
	set(gca,'XTick',min(soas):1:max(soas))
	xlabel('Gabor Change First < ------ SOA (frames) ------ > Gabor Change After')
	ylabel('Reaction Time')
% 	ylim([.01 1.05])
	title('Grand Average')
    
    
       
%% Accuracy by angle
%out_angle: 270 left, 90 Right, 0 straight 
figure('Position',[25,25,1000,1000]); 
widthHeight = ceil(sqrt(nsubs));
for i_sub = 1:nsubs 
	current_sub = sub_nums{i_sub};

	%Find output filename
	Filename = dir(['M:\Data\micb_eyetrack\beh\' current_sub '*']);

	% Save data
	load(['M:\Data\micb_eyetrack\beh\' Filename.name]);

    if i_sub == 1 % make output variables here once loaded first file
		turn_groupL = zeros(nsubs,length(soas));
        turn_groupR = zeros(nsubs,length(soas));
		control_group = zeros(nsubs,length(soas));
    end
    
    isoa = 0;
    for this_soa = soas
        isoa = isoa + 1;
        temp_turn = out_accuracy(out_soa == this_soa & out_angle == 270 & responded & turn_trials);
        turn_outL(isoa) = sum(temp_turn)/length(temp_turn);
        clear temp_turn
        temp_turn = out_accuracy(out_soa == this_soa & out_angle == 90 & responded & turn_trials);
        turn_outR(isoa) = sum(temp_turn)/length(temp_turn);
        temp_cont = out_accuracy(out_soa == this_soa & responded & control_trials);
        control_out(isoa) = sum(temp_cont)/length(temp_cont);
        clear temp_turn temp_cont
    end

	% Plot results
	subplot(widthHeight,widthHeight,i_sub); 
		plot(soas,turn_outL,'r',soas,turn_outR,'g',soas,control_out,'b'); 
			legend({'FlexionL','FlexionR','Control'});
			xlim([min(soas) max(soas)]); 
			set(gca,'XTick',min(soas):1:max(soas))
			xlabel('Gabor First < -- SOA (frames) -- > Gabor After')
			ylabel('Detection Proportion')
			ylim([.01 1.05])
			title(current_sub)

	turn_groupL(i_sub,:) = turn_outL;
    turn_groupR(i_sub,:) = turn_outR;
	control_group(i_sub,:) = control_out;

end

% Plot Grand Average results
figure;
	boundedline(soas, mean(turn_groupL,1), std(turn_groupL,[],1) / sqrt(nsubs),'r',...
        soas, mean(turn_groupR,1), std(turn_groupR,[],1) / sqrt(nsubs),'g',...
		soas, mean(control_group,1), std(control_group,[],1) / sqrt(nsubs),'b');
	legend({'FlexionL','FlexionR','Control'});
	xlim([min(soas) max(soas)]); 
	set(gca,'XTick',min(soas):1:max(soas))
	xlabel('Gabor Change First < ------ SOA (frames) ------ > Gabor Change After')
	ylabel('Detection Proportion')
	ylim([.01 1.05])
	title('Grand Average')    
    
    
    
    
    
    
    
    


