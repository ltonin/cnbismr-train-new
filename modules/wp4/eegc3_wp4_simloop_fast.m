function bci = eegc3_wp4_simloop_fast(filexdf, filetxt, filemat, ...
    rejection, integration, doplot, resetevents, recompute)
% 2013 Andrea Biasiucci <andrea.biasiucci@epfl.ch>
% 2012 Simis for compatibility with eegc3_smr_train
% 2010 Michele Tavella <michele.tavella@epfl.ch>
%
%
% IMPORTANT: This function is used BOTH for protocol simulation reasons
% (when the information of the settings, the classifier, the rejection and
% the integration is needed) AND for classifier training reasons (when the
% settings are selected according to the desired NEW classifier settings
% and NOT according to the settings used when the EEG data was collected --
% apparently this applies for the online runs, since simprotocol only
% applies for online runs)
%
% SEPARATNG the two cases in this function is done by checking whether the
% filetxt argument is empty or not. Passing empty 'filetxt' will treat this
% run (gdf) as data for training, otherwise the script expects also the
% information of rejection and integration in order to re-compute the
% online probabilites (simloop - simprotocol). This difference will also
% siginify whether this script will look for pre-processed features in a
% 'GDFBASENAME.simloop.mat' file or in a 'GDFBASENAME.trnloop.mat' file,
% thus % completely separating the two cases. Both kinds of files are
% however saved into the 'eegc3' folder
%
% TODO Add call info
tic;
if(nargin < 6)
    doplot = false;
end
if(nargin < 7)
    % These events are defaulted for SMR BCI:
    %   781		Continuous Feedback
    %   897		Target hit
    %   898		Target miss
    resetevents = [781 898 897];
end

if(nargin < 8)
    recompute = false;
end

% Create extra/ directory
[extra.directory, extra.basename] = eegc3_mkextra(filexdf, 'eegc3');

% Inialize BCI structure
bci = eegc3_smr_newbci();
bci.trace.eegc3_smr_simloop.datetime    = eegc3_datetime();
bci.trace.eegc3_smr_simloop.filexdf     = filexdf;
bci.trace.eegc3_smr_simloop.filetxt     = filetxt;
bci.trace.eegc3_smr_simloop.rejection   = rejection;
bci.trace.eegc3_smr_simloop.integration = integration;
bci.trace.eegc3_smr_simloop.resetvents  = resetevents;

if(~isempty(bci.trace.eegc3_smr_simloop.integration))
    bci.trace.eegc3_smr_simloop.filemat		= ...
        strrep([extra.directory '/' extra.basename], '.gdf', '.simloop.mat');
else
    bci.trace.eegc3_smr_simloop.filemat		= ...
        strrep([extra.directory '/' extra.basename], '.gdf', '.trnloop.mat');
end
bci.trace.eegc3_smr_simloop.figbasename = ...
    strrep([extra.directory '/' extra.basename], '.gdf', '');

if(~isempty(bci.trace.eegc3_smr_simloop.integration))
    printf('[eegc3_wp4_simloop_fast] Running simulated SMR-BCI loop:\n');
    printf(' < GDF:         %s\n', bci.trace.eegc3_smr_simloop.filexdf);
    printf(' < TXT:         %s\n', bci.trace.eegc3_smr_simloop.filetxt);
    printf(' > MAT:         %s\n', bci.trace.eegc3_smr_simloop.filemat);
    printf(' - Rejection:   %f\n', bci.trace.eegc3_smr_simloop.rejection);
    printf(' - Integration: %f\n', bci.trace.eegc3_smr_simloop.integration);
else
    printf('[eegc3_wp4_simloop_fast] Running training SMR-BCI loop:\n');
    printf('[eegc3_wp4_simloop_fast] Potential existing TXT file, rejection and integration params are ignored.\n');
    printf(' < GDF:         %s\n', bci.trace.eegc3_smr_simloop.filexdf);
    printf(' > MAT:         %s\n', bci.trace.eegc3_smr_simloop.filemat);
