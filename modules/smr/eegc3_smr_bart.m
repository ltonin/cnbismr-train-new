% 2010-08-24  Michele Tavella <michele.tavella@epfl.ch>
% TODO
function eegc3_smr_bart(t, color, width)

if(nargin < 2)
    color = 'k';
end
if(nargin < 3)
    width = 2;
end

line(t, [0 0], ...
	'LineWidth', width, 'Color', color, 'LineStyle', '-');
line(t, [1 1], ...
	'LineWidth', width, 'Color', color, 'LineStyle', '-');
