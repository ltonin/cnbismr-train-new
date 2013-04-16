% EEGC3_SMR_AUTOTRAIN Automatic Training Script, given a set of features
% 
% function [] = eegc3_smr_autotrain(FilePaths)
%
%
% Inputs:
%
% FilePaths: Cell array of GDF filepaths, each one corresponding to a a run
% of a CNBI protocol (mioffline, mionline, incmt2 supported)
%
% presets: Feature presets, electrode positions and frequency bins
% 
%
% Outputs:
% 
% None. The script saves useful variables, among which the trained
% classifier eegc3 MAT files (settings)

function [auc, output] = Myeegc3_smr_autotrain_UseGau(FilePaths,sessionNum)

%% HACK: no gui
% Creates settings
settings = eegc3_newsettings();
settings = eegc3_smr_newsettings(settings);
settings.modules.smr.options.selection.usegui = false;
%%

%% HACK: only rhlh has to be trained
Classifiers{1}.Enable = true;
Classifiers{1}.task_right = 770;
Classifiers{1}.task_left = 769;
Classifiers{1}.filename = '';
Classifiers{1}.filepath = '';
Classifiers{1}.modality = 'rhlh';
%%

%% HACK: PRESETS -> Trains a Classifier using these features, only. 
presets.channels = [7 8 10 11 13 15];
presets.bands = {...           
                            [] ...
           []        []     []    []        [] ...
        [8 10 12] [8 10 12] [] [8 10 12] [8 10 12] ... 
           []      [10 12]  []  [10 12]     [] ...
           };
%--------------------------------------------------------------------------
% presets.usecva -> use - not use CVA selection of features 
%                   if 'true', presets.channels and presets.bands will be
%                   automagically selected and the manual selection will be
%                   ignored
%--------------------------------------------------------------------------
presets.usecva = true;
settings.modules.smr.psd.freqs		= [8:2:12];

% Extract features and labels (prepare dataset)
disp('[eegc3_smr_autotrain] Extracting/loading features from provided runs...');
[dataset, output] = Myeegc3_smr_extract_ArtRej(FilePaths, settings, 0);
dataset.settings = settings;

