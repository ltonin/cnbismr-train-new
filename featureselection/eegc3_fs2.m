% 2010-12-10  Michele Tavella <michele.tavella@epfl.ch>
%
% function F = eegc3_fs2(d1, d2)
% d2   [samples x dimensions]
% d2   [samples x dimensions]
% 
function F = eegc3_fs2(d1, d2)

m1 = mean(d1, 1);
m2 = mean(d2, 1);

s1 = std(d1, [], 1);
s2 = std(d2, [], 1);

F = abs(m2 - m1) ./ sqrt(s1.^2 + s2.^2);
