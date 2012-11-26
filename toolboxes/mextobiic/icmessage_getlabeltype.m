function [ltype] = icmessage_getlabeltype(name)
					ltype = -1;
	mex_id_ = 'getltype(i cstring, io int*)';
[ltype] = tobiic(mex_id_, name, ltype);

