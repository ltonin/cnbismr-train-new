function [status, sptr] = tr_connected(sptr);
	mex_id_ = 'o int = tr_connected(i tr_socket*)';
[status] = transport(mex_id_, sptr);

