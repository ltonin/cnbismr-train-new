% 2010-08-25  Michele Tavella <michele.tavella@epfl.ch>
% function mt_progress(message, i, imin, imax, l)
function mt_progress(message, i, imin, imax, idelta, l)

global mtprogress;
mtprogress.size = 0;

if(nargin < 5)
	if(imax < 100)
		idelta = 1;
	elseif(imax < 1000)
		idelta = 5;
	elseif(imax < 10000)
		idelta = 25;
	elseif(imax < 100000)
		idelta = 100;
	else
		idelta = 250;
	end
end

if(mod(i, idelta) ~= 0)
	return;
end


if(nargin < 6)
	l = 35;
end

in = round(l*i/imax);
mtprogressline = '';
bar = '';
for j = 1:1:l
	if j <= in
		bar = [bar '-'];
	else
		bar = [bar ' '];
	end
end
mtprogressline = sprintf('%-40.40s [%s] %3d/100%% - %d/%d/%d \n', ...
	message, bar, round(i/imax*100), ...
	imin, i, imax);

if(i == imax)
	mtprogress.size = -1;
	fprintf('%s\n', mtprogressline);
else
	mtprogress.size = length(mtprogressline);
	fprintf('%s', mtprogressline);
end
