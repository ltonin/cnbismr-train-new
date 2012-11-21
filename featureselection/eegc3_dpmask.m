% 2010-12-07  Michele Tavella <michele.tavella@epfl.ch>
function [M, Mneg, Mall] = eegc3_dpmask(schannels, sbands, channels, bands)

if(nargin == 1)
	[ichannel, iband] = eegc3_chbn2idx(schannels);
	channels = [1:1:schannels.settings.eeg.chs];
	bands = schannels.settings.features.psd.freqs;
else
	[ichannel, iband] = eegc3_chbn2idx(schannels, sbands, channels, bands);
end

M = zeros(length(channels), length(bands));
Mall = 0*M + 1;
for i = 1:length(ichannel)
	c = ichannel(i);
	b = iband(i);
	M(c, b) = 1;
end
Mneg = -1*M + 1;
