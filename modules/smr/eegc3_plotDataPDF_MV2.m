function eegc3_plotDataPDF_MV2(M1,S1,M2,S2,fignum, w,c)

xx1 = [-5:0.1:5];
xx2 = [-5:0.1:5];
[X1 X2] = meshgrid(xx1,xx2);
zmax = max(mvnpdf(M1',M1',S1),mvnpdf(M2',M2',S2));

for i=1:length(xx1)
    for j=1:length(xx2)
        z1(i,j) = mvnpdf([xx1(i),xx2(j)],M1',S1);
        z2(i,j) = mvnpdf([xx1(i),xx2(j)],M2',S2);
        SumLik = z1(i,j) + z2(i,j);
        Prob = [z1(i,j)/SumLik z2(i,j)/SumLik];
        if(Prob(1) > 0.7)
            nr1(i,j) = Prob(1)*zmax;
        else
            nr1(i,j) = 0;
        end
    if(Prob(2) > 0.7)
            nr2(i,j) = Prob(2)*zmax;
        else
            nr2(i,j) = 0;
        end        
    end
end


if(nargin > 5)
    %x1 = @(x2)(-c./w(1) - w(2)./w(1).*x2);
    x2 = @(x1)(-c./w(2) - w(1)./w(2).*x1);
    P = [-5 x2(-5) 0;...
        -5 x2(-5) zmax;...    
        5 x2(5) zmax;...
        5 x2(5) 0];
end

% figure(fignum);
% contour(xx1,xx2,z1,[0.1,0.1],'--b');
% hold on;
% contour(xx1,xx2,z2,[0.1,0.1],'--r');
% if(nargin>5)
%     patch(P(:,1),P(:,2),'g');
% end
% hold off;
% axis equal
% drawnow;

figure(10*fignum);
surf(X1,X2,z1, ones(size(z1)));
hold on;
surf(X1,X2,z2, 2*ones(size(z2)));
if(nargin>5)
    patch(P(:,1),P(:,2),P(:,3),'g');
end
hold off;
axis square
xlabel('x1');
ylabel('x2');
zlabel('f');
drawnow;
axis([-5 5 -5 5 0 zmax]);
view(45,45)

% Plot non-rejected areas
figure(20*fignum);
surf(X1,X2,nr1, ones(size(nr1)));
hold on;
surf(X1,X2,nr2, 2*ones(size(nr2)));
hold off;
axis square
xlabel('x1');
ylabel('x2');
zlabel('f');
drawnow;
axis([-5 5 -5 5 0 zmax]);
view(45,45)
