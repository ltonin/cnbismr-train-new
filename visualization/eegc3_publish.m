% 2010-01-27  Michele Tavella <michele.tavella@epfl.ch>
% function eegc3_publish(textfs, axesfs, linew, axesw)
function eegc3_publish(textfs, axesfs, linew, axesw)
if(textfs)
	set(0, 'defaulttextfontsize', textfs);
end
if(axesfs)
	set(0, 'defaultaxesfontsize', axesfs);
end
if(linew)
	set(0, 'defaultaxeslinewidth', linew);
end
if(axesw)
	set(0, 'defaultlinelinewidth', axesw);
end
