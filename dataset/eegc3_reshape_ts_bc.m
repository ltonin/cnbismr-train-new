function udataset = eegc3_reshape_ts_bc(dataset)
% Edited by M. Tavella <michele.tavella@epfl.ch> on 20/07/09 12:48:53

tdataset = eegc3_reshape_ts_b_c(dataset);

d1 = eegc3_size(dataset, 't') * eegc3_size(dataset, 's');
d2 = eegc3_size(dataset, 'c') * eegc3_size(dataset, 'b');
transform = [d1 d2];

udataset = zeros(transform);
cb = 1;
for ts = 1:eegc3_size(dataset, 't') * eegc3_size(dataset, 's')
	udataset(cb, :) = tdataset(ts, :);
	cb = cb + 1;
end
