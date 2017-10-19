function data = eegc3_filter(data, opt_filter)

data = filter(opt_filter.b, opt_filter.a, data);