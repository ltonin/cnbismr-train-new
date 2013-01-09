function [data_New, rej_Trial] = Myeegc3_DiscardTrials(data, susp_Trial)

% Inputs: 
%           data: cell (1 x numRuns)
%                   Ech cell contains a Struct (Form of data: same as in eegc3_smr_simloop)
%           susp_Trial: Matrix (1 x numTrials) with 0s and 1s. If 1 the
%                       corresponding trial is suspected for artifacts
% Outputs:
%           data_New: cell (1 x numRuns)
%                       New dataset AFTER Trial Rejection (does NOT include the rejected trials)
%           rej_Trial: cell (1 x numRuns)
%                       Which trials were rejected


if iscell(data)
    numRuns = size(data,2);
else
    numRuns = 1;
end

rej_Trial = cell(1, numRuns);

data_New = data;

for run = 1:numRuns
    
    % Find which trials are to be rejected
    notKeep = find(susp_Trial{run} == 1);
    % Return which trials are to be rejected
    rej_Trial{run} = notKeep;
    
    % Find which trials are to be kept (useful for later)
    keep = find(susp_Trial{run} == 0);
    
    %%% SAMPLES
    % First 'mark' as NaN the samples that are to be rejected
    for i = 1:length(notKeep)
        if i == 1 && notKeep(1) == 1 % If the first trial is rejected
            data_New{run}.eeg(1 : data{run}.pos(4) + data{run}.dur(4), :) = NaN;
        else
            data_New{run}.eeg(1 + data{run}.pos(4*(notKeep(i)-1)) + data{run}.dur(4*(notKeep(i)-1)) : data{run}.pos(4*notKeep(i)) + data{run}.dur(4*notKeep(i)), :) = NaN;
        end
    end

    % And then crop them out
    markedSamples = isnan(data_New{run}.eeg(:,1));
    sampleToRej = find(markedSamples == 1);
    data_New{run}.eeg(sampleToRej,:) = [];
    
    %%% DURATIONS, LBL
    % Find the indices that need to be cropped out
    notKeep_2 = notKeep*4; % (One trial every 4 elements)
    indNotKeep_2 = [notKeep_2-3; notKeep_2-2; notKeep_2-1; notKeep_2];
    indNotKeep_2 = reshape(indNotKeep_2, numel(indNotKeep_2), 1);
    
    % And crop them out...
    data_New{run}.dur(indNotKeep_2) = [];
    data_New{run}.lbl(indNotKeep_2) = [];
    
    %%% POSITIONS
    data_New{run}.pos = zeros(length(data_New{run}.dur),1);
   
    for i = 1:length(keep)
        if (4*i-3) == 1 % Determine which is the first position
            if keep(1) == 1 % If the first trial is to be kept, then the first position is the one of the initial data set.
                data_New{run}.pos(1) = data{run}.pos(1);
            else  % If the first trial is NOT kept determine which is the first position...
                data_New{run}.pos(4*i-3) = data{run}.pos(4*keep(1)-3) - (data{run}.pos(4*(keep(1)-1)) + data{run}.dur(4*(keep(1)-1)));
            end
        else
            data_New{run}.pos(4*i-3) = data_New{run}.pos(4*i-3-1) + data_New{run}.dur(4*i-3-1) + data{run}.pos(4*keep(i)-3) - (data{run}.pos(4*keep(i)-4) + data{run}.dur(4*keep(i)-4));
        end
        data_New{run}.pos(4*i-2) = data_New{run}.pos(4*i-3) + data_New{run}.dur(4*i-3)+1;
        data_New{run}.pos(4*i-1) = data_New{run}.pos(4*i-2) + data_New{run}.dur(4*i-2)+1;
        data_New{run}.pos(4*i) = data_New{run}.pos(4*i-1) + data_New{run}.dur(4*i-1)+1;
    end

    %%% TRIAL_IDX, LBL_SAMPLE
    data_New{run}.lbl_sample = zeros(1,length(data_New{run}.eeg));
    data_New{run}.trial_idx = zeros(1,length(data_New{run}.eeg));
    
    for i = 1 : (length(data_New{run}.pos))/4
        data_New{run}.lbl_sample(data_New{run}.pos(4*i):data_New{run}.pos(4*i)+data_New{run}.dur(4*i)) = data_New{run}.lbl(4*i-1);
        data_New{run}.trial_idx(data_New{run}.pos(4*i):data_New{run}.pos(4*i)+data_New{run}.dur(4*i)) = i;
    end
    
    %%% RED 
    % (Just put 1 at the places indicated by the positions)
    data_New{run}.red = zeros(1,length(data_New{run}.eeg));
    data_New{run}.red(data_New{run}.pos) = 1;
    
    %%% LPT
    % Just zeros
    data_New{run}.lpt = zeros(length(data_New{run}.eeg),1);
    
end