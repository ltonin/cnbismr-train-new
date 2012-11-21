% 2010-08-30  Michele Tavella <michele.tavella@epfl.ch>
% function [s, t] = mt_sigtest(Sf, f, a)
function [s, t] = mt_sigtest(Sf, f, a)

if(nargin < 3)
	a = (1)./[1:0.5:4.5];
end

if(nargin < 2)
	f = [5 25 45 65 85 100 110];
end

if(nargin < 1)
	Sf = 2048;
end

t = [1:1/Sf:2];
s = zeros(size(t));
for i = 1:length(f)
	s = s + a(i)*sin(2*pi*t*f(i));
end
