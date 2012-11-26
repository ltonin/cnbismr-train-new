function [t, cptr] = ccfg_onlinem(cptr, blockname, taskset, message)
										mex_id_ = 'o std::string* = new(i cstring)';
[sblockname] = cnbiconfig(mex_id_, blockname);
	mex_id_ = 'o std::string* = new(i cstring)';
[staskset] = cnbiconfig(mex_id_, taskset);
	mex_id_ = 'o CCfgTaskset* = onlinem(i CCfgConfig*, i std::string*, i std::string*, i ICMessage*)';
[t] = cnbiconfig(mex_id_, cptr, sblockname, staskset, message);

