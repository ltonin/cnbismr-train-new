function [sptr] = tr_delete(sptr);
	mex_id_ = 'free(i tr_socket*)';
transport(mex_id_, sptr);

