function [settings] = Myeegc3_smr_selection(dataset, settings)

% function [settings] = eegc3_smr_selection(dataset, settings)
%
% Function performing feature selection on provided runs (up to the best
% 16th features)
%
% Inputs: 
%
% dataset: Struct holding the data and labels. Data and labels are
% separated in runs (dataset.run{i}.data, dataset.run{i}.labels) according 
% to the provided GDF files. The fields of each run are:
%   data: Data matrix samples x (frequencies x channels)
%   labels: Labels vector, samples x 1
%   path: Filepath of the GDF file corresponding to this run
%
% settings: struct of settings for feature selection, preprocessing, 
% classification etc., created by eegc3_smr_newsettings (this structure 
% also holds the settings of a trained classifier)
%
% Outputs: 
%
% settings: The input settings structure enriched with the results of
% feature selection
%

if(settings.modules.smr.options.selection.stability)
    disp('[eegc3_smr_selection] Running feature selection: stability');
    selection = eegc3_smr_select_up_to_best_16(dataset, settings);
    
    % Put into settings structure the result of selection
    settings.bci.smr.channels = selection.Allchannels;
    settings.bci.smr.bands = selection.Allbands;

%     % Plots 
%     eegc3_dpplot(101, selection.Alldpa, [0 15], ...
%         1:settings.acq.channels_eeg, settings.modules.smr.psd.freqs);
%     
%     eegc3_dpplot(102, selection.Alldpm, [0 15], ...
%         1:settings.acq.channels_eeg, settings.modules.smr.psd.freqs);
    
    % Feature selection GUI evoked here
    if(settings.modules.smr.options.selection.usegui)
        [settings Pbnidx Ptot] = ...
            eegc3_select_gui(selection.Pdpa,...
            selection.Alldpa,selection.Alldpm,settings);
    end
    
else
    
    disp('[eegc3_smr_selection] Running feature selection: batch');
    % Concatenate all runs
    adataset.data = [];
    adataset.labels = [];
    
    RunNum = length(dataset.run);
    for r=1:RunNum
    
        adataset.data = [adataset.data; dataset.run{r}.data];
        adataset.labels = [adataset.labels; dataset.run{r}.labels];
        
    end
    
    [selection.Alldpa, selection.Allchannels, selection.Allbands, ...
	selection.Allbandsidx, selection.Alltot, selection.Alldpm,...
	dummy1, dummy2] = ...
		eegc3_smr_select(adataset, settings);

    % Put into settings structure the result of selection
    settings.bci.smr.channels = selection.Allchannels;
    settings.bci.smr.bands = selection.Allbands; 
    
    % Plots 
    eegc3_dpplot(101, selection.Alldpa, [0 15], ...
        1:settings.acq.channels_eeg, settings.modules.smr.psd.freqs, 1);
    
    eegc3_dpplot(102, selection.Alldpm, [0 15], ...
        1:settings.acq.channels_eeg, settings.modules.smr.psd.freqs, 1);
    
end