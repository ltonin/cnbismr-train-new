function I = eegc3_cp(Pe, Pr, N)
% Edited by M. Tavella <michele.tavella@epfl.ch> on 10/08/09 17:51:13

% Avoid to get NaN
if(Pe == 0)
	Pe = 0.00000001;
end
if(Pe == 1)
	Pe = 0.99999999;;
end
I = (1 - Pr)*(log2(N) + (1 - Pe)*log2(1-Pe) + Pe*log2(Pe/(N-1)));
