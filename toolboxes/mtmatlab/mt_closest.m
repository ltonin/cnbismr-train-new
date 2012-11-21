% 2010-08-26  Michele Tavella <michele.tavella@epfl.ch>
% [b, a, e] = closest(vec, val)
function [b, a, e] = closest(vec, val)
[a, b] = min(abs(vec - val));
a = vec(b);
e = mse(a - val);
