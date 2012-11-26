function [status, q] = icmessage_addclassifier(q, name, desc, vtype, ltype)
												mex_id_ = 'o std::string* = new(i cstring)';
[sname] = tobiic(mex_id_, name);
	mex_id_ = 'o std::string* = new(i cstring)';
[sdesc] = tobiic(mex_id_, desc);
	mex_id_ = 'o bool = addc(i ICMessage*, i std::string*, i std::string*, i int*, i int*)';
[status] = tobiic(mex_id_, q, sname, sdesc, vtype, ltype);

