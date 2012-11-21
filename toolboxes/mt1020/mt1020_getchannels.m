% 2010-09-22  Michele Tavella <michele.tavella@epfl.ch>
%
% map = mt1020_getmap('biosemi', 64, 41);
% idx = mt1020_getchannels(map, {'Cz' Afz});

function idx = mt1020_getchannels(map, channels)

idx = [];
for i = 1:length(channels) 
	idx(i) = map.get(channels{i});
end
