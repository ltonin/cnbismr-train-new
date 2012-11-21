% Edited by M. Tavella <michele.tavella@epfl.ch> on 29/04/09 11:45:56
%
% function [perf] = eegc3_acchard(kt, kr)
%
% Where:  kt    targets (n x 1) 
%         kr    results (n x 1)

function [perf] = eegc3_acchard(kt, kr)

perf = length(find(kt == kr))/length(kt);
