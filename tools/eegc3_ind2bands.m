function bands = eegc3_ind2bands(settings, indices)
Freqs = settings.modules.smr.psd.freqs;
LowFreq = Freqs(1);
HighFreq = Freqs(end);
D = diff(Freqs);

Bin = D(1);

for i = 1:length(indices)
    
    if(ind(i) > 1 && ind(i) < length(Freqs))
        disp('Illegal arguments');
        bands = [];
        return;
    else
        bands(i) = LowFreq + Bin*indices(i);
    end
    
end