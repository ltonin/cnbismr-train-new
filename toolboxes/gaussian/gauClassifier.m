% CLASSIFIER Sample classification using a given gaussian model
%
% Syntax
%
%  function [activities, probabilities] = gauClassifier(centers, covariances, sample)
% 
% Description
%   
%  This function classifies a sample, using a given gaussian model (centers 
%  and covariances). It returns a 2D array of activities (activity of each 
%  prototype of each class) and a 1D array of probabilities (probability of 
%  each class)
%
% Inputs
%
%  centers - 3D array of size ixjxk, where i is the number of classes, j is
%  the number of prototypes per class and k is the space dimensionality
%
%  covariances - 3D array of size ixjxk, where i is the number of classes,
%  j is the number of prototypes per class and k is the space 
%  dimensionality
%
%  sample - 1D array of size k, where k is the space dimensionality
%
% Outputs
% 
%  activities - 2D array of size ixj, where i is the number of classes and
%  j is the number of prototypes per class
%
%  probabilities - 1D array of size i, where i is the number of classes
%
% X-ref: none

function [activities, probabilities] = gauClassifier(centers, covariances, sample)     

model_dimensions = size(centers);                                                   % Dimensions of the model

for i = 1:model_dimensions(1)
    for j = 1:model_dimensions(2)
        determinant = 1;                                                            % Initialisation of the determinant of the covariance matrix            
        % Edited by M. Tavella <michele.tavella@epfl.ch> on 02/08/09 17:19:35
		% This code is really inefficient due to the large numbers of calls done 
		% to squeeze!
		% 
		% distance = (sample - squeeze(centers(i,j,:))').^2 ./ ...
        %     squeeze(covariances(i,j,:))';                                          % Calculate the Distance
		% determinant_temp = determinant * sqrt(squeeze(covariances(i,j,:))');         % Calculate the determinant
		
		% Edited by M. Tavella <michele.tavella@epfl.ch> on 02/08/09 17:21:05
		% This is a quick patch, but the gauClassifier needs some heavy
		% refactory.
        % This patch makes this method 4 times faster!
		M = reshape(centers(i,j,:), [1 model_dimensions(3)]);
		C = reshape(covariances(i,j,:), [1 model_dimensions(3)]);
        distance = (sample - M).^2 ./ C;
		determinant_temp = determinant * sqrt(C);

        determinant_temp(find(determinant_temp==0))=1;                              % Test to prevent determinant = 0
        determinant = prod(determinant_temp);
        distance_sum = sum(distance);                                               % Total distance to sample for prototype j of class i
        activities(i,j) = exp(-distance_sum/2) / determinant;                       % Activity of prototype j of class i
    end
end

raw_probabilities = sum(activities,2)';                                             % Unnormalized probabilities
probabilities_sum = sum(raw_probabilities);                                         % Sum of unnormalized probabilities

if (probabilities_sum  ~= 0)
  probabilities = raw_probabilities / probabilities_sum;                            % Normalized probabilities
else
  probabilities = ones(1,model_dimensions(1)) /model_dimensions(1); 
end

% Pierre Ferrez, IDIAP, pierre.ferrez@idiap.ch, March 2005
% Modified Cristina de Negueruela, IDIAP, January 2007
