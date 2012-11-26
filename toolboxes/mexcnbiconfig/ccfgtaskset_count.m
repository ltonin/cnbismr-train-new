function [count, tptr] = ccfgtaskset_count(tptr)
										mex_id_ = 'o int = counttasks(i CCfgTaskset*)';
[count] = cnbiconfig(mex_id_, tptr);

