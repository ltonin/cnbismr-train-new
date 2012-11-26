function [kptr, tptr] = ccfgtaskset_gettaskbyid(tptr, id)
										mex_id_ = 'o CCfgTask* = gettaskbyid(i CCfgTaskset*, i int)';
[kptr] = cnbiconfig(mex_id_, tptr, id);

