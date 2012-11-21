% 2011-03-11  Michele Tavella <michele.tavella@epfl.ch>
%
% function [S, P, f] = eegc3_fft(x, fs, bands)
function [S, P, f, info] = eegc3_fft(x, fs, bands)

m = length(x);                  % Window length
n = pow2(nextpow2(m));          % Transform length
%y = fft(x.*squeeze(hanning(m)),n);       % Hanning filter then DFT 
y = fft(x,n);
y = y(1:ceil((n+1)/2));         % Through away mirror part
y_abs = abs(y)/m;               % Magnitude of FFT + scaling with window length
f = [0:ceil((n+1)/2)-1]*fs/n;   % Frequency scaling
S = y_abs.^2;                   % Take square for power 
S(2:end) = 2*S(2:end);          % Recover bandpwer lost due to discarding half the spectrum, exclude the DC component
P = angle(y);                   % Phase

if(nargin<3)
    bands = f;
end

[b1, i1] = intersect(f, bands);

f = f(i1);
S = S(i1);
P = P(i1);

info.win = m;
info.nfft = n;