function [address, port, sptr] = tr_getremote(sptr);
					address = '';
	mex_id_ = 'o int = getremote(i tr_socket*, io cstring[x])';
[port, address] = transport(mex_id_, sptr, address, 1024);
