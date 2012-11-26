function [q] = icmessage_deserialize(q, s, buffer)
										mex_id_ = 'deserialize(i ICMessage*, i ICSerializerRapid*, i cstring[x])';
tobiic(mex_id_, q, s, buffer, 4096);

