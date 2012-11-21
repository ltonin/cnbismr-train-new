function [COM,PWGR,V,vp,DISC]=cva_tun(data);
%
% function [COM,PWGR,V,vp,DISC]=cva_tun(data);
%
% Outputs: V. eigenvectors
%          DISC. transformed data with labels in the fist column (There are
%          classes-1 variates).
%          PWGR. Structure matrix: Within groups correlation matrix
%                between components and original features (features*components)
%          COM. Index 'Discriminability Power' (%) that shows the contribution
%                of each feature in the canonical space construction. 
%                 
%
% Inputs: data. Original data with labels in the first column.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CVA transformation

[n,d]=size(data);
pat=data(:,2:d);
a=max(data(:,1));

%Whitin covariance matrix
for k=1:a
    CLASE(k).data=data(find(data(:,1)==k),2:d);%segmentacio de patrons de cada classe
    N(:,:,k)=size(CLASE(k).data);
    myCOV(:,:,k)= (N(1,1,k)-1)*(cov(CLASE(k).data));
end
C=sum(myCOV,3);
    
M=mean(pat);

%Between covariance matrix
for k=1:a
    CLASE(k).data=data(find(data(:,1)==k),2:d);%segmentacio de patrons de cada classe
    N(:,:,k)=size(CLASE(k).data);
    Mg(:,:,k)=mean(CLASE(k).data);
    Centg(:,:,k)=Mg(:,:,k)-M;
    Centgsq(:,:,k)=((Centg(:,:,k))'*(Centg(:,:,k)));
    Bg(:,:,k)=N(1,1,k)*Centgsq(:,:,k);
end
B=sum(Bg,3);
Cinv=pinv(C);
Can=Cinv*B;
[V,vp]=svd(Can);
vp=diag(vp);
%ndices = find(vp>0.01);

DISC=[data(:,1),pat*V(:,1:a-1)];
%DISC=[data(:,1),pat*V(:,ndices)];


%Within groups correlation matrix (Correlation beween components and originalfeatures)

ALL=[DISC,pat];
[nall,dall]=size(ALL);
for k=1:a
    WGCov(k).ALL=ALL(find(ALL(:,1)==k),2:dall);%segmentacio de patrons de cada classe
    NWGCov(:,:,k)=size(WGCov(k).ALL);
    WGCOV(:,:,k)= (NWGCov(1,1,k)-1)*(cov(WGCov(k).ALL));
end
PWGCov=sum(WGCOV,3);
[Dim,Dim]=size(PWGCov);
for i=1:Dim
    for u=1:Dim
        PWGR(i,u)=PWGCov(i,u)/(sqrt(PWGCov(i,i)*PWGCov(u,u)));
    end
end
PWGR(:,a:Dim)=[];
PWGR(1:a-1,:)=[];

%Discriminability Power (%)
vp=vp(1:a-1,1)./sum(vp(1:a-1,1));
%Unweighted
%COM=100.*(sum(PWGR(:,1:a-1).^2,2)./sum(sum(PWGR(:,1:a-1).^2,2)));
%Weighted
%COM=100.*((((PWGR(:,1:a-1).^2)*(vp(1:a-1,1)))./(sum(vp(1:a-1,1))))./(sum(((PWGR(:,1:a-1).^2)*(vp(1:a-1,1)))./(sum(vp(1:a-1,1))))));
COM=100.*(((PWGR(:,1:a-1).^2)*(vp))./(sum((PWGR(:,1:a-1).^2)*(vp))));

%plot(COM,'LineWidth',3);
%axis([1 d-1 0 max(COM)])
%xlabel('Original Features')
%ylabel('Discriminability Power (%)')
%title('Contributions of Each Original Feature in the Canonical Space')
%[OCOM,feature]=sort(COM,'descend');
%OCOM=[feature,OCOM];
