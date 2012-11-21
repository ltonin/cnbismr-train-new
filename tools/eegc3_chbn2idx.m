% 2010-12-15  Michele Tavella <michele.tavella@epfl.ch> 
function [ichannel, iband, labels, total] = eegc3_chbn2idx(schannels, sbands, channels, bands)

ichannel = [];
iband = [];
labels = {};

chnames = {};
if(nargin == 2)
    chnames = sbands;
end
if(nargin == 1 || nargin == 2)
	analysis = schannels;
	channels = [1:1:analysis.settings.eeg.chs];
	bands = analysis.settings.features.psd.freqs;
	schannels = analysis.tools.features.channels;
	sbands = analysis.tools.features.bands;
end

total = 0;
if(length(schannels) > 1)
	for c = schannels
		freqs = sbands{c};
		for f = freqs
			b = find(bands == f);
			ichannel(end+1) = c;
			iband(end+1) = b;
            if(isempty(chnames))
                labels{end+1} = sprintf('Ch. %d, %d Hz', c, f);
            else
                labels{end+1} = sprintf('%s %dHz', chnames{c}, f);
            end
			total = total + 1;
		end
	end
else
	c = schannels;
	for f = sbands 
		b = find(bands == f);
		ichannel(end+1) = c;
		iband(end+1) = b;
		labels{end+1} = sprintf('Ch. %d, %d Hz', c, f);
		total = total + 1;
	end
end
