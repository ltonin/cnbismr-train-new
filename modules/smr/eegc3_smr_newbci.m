%2010-11-11  Michele Tavella <michele.tavella@epfl.ch>
% TODO
function bci = eegc2_smr_newbci()

bci = [];
bci.trace 		= [];	% EEGC3 methods tracing 
bci.analysis 	= [];	% Online SMR analysis
bci.eeg			= [];	% NDF EEG ringbuffer
bci.exg			= [];	% NDF EXG ringbuffer
bci.tri			= [];	% NDF TRI ringbuffer
bci.support  	= [];	% Online SMR support
bci.frames 		= [];	% Frame size (in samples)
bci.framet 		= [];	% Frame total (in samples)
bci.cprobs 		= [];	% Classifier oputput
bci.iprobs 		= [];	% Integrated probabilities
bci.afeats 		= [];	% All PSD features
bci.rfeats 		= [];	% Non-normalized online-only PSD features
bci.nfeats 		= [];	% Online-only PSD features
bci.evt 		= [];	% LPT Trigger position (in frames) 
bci.trg 		= [];	% LPT Trigger value (TODO)
bci.lbl 		= [];	% GDF label event (as numeral)
bci.Sf 			= [];	% SMR BCI sampling frequency (in Hz)
bci.t 			= [];	% SMR BCI time support (in seconds)
