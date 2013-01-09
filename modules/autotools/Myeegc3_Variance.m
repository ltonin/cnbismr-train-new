function [variance, meanOfVariance] = Myeegc3_Variance(data)

% Input:
%       data: cell (1 x numRuns) 
%                   Each cell contains a Struct (Form of data: same as in eegc3_smr_simloop)
% Outputs:
%       variance: cell (1 x numRuns)
%                     variance of every trial and every channel
%                     Each cell contains a Matrix (Number of Trials x Number of Channels)
%       meanOfVariance: cell (1 x numRuns)
%                           average variance of every channel across all trials
%                           Each cell contains a Matrix (1 x Number of Channels)
if iscell(data)
    numRuns = size(data,2);
else
    numRuns = 1;
end

variance = cell(1, numRuns);
meanOfVariance = cell(1, numRuns);

for run = 1:numRuns
    
    numTrials = max(data{run}.trial_idx);
    numChan = size(data{run}.eeg,2) - 1;
    
    variance{run} = zeros(numTrials, numChan);
    
    % Each row of the matrix variance contains the variances of the channels
    % during the corresponding trial
    for i = 1:numTrials
        variance{run}(i,:) = var(data{run}.eeg(data{run}.trial_idx==i,1:end-1));
    end
    
    % The matrix meanOfVariance contains the mean variance of every channel across all trials
    meanOfVariance{run} = mean(variance{run});
end