function [Sigma rho] = eegc3_shrink_OAS(Sampled, n)

% Inputs:
%
% Sampled: Sampled covarianve matrix (computed conventionally on the dataset)
% n: Number of samples (used to compute the covariance matrix)
%
% Outputs:
%
% Sigma: Shrinked covariance matrix
% rho: parameter of shrinkage
%


p = size(Sampled,1);
Target = trace(Sampled)/p*eye(p);

TrSS = trace(Sampled^2);
TrS2 = trace(Sampled)^2;

rho = -TrSS/p + TrS2;
rho = rho/( (n-1)*TrSS/p + (1-n)*TrS2/(p.^2) );
rho = min(rho,1);

Sigma = (1-rho)*Sampled + rho*Target;