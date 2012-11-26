function [retval, q] = icmessage_serialize(q, s)
										retval = '';
	mex_id_ = 'serialize(i ICMessage*, i ICSerializerRapid*, io cstring[x])';
[retval] = tobiic(mex_id_, q, s, retval, 4096);

