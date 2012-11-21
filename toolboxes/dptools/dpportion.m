function [dp] = dpportion(x,y,z)
%
% [dp] = dpportion(x,y,z)
%
% Computes discriminability of a feature for two or three classes. The
% inputs are feature distributions of two or three classes. The output is
% number between 0 and 1 representing discriminant power. The inputs x, y
% and z are one dimentional vectors of any size.
%
% The algorithm counts amount of non-overlapping portion of the
% distribution. For more details read thesis of Laurent Uldry avalable at
% https://publications.idiap.ch
%
% Warning : This method produces bad results for outliers.
%
% See also : dpFWHM

if nargin ==2
    dp = (sum(y>max(x)) + sum(y<min(x)) + sum(x>max(y)) + sum(x<min(y))) /...
        (length(x) + length(y));
elseif nargin ==3
    warning('The dpportion function for three class not seem to be not working properly!')
    fprintf('The dp range is [0 2] instead of [0 1]!!!');
    dp = (sum(y>max(x)) + sum(y<min(x)) + sum(y>max(z)) + sum(y<min(z))...
        + sum(x>max(y)) + sum(x<min(y))+ sum(x>max(z)) + sum(x<min(z))...
        + sum(z>max(x)) + sum(z<min(x)) + sum(z>max(y)) + sum(z<min(y))) / ...
        (length(x) + length(y)+length(z));
else
    error('dpportion algorithm is defined only for two ore three classes.');
end
