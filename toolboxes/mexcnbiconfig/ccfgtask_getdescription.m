function [description, tptr] = ccfgtask_getdescription(tptr);
					description = '';
	mex_id_ = 'get_description(i CCfgTask*, io cstring[x])';
[description] = cnbiconfig(mex_id_, tptr, description, 4096);

