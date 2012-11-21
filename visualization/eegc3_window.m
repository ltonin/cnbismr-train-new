% 2011-01-21  Michele Tavella <michele.tavella@epfl.ch>
function eegc3_window(f, name)

if(isempty(f))
	f = gcf;
end
set(f, 'Name', name);
