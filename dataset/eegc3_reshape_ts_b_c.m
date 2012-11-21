function udataset = eegc3_reshape_ts_b_c(dataset)
% 2010-12-07  Michele Tavella <michele.tavella@epfl.ch>
% 
% From [Samples x Bands x Channels x Trials]
% To   [(Samples x Trials) x Bands x Channels]

d1 = eegc3_size(dataset, 't') * eegc3_size(dataset, 's');
d2 = eegc3_size(dataset, 'b');
d3 = eegc3_size(dataset, 'c');
transform = [d1 d2 d3];

udataset = zeros(transform);
ts = 1;
for t = 1:eegc3_size(dataset, 't')
	for s = 1:eegc3_size(dataset, 's')
		udataset(ts, :, :) = squeeze(dataset(s, :, :, t));
		ts = ts + 1;
	end
end
