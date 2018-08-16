function montage = eegc3_channels2montage(chanlabels)

% Hardcode a standard full montage
LblMontage = cell(10,13);
LblMontage(1,:) = {'','','','','','Fp1','Fpz','Fp2','','','','',''};
LblMontage(2,:) = {'','AF9','AF7','','AF3','','AFz','','AF4','','AF8','AF10',''};
LblMontage(3,:) = {'','F9','F7','F5','F3','F1','Fz','F2','F4','F6','F8','F10',''};
LblMontage(4,:) = {'','FT9','FT7','FC5','FC3','FC1','FCz','FC2','FC4','FC6','FT8','FT10',''};
LblMontage(5,:) = {'','T9','T7','C5','C3','C1','Cz','C2','C4','C6','T8','T10',''};
LblMontage(6,:) = {'M1','TP9','TP7','CP5','CP3','CP1','CPz','CP2','CP4','CP6','TP8','TP10','M2'};
LblMontage(7,:) = {'','P9','P7','P5','P3','P1','Pz','P2','P4','P6','P8','P10',''};
LblMontage(8,:) = {'','PO9','PO7','','PO3','','POz','','PO4','','PO8','PO10',''};
LblMontage(9,:) = {'','O9','','','','O1','Oz','O2','','','','O10',''};
LblMontage(10,:) = {'','','','','','','Iz','','','','','',''};

montage = zeros(10,11);
for ch=1:length(chanlabels)
    [row col] = find(strcmp(lower(LblMontage),lower(chanlabels{ch})));
    if(isempty(row) || isempty(col))
        disp(['[eegc3_channels2montage] Warning: Cannot map channel ' chanlabels{ch} ' to known configuration. Skipping.']);
        %montage = NaN;
        %return;
        %montage(row,col) = ch;
    end
    montage(row,col) = ch;
end

%% Crop edges
ColCrop = [];
RowCrop = [];

% Crop left
for c=1:size(montage,2)
    if(sum(montage(:,c))==0)
        ColCrop = [ColCrop c];
    else
        break;
    end
end

% Crop right
for c=size(montage,2):-1:1
    if(sum(montage(:,c))==0)
        ColCrop = [ColCrop c];
    else
        break;
    end
end

% Crop top
for r=1:size(montage,1)
    if(sum(montage(r,:))==0)
        RowCrop = [RowCrop r];
    else
        break;
    end
end

% Crop bottom
for r=size(montage,1):-1:1
    if(sum(montage(r,:))==0)
        RowCrop = [RowCrop r];
    else
        break;
    end
end

montage(RowCrop,:) = [];
montage(:,ColCrop) = [];
