function [retval, cptr] = ccfg_offline(cptr, blockname, taskset)
										mex_id_ = 'o std::string* = new(i cstring)';
[sblockname] = cnbiconfig(mex_id_, blockname);
	mex_id_ = 'o std::string* = new(i cstring)';
[staskset] = cnbiconfig(mex_id_, taskset);
	mex_id_ = 'o CCfgTaskset* = offline(i CCfgConfig*, i std::string*, i std::string*)';
[retval] = cnbiconfig(mex_id_, cptr, sblockname, staskset);

