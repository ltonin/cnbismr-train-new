% 2010-12-10  Michele Tavella <michele.tavella@epfl.ch>
%
% function F = eegc3_fs2(d1, d2)
% d2   [samples x dimensions]
% d2   [samples x dimensions]
% 
function F = eegc3_fs2(d1, d2)

m1 = nanmean(d1, 1);
m2 = nanmean(d2, 1);

s1 = nanstd(d1, [], 1);
s2 = nanstd(d2, [], 1);

F = abs(m2 - m1) ./ sqrt(s1.^2 + s2.^2);
