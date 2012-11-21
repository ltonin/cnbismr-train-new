function lda = eegc3_train_single(settings, data, labels, trial, TrgLbl)

% function gau = eegc3_train_gau(settings, data, labels, has_init)
%
% Function to train an single Gaussian classifier for CNBI loop. 
%
% Inputs:
%
% settings: struct of settings for feature selection, preprocessing, 
% classification etc., created by eegc3_smr_newsettings (this structure 
% also holds the settings of a trained classifier)
%
% data: Data matrix samples x features
%
% labels: Labels vector samples x 1
%
% shrink: Boolean for using shrinkage or not (OAS Shrinkage)
%
% Outputs:
%
% single: MATLAB struct containing the parameters of the trained LDA
% classifier
%

% % Find if there are intertrial intervals
if(length(unique(labels))>2)
    isinter = true;
else
    isinter = false;
end

% Find class samples
C{1} = find(labels==1);
C{2} = find(labels==2);

if(isinter)
    C{3} = find(labels==0);
end

% Find all target class samples
TrgData = data(C{TrgLbl},:);
TrgLabels = labels(C{TrgLbl});

ImpData = data(C{3-TrgLbl},:);
ImpLabels = labels(C{3-TrgLbl});

if(isinter)
    % Add intertrial intevals to impostors
    ImpData = [ImpData;  data(C{3},:)];
    ImpLabels = [ImpLabels ; labels(C{3})];
end

% Remap data labels
TrgLabels(:) = 1;
ImpLabels(:) = 2;

% Now split to training and testing set, 70/30 split for both classes
PData = [TrgData(1:round(0.7*size(TrgData,1)),:) ; ImpData(1:round(0.7*size(ImpData,1)),:)];
PLabels = [TrgLabels(1:round(0.7*size(TrgData,1)),:) ; ImpLabels(1:round(0.7*size(ImpData,1)),:)];
TData = [TrgData(round(0.7*size(TrgData,1))+1:end,:) ;  ImpData(round(0.7*size(ImpData,1))+1:end,:)];
TLabels = [TrgLabels(round(0.7*size(TrgData,1))+1:end,:) ;  ImpLabels(round(0.7*size(ImpData,1))+1:end,:)];

% Random permutation
Pind =randperm(size(PData,1));
PData = PData(Pind,:);
PLabels = PLabels(Pind);

Tind =randperm(size(TData,1));
TData = TData(Tind,:);
TLabels = TLabels(Tind);

single = {};

% Singel Gaussian for target data from the training set
single.m = mean(PData(PLabels==1,:));
single.cov = cov(PData(PLabels==1,:));

% And this is pretty much about it, a simple Mahalanpbis distance
% classifier, parameterizable by the rejection threhold in terms of Mah
% distance

% Classify training and testing data
for s=1:size(PData,1)
    tmp = eegc3_mah_dst(PData(s,:)',single.m',single.cov);
    if(tmp <= settings.modules.smr.single.rej_th)
        PFC(s) = 1;
    else
        PFC(s) = 2;
    end
end

for s=1:size(TData,1)
    tmp = eegc3_mah_dst(TData(s,:)',single.m',single.cov);
    if(tmp <= settings.modules.smr.single.rej_th)
        TFC(s) = 1;
    else
        TFC(s) = 2;
    end
end

disp('a');

[CM_P_class CM_P_all AccP ErrP] = eegc3_confusion_matrix(NonRejPk, DecP);
[CM_T_class CM_T_all AccT ErrT] = eegc3_confusion_matrix(NonRejTk, DecT);
CP_P = eegc3_channel_capacity(ErrP/100,rejP,2);
CP_T = eegc3_channel_capacity(ErrT/100,rejT,2);