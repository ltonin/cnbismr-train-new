function [tptr] = ccfgtaskset_new();
					mex_id_ = 'o CCfgTaskset* = new_taskset()';
[tptr] = cnbiconfig(mex_id_);

