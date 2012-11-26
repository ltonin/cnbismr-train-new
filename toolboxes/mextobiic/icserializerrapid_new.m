function [q] = icserializerrapid_new(m);
	mex_id_ = 'o ICSerializerRapid* = new(i ICMessage*)';
[q] = tobiic(mex_id_, m);

