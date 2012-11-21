function Class = eegc3_classify_lda_hard(x, w, b)
%
% function Class = eegc3_classify_lda(x, w, b)
%
% Function to classify sample(s) using a known LDA hyperplane
%
%
% Inputs:
% x: Matrix or vector of input(s). Samples are along rows, aka each row is
% a data sample
%
% w: Hyperplane weight terms (column vector)
%
% b: Hyperplane bias term
%
% Outputs:
%
% Class: Hard postprob matrix, [0 1] or [1 0] for each sample
%

class = sign(w'*x' + b);

% Remap labels
class(find(class==-1))=2;

Class = zeros(length(class),2);
for i=1:length(class)
    Class(class(i))=1;
end
