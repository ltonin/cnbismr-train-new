function [bytes, sptr] = tr_send(sptr, buffer);
	mex_id_ = 'o int = tr_send(i tr_socket*, i cstring)';
[bytes] = transport(mex_id_, sptr, buffer);

