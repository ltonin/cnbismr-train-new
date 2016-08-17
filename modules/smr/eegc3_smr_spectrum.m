function [MI nMI info] = eegc3_smr_spectrum(eeg, trial_idx, labels, winsize, settings, ...
    protocol, taskset, bands)

% function [MI nMI info] = eegc3_smr_spectrum(eeg, winsize, trial_idx, settings, ...
%    protocol, taskset, bands)
%
%
%
% Function to plot the spectrum of all channels
%
% Inputs:
%
% eeg: Matrix channels x time of raw EEG data
%
% trial_idx: Trial index of samples, 0 for inter-trial intervals
%
% settings: eegc3 settings structure
%
% Outputs:
%

% Check integrity if loaded EEG data according to settings
if(size(eeg,2) ~= settings.acq.channels_eeg)
    disp(['[eegc3_smr_spectrum] Number of channels in "settings" is '...
        'different from the EEG matrix. You could be using emg channels...' ]);
end

if(nargin < 8)
    % Choose some default bands appropriate for EEG
    bands = [0:0.01:48]; % 0-40 Hz
end

% Find number of EEG trials
TrialNum = max(unique(trial_idx));
LblNum = length(taskset.cues);

switch(protocol)
    
    case {'SMR_Offline_eegc2','SMR_Offline_eegc3','SMR_Online_eegc3','WP4_Online_eegc3'}
        % trial starts 1 sec after the cue (either cfeedback or1 sec after
        % for eegc2_Offline)
        DistFromCue = 1;
    case {'SMR_Online_eegc2','INC_Online'}
        % trial starts at cfeedback, cfeedback 1 sec away for eegc3
        DistFromCue = 0.9375;
    case {'INCMT2_eegc3'}
        DistFromCue = 0;
    otherwise
        disp('[eegc3_smr_spectrum] Unkown protocol! Exiting...');
        return;
end

% In the case of WP4 online data, we only have 1 class, either 770 or 769
if isfield(settings.modules,'wp4')
    if isfield(settings.modules.wp4,'datatype')
        if settings.modules.wp4.datatype
            %taskset.cues = setdiff(taskset.cues,783);
            %taskset.cues = setdiff(taskset.cues,786);
        end
    end
end

for ch = 1:settings.acq.channels_eeg
    chspectrum = cell(1, length(taskset.cues));
    chphase = cell(1,length(taskset.cues));
    chspectrumB1 = cell(1,length(taskset.cues));
    chphaseB1 = cell(1,length(taskset.cues));
    
    for tr = 1:TrialNum
        
        % Trial indices, dependent on the protocol of this run
        
        TrInd = find(trial_idx==tr);
        TrBegin = TrInd(1) - DistFromCue*settings.acq.sf;
        TrEnd = TrInd(end);
        
        % Find kind of trial
        tr_lbl = labels(TrInd(1));
        
        % Check for overlapping
        if(TrBegin > (TrEnd - winsize*settings.acq.sf))
            disp(['[eegc3_smr_spectrum] Discarding trial ' num2str(tr)...
                ' of class ' num2str(tr_lbl) ', overlapping of MI and non-MI intervals']);
            continue;
        end
        
        % Find label index in taskset
        tasksetPos = find(taskset.cues==tr_lbl);
        
%        [chspectrum{tasksetPos}(end+1,:) chphase{tasksetPos}(end+1,:) MI.f info] = ...
%            eegc3_fft(eeg(TrEnd-winsize*settings.acq.sf:TrEnd-1,ch), settings.acq.sf, bands);
%        [chspectrumB1{tasksetPos}(end+1,:) chphaseB1{tasksetPos}(end+1,:) nMI.f] = ...
%            eegc3_fft(eeg(TrBegin-winsize*settings.acq.sf:TrBegin-1,ch), settings.acq.sf, bands);
    end
    
    for class = 1:length(taskset.cues)
        MI.spectrum{class}(:,ch) = mean(chspectrum{class});
        MI.phase{class}(:,ch) = mean(chphase{class});
        MI.task(class) = taskset.cues(class);
        nMI.spectrum{class}(:,ch) = mean(chspectrumB1{class});
        nMI.phase{class}(:,ch) = mean(chphaseB1{class});
    end
end
end
