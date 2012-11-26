function [name, tptr] = ccfgtask_getname(tptr);
					name = '';
	mex_id_ = 'get_name(i CCfgTask*, io cstring[x])';
[name] = cnbiconfig(mex_id_, tptr, name, 4096);

