function [ndataset, cdataset] = Myeegc3_smr_train(FilePaths, settings, Classifiers, usedlg)

% function [] = eegc3_smr_train(FilePaths, settings, Classifiers)
% 
% Inputs:
%
% FilePaths: Cell array of GDF filepaths, each one corresponding to a a run
% of a CNBI protocol (mioffline, mionline, incmt2 supported)
%
% settings: struct of settings for feature selection, preprocessing, 
% classification etc., created by eegc3_smr_newsettings (this structure 
% also holds the settings of a trained classifier)
%
% Classifiers: Cell array of structs keeping the information on the
% classifiers to be trained. The struct Classifers{i} has the fields:
%
% Enabled: Boolean determining whether a classifier for this modality
% will be trained or not
%
% modality: Modality of this classifier, e.g. 'rhlh' for Right Hand vs Left
% Hand MI
%
% task_right: GDF Event for "right" task
%
% task_left: GDF Event for "left" task
%
% filepath, filename: Filepath and filename for precomputed classifier of
% this modality. SOM initialization will be used if filepath is empty ('')
%
% usedlg: Use dialogues for various settings (classification params, saving)
%
%
% Outputs:
% 
% None. The script saves useful variables, among which the trained
% classifier eegc3 MAT files (settings)
%

if(nargin < 4)
    usedlg = false;
end

if(nargin == 0)

    disp(['[eegc3_smr_train] Please specify cell array of GDF'...
        ' filepaths to be used for training or use GUI.']);
    
        [FilePaths settings Classifiers usedlg] = eegc3_train_gui;
        
        % Check if close button has been pressed
        if(isempty(FilePaths))
            return;
        end 
end

if(nargin == 1)
    disp('[eegc3_smr_train] Default settings will be used.');
    settings = eegc3_newsettings();
    settings = eegc3_smr_newsettings(settings);
end

if(nargin == 2)
    disp(['[eegc3_smr_train] No classifier has been specified.'...
        ' Attempt to train for default tasksets rhlh, rhbf, lhbf']);
    
    Classifiers{1}.Enable = true;
    Classifiers{2}.Enable = true;
    Classifiers{3}.Enable = true;
    
    Classifiers{1}.task_right = 770;
    Classifiers{2}.task_right = 770;
    Classifiers{3}.task_right = 771;
    
    
    Classifiers{1}.task_left = 769;
    Classifiers{2}.task_left = 771;
    Classifiers{3}.task_left = 769;
    
    
    Classifiers{1}.filename = '';
    Classifiers{2}.filename = '';
    Classifiers{3}.filename = '';
    
    Classifiers{1}.filepath = '';
    Classifiers{2}.filepath = '';
    Classifiers{3}.filepath = '';
    
end


% Extract features and labels (prepare dataset)
disp(['[eegc3_smr_train] Extracting/loading features from provided runs...']);
dataset = eegc3_smr_extract(FilePaths, settings, usedlg);
dataset.settings = settings;

%%%%%%%%%%%%%%%%%%%%%%%%% Here: eegc3_smr_simloop has been called ---> Gets
%%%%%%%%%%%%%%%%%%%%%%%%% labels, PSD calculation
%%%%%%%%%%%%%%%%%%%%%%%%% dataset = struct: data, labels, trial, path 
%%%%%%%%%%%%%%%%%%%%%%%%% dataset.run{i}.data = bci.afeats;


% Saving raw Log-PSD features
if(usedlg)
    Ans = questdlg('Do you want to save raw PSD features?', 'Attention!', ...
        'Yes','No','No');
else
    Ans = 'No';
end

if(strcmp(Ans,'Yes'))
    % Saving raw features
    Name = ['PSDall_' eegc3_daytime() '.mat'];
    disp(['[eegc3_smr_train] Saving raw features from provided runs: '...
        Name]);
    save(Name,'dataset');
end

