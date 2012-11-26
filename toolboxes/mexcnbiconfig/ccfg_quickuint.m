function [retval, cptr] = ccfg_quickuint(cptr, path)
										mex_id_ = 'o std::string* = new(i cstring)';
[spath] = cnbiconfig(mex_id_, path);
	mex_id_ = 'o uint = quickuint(i CCfgConfig*, i std::string*)';
[retval] = cnbiconfig(mex_id_, cptr, spath);


