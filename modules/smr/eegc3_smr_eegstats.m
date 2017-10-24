function settings = eegc3_smr_eegstats(settings, dataset)
	
% computing the mean and std for all the channels in settings. Used for artefacts detection
zdata = [];
for i=1:length(dataset.run)
   zdata = [zdata ; dataset.run{i}.eeg(dataset.run{i}.eeglabels~=0, [settings.modules.smr.artefacts.channels])];
end

zdata = abs(hilbert(zdata));
settings.modules.smr.artefacts.mean = mean(zdata);
settings.modules.smr.artefacts.std = std(zdata);