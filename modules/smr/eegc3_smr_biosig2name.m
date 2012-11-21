function names = eegc3_smr_biosig2name(biosigCodes)

% function names = eegc3_smr_biosig2name(biosigCodes)
%
% Function to get the modality names from the biosig class codes
%
% Inputs:
%
% biosigCodes: Vector of biosig codes in decimal
%
%
% Outputs:
%
% names: Names of MI classes (e.g. right hand) in cell array if more than
% one, otherwise a single string variable

if(length(biosigCodes) > 1)
    names = cell{1,length(biosigCodes)};
else
    names =[];
end

for code = 1:length(biosigCodes)
    switch(biosigCodes(code))
        case 769
            names{code} = 'Left Hand MI';
        case 770
            names{code} = 'Right Hand MI';
        case 771
            names{code} = 'Both Feet MI';
        case 772
            names{code} = 'Tongue MI';
        case 773
            names{code} = 'Both Hands MI';
        case 783
            names{code} = 'Rest';
        otherwise
            names{code} = 'unknown class';
    end
end


if(length(names) == 1)
    names = names{1};
end
