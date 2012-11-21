% - Initially written by Michele
% - Then modified by Simis who casted the Perdikisian spells in this file
% - Then corrected and integrated in eegemg by Michele
% - Finally approved by Chuck Norris
function [support, nfeature, rfeature, afeature] = eegc3_smr_classify(settings, buffer, ...
	support)

nfeature = [];
afeature = [];
rfeature = [];
fs = settings.acq.sf;

if(ndf_isfull(buffer))
    if(nargout == 4)
        [support.cprobs, nfeature, rfeature, afeature] = ...
			eegc3_smr_bci(settings, buffer);

    elseif(nargout == 3)
        [support.cprobs, nfeature, rfeature] = ...
			eegc3_smr_bci(settings, buffer);
    else
        [support.cprobs, nfeature] = ...
			eegc3_smr_bci(settings, buffer);
    end
    
    if(support.rejection > 0)
        if(max(support.cprobs) < support.rejection)
            support.cprobs = support.nprobs;
        end
    end
    
    if(support.integration > 0)
        support.nprobs = ...
            eegc3_expsmooth(support.nprobs, support.cprobs, ...
            support.integration);
    else
        support.nprobs = support.cprobs;
    end
end
