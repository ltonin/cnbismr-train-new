function D = eegc3_mah_dst(x,m,S)

D = sqrt((x-m)'*inv(S)*(x-m))./sqrt(size(S,1));