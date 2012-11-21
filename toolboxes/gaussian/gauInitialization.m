% INITIALISATION Initialises the centres and covariances for further learning
%
% Syntax
%
%   function [centers, covariances] = gauInitialisation (set, map, shared)
% 
% Description
%   
%   Initialises the values of the centers and covariances for further 
%   learning, using a 2D array of samples, a 1D array with the size of the 
%   2D map to create, and a booloean to specify if all prototypes of all 
%   class should use the same covariances.
%
% Inputs
%
%   set - a 2D array of size nx(k+1) where n is the number of samples and k 
%   is the space dimensionality. The last column of set must contain the 
%   class of the samples
%
%   map - a 1D array specifying the size of the 2D map to create using 
%   Self-Organizing Maps (SOM). For example map = [3 2] if you want 3x2 = 6 
%   prototypes per class
%
%   shared - 'f' for false or 't' for true. True means shared covariances
%
%   traino - use 0 to disable, 1 for CLI, 2 for GUI. This switch was 
%            added to avoid having a gui running when connected remotely
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

function [centers, covariances] = gauInitialisation (set, map, shared, traino)  % Function declaration, 3 inputs and 2 outputs

set_dimensions = size(set);                                                     % Dimensions nx(k+1) of the set
set_classes = set(:,set_dimensions(2));                                         % Classes of the samples
set_data = set(:,1:set_dimensions(2)-1);                                        % Samples

classes = unique(set_classes);                                                  % Sorted list of the unique classes of the samples
classes_number = length(classes);                                               % Number of unique classes

for i = 1:classes_number
    
    data = set_data(find(set_classes==classes(i)),:);                           % Extraction of samples of class i
    data_dimensions = size(data);                                               % Dimensions of the sub-array of samples of class i

    net = newsom(data', map);                                            
    
	net.trainParam.epochs = 400;                                                % SOM will perform 100 iterations
	net.trainParam.showCommandLine = false;
	net.trainParam.showWindow =  false;
	if(traino == 1)
		net.trainParam.showCommandLine = true;
	elseif (traino == 2)
		net.trainParam.showWindow =  true;
	end
	% /Edited
	net = train(net, data');                                          % SOM

    centers(i,:,:) = net.iw{1};                                                 % Extraction of the centers after SOM training

    for k = 1:map(1)*map(2)
        for l = 1:data_dimensions(2)
            covariances_raw(i,k,l) = 0;                                         % Declaration of the covariances
        end
    end
    for j = 1:data_dimensions(1)
        for k = 1:map(1)*map(2)
            for l = 1:data_dimensions(2)
                difference(k,l) = (data(j,l) - centers(i,k,l))^2;               % Distance of sample to centers of class i
            end
            distance(k) = sum(difference(k,:));                                 % Total distance
        end
        [minimum index] = min(distance);                                        % Minimum distance
        for k = 1:map(1)*map(2)
            for l = 1:data_dimensions(2)
                covariances_raw(i,k,l) = covariances_raw(i,k,l) ...
                    + difference(index,l)/data_dimensions(1);                   % Initialisation of covariances using the closest prototype
            end
        end
    end    
    clear data;                                                                 % Clear data for next class
    clear net;                                                                  % Clear net for next class
end

model_dimensions  = size(covariances_raw);                                      % Dimensions of the model

for i = 1:model_dimensions(1)
    for j = 1:model_dimensions(2)
        for k = 1:model_dimensions(3)
            if shared == 't'
                covariances(i,j,k) = mean(covariances_raw(:,j,k));              % Shared covariances, all prototypes of all classes have the
            else                                                                %     same covariances
                covariances(i,j,k) = covariances_raw(i,j,k);                    % Unshared covariances, all prototypes of a given class have
            end                                                                 %     the same covariances, but prototypes of different
        end                                                                     %     classes have different covariances
    end
end

% Pierre Ferrez, IDIAP, pierre.ferrez@idiap.ch, March 2005
% Modified Cristina de Negueruela, IDIAP, January 2007
