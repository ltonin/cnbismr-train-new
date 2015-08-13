function isCompatible = eegc3_smr_comparesettings(settings1, settings2)
%
% function isCompatible = eegc3_smr_comparesettings(settings1, settings2)
%
% Function to compare two CNBI BCI settings structures for compatibility
%
% Inputs:
%
% settings1, settings2: settings structures (see eegc3_newsettings and 
% eegc3_smr_newsettings)
%
% Outputs:
%
% isCompatible: Boolean, true when the two settings structures are
% compatible (not necessarily identical, but describing the same SMR BCI)
%
%
%
%

tmp1 = settings1;
tmp2 = settings2;

% Get rid of insignificant/redundant fields for comparison

tmp1.info.date = [];
tmp1.info.experimenter = [];
tmp1.info.hostname = [];
tmp1.info.basename = [];

tmp1.acq.id = [];
tmp2.acq.id = [];

tmp2.info.date = [];
tmp2.info.experimenter = [];
tmp2.info.hostname = [];
tmp2.info.basename = [];

tmp1.acq.channels_exg = [];
tmp2.acq.channels_exg = [];

tmp1.bci.smr = [];
tmp2.bci.smr = [];

tmp1.modules.smr.dp = [];
tmp2.modules.smr.dp = [];

tmp1.modules.smr.gau = [];
tmp2.modules.smr.gau = [];
tmp1.modules.smr.lda = [];
tmp2.modules.smr.lda = [];


% But, somunits should be the same!
tmp1.modules.smr.gau.somunits = settings1.modules.smr.gau.somunits;
tmp2.modules.smr.gau.somunits = settings2.modules.smr.gau.somunits;

tmp1.modules.smr.options.selection = [];
tmp2.modules.smr.options.selection = [];


tmp1.modules.smr.options.extraction.trials =[];
tmp2.modules.smr.options.extraction.trials =[];

% Now compare
isCompatible = isequal(tmp1,tmp2);