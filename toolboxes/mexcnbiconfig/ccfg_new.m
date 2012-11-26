function [cptr] = ccfg_new(filename);
					mex_id_ = 'o std::string* = new(i cstring)';
[sfilename] = cnbiconfig(mex_id_, filename);
	mex_id_ = 'o CCfgConfig* = new_config(i std::string*)';
[cptr] = cnbiconfig(mex_id_, sfilename);

