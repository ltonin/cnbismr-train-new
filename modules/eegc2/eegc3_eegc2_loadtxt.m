% 2009-12-08  Michele Tavella <michele.tavella@epfl.ch>

function sessions = eegc3_eegc2_loaddescription(descriptionfile)

filename = 'description.txt';
slashes = strfind(descriptionfile, '/');
filename = descriptionfile(slashes(end)+1:end);

path = strrep(descriptionfile, filename, '');

fprintf(1, '[eegc2_ttool_loaddescription] Parsing %s\n', descriptionfile);
fid = fopen(descriptionfile, 'r');
lines = {};
while 1
	line = fgetl(fid);
	if(ischar(line) == false)
		break;
    end
	if(strfind(line, '.txt'))
		lines{end+1} = textscan(line, '%*s%*s%s%s%s%s%s', 'Delimiter', ' ');
	end
end
fclose(fid); 

sessions = {};
for l = 1:length(lines)
	sessions{l} = []; 
	for f = 1:length(lines{l})
		line = cell2mat(lines{l}{f});
		if(strfind(line, '.txt'))
			sessions{l}.files.basename = strrep(line, '.txt', '');
			sessions{l}.files.gdf = [path strrep(line, '.txt', '.gdf')];
			sessions{l}.files.txt = [path line];
		elseif(strfind(line, '.mat'))
			tmp = textscan(line, '%*s%s', 'Delimiter', '=');
			sessions{l}.files.analysis = [path cell2mat(tmp{1})];
		elseif(strfind(line, 'Frames='))
			sessions{l}.info.frames = ...
				textscan(line, '%*s%d', 'Delimiter', '=');
			sessions{l}.info.frames = ... 
				cell2mat(sessions{l}.info.frames);
		elseif(strfind(line, 'Rejection='))
			sessions{l}.options.rejection = ...
				textscan(line, '%*s%f', 'Delimiter', '=');
			sessions{l}.options.rejection = ... 
				cell2mat(sessions{l}.options.rejection);
		elseif(strfind(line, 'Integration='))
			sessions{l}.options.integration = ...
				textscan(line, '%*s%f', 'Delimiter', '=');
			sessions{l}.options.integration = ... 
				cell2mat(sessions{l}.options.integration);
		end
	end
end
