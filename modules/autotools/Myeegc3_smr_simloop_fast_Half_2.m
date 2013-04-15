function bci = Myeegc3_smr_simloop_fast_Half_2(taskset, data, bci, filetxt, ... 
	rejection, integration, doplot, resetevents, protocol_label)

% Calculate spectrum
% Use only the pure MI trials, not the whole recording
printf('[eegc3_smr_simloop] Calculating and plotting EEG spectrum');
[bci.MI bci.nonMI info] = ...
    eegc3_smr_spectrum(data.eeg(:,1:end-1), data.trial_idx,...
    data.lbl_sample, 1, bci.settings, protocol_label, taskset);
% % Plot spectrum
% eegc3_smr_plotSpectrum(bci, bci.trace.eegc3_smr_simloop.filexdf, ...
%     bci.settings.modules.smr.montage, info);

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
	printf('[eegc3_smr_simloop] Mismatch: EEG/PRB = %d/%d, Delta=%d\n', ...
		align.eeg, align.prb, align.delta);

	if(align.delta)
		printf('[eegc3_smr_simloop] Error: mismatch detected');
		align.notaligned = true;
	end
end


% Simulate BCI loop
trgdetect = [];
printf('[eegc3_smr_simloop] Calculating trigger places and extracting labels\n');
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
		printf('[eegc3_smr_simloop] Found >1 trigger in a single frame!\n');
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
    disp(['[eegc3_smr_simloop_fast] The fast PSD method cannot be applied with the current settings!']);
    disp(['[eegc3_smr_simloop_fast] The internal welch window shift has to be a multiple of the overall feature window shift!']);
    return;
end

% Preprocess batch 
% TODO: HACK!! 16 channelsare hardcoded here
bci.settings.acq.channels_eeg = 16;
warning('eegc3_simloop_fast] Careful dude, I only work for gtec 16 electrodes!')
data.eeg = eegc3_smr_preprocess(data.eeg(:,1:bci.settings.acq.channels_eeg), ...
	bci.settings.modules.smr.options.prep.dc, ...
	bci.settings.modules.smr.options.prep.car, ...  
	bci.settings.modules.smr.options.prep.laplacian, ...
	bci.settings.modules.smr.laplacian);

% Calculate all the internal PSD windows beforehand for speed
% HACK: channels set to 16, check bci.settings.acq.channels_eeg, instead
for ch=1:bci.settings.acq.channels_eeg
    disp(['[eegc3_smr_simloop_fast] Internal PSDs on electrode ' num2str(ch)]);
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
bci.afeats = cat(1,nan(WinFrameSize,length(bci.settings.modules.smr.psd.freqs),16), bci.afeats);
% 
% if(doplot && isempty(filetxt) == false && align.notaligned == false);
% 	eegc3_figure(doplot);
% 		subplot(4, 1, 1:2)
% 			plot(bci.t, data.cprobs(:, 1), 'ko');
% 			hold on;
% 			plot(bci.t, bci.cprobs(:, 1), 'r.');
% 			hold off;
% 			legend('TXT', 'GDF')
% 			ylim([0 1]);
% 			xlim([bci.t(1) bci.t(end)]);
% 			grid on;
% 			ylabel('Cprobs TXT/GDF');
% 		subplot(4, 1, 3)
% 			plot(bci.t, (bci.cprobs(:,1) - data.cprobs(:,1)), 'k')
% 			ylim([-1 +1]);
% 			xlim([bci.t(1) bci.t(end)]);
% 			grid on;
% 			xlabel('Time [s]');
% 			ylabel('Cprobs delta');
% 		subplot(4, 1, 4)
% 			imagesc(flipud(bci.nfeats'));
% 			xlabel('EEG frames');
% 		drawnow;
% 	eegc3_figure(doplot, 'print', ...
% 		[bci.trace.eegc3_smr_simloop.figbasename '.simloop.png']);
% end

% SAVE
% printf('[eegc3_smr_simloop] Saving SMR-BCI structure: %s\n', ...
% 	bci.trace.eegc3_smr_simloop.filemat);
%save(bci.trace.eegc3_smr_simloop.filemat, 'bci');

%%%%% Keep last part of file name (in order to save file elsewhere)
ind = strfind(bci.trace.eegc3_smr_simloop.filemat,'eegc3');
%ind = strfind(bci.trace.eegc3_smr_simloop.filemat,'AR');
name = bci.trace.eegc3_smr_simloop.filemat(ind+6:end);
%name = bci.trace.eegc3_smr_simloop.filemat(ind+3:end);

% printf('[eegc3_smr_simloop] Saving SMR-BCI structure: %s\n', ...
% 	['/homes/vliakoni/Results_GAU_Rejection/' name '.mat']);
printf('[eegc3_smr_simloop] Saving SMR-BCI structure: %s\n', ...
	[getenv('TOLEDO_DATA') '/Results/' name(1:find (name=='.')-1) '/Results_GAU_Rejection_'  name]);
save([getenv('TOLEDO_DATA') '/Results/' name(1:find (name=='.')-1) '/Results_GAU_CVA_Rejection_'  name], 'bci');
%save(['/homes/vliakoni/Results_GAU_Rejection/' name '.mat'], 'bci'); 
% printf('[eegc3_smr_simloop] Saving SMR-BCI structure: %s\n', ...
% 	['/homes/vliakoni/Results_GAU_Offline/' name '.mat']);
% save(['/homes/vliakoni/Results_GAU_Offline/' name '.mat'], 'bci');
toc