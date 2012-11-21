% 2010-12-10  Michele Tavella <michele.tavella@epfl.ch>
%
% function F = eegc3_fs(d, k)
% d   [samples x dimensions]
% k   [samples x 1]
% 
function F = eegc3_fs(d, k)

[N, D] = size(d);
F = nan(D, 1);

u = unique(k);
if(length(u) ~= 2)
    return;
end

k1 = find(k == u(1));
k2 = find(k == u(2));

m1 = mean(d(k1, :));
m2 = mean(d(k2, :));

s1 = std(d(k1, :));
s2 = std(d(k2, :));

F = abs(m2 - m1) ./ sqrt(s1.^2 + s2.^2);
