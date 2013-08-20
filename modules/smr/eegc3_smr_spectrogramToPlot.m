% eegc3_smr_spectrogram Spectrogram ready to be plot
%
% eegc3_smr_spectrogram TODO
% eegc3_smr_spectrogram (bci.afeats, bci.lbl_sample,bci.lbl, bci.MI.task(1), ...
%   bci.settings.acq.channels_eeg, bci.settings.modules.smr.psd.freqs, ...
%   bci.dur(4)+1,    

function [avg_spectrogram] = eegc3_smr_spectrogramToPlot(data, lbl_sample, lbl, evt , task, Nelec, freqs, tr_length)

% Consider 2 seconds pretrial
preTime = 32;

tmp_idx = find(lbl_sample ==  task);
tmp_tr_number = length(tmp_idx)/tr_length;
% include 0.5s of preparation
tmp_prep_idx = [];
tmp_evt = evt(find(lbl == 770));
tmp_Ntr = length(find(lbl == 770));
for i = 1: tmp_Ntr
    tmp_prep_idx = [tmp_prep_idx tmp_evt(i)-((1:preTime) -3)];
end
tmp_idx = [tmp_prep_idx tmp_idx'];
% Spectrogram
tmp_spectrogram = data(tmp_idx,:,:);
tmp_spectrogram = reshape(tmp_spectrogram,...
    [tmp_tr_number, tr_length+preTime, length(freqs), Nelec]);
avg_spectrogram = squeeze((mean(tmp_spectrogram)));