function dsize = eegc3_size(dataset, what)
% 2010-12-07  Michele Tavella <michele.tavella@epfl.ch>

if(nargin < 2)
	what = '';
end

dsize = 0;
dim = 0;

if(strcmp(what, 'trials') | strcmp(what, 't'))
	dsize = size(dataset, 4);
elseif(strcmp(what, 'samples') | strcmp(what, 's'))
	dsize = size(dataset, 1);
elseif(strcmp(what, 'channels') | strcmp(what, 'c'))
	dsize = size(dataset, 3);
elseif(strcmp(what, 'bands') | strcmp(what, 'b'))
	dsize = size(dataset, 2);
elseif(strcmp(what, 'dimensions') | strcmp(what, 'd'))
	dsize = length(size(dataset));
else
    disp('[eegc3_size] Dataset info:');
	disp(['  1) Samples:  ' num2str(size(dataset, 1))]);
	disp(['  2) Bands:    ' num2str(size(dataset, 2))]);
	disp(['  3) Channels: ' num2str(size(dataset, 3))]);
	disp(['  4) Trials:   ' num2str(size(dataset, 4))]);
	dsize = size(dataset);
end
