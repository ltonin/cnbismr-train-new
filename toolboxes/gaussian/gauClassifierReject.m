% CLASSIFIER Sample classification using a given gaussian model 
% with rejection
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
%  each class). A rejection scheme has been impleneted, in order to avoid
% returning arbitrary probabilites due to minimal activation of all 
% the prototypes
%
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

function [activities, probabilities] = gauClassifierReject(centers, covariances, sample, rejection_factor)     

model_dimensions = size(centers);                                                   % Dimensions of the model

for i = 1:model_dimensions(1)
	activation_control= zeros(model_dimensions(2),1);
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
	
	% Edited by Serafeim Perdikis, 25/09/2009
	% Check activation of this prorotype
	% The sample coordinates in the input space should not 
	% be more than rejection_factor times away from the mean of
	% the prototype along ALL dimensions of the input space
	
	activation_control(j) = floor(length(find(sqrt(distance)<...
	rejection_factor))/model_dimensions(3));	
	
	
        determinant_temp(find(determinant_temp==0))=1;                              % Test to prevent determinant = 0
        determinant = prod(determinant_temp);
        distance_sum = sum(distance);                                               % Total distance to sample for prototype j of class i
        activities(i,j) = exp(-distance_sum/2) / determinant;                       % Activity of prototype j of class i
    end
	
	% If the class is not activated (enough), note it down
	% Class_activated is either 1 or 0
	ClassActivated(i) = floor(sum(activation_control)/...
	model_dimensions(2));
end

ClassActivated
 % Unnormalized probabilities
raw_probabilities = sum(activities,2)';   

% Refine raw probabilites according to rejection
% The classes that were not activated enough according to the
% criterion will receive zero probability
% If all classes are not activated, uniform distribution will
% be returned, due to the next if clause
raw_probabilities = raw_probabilities.*ClassActivated;

% Sum of unnormalized probabilities
probabilities_sum = sum(raw_probabilities);                                         
if (probabilities_sum  ~= 0)
  probabilities = raw_probabilities / probabilities_sum;                            % Normalized probabilities
else
  probabilities = ones(1,model_dimensions(1)) /model_dimensions(1); 
end

% Pierre Ferrez, IDIAP, pierre.ferrez@idiap.ch, March 2005
% Modified Cristina de Negueruela, IDIAP, January 2007
% Modified by Serafeim Perdikis, EPFL, September 2009
