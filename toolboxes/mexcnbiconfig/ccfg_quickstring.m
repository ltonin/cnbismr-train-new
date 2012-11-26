function [retval, cptr] = ccfg_quickstring(cptr, path)
											retval = '';
	mex_id_ = 'o std::string* = new(i cstring)';
[spath] = cnbiconfig(mex_id_, path);
	mex_id_ = 'quickstring(i CCfgConfig*, i std::string*, io cstring[x])';
[retval] = cnbiconfig(mex_id_, cptr, spath, retval, 4096);

