function [retval, cptr] = ccfg_validate(cptr)
				mex_id_ = 'o bool = validate(i CCfgConfig*)';
[retval] = cnbiconfig(mex_id_, cptr);

