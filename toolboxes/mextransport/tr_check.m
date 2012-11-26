function [status, sptr] = tr_check(sptr);
	mex_id_ = 'o int = tr_check(i tr_socket*)';
[status] = transport(mex_id_, sptr);

