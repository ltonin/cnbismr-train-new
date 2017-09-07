function selection = eegc3_smr_select_stable(cdataset, settings)
%
% function selection = eegc3_smr_select_stable(cdataset, settings)
%
% ATTENTION: TO REVIEW
%
% Function to perform feature selection (CVA or dptools), either
% identifying stable features across runs or batch (using the whole dataset)
%
% Inputs:
%
% cdataset: Struct holding the data and labels. Data and labels are
% separated in runs (dataset.run{i}.data, dataset.run{i}.labels) according 
% to the provided GDF files. The fields of each run are:
%   data: Data matrix samples x (channels x frequencies)
%   labels: Labels vector, samples x 1
%   path: Filepath of the GDF file corresponding to this run
%
% Outputs:
%
% selection: struct holding the selected channels and frequency bands as
% well as the discriminant power indices of the feature pool
%

RunNum = length(cdataset.run);

selection = {};
for r = 1:RunNum
    
	disp(['[eegc2_select_stable] Running feature selection on: ' ...
		cdataset.run{r}.path]);

	[selection.Pdpa{r}, selection.Pch{r}, selection.Pbn{r}, ...
	selection.Pbnidx{r}, selection.Ptot{r}, selection.Pdpm{r},...
	gamma{r}, st_mat{r}] = ...
		eegc3_smr_select(cdataset.run{r}, settings);
end

% Now compute the discriminant power accross all runs
% based on the gamma-s and st_mat-s

% HACK TO MAKE IT WORK WITH 16
%settings.acq.channels_eeg = 16;
Alldp_nom = zeros(settings.acq.channels_eeg*...
    length(settings.modules.smr.psd.freqs),1);

Alldp_denom = 0;

for r=1:RunNum
    currvec = ((st_mat{r}).^2)*(gamma{r});
	Alldp_nom = Alldp_nom + currvec; 
	Alldp_denom = Alldp_denom + sum(currvec);
end

Alldp = 100.*(Alldp_nom/Alldp_denom);

% Now compute selected features based on the threshold
selection.Alldpa = reshape(Alldp, settings.acq.channels_eeg, ...
	length(settings.modules.smr.psd.freqs));

dpath = (settings.modules.smr.dp.threshold) * max(max(selection.Alldpa));
[cidx, bidx] = eegc3_contribute_matrix(selection.Alldpa, dpath);
%analysis.settings.features.psd.freqs

selection.Alldpm = zeros(size(selection.Alldpa));

selection.Allchannels = sort(unique(cidx));
selection.Allbandr = {};
for ch = cidx
	selection.Allbandr{ch} = [];
end

selection.Alltot = 0;
for i = 1:length(cidx)
	ch = cidx(i);
	bn = bidx(i);
	selection.Allbandr{ch} = sort([selection.Allbandr{ch} bn]);
	selection.Alldpm(ch, bn) = selection.Alldpa(ch, bn);
	selection.Alltot = selection.Alltot + 1;
end


selection.Allbands = {};
for ch = cidx
	selection.Allbands{ch} = ...
	settings.modules.smr.psd.freqs(selection.Allbandr{ch});
end


