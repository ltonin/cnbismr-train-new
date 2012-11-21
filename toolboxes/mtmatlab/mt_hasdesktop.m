% 2010-08-31  Michele Tavella <michele.tavella@epfl.ch>
% function result = mt_hasdesktop()
function result = mt_hasdesktop()

result = ~isempty(com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame);
