% 2010-08-30  Michele Tavella <michele.tavella@epfl.ch>
% function [y, Ahp, Bhp] = mt_filtbp(s, Sf, Fhp, Flp, order)
function [y, Ahp, Bhp] = mt_filtbp(s, Sf, Fhp, Flp, order)

Whp = [Fhp Flp]/(Sf/2);
[Bhp, Ahp] = butter(order, Whp);

y = filtfilt(Bhp, Ahp, s);
