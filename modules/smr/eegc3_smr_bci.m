% Edited by M. Tavella <michele.tavella@epfl.ch> on 29/08/09 11:31:13
%
% function postprob = eegc2_bcidemo_classify(problem, buffer)
% 
% Where: postprob	vector with posterior probabilities [1 x classes]
% 
%        problem    structure created with eegc2_bcidemo_train
%        data       EEG window [points x channels]
% 
% Beware: if window size does not match [problem.dw x problem.numChs], 
%         an empty vector is returned

function [postprob, nfeature, rfeature, afeature ] = eegc3_smr_bci(settings, buffer)

% Preprocess EEG
sample = eegc3_smr_preprocess(buffer, ...
	settings.modules.smr.options.prep.dc, ...
	settings.modules.smr.options.prep.car, ...  
	settings.modules.smr.options.prep.laplacian, ...
	settings.modules.smr.laplacian);

% Feature extraction based on feature selection
if(nargout < 4)
	% If online:
	% - compute just the selected channels
	% - for each channel, return only the selected bands
	feature = eegc3_smr_features(sample, ...
		settings.acq.sf, ...
		settings.bci.smr.bands, ...
		settings.modules.smr.psd.win, ...
		settings.modules.smr.psd.ovl, ...
		settings.bci.smr.channels);
    
    rfeature = feature';	
    nfeature = eegc3_smr_npsd(rfeature);
    
    % Classification
    if(~isempty(settings.bci.smr.gau.M))
        [activations postprob] = gauClassifier(...
            settings.bci.smr.gau.M, ...
            settings.bci.smr.gau.C, ...
            nfeature);
    else
        postprob = [NaN NaN];
        %disp(['[eegc3_smr_bci] Cannot compute selected features without valid settings...']);
    end
    
elseif(nargout == 4)
	% If offline:
	% - compute all the channels 
	% - for each channel, return all the bands (afeature)
    % - If there is a classifier, for each channel, extract also the selected 
    % channel/bands (feature) from afeature
    afeature = eegc3_smr_features(sample, ...
    	settings.acq.sf, ...
        settings.modules.smr.psd.freqs, ...
    	settings.modules.smr.psd.win, ...
    	settings.modules.smr.psd.ovl, ...
    	1:settings.acq.channels_eeg);
    
    if(~isempty(settings.bci.smr.gau.M))
        feature = [];
        for ch = settings.bci.smr.channels
            bns = settings.bci.smr.bands{ch}; 
            for bni = bns
            	bn = find(settings.modules.smr.psd.freqs == bni);
                feature = [feature; afeature(ch, bn)];
            end
        end
        
        rfeature = feature';
        nfeature = eegc3_smr_npsd(rfeature);
        [activations postprob] = gauClassifier(...
            settings.bci.smr.gau.M, ...
            settings.bci.smr.gau.C, ...
            nfeature);
    else
        nfeature = [];
        rfeature = [];
        postprob = [NaN NaN];
    end
    
else
    disp(['[eegc3_smr_bci] Error! Ambiguous feaure extraction outputs...']);
end
