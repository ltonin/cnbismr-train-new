function [retval, cptr] = ccfg_quickbool(cptr, path)
										mex_id_ = 'o std::string* = new(i cstring)';
[spath] = cnbiconfig(mex_id_, path);
	mex_id_ = 'o bool = quickbool(i CCfgConfig*, i std::string*)';
[retval] = cnbiconfig(mex_id_, cptr, spath);

