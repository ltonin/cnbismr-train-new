function [aucAll , outputAll] = Mytrain_classifier_All_Auto(numSub_start, numSub)

%% Usage: [aucAll_1_9 outputAll_1_9] = Mytrain_classifier_All_Auto(1, 9)

% Inputs: 
%           numSub_start: Sub ID of first subject (from which you want to
%                       perform training)
%           numSub: Sub ID of last subject (until which you want to
%                       perform training)
%
% Outputs: 
%           aucAll: AUCs of all the requested subjects for both sessions
%           outputAll = Struct. (all subjects for both sessions)
%               Fields:
%                   output.data_Or = Struct with original dataset
%                   output.data_New = Struct with new dataset (the one used
%                                   for training. Can be different or the same with
%                                   output.data_Or depending on whether Artifact Rejection
%                                   was performed)
%                   output.rej_Trial: cell (1 x numRuns)
%                            Each cell contains a matrix: Which trials were rejected
%                   output.interpol_Chan = cell (1 x numRuns)
%                            Each cell contains a matrix: Which channels were interpolated
%                   output.susp_Trial: cell (1 x numRuns)
%                           Each cell contains a Matrix (1 x numTrials) with 0s and 1s. If 1 the
%                           corresponding trial is suspected for artifacts
%                   output.susp_chan: cell (1 x numRuns)
%                           Each cell contains a Matrix (1 x numChan) with 0s and 1s. If 1 the
%                           corresponding channel is suspected for artifacts
%                   output.statistics: cell (1 x numRuns)
%                           Each cell contains a Struct with fields:
%                                                       numSuspTrialPerChan: Matrix (1 x numChan) Number of suspected trials per channel
%                                                       numSuspChanPerTrial: Matrix (numTrials x 1) Number of suspected channels per trial
%                   output.thresholds: Struct with fields:
%                               thres_Trial: variance threshold for channels in order to judge trials
%                               thres_Chan: variance threshold above which a channel would be
%                                           considered suspected for artifacts
%                               maxChan: number of channels per trial that need to considered suspected
%                                           in order to consider a trial suspected

aucAll = zeros(numSub,2);
outputAll = cell(numSub,1);

try
    for sub = numSub_start:numSub
        
        %% File location for each subject
        FilePaths = {};
        files = {};
        
        if sub == 1 || sub == 3 || sub == 14 || sub == 24
            aucAll(sub,:) = 0;
            outputAll{sub} = 0;
            continue; % Skip them!
        elseif sub == 2
            FilePaths = [getenv('TOLEDO_DATA') '/Sub2/20111122/AR/'];
            files = dir([FilePaths '*.gdf']);
        elseif sub == 4 || sub == 6 || sub == 7
            FilePaths =  [getenv('TOLEDO_DATA') '/Sub' num2str(sub) '/20111123/AR/'];
            files = dir([FilePaths '*.gdf']);
        elseif sub == 5
            FilePaths =  [getenv('TOLEDO_DATA') '/Sub' num2str(sub) '/20111123/'];
            files = dir([FilePaths '*.gdf']);
        else % For all the remaining subjects...
            FilePaths =  [getenv('TOLEDO_DATA') '/Sub' num2str(sub) '/AR/'];
            files = dir([FilePaths '*.gdf']);
        end
        
        
        aucSub = zeros(1,2);
        outputSub = cell(1,2);
        
        %% Auto-train
        for i = 1:2
            sessionNum = i;
            
            % SET THE PATHS
            if sub == 5 % Sub5 : First 4 gdfs corrupted. Skip Session 1!
                paths = {[FilePaths files(5,1).name], [FilePaths files(6,1).name], [FilePaths files(7,1).name], [FilePaths files(8,1).name]};
                aucSub(1,1) = 0; % Skip Session 1!
                sessionNum = 2;
                %               [auc,output] = Myeegc3_smr_autotrain(paths,sessionNum);
                %[auc,output] = Myeegc3_smr_autotrain_UseLda(paths,sessionNum);
                               [auc,output] = Myeegc3_smr_autotrain_UseGau(paths,sessionNum);
                auc
                aucSub(1,sessionNum) = auc;
                outputSub{sessionNum} = output;
                break;
            elseif sub == 9 % Sub9 : only 7 gdfs! (Session1 = first 3, Session2 = last 4)
                if i==1
                    paths = {[FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name]};
                else
                    paths = {[FilePaths files((i-1)*4,1).name], [FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name]};
                end
            elseif sub == 15 || sub == 30 || sub ==33 % Sub15, Sub30 and Sub33 : only 7 gdfs!  (Session1 = first 4, Session2 = last 3)
                if i==1
                    paths = {[FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name], [FilePaths files((i-1)*4+4,1).name]};
                else
                    paths = {[FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name]};
                end
            elseif sub == 18 % Sub18 : 9 gdfs! (Session1 = first 3, Session2 = last 6 ???)
                if i==1
                    paths = {[FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name]};
                else
                    paths = {[FilePaths files((i-1)*4,1).name], [FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name], [FilePaths files((i-1)*4+4,1).name], [FilePaths files((i-1)*4+5,1).name]};
                end
            elseif sub == 19 % Sub19 : 9 gdfs! (Session1 = first 5, Session2 = last 4)
                if i==1
                    paths = {[FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name], [FilePaths files((i-1)*4+4,1).name], [FilePaths files((i-1)*4+5,1).name]};
                else
                    paths = {[FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name], [FilePaths files((i-1)*4+4,1).name], [FilePaths files((i-1)*4+5,1).name]};
                end
            else % For all the remaining subjects...
                paths = {[FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name], [FilePaths files((i-1)*4+4,1).name]};
            end
            
            %[auc,output] = Myeegc3_smr_autotrain(paths,sessionNum);
            %[auc,output] = Myeegc3_smr_autotrain_UseLda(paths,sessionNum);
            [auc,output] = Myeegc3_smr_autotrain_UseGau(paths,sessionNum);
            auc
            % 
            output=rmfield(output,'data_New');
            output=rmfield(output,'data_Or');
            %
            aucSub(1,sessionNum) = auc;
            outputSub{sessionNum} = output;
        end
        
        aucAll(sub,:) = aucSub;
        outputAll{sub} = outputSub;
    end
    % Save mat files...
     nameAuc = ['aucAll_' num2str(numSub_start) '_' num2str(numSub) '.mat'];
     nameOutput = ['outputAll_' num2str(numSub_start) '_' num2str(numSub) '.mat'];
     save([getenv('TOLEDO_DATA') '/Results/All/Results_GAU_CVA_Rejection_'  nameAuc], 'aucAll');
     save([getenv('TOLEDO_DATA') '/Results/All/Results_GAU_CVA_Rejection_'  nameOutput], 'outputAll','-v7.3');
catch error
    disp(['Stopped at Subject: ' num2str(sub)]);
    disp(['The following error was detected:  ' error.message])
    
end

