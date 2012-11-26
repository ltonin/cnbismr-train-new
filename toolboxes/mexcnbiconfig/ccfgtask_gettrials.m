function [trials, tptr] = ccfgtask_gettrials(tptr);
				mex_id_ = 'o int = get_trials(i CCfgTask*)';
[trials] = cnbiconfig(mex_id_, tptr);

