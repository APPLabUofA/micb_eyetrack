%% ANALYSIS WRAPPER


% ==== TRIGGERS ====
%
% Start eye tracker: 90 (199 starting subj 015)
% End eye tracker: 99
% Break: 2
% 
% -- Turn Trials --
% Trial start (fixation): soas+10 (3,5,7,9,10,11,13,15,17)
% Stimulus change: 
%   Movement & Gabor: soas+21 (14,16,18,20,21,22,24,26,28)
%   Movement:         soas+30 (23,25,27,29,30,31,33,35,37)
%   Gabor:            soas+41 (34,36,38,40,41,42,44,46,48)
% Trial end: soas+90 (83,85,87,89,90,91,93,95,97)
% Response screen: soas+50 (43,45,47,49,50,51,53,55,57)  
% Response:
%   Correct: soas+61 (54,56,58,60,61,62,64,66,68)
%   Incorrect: soas+70 (63,65,67,69,70,71,73,75,77)
%   Timed out: soas+81 (74,76,78,80,81,82,84,86,88)
%
% -- Straight Trials --
% Trial start (fixation): soas+110 (103,105,107,109,110,111,113,115,117)
% Stimulus change: 
%   Movement & Gabor: soas+121 (114,116,118,120,121,122,124,126,128)
%   Movement:         soas+130 (123,125,127,129,130,131,133,135,137)
%   Gabor:            soas+141 (134,136,138,140,141,142,144,146,148)
% Trial end: soas+190 (183,185,187,189,190,191,193,195,197)
% Response screen: soas+150 (143,145,147,149,150,151,153,155,157)  
% Response:
%   Correct: soas+161 (154,156,158,160,161,162,164,166,168)
%   Incorrect: soas+170 (163,165,167,169,170,171,173,175,177)
%   Timed out: soas+181 (174,176,178,180,181,182,184,186,188)
% 
% /////////////////////////////////////////////////////////////////////////
%clear and close everything
ccc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        >>>>> Description of the saved dataset settings <<<<<
% 
% -> byFix_v1: winsize is 256, no ERSP baseline, epoched to targets; 
%    Epoch limit [-1 2.5]. ERP baseline [-200 0]. Filter on [0.1 50]. 
%    Cycles [2 0.8] (2 cycles at lowest freq & 10 at highest). Freq range [2 50]. 
%    Freq increase in steps of 1 Hz. Timesout = 300. Padratio = 4. 
%    Window size is 1115 samples (1115 ms) wide.
% 
% -> byFix_v2: winsize is 256, no ERSP baseline, epoched to targets; 
%    Epoch limit [-1 2.5]. ERP baseline [-200 0]. Filter on [0.1 50]. 
%    Cycles [2 0.8] (2 cycles at lowest freq & 10 at highest). Freq range [2 50]. 
%    Freq increase in steps of 1 Hz. Timesout = 300. Padratio = 4. 
%    Window size is 1115 samples (1115 ms) wide. **Combining straight &
%    turn trials during processing**
% 
% -> byFix_v3: winsize is 256, no ERSP baseline, epoched to targets; 
%    Epoch limit [-1 2.5]. ERP baseline [800 1092]. Filter on [0.1 50]. 
%    Cycles [2 0.8] (2 cycles at lowest freq & 10 at highest). Freq range [2 50]. 
%    Freq increase in steps of 1 Hz. Timesout = 300. Padratio = 4. 
%    Window size is 1115 samples (1115 ms) wide. *Combining straight &
%    turn trials during processing*
% 
% -> byFix_v4: winsize is 256, no ERSP baseline, epoched to targets; 
%    Epoch limit [-1 2.5]. ERP baseline [700 1092]. Filter on [0.1 50]. 
%    Cycles [2 0.8] (2 cycles at lowest freq & 10 at highest). Freq range [2 50]. 
%    Freq increase in steps of 1 Hz. Timesout = 300. Padratio = 4. 
%    Window size is 1115 samples (1115 ms) wide. 
%    *Separate turn events into correct and incorrect*
% 
% -> byFix_v5: no ERSP baseline, epoched to targets; Epoch limit [-1 2.5]. 
%    ERP baseline [700 1092]. Filter on [0.1 50]. Cycles [0] (FFT). Winsize 
%    is 512. Freq range [2 50]. Timesout = 300. Padratio = 4. 
%    *Separate turn events into correct and incorrect*
% 
% 
% 
% -> byGabor_v1: winsize is 1024, no ERSP baseline, epoched to targets; 
%    Epoch limit [-2.5 2.2]. ERP baseline [-1808 -1608]. Filter on [0.1 50]. 
%    Cycles [2 0.8] (2 cycles at lowest freq & 10 at highest). Freq range [2 50]. 
%    Freq increase in steps of 1 Hz. Timesout = 300. Padratio = 4. 
%    Window size is 1115 samples (1115 ms) wide.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
exp.name = 'micb';
exp.conds = ''; %conds is usually used for comparing the same type of trials
                %under different conditions (e.g., stimulation vs sham)
