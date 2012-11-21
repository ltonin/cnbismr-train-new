% 2011-03-31  Michele Tavella <michele.tavella@epfl.ch>
% function dp = eegc3_cva2(D1, D2)
% Where D1 [samples x variates]
%       D2 [samples x variates]
function dp = eegc3_cva2(D1, D2)

[N1, V1] = size(D1);
[N2, V2] = size(D2);

K1 = 1*ones(N1, 1);
K2 = 2*ones(N2, 1);

dp = cva_tun_opt([D1; D2], [K1; K2]);
