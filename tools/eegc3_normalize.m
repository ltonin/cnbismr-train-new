function nfeature = eegc3_normalize(feature)
% Edited by M. Tavella <michele.tavella@epfl.ch> on 17/07/09 08:39:35
%
% EEGC3_NORMALIZE Normalize feature vector or feature matrix
%
%   NFEATURE = EEGC2_NORMALIZE(FEATURE)
%
%    Accepts:
%       FEATURE    A feature vector or matrix
%
%     Returns:
%       NFEATURE   Absolute sum normalized feature vector or matrix (per row)

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
