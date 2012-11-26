function [status, sptr] = tr_recv(sptr);
	mex_id_ = 'o int = tr_recv(i tr_socket*)';
[status] = transport(mex_id_, sptr);

