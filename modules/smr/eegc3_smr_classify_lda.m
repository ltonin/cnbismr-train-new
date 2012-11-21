% - Initially written by Michele
% - Then modified by Simis who casted the Perdikisian spells in this file
% - Then corrected and integrated in eegemg by Michele
% - Finally approved by Chuck Norris
function [support, nfeature, rfeature, afeature] = eegc3_smr_classify_lda(settings, buffer, ...
	support)

nfeature = [];
afeature = [];
rfeature = [];
fs = settings.acq.sf;

if(ndf_isfull(buffer))
    if(nargout == 4)
        [support.cprobs, nfeature, rfeature, afeature] = ...
			eegc3_smr_bci_lda(settings, buffer);

    elseif(nargout == 3)
        [support.cprobs, nfeature, rfeature] = ...
			eegc3_smr_bci_lda(settings, buffer);
    else
        [support.cprobs, nfeature] = ...
			eegc3_smr_bci_lda(settings, buffer);
    end
    
    if(support.rejection > 0)
        % Reject sample if it is far away from the global_mean of the
        % classifier's training set
        if(norm(nfeature-settings.bci.smr.lda.m_global) > ...
                settings.bci.smr.lda.rej_th)
            % Sample must be rejected do not integrate so that
            % support.nprobs remains the same as before
            return;
        end
    end
    
    if(support.integration > 0)
        support.nprobs = ...
            eegc3_simple_integ(support.nprobs, support.cprobs, ...
            support.integration);
    else
        support.nprobs = support.cprobs;
    end
end
