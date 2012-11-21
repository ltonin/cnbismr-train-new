function [dp] = dpFWHM(x,y,z)
%
%  [dp] = dpFWHM(x,y,z)
%
% Modified discriminant power function with FWHM (Full Width at Half Maximum).
% An extention to 'dpportion' function. This function first cuts the distribution
% of each feature vector in order to keep only the samples that are in the
% range of [mu-0.5*FWHM mu+0.5*FWHM]. Where, FWHM is the width at the half
% of the distribution. H = 1.175*sigma.
%
% Input:
% - x,y, z: Feature distributions of the different classes (two or three)
% Output:
% - dp: Percentage of the samples that are not overlapping between both classes.
%
% This algorithm is not succeptible to outliers.
%
% See also: dpportion_selection

if (nargin <2 )||(nargin>3)
    error('dpportion algorithm is defined only for two ore three classes.');
else
    % compute mean and standard deviation for the first two classes
    m1 = mean(x); m2 = mean(y); s1 = std(x); s2 = std(y);

    % cut the distributions at FWHM
    x = x((x>=m1-1.175*s1)&(x<=m1+1.175*s1));
    y = y((y>=m2-1.175*s2)&(y<=m2+1.175*s2));

    if nargin==2
        % compute dp for two classes
        dp = (sum(y>max(x)) + sum(y<min(x)) + sum(x>max(y)) + sum(x<min(y)))...
            / (length(x) + length(y));
    elseif nargin == 3
        %warning('The dpFWHM function for three class not seem to be not working properly!')
        %fprintf('The dp range is [0 2] instead of [0 1]!!!');
        % compute mean and standard deviation for the third class
        % distribution
        m3 = mean(z); s3 = std(z);

        % cut the distribution of the third class at FWHM
        z = z((z>=m3-1.175*s3)&(z<=m3+1.175*s3));

        % compute dp for three classes
        dp = (sum(y>max(x)) + sum(y<min(x)) + sum(y>max(z)) + sum(y<min(z))...
            + sum(x>max(y)) + sum(x<min(y)) + sum(x>max(z)) + sum(x<min(z))...
            + sum(z>max(x)) + sum(z<min(x)) + sum(z>max(y)) + sum(z<min(y))) / ...
            (length(x) + length(y) + length(z));
		dp = dp/2;
    end
end
