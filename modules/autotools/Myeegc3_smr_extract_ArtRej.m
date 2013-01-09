function [dataset, output] = Myeegc3_smr_extract_ArtRej(Paths, settings, usedlg)
% Edited by S. Perdikis <serafeim.perdikis@epfl.ch> on 29/01/11
%
% EEGC3_SMR_EXTRACT is the eegc3 function that prepares the dataset (data 
% and labels) for classifier training. The input arguments can be collected
% by using eegc3_train_gui. Paths is a cell array containing the filepaths
% of the GDF file(s) (runs) to be used for feature extraction. Settings is
% a structure (of the type returned by eegc3_settings and 
% eegc3_smr_settings) containing the necessary settings for feature
% extraction.
%
% function [data labels] = eegc3_smr_extract(Paths, settings)
%    
%    Accepts:
%       PATHS      cell array
%       SETTINGS   struct
%
%    Returns:
%       DATASET    struct  
%

if(nargin < 3)
    usedlg = true;
end

% Call eegc3_smr_simloop for every given run
FileNum = length(Paths);

% Check whether subject ID is uniform across runs
IDs = eegc3_subjectID(Paths);
if(length(unique(IDs)) > 1)
    if(usedlg)
        Ans = questdlg(['[eegc3_smr_extract] It seems that you requested'...
            ' features for CNBI runs'...
            ' that belong to more than one subjects... Are you sure you want to'...
            ' continue?'],'Attention!','Yes','No','No');
    else
        disp(['[eegc3_smr_extract] It seems that you requested'...
            ' features for CNBI runs that belong to more than one subjects...']);
        Ans = 'Yes';
    end
    
    if(strcmp(Ans,'No'))
        dataset = [];
        return;
    end
else
    
    % Check if the requested classifier is for the same subject
    ID = IDs{1};
    if(~isequal(settings.info.subject,ID))
        
        if(usedlg)
             Ans = questdlg(['[eegc3_smr_extract] It seems that you might'...
                 'have set a subject code'...
            ' other than the one which performed the selected runs... Are you'...
            ' sure you want to continue?'],'Attention!','Yes','No','No');
        else
            disp(['[eegc3_smr_extract] It seems that you requested a classifier for a subject'...
            ' other than the one which performed the selected runs...']);
            Ans = 'Yes';
        end
    
        if(strcmp(Ans,'No'))
            dataset = [];
            return;
        end 
    end
 
end

% Check that all runs used the same sampling frequency and channels
[Curr_Fs Curr_ChanNum] = eegc3_GDFInfo(Paths{1});

for i=2:FileNum
    
    [New_Fs New_ChanNum] = eegc3_GDFInfo(Paths{i});
    if((New_Fs ~= Curr_Fs) || (New_ChanNum ~= Curr_ChanNum))
    
        disp(['[eegc3_smr_extract] Runs with different sampling frequency'...
            'and/or channel configuration detected! Script exiting...']);
        return;
    end
end

dataset.run = {};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simloop is split into two halves.
        % 1) Get raw data for all runs (1st half)
        % 2) Call Artifact rejection procedure for all runs
        % 3) Calculate spectrums for all runs (2nd half)
dataRaw = cell(1,FileNum);
        
for i=1:FileNum
    %if(settings.modules.smr.options.extraction.fast)
        [bci, data, taskset, resetevents, doplot, protocol_label] = Myeegc3_smr_simloop_fast_Half_1(Paths{i},[],settings,[],[]);
        dataRaw{i} = data;
        bciAll{i} = bci;
        tasksetAll{i} = taskset;
        reseteventsAll{i} = resetevents;
        doplotAll{i} = doplot;
        protocol_labelAll{i} = protocol_label;
%    else
%         bci = Myeegc3_smr_simloop_Half_1(Paths{i},[],settings,[],[]);
%         dataRaw{i} = data;
%         bciAll{i} = bci;
%         tasksetAll{i} = taskset;
%         reseteventsAll{i} = resetevents;
%         doplotAll{i} = doplot;
%         protocol_labelAll{i} = protocol_label;
%     end
    
end

