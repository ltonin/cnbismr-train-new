function [address, port, sptr] = tr_getlocal(sptr);
					address = '';
	mex_id_ = 'o int = getlocal(i tr_socket*, io cstring[x])';
[port, address] = transport(mex_id_, sptr, address, 1024);

