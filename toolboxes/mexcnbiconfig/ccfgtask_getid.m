function [id, tptr] = ccfgtask_getid(tptr);
				mex_id_ = 'o int = get_id(i CCfgTask*)';
[id] = cnbiconfig(mex_id_, tptr);

