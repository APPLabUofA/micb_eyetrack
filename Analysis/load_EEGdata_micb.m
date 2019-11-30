% function [varout] = load_EEGdata_micb()


ccc %clear variables & close windows

% -------------------------------------------------------------------------
% Load processing settings
load('byFix_v5_Settings.mat');  %#ok<*LOAD>

% -------------------------------------------------------------------------
anal.tf = 'off'; % if loading TF data
anal.singletrials = 'on'; % if loading single trial data
anal.segments = 'on'; % if loading epochs
anal.tfelecs = exp.brainelecs; %#ok<*NODEF> %electrodes
anal.singletrialselecs = exp.singletrialselecs; %single trial electrodes
% -------------------------------------------------------------------------

nparts = length(exp.participants); %number of subjects
nsets = length(exp.setname);

% -------------------------------------------------------------------------
% Loading data on laptop
% exp.pathname = 'C:\Users\ssshe\Documents\MathLab\micb_eyetrack\Data\EEG\';
% exp.electrode_locs = 'C:\Users\ssshe\Documents\MathLab\micb_eyetrack\Experiments\Analysis\EOG_18_electrode_micb.ced';

% -------------------------------------------------------------------------

% Replicating event names when exp.events is a matrix
if any(size(exp.event_names) ~= size(exp.events))
    repfactor = int8(size(exp.events)./size(exp.event_names));
    exp.event_names = repmat(exp.event_names, repfactor);
end

% -------------------------------------------------------------------------
% start eeglab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
% -------------------------------------------------------------------------



