function [data_New, data_Or, output] = Myeegc3_ArtifactRejection(data, guiOption)

% Inputs:
%       data: cell (1 x numRuns)
%               Each cell contains a Struct (Form of data: same as in eegc3_smr_simloop)
%       guiOption: 1 for launching gui
%                  0 for not launching gui and performing default behavior
%                  (perform Artifact Rejection with default threshold
%                  values)
%
% Outputs:
%       data_New = new dataset AFTER Artifact Rejection
%       data_Or = original dataset BEFORE Artifact Rejection (=data)
%       output = Struct. Fields:
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


% Always return original dataset
data_Or = data;

if guiOption == 1
    % Launch Gui 1: Perform Artifact Rejection or not?
    userResp = Myeegc3_gui_1;
else
    % Default behavior: Perform Artifact Rejection with default threshold values
    userResp = 2;
end


if userResp == 1 % LAUNCH GUI
    
    [data_New, output] = Myeegc3_gui_ArtRej(data);
    
elseif userResp == 2  % NO GUI!
    
    % Calculate variances
    [output.variance, output.meanOfVariance] = Myeegc3_Variance(data);
    
    % Set the default thresholds (uncomment the one you want: always same or changing according to dataset?)
%     output.thresholds.thres_Trial = 800;
%     output.thresholds.thres_Chan = 800;
   
    output.thresholds.thres_Trial = 2*max(output.meanOfVariance{1,1});
    output.thresholds.thres_Chan = 2*max(output.meanOfVariance{1,1});
    
    output.thresholds.maxChan = 3;
    
    % Judge...
    [output.susp_Trial, output.susp_Chan, output.statistics] = Myeegc3_JudgeVariance(data, output.variance, output.meanOfVariance, output.thresholds);
    
    [data_Curr, output.rej_Trial] = Myeegc3_DiscardTrials(data, output.susp_Trial);
    
    %%% Uncomment when Myeegc3_InterpolateChan is ready...
    %%[data_New, output.interpol_Chan] = Myeegc3_InterpolateChan(data_Curr, output.susp_Chan);
    
    %%% But for now set the following values:
    output.interpol_Chan = 0;
    data_New = data_Curr;
    
elseif userResp == 0 % NO ARTIFACT REJECTION!
    data_New = data;
    output.rej_Trial = 0;
    output.interpol_Chan = 0;
    output.statistics = 0;
    output.thresholds = 0;
    output.susp_Trial = 0;
    output.susp_Chan = 0;
    
    % Calculate variances (just for completeness)
    [output.variance, output.meanOfVariance] = Myeegc3_Variance(data);
    
end



