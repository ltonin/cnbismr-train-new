function [buffer, sptr] = tr_getbuffer(sptr);
				buffer = '';
	mex_id_ = 'getbuffer(i tr_socket*, io cstring[x])';
[buffer] = transport(mex_id_, sptr, buffer, 1024);

