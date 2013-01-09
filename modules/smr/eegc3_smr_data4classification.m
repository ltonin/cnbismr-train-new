function [cdataset] = eegc3_smr_data4classification(dataset, settings)
%
% function [cdataset] = eegc3_smr_data4classification(dataset, settings)
%
% Function to crop out non-selected features from the dataset and prepare
% data for classifier training by concantenating the separate run datasets
% into a single training dataset.
%
%
% Inputs:
%
% dataset: Struct holding the data and labels. Data and labels are
% separated in runs (dataset.run{i}.data, dataset.run{i}.labels) according 
% to the provided GDF files. The fields of each run are:
%   data: Data matrix samples x (channels x frequencies)
%   labels: Labels vector, samples x 1
%   path: Filepath of the GDF file corresponding to this run
%
% settings: struct of settings for feature selection, preprocessing, 
% classification etc., created by eegc3_smr_newsettings (this structure 
% also holds the settings of a trained classifier) 
%
% Outputs:
%
% cdataset: struct holding the final training dataset. Fields are:
%
% data: Data matrix, samples x (selected features)
%
% labels: Vector, samples x 1 holding the data class labels
%


% Identify the requested classes in each run in the dataset
RunNum = length(dataset.run);

cdataset.data = [];
cdataset.labels = [];
cdataset.trial = [];
cdataset.Paths = {};

% HACK TO MAKE IT WORK WITH 16
settings.acq.channels_eeg = 16;
ChNum = settings.acq.channels_eeg;

for i=1:RunNum
    
    % Crop data according to feature selection
    fidx = 0;
    rundata = [];
    for ch = 1:length(settings.bci.smr.channels)
        for bn = 1:length(settings.bci.smr.bands{settings.bci.smr.channels(ch)})
            fidx = fidx + 1;
            ChInd = settings.bci.smr.channels(ch);    
            FrInd = eegc3_bands2indices(settings, ...
            settings.bci.smr.bands{settings.bci.smr.channels(ch)}(bn));
            pos = (FrInd - 1)*ChNum + ChInd;
            rundata(:,fidx) = dataset.run{i}.data(:,pos);
        end
    end
    
    cdataset.data = [cdataset.data; rundata];
    cdataset.labels = [cdataset.labels; dataset.run{i}.labels];    
    cdataset.Paths{i} = dataset.run{i}.path;
    cdataset.trial = [cdataset.trial; [repmat(i,length(dataset.run{i}.trial),1) dataset.run{i}.trial']];    
end



