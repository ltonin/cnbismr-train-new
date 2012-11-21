function [avl_ind err] = eegc3_snap2freq(avl_bands, req_bands)

% Function to find the available bands closest to the requested bands
% Is an alternative to intersecting the two vectors which can result in
% empty final bands vector, if the sampling frequency is not a power of 2
%
% Inputs:
%
% avl_bands: Vecotr of available bands (in Hz), after FFT or PSD
% computation
% 
% req_bands: Requested bands to be plotted
%
% Outputs:
%
% avl_ind: Vector of size length(req_bands) containig the indices of the
% bands in avl_bands which are closest to the requested bands
%
% err: Absolute error bewteen requested bands and closest available band
% (in Hz)

for rfr = 1:length(req_bands)
    
    % Find closest available band
    [mval mpos] = min(abs(avl_bands - req_bands(rfr)));
    avl_ind(rfr) = mpos;
    err(rfr) = abs(req_bands(rfr) - avl_bands(mpos));
end