exp.pathname = 'M:\Data\micb_eyetrack\EEG\'; %path of EEG data
exp.settingname = 'byFix_v5'; % name each epoched set

% note: the meaning of set here is to identify the type of analysis done.
%       set is usually used to identify different trial types (e.g., standards
%       vs targets) within the same experimental condition.

% List of participants' ids
%   **subjects 001-004 do not have triggers for direction and gabor change
%   **subjects 005-011 have extra triggers 
%   **subjects 012-014 do not have equal trial lengths
%   **subjects 015 & later have trial length equal across trial type**
%    *do NOT use subject 029 data (age does not meet criteria)*
%    *exclude subject 032 due to large eyeblink artifacts that were not removed by gratton*
%    *exclude subject 039 due to excessive voltage shifts*
% exp.participants = {'033','034'};
exp.participants = {'015','016','017','018','019','020','021','022','023','024','025','026','027','028',...
    '030','031','032','033','034','035','036','037','038','040','041','042','043','044','045','046','047',...
    '048','049','050','051'};
% exp.participants = {'005','006','007','008','009','010','011','012','013','014','015',...
%     '016','017','018','019','020','021','022','023','024','025','026','027','028',...
%     '030','031','032','033','034'};

%% Blink Correction
% the Blink Correction wants dissimilar events (different erps) seperated by 
% commas and similar events (similar erps) seperated with spaces. See 'help gratton_emcp'
% exp.selection_cards = {'11 21','13 23'};
%%%indicates where you want to center your data (where time zero is) 
% exp.selection_cards = {'3 5 7 9 10 11 13 15 17','103 105 107 109 110 111 113 115 117'}; %must be list == length(exp.setname)    
exp.selection_cards = {'1061','1070','110'};  %must be list == length(exp.setname)


%% Artifact rejection. 
% Choose the threshold to reject trials. More lenient threshold followed by an (optional) stricter threshold 
exp.preocularthresh = [-1000 1000]; %First happens before the ocular correction.
% exp.postocularthresh = [ ]; %Second happens after. Leave blank [] to skip
exp.postocularthresh = [-500 500]; %Second happens after. Leave blank [] to skip

%% Events and event labels
%events are what happen within each trial (e.g., fixation, target, response, etc...) 
%%%for each condition (lag 1-4 in this case), numbers correspond to
%%%triggers that will be kept for each condition. All other triggers will
%%%be removed
% exp.events = {[3 5 7 9 10 11 13 15 17];...
%               [103 105 107 109 110 111 113 115 117]};%can be list or matrix (sets x events)
% exp.events = {[31,32,33,34]};%can be list or matrix (sets x events) 
exp.events = {1061;1070;110};%can be list or matrix (sets x events) 
exp.event_names = {'Fix';'Fix';'Fix'}; %must be list or matrix (sets x events)
exp.setname = {'T_C';'T_I';'S'}; %name the rows
exp.suffix = {exp.settingname};

% Each item in the exp.events matrix will become a seperate dataset, including only those epochs referenced by the events in that item. 
%e.g. 3 rows x 4 columns == 12 datasets/participant

