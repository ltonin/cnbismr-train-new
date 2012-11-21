% 2011-01-21  Michele Tavella <michele.tavella@epfl.ch>
function eegc3_fullscreen(f, vp)

if(nargin < 1)
	f = gcf();
end

if(nargin < 2)
    vp = 1.00;
end

if(strcmp(get(gcf, 'WindowStyle'), 'docked') == 0)
    ss = get(0, 'ScreenSize');
    set(f, 'Position', [0 0 ss(3)*vp ss(4)*vp]);
end
