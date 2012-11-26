function [classifier, tptr] = ccfgtaskset_getclassifier(tptr)
									classifier = '';
	mex_id_ = 'getclassifier(i CCfgTaskset*, io cstring[x])';
[classifier] = cnbiconfig(mex_id_, tptr, classifier, 4096);

