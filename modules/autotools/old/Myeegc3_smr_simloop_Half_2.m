function bci = Myeegc3_smr_simloop_Half_2(taskset, data, bci, filetxt, ... 
	rejection, integration, doplot, resetevents, protocol_label)

 % Calculate spectrum
 %Use only the pure MI trials, not the whole recording
 printf('[eegc3_smr_simloop] Calculating and plotting EEG spectrum');
 [bci.MI bci.nonMI info] = ...
     eegc3_smr_spectrum(data.eeg(:,1:end-1), data.trial_idx,...
     data.lbl_sample, 1, bci.settings, protocol_label, taskset);
%  % Plot spectrum
%  eegc3_smr_plotSpectrum(bci, bci.trace.eegc3_smr_simloop.filexdf, ...
%      bci.settings.modules.smr.montage, info);

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
       
% Label each PSD sample individually and add the trial index of eaxh sample
% to the structure
bci = eegc3_smr_labelPSD(bci, protocol_label);

for i = 1:1:bci.framet
    %mt_progressclean();
	mt_progress('[eegc3_smr_simloop] Simulating SMR-BCI', i, 1, bci.framet);
	
	% Get EEG frame
	tmp.framep = i;
	tmp.frame0 = bci.frames * (tmp.framep - 1) + 1;
	tmp.frame1 = bci.frames * tmp.framep;
	tmp.framed = data.eeg(tmp.frame0:tmp.frame1, :);

	% Classify EEG frame
    
        bci.eeg = ndf_add2buffer(bci.eeg, tmp.framed(:,1:end-1));
        bci.tri = ndf_add2buffer(bci.tri, tmp.framed(:,end));
        
    % Enmpty classifier means that the function is called only for feature 
    % extraction, not simulation
    if(~isempty(bci.settings.bci.smr.gau.M))
        [bci.support, tmp.nfeat, tmp.rfeat, tmp.afeat] = ...
            eegc3_smr_classify(bci.settings, bci.eeg, bci.support);
    else
        if((~bci.settings.modules.smr.options.extraction.trials) || ...
                (bci.settings.modules.smr.options.extraction.trials &&...
                (bci.lbl_sample(i) ~= 0)))
            [bci.support, tmp.nfeat, tmp.rfeat, tmp.afeat] = ...
                eegc3_smr_bci(bci.settings, bci.eeg);
        else
            tmp.afeat = [];
            tmp.rfeat = [];
            tmp.nfeat = [];
        end
    end	
    
	% Add features to BCI structure if not empty (simulation case)
	if(isempty(tmp.nfeat) == false)
		bci.nfeats(tmp.framep, :) = tmp.nfeat;
		bci.rfeats(tmp.framep, :) = tmp.rfeat;
    end
    
	if(isempty(tmp.afeat) == false)
		% TODO
		% Problem: I need to transpose because eegserver_mi_classify returns 
		%	[Ch x Freqs]
		% Solution: eegserver_mi_classify should return:
		%	[Freqs x Ch]
		bci.afeats(tmp.framep, :, :) = tmp.afeat';
    end
    
    % Simulation case only
    if(isfield(bci.support,'cprobs'))
        bci.cprobs(end+1, :) = bci.support.cprobs;
        bci.iprobs(end+1, :) = bci.support.nprobs;
    end
	  
	if(tmp.frame1 >= size(data.eeg, 1))
		break;
	end
end
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

% printf('[eegc3_smr_simloop] Saving SMR-BCI structure: %s\n', ...
% 	bci.trace.eegc3_smr_simloop.filemat);
% save(bci.trace.eegc3_smr_simloop.filemat, 'bci');
%%%%% Keep last part of file name (in order to save it elsewhere
ind = strfind(bci.trace.eegc3_smr_simloop.filemat,'eegc3');
%ind = strfind(bci.trace.eegc3_smr_simloop.filemat,'AR');
name = bci.trace.eegc3_smr_simloop.filemat(ind+6:end);
%name = bci.trace.eegc3_smr_simloop.filemat(ind+3:end);

printf('[eegc3_smr_simloop] Saving SMR-BCI structure: %s\n', ...
	['/homes/vliakoni/Results_LDA_Rejection/' name '.mat']);
save(['/homes/vliakoni/Results_LDA_Rejection/' name '.mat'], 'bci');
% printf('[eegc3_smr_simloop] Saving SMR-BCI structure: %s\n', ...
% 	['/homes/vliakoni/Results_GAU_Offline/' name '.mat']);
% save(['/homes/vliakoni/Results_GAU_Offline/' name '.mat'], 'bci');