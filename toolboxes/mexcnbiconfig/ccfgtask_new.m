function [tptr] = ccfgtask_new();
					mex_id_ = 'o CCfgTask* = new_task()';
[tptr] = cnbiconfig(mex_id_);

