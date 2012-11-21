% Serafeim Perdikis 2009
% Function for evidence accumulation (probability integration)
%
% accprobs_new = eegc3_integration(accprobs_old, rawprobs_now, alpha)
%  
% accprobs_old, accprobs_new and rawprobs_now are sized as [nclasses, 1]
% alpha is a parameter between 0.0 and 1.0, usually close to 1.0

function accprobs_new = eegc3_simple_integ(accprobs_old, rawprobs_now, alpha)

if(~isequal(rawprobs_now, [0 1]) && ~isequal(rawprobs_now, [1 0]))
    accprobs_new = accprobs_old;
    return;
end

if(rawprobs_now(1) == 1)
    % Move "right"
    accprobs_new = accprobs_old + [alpha -alpha];
else
    % Move "left"
    accprobs_new = accprobs_old + [-alpha alpha];
end

