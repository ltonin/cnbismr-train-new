function EEG = eegc3_dc(EEG)

% Edited by M. Tavella <michele.tavella@epfl.com> on 06/04/09 22:23:42
%
% function EEG = eegc3_dc(EEG)
%
% Where EEG is a [points x channels] matrix

DC = mean(EEG, 1);
EEG = EEG - repmat(DC, size(EEG, 1), 1);
