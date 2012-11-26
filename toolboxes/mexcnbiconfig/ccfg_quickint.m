function [retval, cptr] = ccfg_quickint(cptr, path)
										mex_id_ = 'o std::string* = new(i cstring)';
[spath] = cnbiconfig(mex_id_, path);
	mex_id_ = 'o int = quickint(i CCfgConfig*, i std::string*)';
[retval] = cnbiconfig(mex_id_, cptr, spath);

