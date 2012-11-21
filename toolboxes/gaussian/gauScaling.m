% SCALING_FACTORS Returns scaling factors to compensate the eventual 
% different numbers of samples of each class in the set
%
% Syntax
%
%   function scaling_factors = gauScaling(set)
% 
% Description
%   
%   Returns scaling factors to compensate the eventual different numbers of 
%   samples of each class in the set
%
% Inputs
%
%   set - a 2D array of size nx(k+1) where n is the number of samples and k 
%   is the space dimensionality. The last column of set must contain the 
%   class of the samples
%
% Outputs
% 
%   scaling_factors - 1D array of size i, where i is the number of classes
%
% X-ref: none

function scaling_factors = gauScaling(set)                                            

set_dimensions = size(set);                                                     % Dimensions nx(k+1) of the set
set_classes = set(:,set_dimensions(2));                                         % Classes of the samples
set_data = set(:,1:set_dimensions(2)-1);                                        % Samples

classes = unique(set_classes);                                                  % Sorted list of the unique classes of the samples
classes_number = length(classes);                                               % Number of unique classes

for j = 1:classes_number
    classes_weight(j) = size(find(set_classes==classes(j)),1);                  % Number of samples of each class
end

classes_weight = 0.2 + 0.8./(classes_weight*classes_number/set_dimensions(1));  % Weight of the classes
scaling_factors = classes_weight./max(classes_weight);                          % Scaling_factors

% Pierre Ferrez, IDIAP, pierre.ferrez@idiap.ch, March 2005
% Modified Cristina de Negueruela, IDIAP, January 2007
