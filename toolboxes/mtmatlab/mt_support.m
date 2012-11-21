% 2010-08-30  Michele Tavella <michele.tavella@epfl.ch>
% function t = mt_support(t0, stot, sf)
function t = mt_support(t0, stot, sf)

t = [t0:1/sf:t0+(1/sf*(stot-1))];
