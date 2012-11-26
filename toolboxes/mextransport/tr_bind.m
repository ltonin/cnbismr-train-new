function [status, sptr] = tr_bind(sptr, port);
	mex_id_ = 'o int = tr_bind(i tr_socket*, i cstring)';
[status] = transport(mex_id_, sptr, port);