class_idx = 0;
% Train all requested classifiers
for i = 1:length(Classifiers)
    
    if(Classifiers{i}.Enable)
        class_idx = class_idx + 1;
        disp(['[eegc3_smr_autotrain] Training classifier: [Modality: '...
            Classifiers{i}.modality ' Task GDF events: '...
            num2str(Classifiers{i}.task_right) ' '...
            num2str(Classifiers{i}.task_left) ']']);
       
        % Prepare dataset for feature selection or dataset cropping
        disp('[eegc3_smr_autotrain] Preparing dataset for feature selection');
        [udataset ndataset] = eegc3_smr_data4selection(dataset, Classifiers{i},...
            settings.modules.smr.options.selection.norm);
        
        udataset.settings = settings;
        ndataset.settings = settings;

        if(isempty(Classifiers{i}.filepath))
            %% Feature selection
            % where the CVA select the 16th most discriminant features!
            % refer to eegc3_smr_select_up_to_best_16.m
            disp(['[eegc3_smr_autotrain] Feature selection for classifier: '...
                Classifiers{i}.modality]);
            if(~settings.modules.smr.options.selection.norm)
                Csettings{class_idx} = Myeegc3_smr_selection(udataset, settings);
            else
                Csettings{class_idx} = Myeegc3_smr_selection(ndataset, settings);                
            end
            
            %% HACK: preset tools
            if ~presets.usecva
                Csettings{class_idx}.bci.smr.channels = presets.channels;
                Csettings{class_idx}.bci.smr.bands = presets.bands;
                settings.bci.smr.taskset.classes = [770 769];
            end
                        
            % Reshape dataset for classifier training
            disp(['[eegc3_smr_autotrain] Reshaping dataset according to feature'...
                ' selection for classifier: ' Classifiers{i}.modality]);
            cdataset =...
                eegc3_smr_data4classification(udataset, Csettings{class_idx});
            
            hasInitClassifier = false;
        else
            % Load previously trained classifier
            disp(['[eegc3_smr_autotrain] Loading initial classifier: ' Classifiers{i}.filepath]);
            settings_prev = load(Classifiers{i}.filepath);
            if(isfield(settings_prev,'analysis'))            
                settings_prev = eegc3_eegc2_updatesettings(settings_prev.analysis,'tmp.mat');
            else
                settings_prev = settings_prev.settings;
            end
            
            % Compare settings to identify incompatibility between the
            % requested settings and those used to train the initial
            % classifier
            isCompatible = eegc3_smr_comparesettings(settings,settings_prev);
            
            if(isCompatible)
                % Store the previous settings as current settings for this
                % classifier (along with the feature selection settings)
                Csettings{class_idx} = settings_prev;
            else
                disp(['[eegc3_smr_autotrain] You have specified an initial'...
                    ' classifier which is not'...
                    ' compatible with the requested settings.'...
                    ' Building classifier [' num2str(Classifiers{i}.task_right)...
                    ' ' num2str(Classifiers{i}.task_left) '] will be omitted!']);
                continue;
            end
            
            % Determine old modality
            if(~isfield(Csettings{class_idx}.bci.smr.taskset,'modality'))
                OldModality = '';
            else
                OldModality = Csettings{class_idx}.bci.smr.taskset.modality;
            end
            
            % Reshape dataset for classifier training
            disp(['[eegc3_smr_autotrain] Reshaping dataset according to feature'...
                ' selection of initial classifier']);
            cdataset = eegc3_smr_data4classification(udataset, Csettings{class_idx});
        
            hasInitClassifier = true;
        end
        
        cdataset.settings = Csettings{class_idx};
        
        
        %% HACK: Manually removed normalization on Nov 19th 2012
        cndataset = cdataset;
        
		disp('[eegc3_smr_autotrain] Default classification options will be used');  
        
        % Train classifier
        SubID = eegc3_subjectID(FilePaths);
        
        %%%%%%%%% USE GAU
		disp(['[eegc3_smr_autotrain] Training CNBI Gaussian classifier: ' Classifiers{i}.modality]);

%%%%%%% Vasia:
        [gau, auc] = Myeegc3_train_gau(Csettings{class_idx}, cndataset.data, ...
 		cndataset.labels, cndataset.trial, hasInitClassifier,SubID,sessionNum);
        
        %%%%%%%%%% Uncomment the appropriate one
		Csettings{class_idx}.bci.smr.gau = gau;
        %Csettings{class_idx}.bci.smr.lda = lda;

		% Add trace
		Csettings{class_idx}.bci.smr.trace.Paths = cndataset.Paths;

		% Add modality
		Csettings{class_idx}.bci.smr.taskset.modality = Classifiers{i}.modality;

		% Add taskset (modality) class GDF events
		Csettings{class_idx}.bci.smr.taskset.classes = [Classifiers{i}.task_right ...
		Classifiers{i}.task_left];

        
        % Save settings
        SubjectID = eegc3_subjectID(FilePaths);
        % Name of classifier
        Modality = Classifiers{i}.modality;
        Date = eegc3_daytime();
        
        if(settings.modules.smr.options.classification.gau)
            settings = Csettings{class_idx};
            % EEGC2 style classifier
            analysis = eegc3_downgrade_settings(settings);
            NameAnalysis = [SubjectID{1} '_' Modality '_' 'Session' num2str(sessionNum) '_' Date '_auto.mat'];
            
            save([getenv('TOLEDO_DATA') '/Results/' NameAnalysis(1:find (NameAnalysis=='_')-1) '/Results_GAU_CVA_Rejection_'  NameAnalysis], 'analysis');
            disp(['[eegc3_smr_autotrain] Saved eegc2 classifier ' ...
                Classifiers{i}.modality ': ' NameAnalysis]);
        end 
    end

end
