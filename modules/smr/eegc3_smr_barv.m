% 2010-08-24  Michele Tavella <michele.tavella@epfl.ch>
% TODO
function eegc3_smr_barv(t, color, width)

if(nargin < 2)
    color = 'k';
end
if(nargin < 3)
    width = 2;
end


for i = 1:length(t)
	line([t(i) t(i)], ...
		get(gca, 'Ylim'), 'LineWidth', width, 'Color', color);
end
