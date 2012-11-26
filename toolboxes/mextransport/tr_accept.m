function [status, sptr] = tr_accept(sptr, eptr);
	mex_id_ = 'o int = tr_accept(i tr_socket*, i tr_socket*)';
[status] = transport(mex_id_, sptr, eptr);

