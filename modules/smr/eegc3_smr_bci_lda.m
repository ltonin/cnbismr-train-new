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

function [class, nfeature, rfeature, afeature ] = eegc3_smr_bci_lda(analysis, buffer)

% Preprocess EEG
sample = eegc3_smr_preprocess(buffer, ...
	analysis.options.prep.dc, ...
	analysis.options.prep.car, ...  
	analysis.options.prep.laplacian, ...
	analysis.settings.prep.laplacian);

% Feature extraction based on feature selection
if(nargout < 4)
	% If online:
	% - compute just the selected channels
	% - for each channel, return only the selected bands
	feature = eegc3_smr_features(sample, ...
		analysis.settings.eeg.fs, ...
		analysis.tools.features.bands, ...
		analysis.settings.features.psd.win, ...
		analysis.settings.features.psd.ovl, ...
		analysis.tools.features.channels);
    
    rfeature = feature';	
    nfeature = eegc3_smr_npsd(rfeature);
    
    % Classification
    if(~isempty(analysis.tools.sep.w))
        class = eegc3_classify_sep(nfeature, analysis.tools.sep);
    else
        disp(['[eegc3_smr_bci] Cannot compute selected features without valid analysis...']);
    end
    
elseif(nargout == 4)
	% If offline:
	% - compute all the channels 
	% - for each channel, return all the bands (afeature)
    % - If there is a classifier, for each channel, extract also the selected 
    % channel/bands (feature) from afeature
    afeature = eegc3_smr_features(sample, ...
    	analysis.settings.eeg.fs, ...
        analysis.settings.features.psd.freqs, ...
    	analysis.settings.features.psd.win, ...
    	analysis.settings.features.psd.ovl, ...
    	1:analysis.settings.eeg.chs);
    
    if(~isempty(analysis.bci.smr.lda.w))
        feature = [];
        for ch = analysis.bci.smr.channels
            bns = analysis.bci.smr.bands{ch}; 
            for bni = bns
            	bn = find(analysis.modules.smr.psd.freqs == bni);
                feature = [feature; afeature(ch, bn)];
            end
        end
        
        rfeature = feature';
        nfeature = eegc3_smr_npsd(rfeature);
        class = eegc3_classify_lda_hard(...
            nfeature,...
            analysis.bci.smr.lda.w, ...
            analysis.bci.smr.lda.Bias);
    else
        nfeature = [];
        rfeature = [];
        class = NaN;
    end
    
else
    disp(['[eegc3_smr_bci] Error! Ambiguous feaure extraction outputs...']);
end
