% 2010-11-10  Michele Tavella <michele.tavella@epfl.ch>
% TODO

function [directory, file] = eegc3_mkextra(fileordirectory, child)

if(exist(fileordirectory, 'dir') == 0 & exist(fileordirectory, 'file') == 0)
	printf('[eegc3_mkextra] Error: %s does not exist\n', fileordirectory);
	return;
end

if(nargin < 2)
	child = 'extra';
end

directory = [];
file = [];
if(exist(fileordirectory) == 2)
	[file, directory] = mtpath_basename(fileordirectory);
elseif(exist(fileordirectory, 'dir'))
	directory = fileordirectory;
end

directory = [directory '/' child];
if(exist(directory, 'dir'))
	return;
else
	printf('[eegc3_mkextra] Creating directory: %s\n', directory);
	mkdir(directory);
end
