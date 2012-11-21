% 2010-09-22  Michele Tavella <michele.tavella@epfl.ch>
%
% mt1020_loadmap('biosemi_custom.txt');
function [map, list] = mt1020_loadmap(filename)

if(exist(filename, 'file') == 0)
	disp(['[mt1020_loadmap] File ' filename ' not found']);
	map = [];
	return;
end

disp(['[mt1020_loadmap] Loading: ' filename]);
list = importdata(filename);

map = java.util.Hashtable;

for i = 1:length(list)
	map.put(list{i}, i);
end
