% eegc3_smr_spectrogram Spectrogram ready to be plot
%
% eegc3_smr_spectrogram TODO
% eegc3_smr_spectrogram (bci.afeats, bci.lbl_sample,bci.lbl, bci.MI.task(1), ...
%   bci.settings.acq.channels_eeg, bci.settings.modules.smr.psd.freqs, ...
%   bci.dur(4)+1,    

function [avg_spectrogram] = eegc3_smr_spectrogramToPlot(data, lbl_sample, lbl, evt , task, Nelec, freqs, tr_length)

% Consider 2 seconds pretrial
preTime = 32;

% Extract samples belonging to a certain task
tmp_idx = find(lbl_sample ==  task);
tmp_tr_number = length(tmp_idx)/tr_length;

% include 0.5s of preparation
tmp_prep_idx = [];
tmp_evt = evt(find(lbl == task));
tmp_Ntr = length(find(lbl == task));
for i = 1: tmp_Ntr
    tmp_prep_idx = [tmp_prep_idx tmp_evt(i)-((1:preTime) -3)];
end
tmp_idx = [tmp_prep_idx tmp_idx'];

% Spectrogram
tmp_spectrogram = data(tmp_idx,:,:);
avg_spectrogram = nan([tmp_tr_number, tr_length+preTime, length(freqs), Nelec]);
for tr = 1:tmp_tr_number
    for time = 1: tr_length+preTime
        for fr = 1: length(freqs)
            for elec = 1:Nelec
                avg_spectrogram(tr, time, fr, elec) = ...
                    tmp_spectrogram(time+(tr_length+preTime)*(tr-1),fr,elec);
            end
        end
    end
end
avg_spectrogram = squeeze((mean(avg_spectrogram)));