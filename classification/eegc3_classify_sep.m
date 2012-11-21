function FC = eegc3_classify_sep(sep, data)

Lik = [mvnpdf(data, sep.m_right_sep, sep.cov_right_sep) ...
    mvnpdf(data, sep.m_left_sep, sep.cov_left_sep)];

FC = double(bsxfun(@gt,Lik(:,1),Lik(:,2)));
FC(find(FC==0)) = 2;