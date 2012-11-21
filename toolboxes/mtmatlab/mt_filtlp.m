% 2010-08-30  Michele Tavella <michele.tavella@epfl.ch>
% function [y, Alp, Blp] = mt_filtlp(s, Sf, Flp, order)
function [y, Alp, Blp] = mt_filtlp(s, Sf, Flp, order)

Wlp = Flp/(Sf/2);
[Blp, Alp] = butter(order, Wlp, 'low');

y = filtfilt(Blp, Alp, s);