% #########################################################################
% #########################################################################
%% Load the data
% The main loop loops through sets, then participants, then events.
for i_set = 1:nsets
    exp.setname(i_set)
    tic
    
    for i_part = 1:nparts
        sprintf(['Loading Participant ' num2str(exp.participants{i_part}) '...' ])
        
        % number of events of interest
        nevents = length(exp.events(i_set,:));
        
        part_name = exp.participants{i_part}; %participant id
        
        for i_event = 1:nevents
            
            filename = [part_name '_' exp.event_names{i_set,i_event} '_' exp.setname{i_set}];
            
            % --------------------------------------------------------------------------------------------------------------------
            % Load the Time frequency data, if needed.
            if strcmpi('on',anal.tf) == 1 % only load these variables if we are loading time-frequency data
                
               if exp.cycles(1) > 0 %for wavelet     
                    %The variable ersp will be a 6D variable: (participants x sets x events x electrodes x frequencies x timepoints).
                    ersp(i_part,i_set,i_event,:,:,:) = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'Wav_' filename '.mat'],'ersp'));
                    itc(i_part,i_set,i_event,:,:,:) = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'Wav_' filename '.mat'],'itc'));
                    if i_part == 1 && i_set == 1 && i_event == 1 %load time and freq data
                        times = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'Wav_' filename '.mat'],'times'));
                        freqs = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'Wav_' filename '.mat'],'freqs'));
                    end
                    
               else %for FFT
                    %The variable ersp will be a 6D variable: (participants x sets x events x electrodes x frequencies x timepoints).
                    ersp(i_part,i_set,i_event,:,:,:) = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'TF_' filename '.mat'],'ersp'));
                    itc(i_part,i_set,i_event,:,:,:) = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'TF_' filename '.mat'],'itc'));
                    if i_part == 1 && i_set == 1 && i_event == 1 %load time and freq data
                        times = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'TF_' filename '.mat'],'times'));
                        freqs = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'TF_' filename '.mat'],'freqs'));
                    end
                    
               end

            end
            % --------------------------------------------------------------------------------------------------------------------
    
            % --------------------------------------------------------------------------------------------------------------------
            % Load the EEGLAB datasets, if needed.
            if strcmpi('on',anal.segments) == 1 || strcmp('on',anal.singletrials) == 1 % only load these variables if we are loading either ERP or single trial data
                try
                    EEG = pop_loadset('filename',[filename '.set'],'filepath',[exp.pathname  '\' exp.suffix{1} '\' exp.setname{i_set} '\Segments\']);
                    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
                catch
                    WaitSecs(.5)
                    EEG = pop_loadset('filename',[filename '.set'],'filepath',[exp.pathname  '\' exp.suffix{1} '\' exp.setname{i_set} '\Segments\']);
                    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
                end
            elseif strcmpi('on',anal.tf) == 1 || strcmpi('on',anal.singletrials) == 1 %if we are loading time-frequency data only, then we just need one of these.
                if i_part == 1 && i_set == 1 && i_event == 1
                    EEG = pop_loadset('filename',[filename '.set'],'filepath',[exp.pathname  '\' exp.suffix{1} '\' exp.setname{i_set} '\Segments\']);
                    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
                end
            end
            % --------------------------------------------------------------------------------------------------------------------
            
            % --------------------------------------------------------------------------------------------------------------------
            % Load the Single Trial complex values, if needed
            if strcmpi('on',anal.singletrials) == 1 % only load these variables if we are loading single trial data
                
%                 ntrigs = length(exp.events{i_set});
                
                % Loads the time values and freqs
                if exp.cycles(1) > 0 %for wavelet
                    if i_part == 1 && i_set == 1 && i_event == 1
                        times = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'Wav_' filename '.mat'],'times'));
                        freqs = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'Wav_' filename '.mat'],'freqs'));
                    end
                else %for FFT
                    if i_part == 1 && i_set == 1 && i_event == 1
                        times = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'TF_' filename '.mat'],'times'));
                        freqs = struct2array(load([exp.pathname '\' exp.suffix{1} '\' exp.setname{i_set} '\TimeFrequency\' 'TF_' filename '.mat'],'freqs'));
                    end
                end
                

                % Load single trial data for each electrode
                for ii = 1:length(exp.singletrialselecs)
                    i_chan = exp.singletrialselecs(ii);
                    
                    if exp.cycles(1) > 0 %for wavelet
                        % all_ersp is (participant x electrode x set).trials(freq x time x trial)
                         try %Unfortunately, this load procedure can break sometimes in a non-reproducible way. So if an error happens here, we wait half a second and try again.
                            channeldata = load([exp.pathname exp.suffix{1} '\' exp.setname{i_set} '\SingleTrials\' part_name '\' EEG.chanlocs(i_chan).labels '_SingleTrials_' exp.event_names{i_set,i_event} '_' exp.setname{i_set} '_Wav.mat'],'elec_all_ersp');
                            all_ersp(i_part,i_chan,i_set) = struct2cell(channeldata);
                        catch
                            WaitSecs(.5)
                            channeldata = load([exp.pathname exp.suffix{1} '\' exp.setname{i_set} '\SingleTrials\' part_name '\' EEG.chanlocs(i_chan).labels '_SingleTrials_' exp.event_names{i_set,i_event} '_' exp.setname{i_set} '_Wav.mat'],'elec_all_ersp');
                            all_ersp(i_part,i_chan,i_set) = struct2cell(channeldata);
                         end
                     
                    else %for FFT
                         % all_ersp is (participant x electrode x set).trials(freq x time x trial)
                        try %Unfortunately, this load procedure can break sometimes in a non-reproducible way. So if an error happens here, we wait half a second and try again.
                            channeldata = load([exp.pathname exp.suffix{1} '\' exp.setname{i_set} '\SingleTrials\' part_name '\' EEG.chanlocs(i_chan).labels '_SingleTrials_' exp.event_names{i_set,i_event} '_' exp.setname{i_set} '.mat'],'elec_all_ersp');
                            all_ersp(i_part,i_chan,i_set) = struct2cell(channeldata);
                        catch
                            WaitSecs(.5)
                            channeldata = load([exp.pathname exp.suffix{1} '\' exp.setname{i_set} '\SingleTrials\' part_name '\' EEG.chanlocs(i_chan).labels '_SingleTrials_' exp.event_names{i_set,i_event} '_' exp.setname{i_set} '.mat'],'elec_all_ersp');
                            all_ersp(i_part,i_chan,i_set) = struct2cell(channeldata);
                        end
                    end
                    clear channeldata
                    
                 end
            % --------------------------------------------------------------------------------------------------------------------
            end
        end
    end
    toc
end
clear i_chan i_event i_set i_part filename nevents nparts nsets ii part_name

eeglab redraw


% -------------------------------------------------------------------------
% Variables for output by function
% varout{1} = times;
% varout{2} = freqs;
% varout{3} = exp;
% varout{4} = ALLEEG;
% varout{5} = EEG;
% 
% % if loading TF data
% if strcmpi('on',anal.tf) == 1
%     varout{6} = ersp;
%     varout{7} = itc;
% end
% 
% % if loading single trial data
% if strcmpi('on',anal.singletrials) == 1 
%     varout{8} = all_ersp;
% end

% -------------------------------------------------------------------------






% #########################################################################
% #########################################################################



