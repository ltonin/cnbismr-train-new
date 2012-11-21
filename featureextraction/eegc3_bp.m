% Edited by M. Tavella <michele.tavella@epfl.ch> on 20/05/09 22:11:50
%
% TODO: remove freq approximation
function [bandpower] = eegc2_bp(signal, fs, bands)

L = length(signal);
nfft = 2^nextpow2(L);

fourier = fft(signal, nfft)/L;

frequencies = [0:1:fs/2-1];
power = 4*abs(fourier(1:nfft/2)).^2;

bandpower = zeros(1, length(bands));
for bn = 1:length(bands)
    bandpower(bn) = log(sum(power(bands{bn}(1):bands{bn}(2))));
end
bandpower = bandpower/sum(power);