% Artifact Rejection (Called with all the runs)
[data_New, data_Or, output] = Myeegc3_ArtifactRejection(dataRaw, 0);
output.data_New = data_New;
output.data_Or = data_Or;

% To return to normal Myeegc3_smr_extract, comment the above three lines
% and uncomment the next two
% data_New = dataRaw;
% output = 0;

for i=1:FileNum
    %if(settings.modules.smr.options.extraction.fast)
        bci = Myeegc3_smr_simloop_fast_Half_2(tasksetAll{i}, data_New{i}, bciAll{i}, [], ... 
	bciAll{i}.trace.eegc3_smr_simloop.rejection, bciAll{i}.trace.eegc3_smr_simloop.integration, doplotAll{i}, reseteventsAll{i}, protocol_labelAll{i});    
    %bci = Myeegc3_smr_simloop_fast(Paths{i},[],settings,[],[]);
    %else
     %   bci =Myeegc3_smr_simloop_Half_2(tasksetAll{i}, data_New{i}, bciAll{i}, [], ... 
	% bciAll{i}.trace.eegc3_smr_simloop.rejection, bciAll{i}.trace.eegc3_smr_simloop.integration, doplotAll{i}, reseteventsAll{i}, protocol_labelAll{i}); 
    %end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    disp(['[eegc3_smr_extract] Extracting/loading features for: ' ...
        bci.trace.eegc3_smr_simloop.filexdf]);
    
    % Extract per trial performances for this run, if it is online
    [tkset, rev, prot_label] = eegc3_smr_guesstask(bci.lbl);
    if(strcmp(prot_label,'SMR_Online_eegc3'))
        % Performance of different classes
        corr = zeros(length(tkset.cues),1);
        err = zeros(length(tkset.cues),1);
        for c = 1:length(tkset.cues)
            % Find cues of this type
            cind = find(bci.lbl==tkset.cues(c));
            resind = cind+2;
            corr(c) = sum(bci.lbl(resind)==897);
            err(c) = sum(bci.lbl(resind)==898);
            disp(['[eegc3_smr_extract] Class ' num2str(tkset.cues(c))...
                ': ' num2str(corr(c)) '/' num2str(corr(c)+err(c)) ', '...
                num2str(100*corr(c)/(corr(c)+err(c))) ' %']);
        end
        disp(['[eegc3_smr_extract] Total: ' num2str(100*sum(corr)/...
            (sum(corr)+sum(err))) ' %' ]);
    end
    
    
    % Check that the requested settings are the same as those used for the
    % feature computation (in case features are precomputed and only loaded 
    % by this script)
    
    % Exclude incopatibility due to subject code (it has been questioned 
    % before)
    tmp1 = settings;
    tmp2 = bci.settings;
    tmp1.info.subject = [];
    tmp2.info.subject = [];
    isCompatible = eegc3_smr_comparesettings(tmp1, tmp2);
    if(~isCompatible)
        
        % Ask whether to recompute with current settings
        if(usedlg)
            Ans = questdlg(['[eegc3_smr_extract] It seems that the precomputed features for this'...
                ' run did not use the same settings you have requested...'...
                ' Do you wish to recompute' ...
                ' the features for this run?'],'Attention!','Yes','No','No');
        else
            disp(['[eegc3_smr_extract] It seems that the precomputed'...
                'features for this run did not use the same settings you'...
                'have requested. Features will be recomputed']);
            Ans = 'Yes';
        end
    
        if(strcmp(Ans,'Yes'))
            % Recompute with current settings
            if(settings.modules.smr.options.extraction.fast)
                bci = Myeegc3_smr_simloop_fast(Paths{i},[],settings,[],[],...
                    false, [781 898 897], 1);
            else
                bci = Myeegc3_smr_simloop(Paths{i},[],settings,[],[],...
                    false, [781 898 897], 1);
            end
        end 
    end
    
    dataset.run{i}.data = bci.afeats;
    dataset.run{i}.labels = bci.lbl_sample;
    dataset.run{i}.trial = bci.trial_idx;
    dataset.run{i}.path = bci.trace.eegc3_smr_simloop.filexdf;
end
