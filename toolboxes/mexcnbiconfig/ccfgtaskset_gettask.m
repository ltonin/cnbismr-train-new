function [kptr, tptr] = ccfgtaskset_gettask(tptr, what)
										mex_id_ = 'o std::string* = new(i cstring)';
[swhat] = cnbiconfig(mex_id_, what);
	mex_id_ = 'o CCfgTask* = gettask(i CCfgTaskset*, i std::string*)';
[kptr] = cnbiconfig(mex_id_, tptr, swhat);

