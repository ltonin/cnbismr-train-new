function [status, q] = icmessage_setvalue(q, name, label, value)
											mex_id_ = 'o std::string* = new(i cstring)';
[sname] = tobiic(mex_id_, name);
	mex_id_ = 'o std::string* = new(i cstring)';
[slabel] = tobiic(mex_id_, label);
	mex_id_ = 'o bool = setv(i ICMessage*, i std::string*, i std::string*, i float*)';
[status] = tobiic(mex_id_, q, sname, slabel, value);

