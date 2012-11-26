function [status, sptr] = tr_connect(sptr, address, port);
	mex_id_ = 'o int = tr_connect(i tr_socket*, i cstring, i cstring)';
[status] = transport(mex_id_, sptr, address, port);

