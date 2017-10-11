function [dpa, channels, bands, bandsidx, tot, dpm, gamma, struct_mat] = ...
	eegc3_smr_select(dataset,  settings)
%function [dpa, channels, bands, bandsidx, tot, dpm, gamma, struct_mat] =
%...eegc3_smr_select(dataset,  settings)%
%
%
% ATTENTION: TO REVIEW
%
% Function to perform feature selection (CVA or dptools) on a single
% dataset
%
% Inputs:
%
% dataset: Struct holding the data and labelsfor a single run:
%   data: Data matrix samples x (channels x frequencies)
%   labels: Labels vector, samples x 1
%   path: Filepath of the GDF file corresponding to this run
%
% Outputs:
%
% dpa: Discrimiannt power index matrix of all features
%
% channels: vector of selected channels
%
% bands: cell array of selected bands for each selected channel
%
% bandsidx: indices of selected bands
%
% tot: Total number of selected features
% 
% dpm: "Masked" dpa matrix, 1 for selected features, 0 otherwise 
%
% gamma: eigenvalues returned by CVA
%
% struct_mat: Structure matrices (see Pierre Ferrez thesis)
%

if(settings.modules.smr.options.selection.cva)
	disp('[eegc2_select] Running CVA feature selection');

	% Simis change to add across session stability functionality
	% gamma is normalized eigenvalue returned by cva_tun_opt
	% struct_mat is structure matrix returned by cva_tun_opt
	[dp struct_mat not_used gamma] = cva_tun_opt(dataset.data, dataset.labels);
end

if(settings.modules.smr.options.selection.dpt)
	disp('[eegc2_select] Running DPT feature selection');
	dp = dpfeatures(udataset, ulabels, 100);
end
	

dpa = reshape(dp,  settings.acq.channels_eeg, ...
	length(settings.modules.smr.psd.freqs));

dpath = (settings.modules.smr.dp.threshold) * max(max(dpa));
[cidx, bidx] = eegc3_contribute_matrix(dpa, dpath);


dpm = zeros(size(dpa));

channels = sort(unique(cidx));
bandsidx = {};
for ch = cidx
	bandsidx{ch} = [];
end

tot = 0;
for i = 1:length(cidx)
	ch = cidx(i);
	bn = bidx(i);
	bandsidx{ch} = sort([bandsidx{ch} bn]);
	dpm(ch, bn) = dpa(ch, bn);
	tot = tot + 1;
end


bands = {};
for ch = cidx
	bands{ch} = settings.modules.smr.psd.freqs(bandsidx{ch});
end
