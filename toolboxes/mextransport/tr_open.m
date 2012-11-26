function [status, sptr] = tr_open(sptr);
	mex_id_ = 'o int = tr_open(i tr_socket*)';
[status] = transport(mex_id_, sptr);

