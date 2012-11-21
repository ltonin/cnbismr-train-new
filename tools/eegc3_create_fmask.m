function Mask = eegc3_create_fmask(settings)
%
% function Mask = eegc3_create_fmask(settings)
%
% Function to return a mask for extracting selected features out of overall
% feature vector
%
% Inputs:
%
% settings: struct of settings for feature selection, preprocessing, 
% classification etc., created by eegc3_smr_newsettings (this structure 
% also holds the settings of a trained classifier) 
%
%
% Outputs:
%
% Mask: Mask for selected feature. It is a vector with 1 at the position of
% selected features and 0 elsewhere
%

% Create mask to crop selected features

Mask  = zeros(1,settings.acq.channels_eeg*length(settings.modules.smr.psd.freqs));
Freqs = settings.modules.smr.psd.freqs;

FNum = length(Freqs);
ChNum = settings.acq.channels_eeg;

% Put ones according to selection

for ch = 1:length(settings.bci.smr.channels)
    for bn = 1:length(settings.bci.smr.bands{settings.bci.smr.channels(ch)})
        
        ChInd = settings.bci.smr.channels(ch);    
        FrInd = eegc3_bands2indices(settings, ...
        settings.bci.smr.bands{settings.bci.smr.channels(ch)}(bn));
        Mask((FrInd - 1)*ChNum + ChInd) = 1;
        
    end
end

