function data = eegc3_filter(data)

% filter design
d = fdesign.bandpass('N,F3dB1,F3dB2',4,1,40,300); % for 4th order from 1 to 15 hz @ 300 Hz  sampling rate
Hd_bp = design(d,'butter');

% apply:
data = filter(Hd_bp,data);