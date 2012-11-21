% 2010-12-05  Michele Tavella <michele.tavella@epfl.ch>
%
% St is [Time x Bandx x Channels x Trials]
% poi is [N x 1] in fames/samples
% dur is [1 x 1] in frames/samples

function [St, t] = eegc3_smr_gettrials(S, Sf, poi, dt)

dur = round(dt*Sf);
t = mt_support(0, dur, Sf);

[T, B, C] = size(S);
N = length(poi);
St = nan(dur, B, C, N);

for n = 1:N
	St(:, :, :, n) = S(poi(n):poi(n)+dur-1, :, :);
end