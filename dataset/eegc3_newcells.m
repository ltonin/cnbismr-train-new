% 2010-12-13  Michele Tavella <michele.tavella@epfl.ch>

function [d, l] = eegc3_newcells(n, s)

if(nargin < 2)
	s = [];
end

d = {};
for i = 1:n
	if(isempty(s))
		d{i} = [];
	else
		d{i} = nan(s);
	end
end

if(nargout == 2)
	l = {};
	for i = 1:n
		l{i} = 'none';
	end
end
