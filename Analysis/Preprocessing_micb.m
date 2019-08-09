function Preprocessing_micb(exp)

try
%     if parpool('poolsize') == 0
%         parpool OPEN 3;
%         parpool(3)
%     end
    
    nparts = length(exp.participants);
    nsets = length(exp.setname);
    
    % Replicating event names when exp.events is a matrix
    if any(size(exp.event_names) ~= size(exp.events))
        repfactor = int8(size(exp.events)./size(exp.event_names));
        exp.event_names = repmat(exp.event_names, repfactor);
    end

    % Replicating event triggers when exp.events is a matrix
    if isempty(exp.epochs) == 1
        exp.epochs = exp.events;
%         exp.epochs = cellstr(num2str(cell2mat(reshape(exp.events,1,size(exp.events,2)*size(exp.events,1)) )'))';
    elseif isempty(exp.events) == 1
        exp.events = exp.epochs;
    end

    % Is epoch names not specified, use event names
    if isempty(exp.epochs_name) == 1
        exp.epochs_name = exp.event_names;
    else
        exp.event_names = exp.epochs_name;
    end
    
    
    for i_set = 1:nsets
        
        sprintf(exp.setname{i_set})
        
        % if folder doesn't exist yet, create one
        if ~exist([exp.pathname  '\' exp.suffix{1} '\' exp.setname{i_set} '\Segments\'])
            mkdir([exp.pathname  '\' exp.suffix{1} '\' exp.setname{i_set} '\Segments\']);
        end
        
        %initialize EEGLAB
        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
        %subject numbers to analyze
        
        nevents = length(exp.events(i_set,:));
        
        %% Load data and channel locations
        for i_part = 23:nparts
            
            part_name = exp.participants{i_part}; %this is cuz subject ids are in the form 'subj1' rather than '001' in orientation wheel
            
            if strcmp('on',exp.epoch) == 1
                
                sprintf(['Participant ' num2str(exp.participants{i_part})])
                
                %% Load a data file
                EEG = pop_loadbv(exp.pathname, [part_name '_noSOA.vhdr']); 
                
                %% Load channel information
                EEG = pop_chanedit(EEG, 'load',{exp.electrode_locs 'filetype' 'autodetect'});
               
                %% Arithmetically re-reference to linked mastoid (M1 + M2)/2
                % only for brain electrodes (exclude mastoids & EOGs)
                for ii = exp.brainelecs(1):length(exp.brainelecs)
                    EEG.data(ii,:) = (EEG.data(ii,:)-((EEG.data(exp.refelec,:))*.5));
                end
                clear ii
                
                %% Filter the data
                if strcmpi(exp.filter,'on')
%                    EEG = pop_eegfilt( EEG, 0, 30, [], 0); %with low pass of 30
                   EEG = pop_eegfiltnew(EEG, exp.locutoff, exp.hicutoff); % filter function
                end
                
                %% Change markers so they can be used by the gratton_emcp script
                allevents = length(EEG.event);
                for i_event = 2:allevents %skip the first
                    EEG.event(i_event).type = num2str(str2num(EEG.event(i_event).type(2:end)));
                end

                %% The triggers are early
                [EEG] = VpixxEarlyTriggerFix(EEG);
                
                %% Extract epochs of data time locked to event
                %Extract data time locked to targets and remove all other events
                EEG = pop_epoch(EEG, exp.epochs, exp.epochslims, 'newname', [part_name '_epochs'], 'epochinfo', 'yes');
                %subtract baseline
                EEG = pop_rmbase(EEG, exp.epochbaseline);
  
                %% Get behavior data and add to EEG structure
                [out_soa,responded,out_angle,accuracy,direction,incorrect_gabor,out_RT,turn_trials,eventtrack] =...
                    getBEHdata_micb(part_name);
            
                % add behavioral data to epoch structure
                EEG.beh.out_soa = out_soa;
                EEG.beh.responded = responded;
                EEG.beh.out_angle = out_angle;
                EEG.beh.accuracy = accuracy;
                EEG.beh.direction = direction;
                EEG.beh.incor_gabor = incorrect_gabor;
                EEG.beh.out_RT = out_RT;
                EEG.beh.turn_trials = turn_trials;
                EEG.beh.eventtrack = eventtrack;
                
                clear out_soa responded out_angle accuracy direction incorrect_gabor...
                    out_RT turn_trials eventtrack
                
                
                %% Reject practice trials from data
                rej_practice = zeros(1,length(EEG.epoch));
                if strcmpi(part_name,'006') %1 less practice trial recorded
                    rej_practice(1,1:21) = 1; %mark the first 21 trials for removal
                else
                    rej_practice(1,1:22) = 1; %mark the first 22 trials for removal
                end
                EEG = pop_rejepoch(EEG, rej_practice, 0);
                clear rej_practice
                

% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                %% Artifact Rejection, EMCP Correction, then 2nd Rejection
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  

                % :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                % Artifact rejection 1, trials with range >exp.preocularthresh uV
                if isempty(exp.preocularthresh) == 0
                    rejtrial = struct([]);
                    [EEG Indexes] = pop_eegthresh(EEG,1,[1:size(EEG.data,1)],exp.preocularthresh(1),exp.preocularthresh(2),EEG.xmin,EEG.xmax,0,1);
                    rejtrial(i_set, 1).ids = find(EEG.reject.rejthresh==1);
                end
                % :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                
                % :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                % EMCP occular correction
                temp_ocular = EEG.data(end-1:end,:,:); %to save the EYE data for after
                EEG = gratton_emcp(EEG, exp.selection_cards, {'VEOG'},{'HEOG'}); %this assumes the eye channels are called this
                EEG.emcp.table %this prints out the regression coefficients
                EEG.data(end-1:end,:,:) = temp_ocular; %replace the eye data
                % :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                
                % :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                % Baseline again since EMCP changed it
                EEG = pop_rmbase(EEG,exp.epochbaseline);
                % :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                
                % :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                % Artifact rejection 2, trials with range >exp.postocularthresh uV
                if isempty(exp.postocularthresh) == 0
                    [EEG Indexes] = pop_eegthresh(EEG,1,[1:size(EEG.data,1)-2],exp.postocularthresh(1),exp.postocularthresh(2),EEG.xmin,EEG.xmax,0,1);
                    rejtrial(i_set,2).ids = find(EEG.reject.rejthresh==1);
                end
                % :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 
                
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
% ````````````````````````````````````````````````````````````````````````````````````````````  
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
                %% Additional rejection of trials (reviewed visually) 
                if (strcmpi(part_name,'016') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(83)=1;
                    EEG.reject.rejthresh(144)=1;
                    EEG.reject.rejthresh(174:175)=1;
                    EEG.reject.rejthresh(199)=1;
                    EEG.reject.rejthresh(221)=1;
                    EEG.reject.rejthresh(283)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                    
                elseif (strcmpi(part_name,'017') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(112)=1;
                    EEG.reject.rejthresh(116)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                    
                elseif (strcmpi(part_name,'018') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(187)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);  
                    
                elseif (strcmpi(part_name,'019') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(41)=1;
                    EEG.reject.rejthresh(117:118)=1;
                    EEG.reject.rejthresh(135:136)=1;
                    EEG.reject.rejthresh(155)=1;
                    EEG.reject.rejthresh(200:201)=1;
                    EEG.reject.rejthresh(206:207)=1;
                    EEG.reject.rejthresh(241)=1;
                    EEG.reject.rejthresh(256)=1;
                    EEG.reject.rejthresh(262)=1;
                    EEG.reject.rejthresh(270)=1;
                    EEG.reject.rejthresh(279:280)=1;
                    EEG.reject.rejthresh(283)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                    
                elseif (strcmpi(part_name,'020') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(49)=1;
                    EEG.reject.rejthresh(141)=1;
                    EEG.reject.rejthresh(143)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);    
                    
                elseif (strcmpi(part_name,'021') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(254)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                    
                elseif (strcmpi(part_name,'022') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(127)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                
                elseif (strcmpi(part_name,'023') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(47:48)=1;
                    EEG.reject.rejthresh(52)=1;
                    EEG.reject.rejthresh(85)=1;
                    EEG.reject.rejthresh(131:132)=1;
                    EEG.reject.rejthresh(143)=1;
                    EEG.reject.rejthresh(151)=1;
                    EEG.reject.rejthresh(172)=1;
                    EEG.reject.rejthresh(187)=1;
                    EEG.reject.rejthresh(234)=1;
                    EEG.reject.rejthresh(245:246)=1;
                    EEG.reject.rejthresh(266)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                    
                elseif (strcmpi(part_name,'024') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(114)=1;
                    EEG.reject.rejthresh(231)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                
                elseif (strcmpi(part_name,'026') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(69)=1;
                    EEG.reject.rejthresh(102)=1;
                    EEG.reject.rejthresh(242)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);    
                
                elseif (strcmpi(part_name,'027') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(54:55)=1;
                    EEG.reject.rejthresh(138:139)=1;
                    EEG.reject.rejthresh(242)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);    
                    
                elseif (strcmpi(part_name,'028') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(30)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                
                elseif (strcmpi(part_name,'032') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(5)=1;
                    EEG.reject.rejthresh(33)=1;
                    EEG.reject.rejthresh(41)=1;
                    EEG.reject.rejthresh(47)=1;
                    EEG.reject.rejthresh(59)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                
                elseif (strcmpi(part_name,'033') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(13)=1;
                    EEG.reject.rejthresh(25)=1;
                    EEG.reject.rejthresh(33)=1;
                    EEG.reject.rejthresh(70)=1;
                    EEG.reject.rejthresh(85)=1;
                    EEG.reject.rejthresh(137)=1;
                    EEG.reject.rejthresh(165)=1;
                    EEG.reject.rejthresh(186)=1;
                    EEG.reject.rejthresh(238)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                
                elseif (strcmpi(part_name,'034') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(30)=1;
                    EEG.reject.rejthresh(37)=1;
                    EEG.reject.rejthresh(77)=1;
                    EEG.reject.rejthresh(97)=1;
                    EEG.reject.rejthresh(103)=1;
                    EEG.reject.rejthresh(110)=1;
                    EEG.reject.rejthresh(114:115)=1;
                    EEG.reject.rejthresh(117:118)=1;
                    EEG.reject.rejthresh(143)=1;
                    EEG.reject.rejthresh(160)=1;
                    EEG.reject.rejthresh(178:179)=1;
                    EEG.reject.rejthresh(189:190)=1;
                    EEG.reject.rejthresh(233)=1;
                    EEG.reject.rejthresh(241)=1;
                    EEG.reject.rejthresh(263)=1;
                    EEG.reject.rejthresh(275)=1;
                    EEG.reject.rejthresh(277:278)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                
                elseif (strcmpi(part_name,'035') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(1)=1;
                    EEG.reject.rejthresh(95)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                
                elseif (strcmpi(part_name,'036') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(14)=1;
                    EEG.reject.rejthresh(46)=1;
                    EEG.reject.rejthresh(76)=1;
                    EEG.reject.rejthresh(87)=1;
                    EEG.reject.rejthresh(187)=1;
                    EEG.reject.rejthresh(285)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                
                elseif (strcmpi(part_name,'037') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(50)=1;
                    EEG.reject.rejthresh(57)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
                
                elseif (strcmpi(part_name,'038') && strcmpi(exp.settingname,'byFix_v3'))%only when using this specific settings 
                    EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
                    EEG.reject.rejthresh(65)=1;
                    EEG.reject.rejthresh(270)=1;
                    EEG.reject.rejthresh(281)=1;
                    rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
                    EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);  
                
                end
                
% ````````````````````````````````````````````````````````````````````````````````````````````

                % :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                % save rejected trials
                EEG.rejtrial = rejtrial;
                % :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                
                % :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                %replace the stored data with this new set
                tempEEG = EEG;               
                
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
% ````````````````````````````````````````````````````````````````````````````````````````````  
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 
                %% Select individual events
                for i_event = 1:nevents
                    EEG = pop_selectevent( tempEEG, 'type', exp.events{i_set,i_event}, 'deleteevents','on','deleteepochs','on','invertepochs','off');
                    EEG = pop_editset(EEG, 'setname', [part_name '_' exp.event_names{i_set,i_event} '_' exp.setname{i_set}] );
                    EEG = pop_editset(EEG, 'condition', exp.setname{i_set} );
                    EEG = pop_saveset( EEG, 'filename',[part_name '_' exp.event_names{i_set,i_event} '_' exp.setname{i_set} '.set'],'filepath',[exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\Segments\']);
                end
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::                 
            end %create epoch loop end
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
            %% Time-Frequency Data
            if strcmp('on',exp.tf) == 1 || strcmp('on',exp.singletrials) == 1
                
                if ~exist([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\'])
                    mkdir([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\']);
                end

                
                for i_event = 1:nevents
                    
                    if strcmp('on',exp.epoch) == 0 %loading previous epochs if not created this session
                        filename = [part_name '_' exp.event_names{i_set,i_event} '_' exp.setname{i_set}];
                        EEG = pop_loadset('filename',[filename '.set'],'filepath',[exp.pathname  '\' exp.suffix{1} '\' exp.setname{i_set} '\Segments\']);
                    end
                    
                    if isempty(exp.tfelecs) %if TF electrodes not specified, same as exp.brainelecs
                       exp.tfelecs = exp.brainelecs; 
                    end
                    
                    for i_tf = 1:length(exp.tfelecs)
                        i_chan = exp.tfelecs(i_tf);
                        EEG = eeg_checkset(EEG);
                        [ersp(i_chan,:,:),itc(i_chan,:,:),powbase,times,freqs,dum1,dum2,all_ersp(i_chan).trials] =...
                            pop_newtimef(EEG, 1, i_chan, exp.epochslims*1000, exp.cycles, ...
                            'topovec', i_chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo,...
                            'baseline', exp.erspbaseline, 'freqs', exp.freqrange, 'freqscale', 'linear', ...
                            'padratio', exp.padratio, 'plotphase','off','plotitc','off','plotersp','off',...
                            'winsize',exp.winsize,'timesout',exp.timesout);
                    end
                    clear i_chan i_tf

                    if strcmp('on',exp.tf) == 1 %if TF was done already, do not save
                        if exp.cycles(1) > 0 %for wavelet
                            save([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\Wav_' part_name '_' exp.event_names{i_set,i_event} '_' exp.setname{i_set} '.mat'],'ersp','itc','times','freqs','powbase','exp')
                        else %for FFT
                            save([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\TF_' part_name '_' exp.event_names{i_set,i_event} '_' exp.setname{i_set} '.mat'],'ersp','itc','times','freqs','powbase','exp')
                        end
                    end
                        
                    
                     % Save single trial data
                    if strcmp('on',exp.singletrials) == 1
                        
                        % Create folder for single trial data
                        if ~exist([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\SingleTrials\' part_name '\'],'dir')
                            mkdir([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\SingleTrials\' part_name '\']);
                        end
                        
                        % File path name
                        Filepath_Trials = [exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\SingleTrials\' part_name '\'];
                        
                        % Save single trial data from the selected electrodes
                        for zzz = 1:length(exp.singletrialselecs)
                            i_chan = exp.singletrialselecs(zzz);
                            elec_all_ersp = all_ersp(i_chan).trials;
                            if exp.cycles(1) > 0 %for wavelet
                                save([Filepath_Trials exp.singtrlelec_name{zzz} '_SingleTrials_' exp.event_names{i_set,i_event} '_' exp.setname{i_set} '_Wav.mat'],...
                                'elec_all_ersp','times','freqs','powbase','exp')
                            else %for FFT
                                save([Filepath_Trials exp.singtrlelec_name{zzz} '_SingleTrials_' exp.event_names{i_set,i_event} '_' exp.setname{i_set} '.mat'],...
                                'elec_all_ersp','times','freqs','powbase','exp')
                            end
                        end
                        clear i_chan elec_all_ersp zzz
                    end
                    clear Filepath_Trials

                end
                eeglab redraw
                
            end
            clear part_name
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::             
        end %i_part loop end
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::         
    end %i_set loop end
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 

    
% !!!!!!!!!!!!!!!!    
catch ME % !!!!!!!
    save('dump') 
    throw(ME)
end % !!!!!!!!!!!!
% !!!!!!!!!!!!!!!! 


% ####################
end % end function ###
% ####################
