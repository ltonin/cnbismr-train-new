function eegc3_plotDataPDF_UV(M1,S1,M2,S2, showdiff, fignum)

Left = min(M1,M2);
Right = max(M1,M2);
s = (S1 + S2)/2;

Left = Left-4*s;
Right = Right+4*s;
xx = [Left:s/100:Right];


f1 = @(x)normpdf(x,M1,S1);
f2 = @(x)normpdf(x,M2,S2);
g1 = @(x)(f1(x) - f2(x));
g2 = @(x)(f2(x) - f1(x));

fmax = max(f1(M1),f2(M2));

figure(fignum);
if(showdiff)
    plot(xx,f1(xx),'b',xx,f2(xx),'r',xx,g1(xx),'k',xx,g2(xx),'g');
else
    plot(xx,f1(xx),'b',xx,f2(xx),'r');
end
xlabel('x');
ylabel('f');
axis([Left Right 0 fmax]);
%axis equal
drawnow;
