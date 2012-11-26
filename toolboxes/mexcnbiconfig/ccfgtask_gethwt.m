function [hwt, tptr] = ccfgtask_gethwt(tptr);
				mex_id_ = 'o int = get_hwt(i CCfgTask*)';
[hwt] = cnbiconfig(mex_id_, tptr);

