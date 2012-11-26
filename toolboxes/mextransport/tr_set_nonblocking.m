function [status, sptr] = tr_set_nonblocking(sptr, value);
	mex_id_ = 'o int = tr_set_nonblocking(i tr_socket*, i int)';
[status] = transport(mex_id_, sptr, value);

