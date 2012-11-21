% 2010-12-07  Michele Tavella <michele.tavella@epfl.ch>

function [V, L] = eegc3_dpmask(DP, schannels, sbands, channels, bands)

if(nargin == 3)
	channels = [1:1:16];
	bands = [4:2:48];
end

if(nargin == 2)
	analysis = schannels;
	channels = [1:1:analysis.settings.eeg.chs];
	bands = analysis.settings.features.psd.freqs;
	schannels = analysis.tools.features.channels;
	sbands = analysis.tools.features.bands;
end

%M = zeros(length(channels), length(bands));
%Mall = 0*M + 1;

total = 0;
for c = schannels
	freqs = sbands{c};
	for f = freqs
		total = total + 1;
	end
end

V = zeros(total, 1);
L = {};

index = 1;
for c = schannels
	freqs = sbands{c};
	for f = freqs
		b = find(bands == f);
		V(index) = DP(c, b);
		if(nargout == 2)
			L{index} = ['Ch. ' num2str(c) ', ' num2str(f) ' Hz'];
		end
		index = index + 1;
	end
end

