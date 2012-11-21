% 2010-08-31  Michele Tavella <michele.tavella@epfl.ch>
% function p = mt_power(x, wsize, wshift)
function p = mt_power(x, wsize, wshift)

p = [];

for s0 = [1:wshift:(length(x)-wsize)]
	p(end+1) = sum(x(s0:s0+wsize).^2);
end
%dx = dx((1+wsize):(length(x)-wsize));
