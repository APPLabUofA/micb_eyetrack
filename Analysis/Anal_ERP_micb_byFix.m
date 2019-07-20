


% /////////////////////////////////////////////////////////////////////////
% /////////////////////////////////////////////////////////////////////////

% List of electrodes to make ERPs
elect_erp = [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18];
el_erp_names = {'Oz';'Pz';'Cz';'FCz';'Fz';'O1';'O2';'P3';'P4';'P7';'P8';'CP1';'CP2';'C5';'C6';'F3';'F4'};


% List electrodes to get ERP topograph plots (need all of them) 
elect_top = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];
el_top_names = {'M2';'Oz';'Pz';'Cz';'FCz';'Fz';'O1';'O2';'P3';'P4';'P7';'P8';...
    'CP1';'CP2';'C5';'C6';'F3';'F4';'VEOG';'HEOG'};

% /////////////////////////////////////////////////////////////////////////
% /////////////////////////////////////////////////////////////////////////

% Remove trials from the behavioral data that were rejected during EEG
% processing
[out_soa,out_responded,out_angle] = rej_beh_trials(exp,ALLEEG);


% /////////////////////////////////////////////////////////////////////////
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%%                  ERPs by Errors - Mean
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
% /////////////////////////////////////////////////////////////////////////

errlims = cell(1,length(exp.participants));    %pre-allocate
errs_x = cell(1,length(exp.participants));    %pre-allocate
errs_n = cell(1,length(exp.participants));    %pre-allocate
% create separate ERPs for large and small errors
for i_part = 1:length(exp.participants) % --------------------------------- 
    
    % Calculate ERP
    for ii = 1:length(elect_erp)
        i_elect = elect_erp(ii); %for doing only a selection of electrodes
        
        % Get trials with small errors
        erp_out_x(i_part,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,...
            [find((resp_errdeg{i_part}<(errlims{i_part}(2)*0.75) & resp_errdeg{i_part}>(errlims{i_part}(1)*0.75)))] ),3));
        %save small errors
        errs_x{i_part} = resp_errdeg{i_part}(resp_errdeg{i_part}<(errlims{i_part}(2)*0.75) & resp_errdeg{i_part}>(errlims{i_part}(1)*0.75));
        
        % Get trials with large errors
        erp_out_n(i_part,ii,:) = squeeze(mean(ALLEEG(i_part).data(i_elect,:,...
            [find(resp_errdeg{i_part}>=(errlims{i_part}(2)*1.5)) find(resp_errdeg{i_part}<=(errlims{i_part}(1)*1.5))] ),3));
        %save large errors
        errs_n{i_part} = resp_errdeg{i_part}([find(resp_errdeg{i_part}>=(errlims{i_part}(2)*1.5)) find(resp_errdeg{i_part}<=(errlims{i_part}(1)*1.5))]);
    end
    clear ii i_elect
end
clear i_part

% /////////////////////////////////////////////////////////////////////////






























