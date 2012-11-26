function [status, sptr] = tr_listen(sptr);
	mex_id_ = 'o int = tr_listen(i tr_socket*)';
[status] = transport(mex_id_, sptr);

