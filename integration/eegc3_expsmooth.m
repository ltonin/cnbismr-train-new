% Serafeim Perdikis 2009
% Function for evidence accumulation (probability integration)
%
% accprobs_new = eegc3_integration(accprobs_old, rawprobs_now, alpha)
%  
% accprobs_old, accprobs_new and rawprobs_now are sized as [nclasses, 1]
% alpha is a parameter between 0.0 and 1.0, usually close to 1.0

function accprobs_new = eegc3_expsmooth(accprobs_old, rawprobs_now, alpha)
accprobs_new = alpha * accprobs_old + (1 - alpha) * rawprobs_now;
