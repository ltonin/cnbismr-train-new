% 2010-12-07  Michele Tavella <michele.tavella@epfl.ch>
function eegc3_dpplot(f, M, interval, channels, bands, plotcb)

if(nargin == 3)
	channels = [1:1:16];
	bands = [4:2:48];
end

if(nargin < 6)
    plotcb = false;
end

if(f > 0)
    eegc3_figure(f);
end
imagesc(M, interval);
if(iscell(channels))
    set(gca, 'YTick',      1:1:length(channels));
    set(gca, 'YTickLabel', channels);
else
    set(gca, 'YTick',      [1:2:length(channels)]);
    set(gca, 'YTickLabel', channels(1:2:end));
end
set(gca, 'XTick',      [1:4:length(bands)]);
set(gca, 'XTickLabel', bands(1:4:end));
xlabel('Band [Hz]');
ylabel('Channel');
colormap(1-copper);
if(plotcb)
    colorbar;
end
axis image;