end

if(exist(bci.trace.eegc3_smr_simloop.filemat, 'file') && (~recompute))
    printf('[eegc3_wp4_simloop_fast] Loading precomputed MAT: %s\n', ...
        bci.trace.eegc3_smr_simloop.filemat);
    load(bci.trace.eegc3_smr_simloop.filemat);
    
%    % Plot spectrum
%    printf('[eegc3_wp4_simloop_fast] Plotting precomputed EEG spectrum');
%    eegc3_smr_plotSpectrum(bci, bci.trace.eegc3_smr_simloop.filexdf, ...
%        bci.settings.modules.smr.montage);
    return;
end

% Import all the data we need
printf('[eegc3_wp4_simloop_fast] Loading GDF/TXT files... ');
[data.eeg, data.hdr] = sload(filexdf);
if(~isempty(bci.trace.eegc3_smr_simloop.filetxt))
    data.aprobs = importdata(filetxt);
    data.cprobs = data.aprobs(:, 1:2);
    data.iprobs = data.aprobs(:, 3:4);
end
printf('Done!\n');

% Extract trigger informations
data.lpt = data.eeg(:, end);
data.lpt(find(data.lpt > 1)) = 1;		% To be changed = 0
data.evt = gettrigger(data.lpt);
data.red = zeros(1, size(data.eeg,1));

if (length(data.evt) ~= length(data.hdr.EVENT.POS))
    disp('It seems that HW triggers are missing. Using SW trigger positions and durations instead');
    data.red(data.hdr.EVENT.POS) = 1;
    data.pos = data.hdr.EVENT.POS;
else
    disp('Using HW trigger positions for precise timing');
    data.red(data.evt) = 1;
    data.pos = data.evt;
end

data.lbl = data.hdr.EVENT.TYP;
data.dur = data.hdr.EVENT.DUR;

% Set up simulated BCI
if(isstruct(filemat))
    bci.settings = filemat;
else
    
    bci.analysis = load(filemat);
    
    % Check if it is an eegc2 or eegc3 settings file
    if(isfield(bci.analysis,'analysis'))
        disp('eegc2 settings format detected, converting to eegc3...');
        bci.settings =  eegc3_eegc2_updatesettings(filemat);
    elseif(isfield(bci.analysis,'settings'))
        disp('eegc3 settings format detected');
        bci.settings = bci.analysis.settings;
    else
        disp('Invalid MAT file, exiting...');
        bci = [];
        return;
    end
    
end

