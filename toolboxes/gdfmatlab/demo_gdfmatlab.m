% demonstrating the gdf save close the GDF file
% R.Leeb, 08-May-09, initial version
% R.Leeb, 11-May-09, data is stored in 'short' instead of 'float64'

% addpath to biosig toolbox
addpath(genpath('../..//Thirdparty/matlab/biosig/'))

% Create GDF file
HDR = GDFCreateFile(info, filename);
% Writes data
HDR = GDFWriteBlock(HDR, data);
% Store additional events to the file
HDR = GDFAddEvent(HDR, EVENT);
% Close GDF file
HDR = GDFCloseFile(HDR);

%---------------------------------------
%-------- dummy implementation ---------
%---------------------------------------
% FileName
filename = 'test_5.gdf';
info = GDFdummySettingsEPFLgUSBamp;

% Create GDF file
HDR = GDFCreateFile(info, filename);

% Generates and stores an stepwise increasing data set
data = zeros(32,17);
dataBackup = [];
for k = 1 : 123
    fprintf('.')
    % Writes data
    data = data+1;  % dummy code
    dataBackup = [dataBackup; data]; % dummy for comparision afterwards
    HDR = GDFWriteBlock(HDR, data);
    if mod(k,10)==0
        % dummy - Store additional events to the file, every 10 block
        EVENT = [hex2dec('0300')];
        HDR = GDFAddEvent(HDR, EVENT);
    end
end
disp(' ');
% Close GDF file
HDR = GDFCloseFile(HDR);

%---------------------------------------
% Loading the data afterwards
[s,h]=sload(filename); 
ch = 1; % select channel
plot(s(:,ch));
% Compare loaded to original data
hold on
plot(dataBackup(:,ch),'r');

%---------------------------------------
%-------- dummy implementation ---------
%---------------------------------------
