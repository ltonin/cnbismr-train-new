% UPDATE Updates the centers and covariances of the gaussian model
%
% Syntax
%
%  function [centers, covariances] = gauUpdate(centers, covariances, set, ...
%       centers_rate, covariances_rate, shared)
% 
% Description
%   
%  This function updates the centers and covariances of the model for each 
%  sample of the set using the given learning rates for centers and 
%  covariances and a booloean to specify if all prototypes of all class 
%  should use the same covariances
%
% Inputs
%
%   centers - 3D array of size ixjxk, where i is the number of classes, j
%   is the number of prototypes per class and k is the space dimensionality
%
%   covariances - 3D array of size ixjxk, where i is the number of classes, 
%   j is the number of prototypes per class and k is the space 
%   dimensionality.
%
%   set - a 2D array of size nx(k+1) where n is the number of samples and k 
%   is the space dimensionality. The last column of set must contain the 
%   class of the samples
%
%   centers_rate - a scalar, the learning rate for the centers
%
%   covariances_rate - a scalar, the learning rate for the covariances
%
%   shared - a boolean ('f' or 't') for unshared/shared covariances
%
% Outputs
% 
%   centers - 3D array of size ixjxk, where i is the number of classes, j
%   is the number of prototypes per class and k is the space dimensionality
%
%   covariances - 3D array of size ixjxk, where i is the number of classes, 
%   j is the number of prototypes per class and k is the space 
%   dimensionality.
%
% X-ref: none

function [centers, covariances] = gauUpdate(centers, covariances, set, ...             
    centers_rate, covariances_rate, shared)            

model_dimensions = size(centers);                                                   % Dimensions of the model
set_dimensions = size(set);                                                         % Dimensions nx(k+1) of the set
set_classes = set(:,set_dimensions(2));                                             % Classes of the samples
set_data = set(:,1:set_dimensions(2)-1);                                            % Samples

classes = unique(set_classes);                                                      % Sorted list of the unique classes of the samples
classes_number = length(classes);                                                   % Number of unique classes

scaling_factors = gauScaling(set);                                                     % Scaling factors

for i = 1:set_dimensions(1)
    [activities, probabilities] = gauClassifier(centers, covariances, set_data(i,:));  % Activities and probabilities for sample i
    sum_activities = sum(sum(activities));
   	%imagesc(activities/sum(sum(activities)));
	%axis image;
	%drawnow;

    if (sum_activities ~=0)
      activities = activities/sum_activities;                                       % Normalized activities
    end
    
    target = zeros(1,classes_number);                                               % Target initialisation
    target(find(classes == set_classes(i))) = 1;                                    % Target = 1 if class match the class of the sample
    
    error = sum((target-probabilities).*probabilities);                             % Pseudo error function
    factor = (target - probabilities - error).*scaling_factors;                     % Activity factors
    
    activities = activities .* repmat(factor',[1,model_dimensions(2)]);             % Weighted activities
    
    laRate = centers_rate*activities;                                               % Rates for the centers
    lbRate = covariances_rate*activities;                                           % Rates for the covariances

    for j = 1:model_dimensions(1)
        for k = 1:model_dimensions(2)
            for l = 1:model_dimensions(3)
                centers_new(j,k,l) = centers(j,k,l) + laRate(j,k)*...
                    (set_data(i,l) - centers(j,k,l))/covariances(j,k,l);            % Centers update
                covariances_new(j,k,l) =covariances(j,k,l)*exp(lbRate(j,k)*...      % Covariances update
                    (((set_data(i,l) - centers(j,k,l))^2)/(covariances(j,k,l)^1.5)));
            end
        end
    end
    
    % These two lines should do the same as the for lop above, but
    % there's a slight difference and it takes 1 second more...
%     centers_new = centers + repmat(laRate,[1,1,model_dimensions(3)]) .* (repmat(set_data(i),[model_dimensions(1),model_dimensions(2),model_dimensions(3)]) - centers)./covariances;
%     covariances_new = (repmat(lbRate,[1,1,model_dimensions(3)]) .* (((repmat(set_data(i),[model_dimensions(1),model_dimensions(2),model_dimensions(3)]) - centers).^2)./(covariances.^1.5)) + sqrt(covariances)).^2; 

    centers = centers_new;
    
    covariances_unshared = repmat(mean(covariances_new,2),[1,model_dimensions(2)]); % Averaging covariances of same class
    
    if shared =='t'
        covariances = repmat(mean(covariances_unshared,1),[model_dimensions(1),1]); % Shared covariances if shared = 't'
    else
        covariances = covariances_unshared;                                         % Unshared covariances if shared = 'f'
    end
        
end

% Pierre Ferrez, IDIAP, pierre.ferrez@idiap.ch, March 2005
% Modified Cristina de Negueruela, IDIAP, March 2007
