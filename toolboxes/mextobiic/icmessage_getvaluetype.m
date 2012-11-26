function [vtype] = icmessage_getvaluetype(name)
					vtype = -1;
	mex_id_ = 'getvtype(i cstring, io int*)';
[vtype] = tobiic(mex_id_, name, vtype);

