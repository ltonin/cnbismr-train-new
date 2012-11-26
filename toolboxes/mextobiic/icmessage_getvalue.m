function [retval, q] = icmessage_getvalue(q, name, label)
										mex_id_ = 'o std::string* = new(i cstring)';
[sname] = tobiic(mex_id_, name);
	mex_id_ = 'o std::string* = new(i cstring)';
[slabel] = tobiic(mex_id_, label);
	mex_id_ = 'o float = getv(i ICMessage*, i std::string*, i std::string*)';
[retval] = tobiic(mex_id_, q, sname, slabel);

