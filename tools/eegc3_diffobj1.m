function [f g h] = eegc3_diffobj1(x,m1,s1,m2,s2)

f1 = normpdf(x,m1,s1);
f2 = normpdf(x,m2,s2);

f = f2-f1;
g = -f2.*(x-m2)./(s2^2) + f1.*(x-m1)./(s1^2);
h = f2.*((x-m2).^2)./(s2^4) - f2./(s2^2) ...
    - f1.*((x-m1).^2)./(s1^4) + f1./(s1^2);