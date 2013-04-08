function [SR EEGChanNum TrigChanNum] = eegc3_GDFInfo(GDFPath)

% function [SR EEGChanNum TrigChanNum] = eegc3_GDFInfo(GDFPath)
%
% Function to return important recording variables stored in the header 
% of a GDF file. EEG channels are supposed to be the first N channels, and
% the remianing extra channels are supposed to be trigger channels.
%
% Inputs:
%
% GDFPath: Filepath of the GDF file
%
%
% Outputs:
%
% SR: Sampling rate
%
% EEGChanNum: Number of EEG channels
%
% TrigChanNum: EEGChanNum: Number of trigger channels
%

% Load header
header = sopen(GDFPath);

SR = header.SampleRate;

% Wrong! This mixes EEG and EMG. Hardcoding it to 16
% EEGChanNum = length(find(header.CHANTYP == 'E'));
EEGChanNum = 16;
TrigChanNum = length(find(header.CHANTYP == 'T'));









