function [bci, data, taskset, resetevents, doplot, protocol_label] = Myeegc3_smr_simloop_fast_Half_1(filexdf, filetxt, filemat, ... 
	rejection, integration, doplot, resetevents, recompute)
% 
% 2012 Simis for compatibility with eegc3_smr_train
% 2010 Michele Tavella <michele.tavella@epfl.ch>
% 
% IMPORTANT: This function is used BOTH for protocol simulation reasons 
% (when the information of the settings, the classifier, the rejection and 
% the integration is needed) AND for classifier training reasons (when the 
% settings are selected according to the desired NEW classifier settings 
% and NOT according to the settings used when the EEG data was collected -- 
% apparently this applies for the online runs, since simprotocol only 
% applies for online runs)
%
% SEPARATNG the two cases in this function is done by checking whether the 
% filetxt argument is empty or not. Passing empty 'filetxt' will treat this 
% run (gdf) as data for training, otherwise the script expects also the
% information of rejection and integration in order to re-compute the
% online probabilites (simloop - simprotocol). This difference will also
% siginify whether this script will look for pre-processed features in a 
% 'GDFBASENAME.simloop.mat' file or in a 'GDFBASENAME.trnloop.mat' file, 
% thus % completely separating the two cases. Both kinds of files are 
% however saved into the 'eegc3' folder 
%
% TODO Add call info
tic;
if(nargin < 6)
	doplot = false;
end
if(nargin < 7)
	% These events are defaulted for SMR BCI:
	%   781		Continuous Feedback
	%   897		Target hit
	%   898		Target miss
	resetevents = [781 898 897];
end

if(nargin < 8)
    recompute = false;
end

% Create extra/ directory
[extra.directory, extra.basename] = eegc3_mkextra(filexdf, 'eegc3');

% Inialize BCI structure
bci = eegc3_smr_newbci();
bci.trace.eegc3_smr_simloop.datetime    = eegc3_datetime();
bci.trace.eegc3_smr_simloop.filexdf     = filexdf;
bci.trace.eegc3_smr_simloop.filetxt     = filetxt;
bci.trace.eegc3_smr_simloop.rejection   = rejection;
bci.trace.eegc3_smr_simloop.integration = integration; 
bci.trace.eegc3_smr_simloop.resetvents  = resetevents; 

if(~isempty(bci.trace.eegc3_smr_simloop.integration))
    bci.trace.eegc3_smr_simloop.filemat		= ...
        strrep([extra.directory '/' extra.basename], '.gdf', '.simloop.mat');
else
    bci.trace.eegc3_smr_simloop.filemat		= ...
        strrep([extra.directory '/' extra.basename], '.gdf', '.trnloop.mat');
end
bci.trace.eegc3_smr_simloop.figbasename = ...
	strrep([extra.directory '/' extra.basename], '.gdf', '');

if(~isempty(bci.trace.eegc3_smr_simloop.integration))
    printf('[eegc3_smr_simloop] Running simulated SMR-BCI loop:\n');
    printf(' < GDF:         %s\n', bci.trace.eegc3_smr_simloop.filexdf);
    printf(' < TXT:         %s\n', bci.trace.eegc3_smr_simloop.filetxt);
    printf(' > MAT:         %s\n', bci.trace.eegc3_smr_simloop.filemat);
    printf(' - Rejection:   %f\n', bci.trace.eegc3_smr_simloop.rejection);
    printf(' - Integration: %f\n', bci.trace.eegc3_smr_simloop.integration);
else
    printf('[eegc3_smr_simloop] Running training SMR-BCI loop:\n');
    printf('[eegc3_smr_simloop] Potential existing TXT file, rejection and integration params are ignored.\n');
    printf(' < GDF:         %s\n', bci.trace.eegc3_smr_simloop.filexdf);
    printf(' > MAT:         %s\n', bci.trace.eegc3_smr_simloop.filemat);    
end

% if(exist(bci.trace.eegc3_smr_simloop.filemat, 'file') && (~recompute))
% 	printf('[eegc3_smr_simloop] Loading precomputed MAT: %s\n', ...
% 		bci.trace.eegc3_smr_simloop.filemat);
% 	load(bci.trace.eegc3_smr_simloop.filemat);
% %     
% %     % Plot spectrum
% %     printf('[eegc3_smr_simloop] Plotting precomputed EEG spectrum');
% %     eegc3_smr_plotSpectrum(bci, bci.trace.eegc3_smr_simloop.filexdf, ...
% %         bci.settings.modules.smr.montage);
% 	return;
% end

% Import all the data we need
printf('[eegc3_smr_simloop] Loading GDF/TXT files... ');
[data.eeg, data.hdr] = sload(filexdf);
if(~isempty(bci.trace.eegc3_smr_simloop.filetxt))
	data.aprobs = importdata(filetxt);
	data.cprobs = data.aprobs(:, 1:2);
	data.iprobs = data.aprobs(:, 3:4);
end
printf('Done!\n');

% Extract trigger informations
data.lpt = data.eeg(:, end);
data.lpt(find(data.lpt > 1)) = 1;		% To be changed = 0
data.evt = gettrigger(data.lpt);
data.red = zeros(1, size(data.eeg,1));

if (length(data.evt) ~= length(data.hdr.EVENT.POS))
    disp('It seems that HW triggers are missing. Using SW trigger positions and durations instead');
    data.red(data.hdr.EVENT.POS) = 1;
    data.pos = data.hdr.EVENT.POS;
else
    disp('Using HW trigger positions for precise timing');
    data.red(data.evt) = 1;
    data.pos = data.evt;
end

data.lbl = data.hdr.EVENT.TYP;
data.dur = data.hdr.EVENT.DUR;

% Set up simulated BCI
if(isstruct(filemat))
    bci.settings = filemat;
else
    
    bci.analysis = load(filemat);

    % Check if it is an eegc2 or eegc3 settings file
    if(isfield(bci.analysis,'analysis'))
        disp('eegc2 settings format detected, converting to eegc3...');
        bci.settings =  eegc3_eegc2_updatesettings(filemat);
    elseif(isfield(bci.analysis,'settings'))
        disp('eegc3 settings format detected');
        bci.settings = bci.analysis.settings;
    else
        disp('Invalid MAT file, exiting...');
        bci = [];
        return;
    end

end

% Find the protocol
[taskset, resetevents, protocol_label] = eegc3_smr_guesstask(data.lbl');

% Find the labels of EEG samples (time domain)
data.lbl_sample = zeros(1, size(data.eeg,1));
data.trial_idx = zeros(1, size(data.eeg,1));
printf('[eegc3_smr_simloop] Labeling raw EEG data according to protocol');
data = eegc3_smr_labelEEG(data, protocol_label, bci.settings);

