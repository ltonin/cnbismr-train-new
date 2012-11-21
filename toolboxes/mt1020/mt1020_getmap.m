% 2010-09-22  Michele Tavella <michele.tavella@epfl.ch>
%
% mt1020_getmap('biosemi', 64, 41);
% mt1020_getmap('1020', 64, 41);
% mt1020_getmap('1020', 64, 0);
function [map, list] = mt1020_getmap(system, chtot, chset)

tot = sprintf('%.3d', chtot);
set = sprintf('%.3d', chset);
filename = ['mt1020_' system '_' tot '_' set '.txt'];

if(exist(filename, 'file') == 0)
	disp(['[mt1020_getmap] File ' filename ' not found']);
	map = [];
	return;
end

disp(['[mt1020_getmap] Loading: ' filename]);
list = importdata(filename);

map = java.util.Hashtable;
for i = 1:length(list)
	map.put(list{i}, i);
end
