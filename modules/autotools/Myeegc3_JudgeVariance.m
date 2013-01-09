function [susp_Trial, susp_Chan, statistics] = Myeegc3_JudgeVariance(data, variance, meanOfVariance, thresholds)

% Inputs:   
%           data: cell (1 x numRuns) 
%                   Each cell contains a Struct (Form of data: same as in eegc3_smr_simloop)
%           variance: cell (1 x numRuns)
%                     variance of every trial and every channel
%                     Each cell contains a Matrix (Number of Trials x Number of Channels)
%           meanOfVariance: cell (1 x numRuns)
%                           average variance of every channel across all trials
%                           Each cell contains a Matrix (1 x Number of Channels)
%           thresholds: Struct with fields:
%                               thres_Trial: variance threshold for channels in order to judge trials
%                               thres_Chan: variance threshold above which a channel would be
%                                           considered suspected for artifacts
%                               maxChan: number of channels per trial that need to considered suspected
%                                           in order to consider a trial suspected
% Outputs:
%           susp_Trial: cell (1 x numRuns)
%                       Each cell contains a Matrix (1 x numTrials) with 0s and 1s. If 1 the
%                       corresponding trial is suspected for artifacts
%           susp_chan: cell (1 x numRuns)
%                       Each cell contains a Matrix (1 x numChan) with 0s and 1s. If 1 the
%                       corresponding channel is suspected for artifacts
%           statistics: cell (1 x numRuns)
%                               Each cell contains a Struct with fields:
%                                                       numSuspTrialPerChan: Matrix (1 x numChan) Number of suspected trials per channel
%                                                       numSuspChanPerTrial: Matrix (numTrials x 1) Number of suspected channels per trial
%
% The above cells are also saved (if you uncomment the corresponding part)
%
% Remarks: 
% - A Channel is considered contaminated if its variance across the
% trials is above the threshold (thres_Chan)
% - A Trial is considered contaminated if the variance of a certain number(maxChan) (or more) of channels 
% within the trial is above the threshold (thres_Trial)

if iscell(data)
    numRuns = size(data,2);
else
    numRuns = 1;
end

susp_Trial = cell(1,numRuns);
susp_Chan = cell(1,numRuns);
statistics = cell(1,numRuns);

% Judge...
for run = 1:numRuns
    
    numTrials = max(data{run}.trial_idx);
    numChan = size(data{run}.eeg,2) - 1;
    temp_Trials = zeros(numTrials, numChan);
    
    susp_Chan{run} = zeros(1,numChan);
    susp_Trial{run} = zeros(1,numTrials);
    
    % Judge channels
    susp_Chan{run}(meanOfVariance{run} >= thresholds.thres_Chan) = 1;
    
    % Judge trials
    for i = 1:numTrials
        temp_Trials(i,:) = (variance{run}(i,:) >= thresholds.thres_Trial);
    end
    
    % Number of suspected channels for every trial
    numSuspChanPerTrial = sum(temp_Trials,2);
    
    % Suspected trials
    susp_Trial{run}(numSuspChanPerTrial >= thresholds.maxChan) = 1;
    
    % Number of suspected trials for every channel
    numSuspTrialPerChan = sum(temp_Trials,1);
    
    % % Save results and statistics
    % saveas(numSuspTrialPerChan,['/homes/vliakoni/' 'numSuspTrialPerChan' '.mat']);
    % saveas(numSuspChanPerTrial,['/homes/vliakoni/' 'numSuspChanPerTrial' '.mat']);
    % saveas(susp_Trial,['/homes/vliakoni/' 'susp_Trial' '.mat']);
    % saveas(susp_Chan,['/homes/vliakoni/' 'susp_Chan' '.mat']);
    
    % Return statistics
    statistics{run}.numSuspTrialPerChan = numSuspTrialPerChan;
    statistics{run}.numSuspChanPerTrial = numSuspChanPerTrial;
end