% Find the protocol
[taskset, resetevents, protocol_label] = eegc3_smr_guesstask(data.lbl', bci.settings);

% Find the labels of EEG samples (time domain)
data.lbl_sample = zeros(1, size(data.eeg,1));
data.trial_idx = zeros(1, size(data.eeg,1));
printf('[eegc3_wp4_simloop_fast] Labeling raw EEG data according to protocol\n');
data = eegc3_smr_labelEEG(data, protocol_label, bci.settings);

%% Calculate spectrum
%% Use only the pure MI trials, not the whole recording
%printf('[eegc3_wp4_simloop_fast] Calculating and plotting EEG spectrum\n');
%[bci.MI bci.nonMI info] = ...
%    eegc3_smr_spectrum(data.eeg(:,1:end-1), data.trial_idx,...
%    data.lbl_sample, 1, bci.settings, protocol_label, taskset);
%% Plot spectrum
%eegc3_smr_plotSpectrum(bci, bci.trace.eegc3_smr_simloop.filexdf, ...
%    bci.settings.modules.smr.montage, info);

bci.eeg = ndf_ringbuffer(bci.settings.acq.sf, ...
    bci.settings.acq.channels_eeg, 1);
bci.tri = ndf_ringbuffer(bci.settings.acq.sf, 1, 1);
bci.support = eegc3_smr_newsupport(bci.settings, rejection, integration);
bci.frames = bci.settings.modules.smr.win.shift* ...
    bci.settings.acq.sf;
bci.framez = bci.settings.modules.smr.win.size* ...
    bci.settings.acq.sf;
bci.framet = size(data.eeg, 1) / bci.frames;
bci.cprobs = [];	% Classifier oputput
bci.iprobs = [];	% Integrated probabilities
bci.afeats = nan(bci.framet, ...
    length(bci.settings.modules.smr.psd.freqs), ...
    bci.settings.acq.channels_eeg);
bci.rfeats = nan(bci.framet, ...
    size(bci.settings.bci.smr.gau.M, 3));
bci.nfeats = nan(bci.framet, ...
    size(bci.settings.bci.smr.gau.M, 3));
bci.evt = [];		% Trigger position (in frames)
bci.trg = [];		% LPT Trigger value (TODO)
bci.lbl = [];		% GDF label event
bci.dur = [];		% GDF event duration
bci.Sf = bci.settings.acq.sf/bci.frames;
bci.t = mt_support(0, bci.framet, bci.Sf);

% Temporary data structures for simulating the loop
tmp.framed = [];	% EEG frame
tmp.nfeat  = [];	% PSD feature
tmp.rfeat  = [];	% PSD feature
tmp.afeat  = [];	% PSD feature
tmp.framep = 1;		% Pointer to EEG frame
tmp.frame0 = -1;	% Starting sample for current frame
tmp.frame1 = -1;	% Ending sample for current frame

% Check for frame mismatch
align = {};
align.notaligned = false;
if(isempty(filetxt) == false)
    align.eeg = size(data.eeg, 1)/bci.frames;
    align.prb = size(data.aprobs, 1);
    align.delta = align.eeg-align.prb;
    printf('[eegc3_wp4_simloop_fast] Mismatch: EEG/PRB = %d/%d, Delta=%d\n', ...
        align.eeg, align.prb, align.delta);
    
    if(align.delta)
        printf('[eegc3_wp4_simloop_fast] Error: mismatch detected');
        align.notaligned = true;
    end
end


% Simulate BCI loop
trgdetect = [];
printf('[eegc3_wp4_simloop_fast] Calculating trigger places and extracting labels\n');
for i = 1:1:bci.framet
    
    % Get EEG frame
    tmp.framep = i;
    tmp.frame0 = bci.frames * (tmp.framep - 1) + 1;
    tmp.frame1 = bci.frames * tmp.framep;
    tmp.framed = data.eeg(tmp.frame0:tmp.frame1, :);
    
    % Check for raising edges in current frame
    trgdetect.tnow = length(find(data.red(tmp.frame0:tmp.frame1) == 1));
    
    if(trgdetect.tnow == 1)
        bci.evt(end+1) = tmp.framep;
        durlen = data.dur(length(bci.evt)) - bci.framez;
        if durlen < 0
            durlen = 0;
        end
        % Converted event duration from EEG samples (time) to frames
        bci.dur(end+1) = floor(durlen/bci.frames) + 1;
        bci.lbl(end+1) = data.lbl(length(bci.evt));
        if(isfield(bci.support,'nprobs'))
            if(find(resetevents == bci.lbl(end)))
                bci.support.nprobs = bci.support.dist.uniform;
            end
        end
    elseif(trgdetect.tnow > 1)
        printf('[eegc3_wp4_simloop_fast] Found >1 trigger in a single frame!\n');
        return;
    end
    
    if(tmp.frame1 >= size(data.eeg, 1))
        break;
    end
    
end

% Assign class labels to the PSD samples
bci.lbl_sample = zeros(size(bci.afeats,1),1);
bci.trial_idx = zeros(size(bci.afeats,1),1)';

% Label each PSD sample individually and add the trial index of eaxh sample
% to the structure
bci = eegc3_smr_labelPSD(bci, protocol_label);

if(mod(bci.settings.modules.smr.psd.win*bci.settings.modules.smr.psd.ovl,...
        bci.settings.modules.smr.win.size*bci.settings.modules.smr.win.shift) ~= 0)
    disp(['[eegc3_wp4_simloop_fast] The fast PSD method cannot be applied with the current settings!']);
    disp(['[eegc3_wp4_simloop_fast] The internal welch window shift has to be a multiple of the overall feature window shift!']);
    return;
end

% Preprocess batch
data.eeg = eegc3_smr_preprocess(data.eeg(:,1:bci.settings.acq.channels_eeg), ...
    bci.settings.modules.smr.options.prep.dc, ...
    bci.settings.modules.smr.options.prep.car, ...
    bci.settings.modules.smr.options.prep.laplacian, ...
    bci.settings.modules.smr.laplacian);

% Calculate all the internal PSD windows beforehand for speed
for ch=1:bci.settings.acq.channels_eeg
    disp(['[eegc3_wp4_simloop_fast] Internal PSDs on electrode ' num2str(ch)]);
    [~,f,t,p(:,:,ch)] = spectrogram(data.eeg(:,ch), ...
        bci.settings.acq.sf*bci.settings.modules.smr.psd.win, ...
        bci.settings.acq.sf*(bci.settings.modules.smr.psd.win-bci.settings.modules.smr.win.shift),...
        [], bci.settings.acq.sf);
end

p = p(find(ismember(f,bci.settings.modules.smr.psd.freqs)),:,:);

% Moving average
SpecWinStep = bci.settings.modules.smr.psd.win*bci.settings.modules.smr.psd.ovl/...
    bci.settings.modules.smr.win.shift;
SpecWinNum = (bci.settings.modules.smr.win.size/bci.settings.modules.smr.win.shift)/...
    SpecWinStep - 1;

FiltB = zeros(1,SpecWinStep*SpecWinNum);
FiltB(1:SpecWinStep:end) = 1/SpecWinNum;
FiltA = 1;
bci.afeats = filter(FiltB,FiltA,p,[],2);
bci.afeats = permute(bci.afeats, [2 1 3]);
% Get rid of the first samples before window is full
discardInd = find(FiltB>0);
discardInd = discardInd(end);
bci.afeats = bci.afeats(discardInd:end,:,:);

% Take the log
bci.afeats = log(bci.afeats);

% Set NaNs to the first WinFrameSize-1 feature matrices, just for compatibility
% with the per sample extraction
WinFrameSize = bci.settings.modules.smr.win.size/bci.settings.modules.smr.win.shift - 1;
bci.afeats = cat(1,nan(WinFrameSize,23,16), bci.afeats);

if(doplot && isempty(filetxt) == false && align.notaligned == false);
    eegc3_figure(doplot);
    subplot(4, 1, 1:2)
    plot(bci.t, data.cprobs(:, 1), 'ko');
    hold on;
    plot(bci.t, bci.cprobs(:, 1), 'r.');
    hold off;
    legend('TXT', 'GDF')
    ylim([0 1]);
    xlim([bci.t(1) bci.t(end)]);
    grid on;
    ylabel('Cprobs TXT/GDF');
    subplot(4, 1, 3)
    plot(bci.t, (bci.cprobs(:,1) - data.cprobs(:,1)), 'k')
    ylim([-1 +1]);
    xlim([bci.t(1) bci.t(end)]);
    grid on;
    xlabel('Time [s]');
    ylabel('Cprobs delta');
    subplot(4, 1, 4)
    imagesc(flipud(bci.nfeats'));
    xlabel('EEG frames');
    drawnow;
    eegc3_figure(doplot, 'print', ...
        [bci.trace.eegc3_smr_simloop.figbasename '.simloop.png']);
end

printf('[eegc3_wp4_simloop_fast] Saving SMR-BCI structure: %s\n', ...
    bci.trace.eegc3_smr_simloop.filemat);
save(bci.trace.eegc3_smr_simloop.filemat, 'bci');
toc
