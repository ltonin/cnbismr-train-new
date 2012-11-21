function info = GDFdummySettingsEPFLgUSBamp
% GDFdummySettingsEPFLgUSBamp creates dummy settings for the first
% use of the gUSBamp 
%
% output: 
%   info       information structure about subject, amplifier, inputs,...

% R.Leeb, 08-May-09, initial version


% General settings
info = [];
% info of subject
info.Subject.Name='subject code/id';
info.Subject.Sex='M/F';
info.Subject.Handedness='none';
info.Subject.Medication='none';
info.Subject.YearOfBirth='1900';   
% info of recording hardware
info.Equipment.Computer = 'EPFL-Laptop';
info.Equipment.Amplifier = 'gUSBamp';
info.SampleRate = 512;
info.DAQbits = 24;

% info over each channel
% ChannelNummer, ChannelName, Amplitue [uV], HP [Hz], LP [Hz], NotchFilter1, 'EEG:FPz',  25e4, 0.5, 30 'on'}
% e.g.
%info.AnalogChannels{1} = {1,'EEG:C3', 25e4, 0.5, 30 'on'}
%info.AnalogChannels{2} = {1,'EEG:Cz', 25e4, 0.5, 30 'on'}
for k = 1 : 16
    info.AnalogChannel{k} = {k,['EEG:' num2str(k)], 250e3, 0.5, 100 'on'};
end
info.AnalogChannel{17} = {17,'Trigger', 250e3, 0, 0 'off'};

