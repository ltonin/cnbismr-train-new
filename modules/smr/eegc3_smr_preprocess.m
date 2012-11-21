function data = eegc3_smr_preprocess(data, opt_dc, opt_car, opt_laplacian, laplacian)
% Edited by M. Tavella <michele.tavella@epfl.ch> on 16/07/09 15:38:11
%
% EEGC2_PREPROCESS Runs DC, CAR and Laplacian filtering on EEG data
% It works as a wrapper for the EEGC2_DC and EEGC2_CAR functions.
%
%    RESULT = EEGC2_PREPROCESS(DATA, OPT_DC, OPT_CAR, MONTAGE)
%    Use OPT_DC and OPT_CAR and OPT_LAPLACIAN to enable/disable DC and CAR
%    (bool).
%    If LAPLACIAN is not an empty matrix, perform Laplacian filtering.
%   
%    Accepts:  
%      DATA           [samples x channels].
%      OPT_CAR        bool
%      OPT_DC         bool
%      OPT_LAPLACIAN  bool
%      LAPLACIAN      [channels x channels]
%
%    Returns:
%      RESULT         [samples x channels].

if(opt_dc)
	data = eegc3_dc(data);
end

if(opt_car)
	data = eegc3_car(data);
end

if(opt_laplacian)
	data = data * laplacian;
end
