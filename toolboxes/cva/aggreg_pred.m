function [OCOM,PWGR,V,vp,DISC,DISCT]=aggreg_pred(data,test);

% function [OCOM,PWGR,V,vp,DISC,DISCT]=aggreg_pred(data,test);
%
% Outputs: V. eigenvectors
%          DISC. transformed training data with labels in the fist column
%          DISCT.transformed test data
%          PWFR. Structure matrix: Within groups correlation matrix
%                between components and original features (features*components)
%          OCOM. Index 'Discriminability Power' (%) that shows the contribution
%                of each feature in the canonical space construction. 
%                Based in PWFR. First column is the feature number and the second is the index.  
%
% Inputs: data. Original data with labels in the fist column.
%         test. Original test data (without labels)


[n,d]=size(test);
a=max(data(:,1));

[OCOM,PWGR,V,vp,DISC]=cva_tun(data);
DISCT=test*V(:,1:a-1);
