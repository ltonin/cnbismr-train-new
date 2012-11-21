function Labels = eegc3_ind2chbnd(ind, settings, ElecLbl)

if(nargin<2)
    settings = eegc3_smr_newsettings;
end

if(nargin < 3)
    ElecLbl = {'Fz', 'FC3', 'FC1', 'FCz', 'FC2', 'FC4', 'C3', 'C1', 'Cz',...
        'C2', 'C4', 'CP3', 'CP1', 'CPz', 'CP2', 'CP4'};
end

if(length(ElecLbl) ~= settings.acq.channels_eeg)
    disp('Illegal electrode label size');
    return;
end

NumFreq = length(settings.modules.smr.psd.freqs);
NumElec = settings.acq.channels_eeg;

NumFeat = NumFreq*NumElec;

for i=1:length(ind)
    
    if(ind(i) > NumFeat || ind(i)<0)
        disp(['Illegal feature index ' num2str(ind(i))...
            ' for the given settings']);
    end
        
    % Find electrode index and label
    iElec(i) = floor((ind(i)-1)/NumFreq) + 1;
    
    % Find frequency index and label
    iFreq(i) = mod(ind(i)-1,NumFreq) + 1;
    
    Labels{i}.ChannelIndex = iElec(i);
    Labels{i}.FreqIndex = iFreq(i);
    Labels{i}.ChannelLbl = ElecLbl(iElec(i));
    Labels{i}.FreqLbl = settings.modules.smr.psd.freqs(iFreq(i));
end