function [retval, cptr] = ccfg_quickfloat(cptr, path)
										mex_id_ = 'o std::string* = new(i cstring)';
[spath] = cnbiconfig(mex_id_, path);
	mex_id_ = 'o float = quickfloat(i CCfgConfig*, i std::string*)';
[retval] = cnbiconfig(mex_id_, cptr, spath);

