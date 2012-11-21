function nfeature = eegc2_normalize(feature)
% Edited by M. Tavella <michele.tavella@epfl.ch> on 17/07/09 08:39:35
%
% EEGC2_NORMALIZE Normalize feature vector or feature matrix
%
%   NFEATURE = EEGC2_NORMALIZE(FEATURE)
%
%    Accepts:
%       FEATURE    TODO
%
%     Returns:
%       NFEATURE   TODO

feaTot = size(feature, 1);
dimTot = size(feature, 2);

if(feaTot == 1)
	nfeature = feature / sum(abs(feature));
else
	nfeature = zeros(feaTot, dimTot);
	for f = 1:feaTot
		nfeature(f, :) = feature(f, :) / sum(abs(feature(f, :)));
	end
end
