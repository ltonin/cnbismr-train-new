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

function [] = eegc3_smr_autotrain(FilePaths, presets)
% 2012-2013  Andrea Biasiucci <andrea.biasiucci@epfl.ch>

%% No gui
% Creates settings
settings = eegc3_newsettings();
settings = eegc3_smr_newsettings(settings);
settings.modules.smr.options.selection.usegui = false;
%%

%% Only rhlh has to be trained
Classifiers{1}.Enable = true;
Classifiers{1}.task_right = 770;
Classifiers{1}.task_left = 769;
Classifiers{1}.filename = '';
Classifiers{1}.filepath = '';
Classifiers{1}.modality = 'rhlh';


%% Using no GUI-buttons
usedlg = 0;

% Extract features and labels (prepare dataset)
disp('[eegc3_smr_autotrain] Extracting/loading features from provided runs...');
dataset = eegc3_smr_extract(FilePaths, settings, usedlg);
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
		
		% NO NORMALIZATION IS USED
		settings.modules.smr.options.selection.norm = false;

		% Save classifier settings
        Csettings{class_idx} = settings;

        % Prepare dataset for feature selection or dataset cropping
        disp('[eegc3_smr_autotrain] Preparing dataset for feature selection');
        [udataset ndataset] = eegc3_smr_data4selection(dataset, Classifiers{i},...
			settings.modules.smr.options.selection.norm);
        udataset.settings = Csettings{class_idx};
        ndataset.settings = Csettings{class_idx};
		
		% If intertrial intervals are included, dataset is bound to
        % contain NaNs in the beginning of each run. Lets get rid of it
        for r=1:length(udataset.run)
            notnanind = [];
            notnanind = find(~isnan(udataset.run{r}.data(:,1)));
            udataset.run{r}.data = udataset.run{r}.data(notnanind,:);
            udataset.run{r}.labels = udataset.run{r}.labels(notnanind);
            udataset.run{r}.trial = udataset.run{r}.trial(1,notnanind);
        end
        
        if(isfield(ndataset,'run'))
            for r=1:length(ndataset.run)
                notnanind = [];
                notnanind = find(~isnan(ndataset.run{r}.data(:,1)));
                ndataset.run{r}.data = ndataset.run{r}.data(notnanind,:);
                ndataset.run{r}.labels = ndataset.run{r}.labels(notnanind);
                ndataset.run{r}.trial = ndataset.run{r}.trial(1,notnanind);
            end
        end


        if(isempty(Classifiers{i}.filepath))
            % Feature selection
            disp(['[eegc3_smr_autotrain] Feature selection for classifier: '...
                Classifiers{i}.modality]);
			if(~Csettings{class_idx}.modules.smr.options.selection.norm)
                Csettings{class_idx} = eegc3_smr_selection(udataset, Csettings{class_idx});
            else
                Csettings{class_idx} = eegc3_smr_selection(ndataset, Csettings{class_idx});                
            end
            
            %% Applying Presets
            if ~presets.usecva
                Csettings{class_idx}.bci.smr.channels = presets.channels;
                Csettings{class_idx}.bci.smr.bands = presets.bands;
                settings.bci.smr.taskset.classes = [770 769];
            end
            %%
            
            % Reshape dataset for classifier training
			% Here, always use the unnormalized dataset -> udataset, as we will choose
            % later whether we should normalize before classification. Here
            % we just want to crop to selected features only
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
                        
	
			% Enrich the modules.classes with the currently requested
            % classes
            settings.modules.smr.taskset.classes = ...
                [Classifiers{i}.task_right Classifiers{i}.task_left];
    
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
        
		% Extract and plot distributions
        eegc3_figure(10 + i);
        eegc3_publish(14,14,3,3);
        [pdf1 pdf2] = eegc3_smr_cvaspace(cdataset.data,cdataset.labels,[1 2]);
        plot(pdf1.x,pdf1.f,'b',pdf2.x,pdf2.f,'r')
        title([Classifiers{i}.modality ' dataset in canonical space -- Unnormalized']);
        xlabel('1st canonical dimension');
        ylabel('PDF');
        legend('Class 1','Class2');
        
        % Normalization during classification - no normalization used
		disp(['[eegc3_smr_autotrain] Not normalizing before classification']);
        Csettings{class_idx}.modules.smr.options.classification.norm = false;
        cndataset = cdataset;
        cndataset.settings = Csettings{class_idx};
        
        eegc3_figure(20 + i);
        eegc3_publish(14,14,3,3);
        [npdf1 npdf2] = eegc3_smr_cvaspace(cndataset.data,cndataset.labels,[1 2]);
        plot(npdf1.x,npdf1.f,'b',npdf2.x,npdf2.f,'r')
        title([Classifiers{i}.modality ' dataset in canonical space ']);
        xlabel('1st canonical dimension');
        ylabel('PDF');
        legend('Class 1','Class2');
            
		% Train classifier
		% Only train a CNBI GAUSSIAN classifier
		disp(['[eegc3_smr_autotrain] Training CNBI Gaussian classifier: ' Classifiers{i}.modality]);
		gau = eegc3_train_gau(Csettings{class_idx}, cndataset.data, ...
		cndataset.labels, cndataset.trial, hasInitClassifier);

		Csettings{class_idx}.bci.smr.gau = gau;

		% Add trace
		Csettings{class_idx}.bci.smr.trace.Paths = cndataset.Paths;

		% Add modality
		Csettings{class_idx}.bci.smr.taskset.modality = Classifiers{i}.modality;

		% Add taskset (modality) class GDF events
		Csettings{class_idx}.bci.smr.taskset.classes = [Classifiers{i}.task_right ...
		Classifiers{i}.task_left];

        
        % Save settings
        % Name of classifier
        SubjectID = eegc3_subjectID(FilePaths);
        Modality = Classifiers{i}.modality;
        Date = eegc3_daytime();
        
        if(settings.modules.smr.options.classification.gau)
            settings = Csettings{class_idx};
            % EEGC2 style classifier
            analysis = eegc3_downgrade_settings(settings);
            NameAnalysis = [SubjectID{1} '_' Modality '_' Date '_auto.mat'];
            save(NameAnalysis, 'analysis');
            disp(['[eegc3_smr_autotrain] Saved eegc2 classifier ' ...
                Classifiers{i}.modality ': ' NameAnalysis]);
        end 
    end

end
