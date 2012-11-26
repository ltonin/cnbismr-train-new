function [status, sptr] = tr_close(sptr);
	mex_id_ = 'o int = tr_close(i tr_socket*)';
[status] = transport(mex_id_, sptr);

