function [gdf, tptr] = ccfgtask_getgdf(tptr);
				mex_id_ = 'o int = get_gdf(i CCfgTask*)';
[gdf] = cnbiconfig(mex_id_, tptr);

%@function [tptr] = ccfgtask_delete(tptr)
%	# delete(CCfgTask* tptr);
