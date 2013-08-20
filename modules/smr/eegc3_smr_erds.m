% eegc3_smr_erds ERD/S
%
% eegc3_smr_erds calculates erd/s on epochs extracted from data , with 
% respect to baseline.
% 
% Algorithm initially proposed by  Pfurtscheller et al. "Event-related 
% EEG/MEG synchronization and desynchronization: basic principles", 
% Clinical Neurophysiology, 1999.

function [avg_erds] = eegc3_smr_erds(data,filt)

fs = 512;

[B,A] 	= butter(filt.bfo,[filt.lcf filt.hcf]/(fs/2));
tmp_s 	= filter(B,A,data.eeg);

% Notch
Wo = 50/(fs/2);  BW = Wo/35;
[b,a] = iirnotch(Wo,BW); 
tmp_s = filter(b,a,tmp_s);

% Squaring
for el = 1:size(tmp_s,2)
    tmp_s(:,el) = tmp_s(:,el).^2;
end

% Extracting epochs 
Classes = [770 769 783];
avg_erds = cell([1  length(Classes)]);

win_size = [-1 4.75]; % epochs to be considered (in seconds)
epochs = cell([1  length(Classes)]);
for cl = 1: length(Classes)
    events = data.hdr.EVENT.POS(find(data.hdr.EVENT.TYP == Classes(cl)));
    Ntrials = length(find(data.hdr.EVENT.TYP == Classes(cl)));
    epochs{cl} = zeros([Ntrials (win_size(2)-win_size(1))*fs]);
    
    idxs = win_size*fs;
    idxs = (idxs(1):(idxs(2)-1))-1;
    
    % Extract trigger positions
    tmp_idxs = [];
    for tr = 1:Ntrials
        tmp_idxs = [tmp_idxs idxs+events(tr)];
    end
    
    epochs{cl} = tmp_s(tmp_idxs,:);

    % Build epochs
    epochs{cl} = reshape(epochs{cl}',...
        Ntrials, (win_size(2)-win_size(1))*fs, size(tmp_s,2));    
    
    % Averaging
    tmp_avg = squeeze(mean(epochs{cl},1));
    
    % Relative power
    bl_win = 1:512; % baseline period [-1 0]s
    baseline =mean(tmp_avg(bl_win,:),1);
    avg_erds{cl} = zeros(size(tmp_avg));
    for ch = 1:size(tmp_avg,2)
        avg_erds{cl}(:,ch) = (tmp_avg(:,ch)-baseline(ch))./baseline(ch)*100;
    end
end

