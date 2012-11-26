function [sptr] = tr_new();
				mex_id_ = 'o tr_socket* = newsocket()';
[sptr] = transport(mex_id_);

