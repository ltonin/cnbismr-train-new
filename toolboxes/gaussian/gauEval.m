% EVAL_PERFORMANCES Evaluates the performances of a model on a given set 
% using a probability threshold
%
% Syntax
%
%   function [conf_matrix, perf] = gauEval(centers, covariances, ...  
%    set, prob_thresh)
% 
% Description
%   
%   Evaluates the performances of a given model (centers and covariances) 
%   on a given set using a probability threshold.
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
%   prob_thresh - scalar, the probability threshold
%
% Outputs
% 
%   conf_matrix - 2D array, the confusion matrix, absolute and relative 
%   values
%
%   perf - 1D array of size 3. It contains the error function, the 
%   percentage of miss-classfied samples and the percentage of 
%   non-classified samples.
%
% X-ref: classifier.m, scaling.m

function [conf_matrix, perf] = gauEval(centers, covariances, ...  
    set, prob_thresh)    

set_dimensions = size(set);                                                         % Dimensions nx(k+1) of the set
set_classes = set(:,set_dimensions(2));                                             % Labels of the samples
set_data = set(:,1:set_dimensions(2)-1);                                            % Samples

classes = unique(set_classes);                                                      % Sorted list of the unique classes of the samples
classes_number = length(classes);                                                   % Number of unique classes

conf_matrix_abs = zeros (classes_number, classes_number+1);                         % Initialisation of absolute confusion matrix

for i = 1:set_dimensions(1)
    [activities, probabilities] = gauClassifier(centers, covariances, set_data(i,:));  % Classification of sample i
    [max_prob index_class] = max(probabilities);                                    % Highest probability, recognised class = classes(index_class)
    index_label=find(classes==set_classes(i));                                      % Class index for label of current sample
    if max_prob < prob_thresh                                                       % Updating absolute confusion matrix
        conf_matrix_abs(index_label,classes_number+1) = ...                         % Unclassified if under the threshold
            conf_matrix_abs(index_label,classes_number+1)+1;
    else
        conf_matrix_abs(index_label,index_class) = ...
            conf_matrix_abs(index_label,index_class)+1;                             % Updating absolute confusion matrix
    end
    target = zeros(1,classes_number);                                               % Initialisation of target
    target(find(classes==set_classes(i))) = 1;                                      % Target = 1 for class of sample i
    
    scaling_factors = gauScaling(set);                                                 % Scaling factors
    error(i) = sum(((probabilities - target).^2).*scaling_factors);                 % Error function for sample i
end
err_function = sum(error)/set_dimensions(1)/2;                                      % Total error function

for i = 1:classes_number
    conf_matrix_rel(i,:) = 100*conf_matrix_abs(i,:)/sum(conf_matrix_abs(i,:));      % Relative confusion matrix
end

correct_class = sum(diag(conf_matrix_abs));                                         % Correctly classified samples

non_class_abs = sum(conf_matrix_abs(:,classes_number+1));                           % Non-classified samples
non_class = non_class_abs/set_dimensions(1);                                        % Ratio of non-classified samples

miss_class_abs = set_dimensions(1) - correct_class - non_class_abs;                 % Miss-classified samples
miss_class = miss_class_abs/set_dimensions(1);                                      % Ratio of miss-classified samples

conf_matrix=[conf_matrix_abs;conf_matrix_rel];                                      % General confusion matrix
perf = [err_function, miss_class, non_class];                                       % Performances

% Pierre Ferrez, IDIAP, pierre.ferrez@idiap.ch, March 2005
% Modified Cristina de Negueruela, IDIAP, January 2007
