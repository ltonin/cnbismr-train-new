% 2009-12-07  Michele Tavella <michele.tavella@epfl.ch>

function fh = eegc3_figure(h, options, basename, psize)

if(nargin >= 1)
	if ishandle(h)
		set(0, 'CurrentFigure', h);
	else
		h = figure(h);
		set(h, 'Color',[1.0 1.0 1.0]);
    end
	% 2011-01-13  Michele Tavella <michele.tavella@epfl.ch>
	% Keeping defaults
    % set(0,'DefaultFigureWindowStyle','docked');
else
	h = figure;
	set(h, 'Color',[1.0 1.0 1.0]);
end


if(nargin > 1)
	switch(options)
		case 'fill'
			k = 1.00;
			%disp('[eegc3_figure] Filling');
			set(gca, 'Position', ...
				get(gca, 'OuterPosition') - ...
				get(gca, 'TightInset') * [-k 0 k 0; 0 -k 0 k; 0 0 k 0; 0 0 0 k]);
		case 'print'
			if(nargin >= 3)
				disp(['[eegc3_figure] Printing to ' basename]);
				set(h, 'renderer', 'painters');
				set(h, 'PaperUnits', 'centimeters');
				if(nargin >= 4)
					if(isempty(psize))
						psize = [21 29.7];
					end
				else
					psize = [29.7 21];
				end
				set(h, 'PaperSize', psize);
				set(h, 'PaperPosition', [0 0 psize]);
				set(h, 'PaperPositionMode', 'manual');
				if(strfind(basename, '.pdf'))
                    print(h, '-dpdf',   basename);
                elseif(strfind(basename, '.png'))
                    print(h, '-dpng',   basename);
                elseif(strfind(basename, '.eps'))
                    print(h, '-depsc2', basename);
                else
                    print(h, '-dpdf',   [basename '.pdf']);
                    print(h, '-dpng',   [basename '.png']);
                    print(h, '-depsc2', [basename '.eps']);
                end
			else
				disp('[eegc3_figure] Error: no basename specified');
            end
        case 'rawprint'
			if(nargin >= 3)
				disp(['[eegc3_figure] RAW-printing to ' basename]);
				if(strfind(basename, '.pdf'))
                    print(h, '-dpdf',   basename);
                elseif(strfind(basename, '.png'))
                    print(h, '-dpng',   basename);
                elseif(strfind(basename, '.eps'))
                    print(h, '-depsc2', basename);
                else
                    print(h, '-dpdf',   [basename '.pdf']);
                    print(h, '-dpng',   [basename '.png']);
                    print(h, '-depsc2', [basename '.eps']);
                end
			else
				disp('[eegc3_figure] Error: no basename specified');
            end
        otherwise	
            set(gcf, 'Name', options);
			%h = annotation('textbox', [0.5 0.9 0.10 0.10]); 
			%set(h, 'HorizontalAlignment', 'center');
			%set(h, 'EdgeColor', [1 1 1]);
			%set(h, 'String', options); 
	end
end

