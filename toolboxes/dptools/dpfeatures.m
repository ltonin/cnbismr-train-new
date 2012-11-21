function [dp, selected] = dpfeatures(feats,labels,percent)
%
%
% Ranks features based on discriminant power and select top nBestFeat.
% The current version works only for two class problem
%
%
%  Input :
%         'feat' is a vector of nTrial x nFeat
%         'labels' is a 1D vector of length nTrials
%         'percent' percentage of features to be selected  
%
% See also: dpFWHM, dpportion

% check class labels
class_types = unique(double(labels));

if length(class_types)<2
    error('labels tyeps should at least be 2');
% Edited by M. Tavella <michele.tavella@epfl.com> on 07/04/09 09:09:39
% Initial support for 3 class problems
%elseif length(class_types)>2
    %error('current version does not support more than two classes');
end

% Extract class sepecific features
feats1 = feats(labels==class_types(1),:);
feats2 = feats(labels==class_types(2),:);
if(length(class_types) == 3)
	feats3 = feats(labels==class_types(3),:);
end
nFeat = size(feats,2);

% Compute discriminant power
if(length(class_types) == 2)
	for f = 1:nFeat
		dp(f) = dpFWHM(feats1(:,f), feats2(:,f));
	end
elseif(length(class_types) == 3)
	for f = 1:nFeat
		dp(f) = dpFWHM(feats1(:,f), feats2(:,f), feats3(:,f));
	end
end

% select features
if (nargout==2)
    
    if (nargin<3)
        percent = 10; % select 10% of the features if not metioned
    end
    
    % find threshold corsponding to the percentage
    sortdp = sort(dp,'descend');
    nFeatsSelect = ceil(percent*nFeat/100);
    if nFeatsSelect<1
        error('features to be selected are zero');
    end
    
    thresh = sortdp(nFeatsSelect);
    selected = (dp>=thresh);
end
