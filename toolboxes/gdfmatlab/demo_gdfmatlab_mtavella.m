% Edited by M. Tavella <michele.tavella@epfl.ch> on 11/05/09 23:57:21

function demo_gdfmatlab_mtavella

basename = 'doggie';
system(['rm -f ' basename '.*']);
info = GDFdummySettingsEPFLgUSBamp;
HDR = GDFCreateFile(info, [basename '.gdf']);

nk = 3; 
nr = 3;
dt = 4;
fs = 512;

N = fs*(nk*nr*dt + 1);
data = 0 + 8.*rand(N, 16);
trigger = zeros(N, 1);
trigger([fs+1:fs*dt+1:length(trigger)]) = 1;
HDR = GDFWriteBlock(HDR, [data trigger]);
HDR = GDFCloseFile(HDR);

% Note by M.Tavella <michele.tavella@epfl.ch> on 12/05/09 00:16:34m
% - Double quotes to make my life easier
% - No timestamp is needed
% - Rnd description as proof of concept
fid = fopen([basename '.evt'], 'w');
for j = 1:nr
	for k = 1:nk
		fprintf(fid, '%d "all your base are belong to us"\n', k);
	end
end
fclose(fid);

% Just as a reminder:
%[s,h]=sload(filename); 
