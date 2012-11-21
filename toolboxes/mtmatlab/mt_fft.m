% 2010-11-02  Michele Tavella <michele.tavella@epfl.ch>
% function Y = mt_fft(y, Sf, fmax, doplot)
function [Y, f, t] = mt_fft(y, Sf, freqs, doplot)

if(nargin < 4)
	doplot = false;
end

if(nargin < 3)
	freqs = [0 Sf/2];
end

T = 1/Sf;
L = length(y);
t = (0:L-1)*T;
NFFT = 2^nextpow2(L);
Y = fft(y, NFFT)/L;
f = Sf/2*linspace(0, 1, NFFT/2+1);
fmin = mt_closest(f, freqs(1));
fmax = mt_closest(f, freqs(2));

if(doplot > 0)
	eegc2_figure(doplot);
	%plot(f, 2*abs(Y(1:NFFT/2+1)));
	plot(f(fmin:fmax), 2*abs(Y(fmin:fmax)));
	title('Single-Sided Amplitude Spectrum of y(t)');
	xlabel('Frequency (Hz)');
	ylabel('|Y(f)|');
	axis tight;
	grid on;
	set(gca, 'XMinorTick', 'on');
end
