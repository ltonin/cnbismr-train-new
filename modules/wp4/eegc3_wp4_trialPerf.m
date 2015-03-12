function perf = eegc3_wp4_trialPerf(filexdf)

[data.eeg, data.hdr] = sload(filexdf);
perf = [];
slashes = find(filexdf == '/');
fileid = filexdf(slashes(end)+1:end-4);
% Open text file, save line with run id and update it with the number of
% deliveries
if sum(data.hdr.EVENT.TYP == 770) > 0
    EVENTTYPE = 770;
else
    EVENTTYPE = 769;
end

% Compute Single Trial performance (#of correct deliveries)
perf.Ndeliveries = sum(data.hdr.EVENT.TYP == 897);
perf.Ntrials = sum(data.hdr.EVENT.TYP == EVENTTYPE);
printf('BCI Performance in this run\n')
disp(perf);

% Create folder to save performance results
if (~exist('perf','dir'))
    mkdir('perf')
end
fileID = fopen(['perf/' fileid '_performance.txt'],'w');

% Add New Lines
fprintf(fileID,[fileid '\n']);
fprintf(fileID,'NCorr   NTrials\n');
fprintf(fileID,'%.0f %8.0f\n',perf.Ndeliveries,perf.Ntrials);

fclose(fileID);
