% Edited by M. Tavella <michele.tavella@epfl.ch> on 29/04/09 22:13:08
%
% function [perf, rej, krh] = eegc3_accsoft(kt, kr, k, th)
%
% Where:  kt    targets (n x 1) 
%         kr    results (n x K)
%         k     classes (1 x K)
%         th    threshold
%
% With: K number of classes, n number of patterns

function [perf, rej, krh] = eegc3_accsoft(kt, kr, k, th)

krh = zeros(size(kr));
for ki = 1:length(k)
	above = find(kr(:,ki) > th);
	below = setdiff(1:size(kr,1), above);
	krh(above, ki) = 1;
	krh(below, ki) = 0;
end

krh = krh*k';

rej  = length(find(krh == 0))/length(kt);
accP = find(krh ~= 0);
perf = length(find(krh(accP) == kt(accP))) / length(kt);
