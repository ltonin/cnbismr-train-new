% 2010-08-24  Michele Tavella <michele.tavella@epfl.ch>
% TODO
function eegc3_smr_barh(f, color, width)

if(nargin < 2)
    color = 'k';
end
if(nargin < 3)
    width = 2;
end

for i = 1:length(f)
	line(get(gca, 'Xlim'), ...
		[f(i) f(i)], 'LineWidth', width, 'Color', color, 'LineStyle', '-');
end
