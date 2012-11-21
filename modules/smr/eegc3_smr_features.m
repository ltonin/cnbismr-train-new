function fvector = eegc3_smr_features(data, fs, frqs, win, ovl, channels)
% Edited by M. Tavella <michele.tavella@epfl.ch> on 17/07/09 08:18:21
%
% EEGC2_FEATURES Extract Band Power or Power Spectrum Density features 
% from EEG data. It works as a wrapper for the EEGC2_BP and EEGC2_WPSD
% functions.
%
%    FVECTOR = EEGC3_SMR_FEATURES(DATA, FS, FRQS, WIN, OVL)
% 
%    If WIN or OVL are empty (eg: []), Band Power features are extracted.
%    Otherwise, Power Spectrum Density Features are extracted.
%    
%    Accepts:
%       DATA       [samples x channels]
%       FS         double
%       FRQS       array or cell array (check example!)
%       WIN        double
%       OVL        double 
%
%    Returns:
%       FVECTOR    [1 x channels] 
%
%     Examples:
%       TODO bp
%       TODO wpsd



if(isempty(channels))
	channels = 1:1:size(data, 2);
end
fvector = zeros(size(data, 2), length(frqs));

if(iscell(frqs))
	% Online use: chs/freqs are "sparse", return "sparse" structure
	%fvector = {};
	fvector = [];
	if(isempty(win) | isempty(ovl))
		for ch = channels
			fvector = [fvector; eegc3_bp(data(:, ch), fs, frqs{ch})];
		end	
	else
		for ch = channels
			fvector = [fvector; eegc3_psd(data(:, ch), frqs{ch}, fs, win, ovl)];
		end	
	end
else
	% Offline use: all the chs for all the freqs
	fvector = zeros(size(data, 2), length(frqs));
	if(isempty(win) | isempty(ovl))
		for ch = channels
			fvector(ch, :) = eegc3_bp(data(:, ch), fs, frqs);
		end
	else
		for ch = channels 
			fvector(ch, :) = eegc3_psd(data(:, ch), frqs, fs, win, ovl);
		end
	end
end