class_idx = 0;
% Train all requested classifiers
for i = 1:length(Classifiers)
    
    if(Classifiers{i}.Enable)
        class_idx = class_idx + 1;
        disp(['[eegc3_smr_train] Training classifier: [Modality: '...
            Classifiers{i}.modality ' Task GDF events: '...
            num2str(Classifiers{i}.task_right) ' '...
            num2str(Classifiers{i}.task_left) ']']);
       
        % Prepare dataset for feature selection or dataset cropping
        disp('[eegc3_smr_train] Preparing dataset for feature selection');
        [udataset ndataset] = eegc3_smr_data4selection(dataset, Classifiers{i}); 
        
        udataset.settings = settings;
        %%%%%%%%%%%%%%%%%%%%%%%%% Here: Keep only selected classes. Normalizing. Reshaping. 
        %%%%%%%%%%%%%%%%%%%%%%%%% eegc3_normalize and eegc3_reshape_sbc2s have been called
        %%%%%%%%%%%%%%%%%%%%%%%%% Reshaping from samplesxfreqxchan to samplesx(chan*freq) 
        %%%%%%%%%%%%%%%%%%%%%%%%% ndataset = struct: data, labels, trial, path 
        
        % Saving cropped unnormalized Log-PSD features
        if(usedlg)
            Ans = questdlg(['Do you want to normalize PSD features'...
                ' before feature selection?'], 'Attention!','Yes','No','No');
        else
            if(settings.modules.smr.options.selection.norm)
                Ans = 'Yes';
            else
                Ans = 'No';
            end
        end

        if(strcmp(Ans,'Yes'))
            settings.modules.smr.options.selection.norm = true;
        else
            settings.modules.smr.options.selection.norm = false;
        end        
        
        % Save classifier settings
        Csettings{class_idx} = settings;
        
        
        disp('[eegc3_smr_train] Preparing dataset for feature selection');
        [udataset ndataset] = eegc3_smr_data4selection(dataset, Classifiers{i},...
            settings.modules.smr.options.selection.norm);
        udataset.settings = Csettings{class_idx};
        ndataset.settings = Csettings{class_idx};
        
        % Saving cropped Log-PSD features
        if(usedlg)
            Ans = questdlg(['Do you want to save PSD features'...
                ' cropped for modality ' Classifiers{i}.modality...
                ' ?'], 'Attention!','Yes','No','No');
        else
            Ans = 'No';
        end

        if(strcmp(Ans,'Yes'))
            % Saving cropped PSD features
            if(~Csettings{class_idx}.modules.smr.options.selection.norm)
                Name = ['PSD_' Classifiers{i}.modality '_' eegc3_daytime() '.mat'];
                save(Name,'udataset');
            else
                Name = ['PSD_' Classifiers{i}.modality '_normalized_' eegc3_daytime() '.mat'];
                save(Name,'ndataset');
            end
            disp(['[eegc3_smr_train] Saving cropped features'...
                ' from provided runs: ' Name]);
        end
        
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
            disp(['[eegc3_smr_train] Feature selection for classifier: '...
                Classifiers{i}.modality]);
            if(~Csettings{class_idx}.modules.smr.options.selection.norm)
                Csettings{class_idx} = eegc3_smr_selection(udataset, Csettings{class_idx});
            else
                Csettings{class_idx} = eegc3_smr_selection(ndataset, Csettings{class_idx});                
            end
			%%%%%%%%%%%%%%%%%%%%%%%%% Here: Feature selection gui launched.
            %%%%%%%%%%%%%%%%%%%%%%%%% FS performed. Certain channels and
            %%%%%%%%%%%%%%%%%%%%%%%%% bands selected. FS Plots (101 & 102).
            %%%%%%%%%%%%%%%%%%%%%%%%% eegc3_smr_select_stable and eegc3_smr_select have been called
            %%%%%%%%%%%%%%%%%%%%%%%%% Csettings = The input settings structure enriched
            %%%%%%%%%%%%%%%%%%%%%%%%% with the results of feature selection             
            
            % Reshape dataset for classifier training
            % Here, always use the unnormalized dataset -> udataset, as we will choose
            % later whether we should normalize before classification. Here
            % we just want to crop to selected features only
            disp(['[eegc3_smr_train] Reshaping dataset according to feature'...
                ' selection for classifier: ' Classifiers{i}.modality]);
            cdataset =...
                eegc3_smr_data4classification(udataset, Csettings{class_idx});
            
            hasInitClassifier = false;
            
        else
            
            % Load previously trained classifier
            disp(['[eegc3_smr_train] Loading initial classifier: ' Classifiers{i}.filepath]);
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
                disp(['[eegc3_smr_train] You have specified an initial'...
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
            
            % Compare modalities
            Ans = 'Yes';
            if(~strcmp(OldModality,Classifiers{i}.modality))
                if(usedlg)
                    Ans = questdlg(['[eegc3_smr_train] Initial classifier might use '...
                        'different modality than the requested classifier!'...
                        ' Do you want to proceed anyway?'],...
                        'Attention!','Yes','No','No');
                else
                    disp(['[eegc3_smr_train] WARNING! Initial classifier'...
                        ' might use different '...
                        'modality than the requested classifier!']);
                    Ans = 'Yes';
                end
                
            end
            
            if(strcmp(Ans,'No'))
                continue;
            end
            
            % Reshape dataset for classifier training
            disp(['[eegc3_smr_train] Reshaping dataset according to feature'...
                ' selection of initial classifier']);
            cdataset = eegc3_smr_data4classification(udataset, Csettings{class_idx});
        
            hasInitClassifier = true;
        end
        
        cdataset.settings = Csettings{class_idx};
        
        %%%%%%%%%%%%%%%%%%%%%%%%% Here: Non-selected features cropped out
        %%%%%%%%%%%%%%%%%%%%%%%%% from the dataset. Dataset prepared
        %%%%%%%%%%%%%%%%%%%%%%%%% for classifier training by concatenating the separate run datasets
        %%%%%%%%%%%%%%%%%%%%%%%%% into a single training dataset.
        %%%%%%%%%%%%%%%%%%%%%%%%% cdataset: struct with final training dataset.
        %%%%%%%%%%%%%%%%%%%%%%%%% Fields: data: Data matrix, samples x (selected features)
        %%%%%%%%%%%%%%%%%%%%%%%%% labels: Vector, samples x 1 holding the data class labels
 
        % Saving cropped, selected Log-PSD features
        if(usedlg)
            Ans = questdlg(['Do you want to save selected unnormalized PSD'...
                'features cropped for modality ' Classifiers{i}.modality...
                ' ?'], 'Attention!','Yes','No','No');
        else
            Ans = 'No';
        end

        if(strcmp(Ans,'Yes'))
            % Saving selected unnormalized PSD features
            Name = ['PSDselect_' Classifiers{i}.modality '_' eegc3_daytime() '.mat'];
            disp(['[eegc3_smr_train] Saving selected unnormalized'...
                'features from provided runs: ' Name]);
            save(Name,'cdataset');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calculation of pdfs and Plotting.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Both for normalized and
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% unnormalized
        eegc3_figure(10 + i);
        eegc3_publish(14,14,3,3);
        [pdf1 pdf2] = eegc3_smr_cvaspace(cdataset.data,cdataset.labels,[1 2]);
        plot(pdf1.x,pdf1.f,'b',pdf2.x,pdf2.f,'r')
        title([Classifiers{i}.modality ' dataset in canonical space -- Unnormalized']);
        xlabel('1st canonical dimension');
        ylabel('PDF');
        legend('Class 1','Class2');
        
        % Ask whether it should normalize before classification
        if(usedlg)
            Ans = questdlg(['Do you want to normalize for classification?'], 'Attention!','Yes','No','No');
        else
            if(Csettings{class_idx}.modules.smr.options.classification.norm)
                Ans = 'Yes';
            else
                Ans = 'No';
            end
        end

        if(strcmp(Ans,'Yes'))
            % Normalize data for classification
            % NORMALIZE
            Csettings{class_idx}.modules.smr.options.classification.norm = true;
            disp(['[eegc3_smr_train] I AM NORMALIZING BEFORE CLASSIFICATION']);
            cndataset.data = zeros(size(cdataset.data));
            cndataset.labels = cdataset.labels;
            cndataset.trial = cdataset.trial;
            cndataset.Paths = cdataset.Paths;
            cndataset.settings = Csettings{class_idx};
            
            for s=1:size(cdataset.data,1)
                cndataset.data(s,:) = eegc3_normalize(squeeze(cdataset.data(s,:)));
            end
            
            % Saving cropped, selected, normalized Log-PSD features
            if(usedlg)
                SAns = questdlg(['Do you want to save selected normalized PSD'...
                    'features cropped for modality ' Classifiers{i}.modality...
                    ' ?'], 'Attention!','Yes','No','No');
            else
                SAns = 'No';
            end

            if(strcmp(SAns,'Yes'))
                % Saving normalized selected PSD features
                Name = ['PSDselectNorm_' Classifiers{i}.modality '_' eegc3_daytime() '.mat'];
                disp(['[eegc3_smr_train] Saving selected normalized'...
                    'features from provided runs: ' Name]);
                save(Name,'cndataset');
            end
        
        else
            % Do not normalize
            Csettings{class_idx}.modules.smr.options.classification.norm = false;
            cndataset = cdataset;
            cndataset.settings = Csettings{class_idx};
        end        

        eegc3_figure(20 + i);
        eegc3_publish(14,14,3,3);
        [npdf1 npdf2] = eegc3_smr_cvaspace(cndataset.data,cndataset.labels,[1 2]);
        plot(npdf1.x,npdf1.f,'b',npdf2.x,npdf2.f,'r')
        title([Classifiers{i}.modality ' dataset in canonical space']);
        xlabel('1st canonical dimension');
        ylabel('PDF');
        legend('Class 1','Class2');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Classification
        
        if(usedlg)
            Ans = questdlg(['Do you want to train a CNBI Gaussian classifier for modality ' Classifiers{i}.modality...
                ' ?'], 'Attention!','Yes','No','Yes');
            if(strcmp(Ans,'Yes'))
                Csettings{class_idx}.modules.smr.options.classification.gau = true;
            else
                Csettings{class_idx}.modules.smr.options.classification.gau = false;
            end
        else
            if(Csettings{class_idx}.modules.smr.options.classification.gau)
                Ans = 'Yes';
            else
                Ans = 'No';
            end
        end

        if(strcmp(Ans,'Yes'))
            
            if(usedlg)
                % Ask for classifier settings
                ClassSettingsNames = {'Epochs','Rejection Threshold',...
                    'Mean Learning Rate', 'Covariance Learning Rate',...
                    'SOM dim 1','SOM dim 1','Shared Covariance (t or f)','Terminate ()'};
            
                Defaults = {num2str(Csettings{class_idx}.modules.smr.gau.epochs),...
                    num2str(Csettings{class_idx}.modules.smr.gau.th),...
                    num2str(Csettings{class_idx}.modules.smr.gau.mimean),...
                    num2str(Csettings{class_idx}.modules.smr.gau.micov),...
                    num2str(Csettings{class_idx}.modules.smr.gau.somunits(1)),...
                    num2str(Csettings{class_idx}.modules.smr.gau.somunits(2)),...
                    Csettings{class_idx}.modules.smr.gau.sharedcov,...
                    num2str(Csettings{class_idx}.modules.smr.gau.terminate)};
            
            
                ClassSettingsAns = inputdlg(ClassSettingsNames,...
                    'Classifier options', ones(1,1:...
                    length(ClassSettingsNames)), Defaults);
            
                % Set classification settings
                Csettings{class_idx}.modules.smr.gau.epochs = ...
                    str2num(ClassSettingsAns{1});
                Csettings{class_idx}.modules.smr.gau.th = ...
                    str2num(ClassSettingsAns{2});
                Csettings{class_idx}.modules.smr.gau.mimean = ...
                    str2num(ClassSettingsAns{3});
                Csettings{class_idx}.modules.smr.gau.micov = ...
                    str2num(ClassSettingsAns{4});
                Csettings{class_idx}.modules.smr.gau.somunits = ...
                    [str2num(ClassSettingsAns{5}) str2num(ClassSettingsAns{6})];
                Csettings{class_idx}.modules.smr.gau.sharedcov = ...
                    ClassSettingsAns{7};
                Csettings{class_idx}.modules.smr.gau.terminate = ...
                    str2num(ClassSettingsAns{8});
            
            else
                disp('[eegc3_smr_train] Default classification options will be used');  
            end
            
            % Train classifier
            disp(['[eegc3_smr_train] Training CNBI Gaussian classifier: ' Classifiers{i}.modality]);
            gau = eegc3_train_gau(Csettings{class_idx}, cndataset.data, ...
                cndataset.labels, cndataset.trial, hasInitClassifier);
            
             %%%%%%%%%%%%%%%%%%%%%%%%% Here: Training of a CNBI Gaussian Classifier. 
             %%%%%%%%%%%%%%%%%%%%%%%%% From the input data, the first 70% is used for training and the remaining 30% for testing.
             %%%%%%%%%%%%%%%%%%%%%%%%% Testing of balance of data.
             %%%%%%%%%%%%%%%%%%%%%%%%% gau: struct with the means and covariances of the Gaussian classifier prototypes
      
            
            Csettings{class_idx}.bci.smr.gau = gau;
         
            % Add trace
            Csettings{class_idx}.bci.smr.trace.Paths = cndataset.Paths;
        
            % Add modality
            Csettings{class_idx}.bci.smr.taskset.modality = Classifiers{i}.modality;
        
            % Add taskset (modality) class GDF events
            Csettings{class_idx}.bci.smr.taskset.classes = [Classifiers{i}.task_right ...
                Classifiers{i}.task_left];

        end

        
        if(usedlg)
            
            Ans = questdlg(['Do you want to train a LDA classifier for modality ' Classifiers{i}.modality...
                ' ?'], 'Attention!','Yes','No','Yes');
            if(strcmp(Ans,'Yes'))
                Csettings{class_idx}.modules.smr.options.classification.lda = true;
            else
                Csettings{class_idx}.modules.smr.options.classification.lda = false;
            end
        else
            if(Csettings{class_idx}.modules.smr.options.classification.lda)
                Ans = 'Yes';
            else
                Ans = 'No';
            end
        end

        if(strcmp(Ans,'Yes'))
            % Train classifier
            disp(['[eegc3_smr_train] Training LDA classifier: ' Classifiers{i}.modality]);
            lda = eegc3_train_lda(Csettings{class_idx}, cndataset.data, ...
                cndataset.labels, cndataset.trial);
            
            Csettings{class_idx}.bci.smr.lda = lda;
         
            % Add trace
            Csettings{class_idx}.bci.smr.trace.Paths = cndataset.Paths;
        
            % Add modality
            Csettings{class_idx}.bci.smr.taskset.modality = Classifiers{i}.modality;
        
            % Add taskset (modality) class GDF events
            Csettings{class_idx}.bci.smr.taskset.classes = [Classifiers{i}.task_right ...
                Classifiers{i}.task_left];
        end
        
        
        if(usedlg)
            
            Ans = questdlg(['Do you want to train a sepBCI classifier for modality ' Classifiers{i}.modality...
                ' ?'], 'Attention!','Yes','No','Yes');
            if(strcmp(Ans,'Yes'))
                Csettings{class_idx}.modules.smr.options.classification.sep = true;
            else
                Csettings{class_idx}.modules.smr.options.classification.sep = false;
            end
        else
            if(Csettings{class_idx}.modules.smr.options.classification.sep)
                Ans = 'Yes';
            else
                Ans = 'No';
            end
        end

        if(strcmp(Ans,'Yes'))
            
            % Train classifier
            disp(['[eegc3_smr_train] Training Sep classifier: ' Classifiers{i}.modality]);
            sep = eegc3_train_sep(Csettings{class_idx}, cndataset.data, ...
                cndataset.labels, cndataset.trial);
            
            Csettings{class_idx}.bci.smr.sep = sep;
         
            % Add trace
            Csettings{class_idx}.bci.smr.trace.Paths = cndataset.Paths;
        
            % Add modality
            Csettings{class_idx}.bci.smr.taskset.modality = Classifiers{i}.modality;
        
            % Add taskset (modality) class GDF events
            Csettings{class_idx}.bci.smr.taskset.classes = [Classifiers{i}.task_right ...
                Classifiers{i}.task_left];

        end   
        
%         if(usedlg)
%             
%             Ans = questdlg(['Do you want to train a single-class detection classifier?'...
%                  ''], 'Attention!','Yes','No','Yes');
%             if(strcmp(Ans,'Yes'))
%                 Csettings{class_idx}.modules.smr.options.classification.single = true;
%             else
%                 Csettings{class_idx}.modules.smr.options.classification.single = false;
%             end
%         else
%             if(Csettings{class_idx}.modules.smr.options.classification.single)
%                 Ans = 'Yes';
%             else
%                 Ans = 'No';
%             end
%         end
% 
%         if(strcmp(Ans,'Yes'))
%             
%             % Check which class the user wants to train for, out of the two available
%             SingleClass = questdlg(['Which class do you want ot train for?'...
%                 ''], 'Class selection',num2str(Classifiers{i}.task_right),...
%                 num2str(Classifiers{i}.task_left),num2str(Classifiers{i}.task_right));
%             SingleClass = str2num(SingleClass);
%             
%             if(SingleClass == Classifiers{i}.task_right)
%                 UseLbl = 1;
%             elseif(SingleClass == Classifiers{i}.task_left)
%                 UseLbl = 2;
%             else
%                 disp(['[eegc3_smr_train] No such class! Exiting!']);
%                 return;
%             end
%             
%             % Train classifier
%             disp(['[eegc3_smr_train] Training single class classifier for class: ' num2str(SingleClass)]);
%             single = eegc3_train_single(Csettings{class_idx}, cndataset.data, ...
%                 cndataset.labels, cndataset.trial, UseLbl);
%             
%             Csettings{class_idx}.bci.smr.single = single;
%             % Add trace
%             Csettings{class_idx}.bci.smr.trace.Paths = cndataset.Paths;
% 
%             
%             % Add modality
%             Csettings{class_idx}.bci.smr.taskset.modality = 'mirest';
%         
%             % Add taskset (modality) class GDF events
%             % The first task (right) is always considered to be: rest-> 783
%             Csettings{class_idx}.bci.smr.taskset.classes = [783 ...
%                 SingleClass];
%         end        

        % Save settings
        % Name of classifier
        SubjectID = Csettings{class_idx}.info.subject;
        Modality = Classifiers{i}.modality;
        Date = eegc3_daytime();
        
        if(Csettings{class_idx}.modules.smr.options.classification.gau)
            Name = [SubjectID '_' Modality '_' Date '.smr.mat'];
            settings = Csettings{class_idx};
            save(Name, 'settings');
            disp(['[eegc3_smr_train] Saved eegc3 CNBI Gausiian classifier/settings ' ...
            Classifiers{i}.modality ': ' Name]);
            
            % EEGC2 compatibility
            analysis = eegc3_downgrade_settings(settings);
            NameAnalysis = [SubjectID '_' Modality '_' Date '.mat'];
            save(NameAnalysis, 'analysis');
            disp(['[eegc3_smr_train] Saved eegc2 classifier ' ...
                Classifiers{i}.modality ': ' NameAnalysis]);
        end
        
        if(Csettings{class_idx}.modules.smr.options.classification.lda)
            Name = [SubjectID '_' Modality '_' Date '.smr.lda.mat'];
            settings = Csettings{class_idx};
            save(Name, 'settings');
            disp(['[eegc3_smr_train] Saved eegc3 LDA classifier/settings ' ...
            Classifiers{i}.modality ': ' Name]);
        
            % EEGC2 compatibility
            analysis = eegc3_downgrade_settings(settings);
            NameAnalysis = [SubjectID '_' Modality '_' Date '.lda.mat'];
            save(NameAnalysis, 'analysis');
            disp(['[eegc3_smr_train] Saved eegc2 LDA classifier (analysis)' ...
                Classifiers{i}.modality ': ' NameAnalysis]);
        end
        
        if(Csettings{class_idx}.modules.smr.options.classification.sep)
            Name = [SubjectID '_' Modality '_' Date '.smr.sep.mat'];
            settings = Csettings{class_idx};
            save(Name, 'settings');
            disp(['[eegc3_smr_train] Saved eegc3 Sep classifier/settings ' ...
            Classifiers{i}.modality ': ' Name]);
        
            % EEGC2 compatibility
            analysis = eegc3_downgrade_settings(settings);
            NameAnalysis = [SubjectID '_' Modality '_' Date '.sep.mat'];
            save(NameAnalysis, 'analysis');
            disp(['[eegc3_smr_train] Saved eegc2 Sep classifier (analysis)' ...
                Classifiers{i}.modality ': ' NameAnalysis]);
        end        
            
    end

end