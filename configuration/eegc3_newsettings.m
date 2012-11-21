function settings = eegc3_newsettings()
%
% function settings = eegc3_newsettings()
%
% Function to create default settings structure for a CNBI BCI
%
% Inputs: 
%
% None
%
% Outputs:
%
% settings: MATLAB structure holding settings information about feature
% extraction, feature selection, classification as well as the classifier
% parameters for a CNBI classifier
%

settings = {};

settings.info.subject 				= 'unknown';
settings.info.experimenter			= 'unknown';
settings.info.hostname				= 'unknown';
settings.info.date					= 'unknown';
settings.info.basename 				= 'unknown';

settings.acq.id                     = 0;
settings.acq.sf                     = 0;
settings.acq.channels_eeg			= 0;
settings.acq.channels_exg           = 0;
settings.acq.channels_tri           = 0;

settings.modules = {};
settings.bci = {};
