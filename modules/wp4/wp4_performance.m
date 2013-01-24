% WP4_PERFORMANCE single-trial performance for wp4 online data
%
% USAGE:
% [acc hits tot fileid] = wp4_performance(filePath);
% 

function [acc hits tot fileid] = wp4_performance(filePath);
% 2013 Andrea Biasiucci <andrea.biasiucci@epfl.ch>

[data.eeg, data.hdr] = sload(filePath);
fileid = filePath(1:end-4);
% Open text file, save line with run id and update it with the number of
% deliveries
if sum(data.hdr.EVENT.TYP == 770) > 0
    EVENTTYPE = 770;
else
    EVENTTYPE = 771;
end
% Compute Single Trial performance (#of correct deliveries)
hits = sum(data.hdr.EVENT.TYP == 33549);
tot = sum(data.hdr.EVENT.TYP == EVENTTYPE);

% Check if the number of deliveries is 15, else discard the run!
if (tot == 15)
	acc = hits / tot;
else 
	acc = [];
	hits = [];
end
%printf('BCI Performance in this run\n')
%disp(acc);

%% Create folder to save performance results
%if (~exist('perf','dir'))
%    mkdir('perf')
%end
%fileID = fopen(['perf/' fileid '_performance.txt'],'w');
%
%% Add New Lines
%fprintf(fileID,[fileid '\n']);
%fprintf(fileID,'NCorr   NTrials\n');
%fprintf(fileID,'%.0f %8.0f\n',perf.Ndeliveries,perf.Ntrials);
%
%fclose(fileID);
