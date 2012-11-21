% 2010-08-30  Michele Tavella <michele.tavella@epfl.ch>
% function [y, Ahp, Bhp] = mt_filthp(s, Sf, Fhp, order)
function [y, Ahp, Bhp] = mt_filthp(s, Sf, Fhp, order)

Whp = Fhp/(Sf/2);
[Bhp, Ahp] = butter(order, Whp, 'high');

y = filtfilt(Bhp, Ahp, s);
