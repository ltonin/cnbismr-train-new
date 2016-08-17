function [udataset ndataset]  = eegc3_smr_data4selection(dataset, Classifier, norm)
%
% function [udataset ndataset] = eegc3_smr_data4selection(dataset,
% Classifier)
%
% Function preparing the dataset for feature selection (CVA). 
% 
% Inputs: 
%
% dataset: Struct holding the data and labels. Data and labels are
% separated in runs (dataset.run{i}.data, dataset.run{i}.labels) according 
% to the provided GDF files. The fields of each run are:
%   data: Data matrix samples x frequencies x channels
%   labels: Labels vector, samples x 1
%   path: Filepath of the GDF file corresponding to this run
%
% Classifier: Classifier structure corresponding to the classifier to be
% trained. Task information is needed to extract only the data for the 
% required from the overall pool of samples
% norm: Boolean specifyubg whether PSD features should be normalized for
% feature selection
% 
% Ouputs:
% udataset: Cropped and reshaped dataset
% ndataset: Normalized, cropped and reshaped dataset
%
% Both udataset and ndataset have the same structure as the input dataset,
% but contain only samples of the two requested classes
%

% Identify the requested classes in each run in the dataset

RunNum = length(dataset.run);

UsedRun = 0;

for i=1:RunNum
    
    % Search for the classes
    Right = find(ismember(dataset.run{i}.labels, Classifier.task_right));
    Left = find(ismember(dataset.run{i}.labels, Classifier.task_left));
    Top = find(ismember(dataset.run{i}.labels, Classifier.task_top));
    Bottom = find(ismember(dataset.run{i}.labels, Classifier.task_bottom));
    
    if(Classifier.task_bottom == -1)
        if(Classifier.task_top == -1)
            AllClasses = find(ismember(dataset.run{i}.labels,...
            [Classifier.task_right Classifier.task_left]));
        else
            AllClasses = find(ismember(dataset.run{i}.labels,...
            [Classifier.task_right Classifier.task_left Classifier.task_top]));
        end
    else
        AllClasses = find(ismember(dataset.run{i}.labels,...
        [Classifier.task_right Classifier.task_left ...
        Classifier.task_top Classifier.task_bottom]));
    end
    
    
    NRight  = length(Right);
    NLeft  = length(Left);
    NTop  = length(Top);
    NBottom  = length(Bottom);
    
    if((NRight == 0) || (NLeft == 0) || (NTop == 0 && Classifier.task_top~=-1) || ...
            (NBottom == 0 && Classifier.task_bottom~=-1))
        disp(['[eegc3_smr_data4selection] Run ' dataset.run{i}.path...
            ' does not contain one of the requested classes!!'...
            ' This run will be ommited from further processing']);
        
    else
        
        UsedRun = UsedRun + 1;
        
        % Remap labels
        disp('[eegc3_smr_data4selection] Remapping labels');
        dataset.run{i}.labels(Right) = 1;
        dataset.run{i}.labels(Left) = 2;
        if(Classifier.task_top ~= -1)
            dataset.run{i}.labels(Top) = 3;
        end
        if(Classifier.task_bottom ~= -1)
            dataset.run{i}.labels(Bottom) = 4;
        end        
        
        
        % Keep only class data
        disp(['[eegc3_smr_data4selection] Cropping out irrelevant data']);
        cdataset.run{UsedRun}.data = ...
            dataset.run{i}.data(AllClasses,:,:);
        cdataset.run{UsedRun}.labels = ...
            dataset.run{i}.labels(AllClasses);
        cdataset.run{UsedRun}.path = dataset.run{i}.path;
        cdataset.run{UsedRun}.trial = ...
            dataset.run{i}.trial(AllClasses);
        
        
        if(norm)
            
            % Normalize
            disp(['[eegc3_smr_data4selection] Normalizing run']);
            for sample = 1:size(cdataset.run{UsedRun}.data,1)
                tmp = eegc3_normalize(squeeze(cdataset.run{UsedRun}.data(sample,:,:))')';
                ndataset.run{UsedRun}.data(sample,:,:) = tmp;
            end
            ndataset.run{UsedRun}.labels = cdataset.run{UsedRun}.labels;
            ndataset.run{UsedRun}.trial = cdataset.run{UsedRun}.trial;
            ndataset.run{UsedRun}.path = dataset.run{i}.path;
            
            % Reshape
            disp(['[eegc3_smr_data4selection] Reshaping dataset to feature'...
                ' vectors for normalized data']);
            [ndataset.run{UsedRun}.data ndataset.run{UsedRun}.labels] = ...
                eegc3_reshape_sbc2s(ndataset.run{UsedRun}.data, ...
                ndataset.run{UsedRun}.labels);
        else
            ndataset = {};
        end
              
        % Reshape unnormalized for later use
        disp(['[eegc3_smr_data4selection] Reshaping dataset to feature'...
                ' vectors for unnormalized data']);
        [udataset.run{UsedRun}.data udataset.run{UsedRun}.labels] = ...
            eegc3_reshape_sbc2s(cdataset.run{UsedRun}.data, ...
            cdataset.run{UsedRun}.labels);
        udataset.run{UsedRun}.labels = cdataset.run{UsedRun}.labels;
        udataset.run{UsedRun}.trial = cdataset.run{UsedRun}.trial;
        udataset.run{UsedRun}.path = dataset.run{i}.path;
    
    end
end
