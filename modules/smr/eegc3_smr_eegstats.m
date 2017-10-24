function settings = eegc3_smr_eegstats(settings, dataset)
	
% computing the mean and std for all the channels in settings. Used for artefacts detection
zdata = [];
for i=1:length(dataset.run)
    % Apply band-pass
    dataset.run{i}.orig_eeg = eegc3_filter(dataset.run{i}.orig_eeg,settings.modules.smr.options.prep.filter);
    % Apply DC removal
    dataset.run{i}.orig_eeg = eegc3_dc(dataset.run{i}.orig_eeg);
    zdata = [zdata ; dataset.run{i}.orig_eeg(dataset.run{i}.eeglabels~=0, [settings.modules.smr.artefacts.channels])];
end

zdata = abs(hilbert(zdata));
settings.modules.smr.artefacts.mean = mean(zdata);
settings.modules.smr.artefacts.std = std(zdata);