function lda = eegc3_train_lda(settings, data, labels, trial)

% function gau = eegc3_train_gau(settings, data, labels, has_init)
%
% Function to train an LDA classifier for CNBI loop. 
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
% lda: MATLAB struct containing the parameters of the trained LDA
% classifier
%

% Split possible 50/50
% Find class samples
C{1} = find(labels==1);
C{2} = find(labels==2);

% Find minimum
[CminN Cmin]  = min([length(C{1}) length(C{2})]);
[CmaxN Cmax]  = max([length(C{1}) length(C{2})]);
%disp(['[eegc3_train_lda] Dropping ' num2str(100*(CmaxN-CminN)/CmaxN) '% first'... 
%    ' coming data of class ' num2str(Cmax) ' to avoid unbalanced classes']);
%C{Cmax} = C{Cmax}(CmaxN-CminN+1:end);
dataind = union(C{1},C{2});
bdata = data(dataind,:);
blabels = labels(dataind,:);

% Random permutation
brand = randperm(length(blabels));
blabels = blabels(brand);
bdata = bdata(brand,:);

% Now split to training and testing set, 70/30 split
Pind = [1:round(0.7*length(blabels))];
Tind = [max(Pind)+1:length(blabels)];

P = bdata(Pind,:);
Pk = blabels(Pind,:);
   
T = bdata(Tind,:);
Tk = blabels(Tind,:);

Size = size(bdata,1);
TrSize = size(Pk,1);

% Test the balance of samples in training set
Pc1 = length(find(Pk==1))/TrSize;
Pc2 = length(find(Pk==2))/TrSize;
disp(['[eegc3_train_gau] Training samples (%): Class 1 vs Class 2: '...
    num2str(100*Pc1) ' - ' num2str(100*Pc2)]);
if(abs(Pc1-Pc2)>0.2)
    disp(['[eegc3_train_gau] Warning: Training samples seem to be too unbalanced...']);
end

% Test the balance of samples in testing set
Tc1 = length(find(Tk==1))/(Size-TrSize);
Tc2 = length(find(Tk==2))/(Size-TrSize);
disp(['[eegc3_train_gau] Testing samples (%): Class 1 vs Class 2: '...
    num2str(100*Tc1) ' - ' num2str(100*Tc2)]);
if(abs(Tc1-Tc2)>0.2)
    disp(['[eegc3_train_gau] Warning: Testing samples seem to be too unbalanced...']);
end


lda = {};

% LDA classifier
RightInd = find(Pk==1);
LeftInd = find(Pk==2);

RightData = P(RightInd,:);
LeftData = P(LeftInd,:);

% Means and covariances
lda.m_right = mean(RightData);
lda.cov_right = cov(RightData);


lda.m_left = mean(LeftData);
lda.cov_left = cov(LeftData);

% Global statistics
lda.m_global = mean(P);
lda.cov_global = cov(P);

if(settings.modules.smr.lda.shrink)
    
    disp('[eegc3_train_lda] Shrinking all covariance matrices using OAS shrinkage');
    
    SampleSize = size(P,1);
    SampleSizeR = size(RightData,1);
    SampleSizeL = size(LeftData,1);
    
    lda.cov_right = eegc3_shrink_OAS(lda.cov_right, SampleSizeR);
    lda.cov_left = eegc3_shrink_OAS(lda.cov_left, SampleSizeL);
    lda.cov_global = eegc3_shrink_OAS(lda.cov_global, SampleSize);
    
end

% Calculate separating hyperplane
Prior1 = settings.modules.smr.lda.priors(1);
Prior2 = settings.modules.smr.lda.priors(2);
Loss = settings.modules.smr.lda.loss;

Bias1 = -0.5*(lda.m_right*inv(lda.cov_global)*lda.m_right') + log(Prior1) +...
    log(Loss(2,1)-Loss(1,1));
Bias2 = -0.5*(lda.m_left*inv(lda.cov_global)*lda.m_left') + log(Prior2) +...
    log(Loss(1,2)-Loss(2,2));

% Parameters that define the separating plane
lda.w = inv(lda.cov_global)*(lda.m_right' - lda.m_left');
lda.Bias = Bias1 - Bias2;

% Save the number of samples used for training
lda.n_right = length(RightInd);
lda.n_left = length(LeftInd);
lda.n_all = size(P,1);

% Reject according to distance from global mean
if(settings.modules.smr.lda.reject)
    FakeStd = sqrt(sum(diag(lda.cov_global)));
    lda.rej_th = 2*FakeStd;
    
    % Find rejected samples of training set
    for i=1:size(P,1)
        if(norm(P(i,:)-lda.m_global) > lda.rej_th)
            RejSampleP(i) = 1;
        else
            RejSampleP(i) = 0;
        end
    end
    
    % Find rejected samples of testing set
    for i=1:size(T,1)
        if(norm(T(i,:)-lda.m_global) > lda.rej_th)
            RejSampleT(i) = 1;
        else
            RejSampleT(i) = 0;
        end
    end
else
    RejSampleP = zeros(1,size(P,1));
    RejSampleT = zeros(1,size(T,1));
end

rejP = sum(RejSampleP==1)/length(RejSampleP);
rejT = sum(RejSampleT==1)/length(RejSampleT);

% Calculate accuracies
% Crop out rejected samples
RejIndP = find(RejSampleP==1);
RejIndT = find(RejSampleT==1);

KeepP = setdiff(1:length(RejSampleP), RejIndP);
KeepT = setdiff(1:length(RejSampleT), RejIndT);

NonRejP = P(KeepP,:);
NonRejT = T(KeepT,:);
NonRejPk = Pk(KeepP);
NonRejTk = Tk(KeepT);

% Classify remaining samples
DecP = sign(lda.w'*NonRejP' + lda.Bias);
DecT = sign(lda.w'*NonRejT' + lda.Bias);

% Turn [1 -1] to [1 2] respectively
DecP(find(DecP==-1)) = 2;
%DecP(find(DecP==1)) = 1;

DecT(find(DecT==-1)) = 2;
%DecT(find(DecT==1)) = 1;

[CM_P_class CM_P_all AccP ErrP] = eegc3_confusion_matrix(NonRejPk, DecP)
[CM_T_class CM_T_all AccT ErrT] = eegc3_confusion_matrix(NonRejTk, DecT)
CP_P = eegc3_channel_capacity(ErrP/100,rejP,2);
CP_T = eegc3_channel_capacity(ErrT/100,rejT,2);

disp(['[eegc3_train_lda] Training set: Accuracy --> ' num2str(AccP)...
    ' %, Rejection --> ' num2str(100*rejP)...
    ' %, Channel Capacity --> ' num2str(CP_P)]);
disp(['[eegc3_train_lda] Testing set: Accuracy --> ' num2str(AccT)...
    ' %, Rejection --> ' num2str(100*rejT)...
    ' %, Channel Capacity --> ' num2str(CP_T)]);
    