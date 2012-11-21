function [rdata rlabels] = eegc3_reshape_sbc2s(data, labels)
% function [rdata rlabels] = eegc3_reshape_sbc2s(data, labels)
%
% Function to reshape a data matrix from Samples x Freqs x Channels to 
% Samples x (Channels x Frequencies)
%
%
% Input: 
% 
% data: Matrix samples x frequencies x channels
% labels: Vector samples x 1
%
%
% Outputs:
%
% rdata: Data matrix samples x (channels x frequencies)
% rlabels: Same as labels
%
%

SampleNum = size(data,1);
Freqs = size(data,2);
Channels = size(data,3);

rdata = zeros(SampleNum,Freqs*Channels);

for i=1:SampleNum
    tdata = squeeze(data(i,:,:))';
    rdata(i,:) = tdata(:);
end

rlabels = labels;