%% Electrode location
%Where are your electrodes? (.ced file)
exp.electrode_locs = 'M:\Experiments\micb_eyetrack\Analysis\EOG_18_electrode_micb.ced';
% electrode information
exp.electrode = [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18];
exp.elec_names = {'Oz';'Pz';'Cz';'FCz';'Fz';'O1';'O2';'P3';'P4';'P7';'P8';'CP1';'CP2';'C5';'C6';'F3';'F4'};

%% Re-referencing the data
exp.refelec = 1; %which electrode do you want to re-reference to?
exp.brainelecs = [2:18]; %list of every electrode collecting brain data (exclude mastoid reference, EOGs, HR, EMG, etc.

%% Filter the data?
exp.filter = 'on'; %filter all files
exp.hicutoff = 50; %higher edge of the frequency pass band (Hz)
exp.locutoff = 0.1; %lower edge of the frequency pass band (Hz)

%% FFT/Wavelet settings
% How long is your window going to be? (Longer window == BETTER frequency 
% resolution & WORSE time resolution)
exp.winsize = 512; %use numbers that are 2^x, e.g. 2^10 == 1024ms

% Baseline will be subtracted from the power variable. It is relative to 
% your window size. Can use just NaN for no baseline
%e.g., [-200 0] will use [-200-exp.winsize/2 0-exp.winsize/2]; 
exp.erspbaseline = NaN;
% exp.erspbaseline = [-400 -200];

% Instead of choosing a windowsize, you can choose a number of cycles per 
% frequency for standard wavelet analysis: usually [3] for better temporal
% precision or [6] for better frequency precision.
% If [wavecycles factor], wavelet cycles increase with frequency beginning 
% at wavecyles. See "help popnewtimef"
exp.cycles = [0]; %leave it at 0 to use FFT
% exp.cycles = [2 0.8]; %number of cycles 

% Choose number of output times
exp.timesout = 300; %200 is usually used

% Set sampling factor for frequencies. 
% when exp.cycles==0, frequency spacing is (low_freq/padratio). For wavelet,
% multiplies the # of output freqs by dividing their spacing (2 is default).
% higher values give smooth looking plot but at computational cost (16 is
% very high)
exp.padratio = 4;

% What frequencies to consider?
% exp.freqrange = [1:40]; 
exp.freqrange = [exp.cycles(1):50]; %when doing wavelet

%% Epoching the data
exp.epoch = 'on'; %on to epoch data; off to load previous data
%%%indicates where you want to center your data (where time zero is)
% exp.epochs = {'3','5','7','9','10','11','13','15','17',...
%     '103','105','107','109','110','111','113','115','117'}; %must be list == length(exp.setname)
exp.epochs = {'1061','1070','110'}; %must be list == length(exp.setname)
exp.epochs_name = {};
exp.epochslims = [-1 2.5]; %in seconds; epoched trigger is 0 e.g. [-1 2]
exp.epochbaseline = [700 1092]; %remove the baseline for each epoched set, in ms. e.g. [-200 0] 


%% Time-Frequency settings
%Do you want to run time-frequency analyses? (on/off)
exp.tf = 'on';
%Do you want to use all the electrodes or just a few? Leave blank [] for 
% all (will use same as exp.brainelecs)
exp.tfelecs = [];

%Do you want to save the single-trial data? (on/off) (Memory intensive!!!)
exp.singletrials = 'on';
%Saving the single trial data is memory intensive. Just use the electrodes
% you need. 
exp.singletrialselecs = [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18];
exp.singtrlelec_name = {'Oz';'Pz';'Cz';'FCz';'Fz';'O1';'O2';'P3';'P4';'P7';'P8';'CP1';'CP2';'C5';'C6';'F3';'F4'};


%//////////////////////////////////////////////////////////////////////////
%% Save your pipeline settings
% The settings will be saved as a new folder. It lets you save multiple datasets with different preprocessing parameters.
% Saving will help you remember what settings were used in each dataset
save([exp.settingname '_Settings'],'exp') %save these settings as a .mat file. 
%//////////////////////////////////////////////////////////////////////////


%% Run preprocessing code
tic %start timer
Preprocessing_micb(exp)
toc %end timer

%run analysis
% exp.electrode = 3
% Analysis_Att_Ent(exp)
%
