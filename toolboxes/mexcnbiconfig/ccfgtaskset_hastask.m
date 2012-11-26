function [retval, tptr] = ccfgtaskset_hastask(tptr, what)
												mex_id_ = 'o std::string* = new(i cstring)';
[swhat] = cnbiconfig(mex_id_, what);
	mex_id_ = 'o bool = hastask(i CCfgTaskset*, i std::string*)';
[retval] = cnbiconfig(mex_id_, tptr, swhat);


