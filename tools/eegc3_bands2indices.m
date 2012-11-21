function ind = eegc3_bands2indices(settings, bands)

% function ind = eegc3_bands2indices(settings, bands)
%
% Function to return the indices (in the overall feature vector) of an
% array of frequency bands in Hz (useful for data manipulation)
%
% Inputs: 
%
% settings: struct of settings for feature selection, preprocessing, 
% classification etc., created by eegc3_smr_newsettings (this structure 
% also holds the settings of a trained classifier)  
%
% bands: Vector of frequency bands of the CNBI SMR BCI (e.g. [4 8 14]) in
% Hz
%
%


Freqs = settings.modules.smr.psd.freqs;
LowFreq = Freqs(1);
HighFreq = Freqs(end);
D = diff(Freqs);

Bin = D(1);

for bn = 1:length(bands)
     
    if(length(find(Freqs == bands(bn)))==0)
        disp('Illegal arguments');
        ind = [];
        return
    else
        ind(bn) = (bands(bn) - LowFreq)/Bin + 1;
    end
end