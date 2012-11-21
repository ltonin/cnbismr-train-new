% 2011-01-19  Michele Tavella <michele.tavella@epfl.ch>

function eegc3_zoom(h, k)

if(nargin == 0)
	h = gca();
end

if(nargin < 2)
	k = 1;
end

if(k > 0)
	for i = 1:k
		set(h, 'Position', get(h, 'OuterPosition'));
		drawnow;
	end
elseif(k < 0)
	for i = 1:abs(k)
		set(h, 'OuterPosition', get(h, 'Position'));
		drawnow;
	end
end
