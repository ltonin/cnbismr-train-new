function sep = eegc3_train_sep(settings, data, labels, trial)

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
% sep: MATLAB struct containing the parameters of the trained LDA
% classifier
%

% Split possible 50/50
% Find class samples
C{1} = find(labels==1);
C{2} = find(labels==2);

% Find minimum
[CminN Cmin]  = min([length(C{1}) length(C{2})]);
[CmaxN Cmax]  = max([length(C{1}) length(C{2})]);
disp(['[eegc3_train_gau] Dropping ' num2str(100*(CmaxN-CminN)/CmaxN) '% first'... 
    ' coming data of class ' num2str(Cmax) ' to avoid unbalanced classes']);
C{Cmax} = C{Cmax}(CmaxN-CminN+1:end);
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


sep = {};

% LDA classifier
RightInd = find(Pk==1);
LeftInd = find(Pk==2);

RightData = P(RightInd,:);
LeftData = P(LeftInd,:);

% Means and covariances
sep.m_right = mean(RightData);
sep.cov_right = cov(RightData);

sep.m_left = mean(LeftData);
sep.cov_left = cov(LeftData);

sep.m_global = (sep.m_right + sep.m_left)/2;
sep.cov_global = (sep.cov_right + sep.cov_left)/2;

if(settings.modules.smr.sep.shrink)
    
    disp('[eegc3_train_Sep] Shrinking all covariance matrices using OAS shrinkage');
    
    SampleSize = size(P,1);
    SampleSizeR = size(RightData,1);
    SampleSizeL = size(LeftData,1);
    
    sep.cov_right = eegc3_shrink_OAS(sep.cov_right, SampleSizeR);
    sep.cov_left = eegc3_shrink_OAS(sep.cov_left, SampleSizeL);
    sep.cov_global = eegc3_shrink_OAS(sep.cov_global, SampleSize);
    
end



% Calculate separating hyperplane


% Parameters that define the separating plane
sep.w = inv(sep.cov_global)*(sep.m_left - sep.m_right)';
nb = norm(sep.w);
sep.w = sep.w/nb;
sep.Bias = -0.5*nb*dot(sep.w,sep.m_left + sep.m_right);

% Save the number of samples used for training
sep.n_right = length(RightInd);
sep.n_left = length(LeftInd);
sep.n_all = size(P,1);

%% Compute the new separated distributions

% Find rotation of the system (Gram - Schmidt - like)
RotMat = eegc3_findRot(sep.w);

M1p = RotMat*sep.m_right';
M2p = RotMat*sep.m_left';
M1p = M1p(1);
M2p = M2p(1);

if(M1p > M2p)
    disp('Problem');
end

RS1 = RotMat'*sep.cov_right'*RotMat;
RS2 = RotMat'*sep.cov_left'*RotMat;

S1p = sqrt(RS1(1,1));
S2p = sqrt(RS2(1,1));

eegc3_plotDataPDF_UV(M1p,S1p,M2p,S2p, true,92);

% Find the new positions of the means as a maximization problem on the
% projected Gaussians
options = optimset('GradObj','on', 'Hessian','on', 'Display','off');

[x1 fx1 exflag1 out1] = fminunc(@(x)eegc3_diffobj1(x,M1p,S1p,M2p,S2p),M1p-S1p, options);
[x2 fx2 exflag2 out2] = fminunc(@(x)eegc3_diffobj2(x,M1p,S1p,M2p,S2p),M2p+S2p, options);

if(exflag1~= 1)
    disp(['[eegc3_train_sep] Possible problem in solution 1! Flag: ' num2str(exflag1)]);
elseif(exflag2~= 1)
    disp(['[eegc3_train_sep] Possible problem in solution 2! Flag: ' num2str(exflag2)]);
else
    disp('[eegc3_train_sep] Solutions OK!');
end

% Compute displacement along w for both means
l1 = abs(M1p - x1);
l2 = abs(M2p - x2);

% Compute new means
sep.m_right_sep = (sep.m_right' - l1*sep.w)';
sep.m_left_sep = (sep.m_left' + l2*sep.w)';

% Compute scale of stds to avoid overlapping
k = abs(x2-x1)./(3*(S1p+S2p));

%% Plot newly made distrs
eegc3_plotDataPDF_UV(x1,k*S1p,x2,k*S2p,false, 93);

% Scale covariances appropriately
sep.cov_right_sep = (k^2)*sep.cov_right;
sep.cov_left_sep = (k^2)*sep.cov_left;

%RS1(1,1) = (k^2)*RS1(1,1);
%RS2(1,1) = (k^2)*RS2(1,1);

%sep.cov_right_sep = inv(RotMat)'*RS1'*inv(RotMat);
%sep.cov_left_sep = inv(RotMat)'*RS2'*inv(RotMat);

%% Plot final distributions for first two features
eegc3_plotDataPDF_MV2(sep.m_right_sep([1 2])',sep.cov_right_sep([1 2],[1 2]),...
    sep.m_left_sep([1 2])',sep.cov_left_sep([1 2],[1 2]), 94);

sep.rej_th = settings.modules.smr.sep.rej_th;

% Reject according to distance from global mean
if(settings.modules.smr.sep.reject)
    
    % Find rejected samples of training set
    for i=1:size(P,1)
        Rx = RotMat*P(i,:)';
        Rx = Rx(1);
        if(((eegc3_mah_dst(P(i,:)', sep.m_right_sep', sep.cov_right_sep) > sep.rej_th)...
                && (eegc3_mah_dst(P(i,:)', sep.m_left_sep', sep.cov_left_sep) > settings.modules.smr.sep.rej_th)) )%|| ...
                %((Rx > M1p) && (Rx < M2p)))
            
            RejSampleP(i) = 1;
        else
            RejSampleP(i) = 0;
        end
    end
    
    % Find rejected samples of testing set
    for i=1:size(T,1)
        Rx = RotMat*T(i,:)';
        Rx = Rx(1);
        if(((eegc3_mah_dst(T(i,:)', sep.m_right_sep', sep.cov_right_sep) > sep.rej_th)...
                && (eegc3_mah_dst(T(i,:)', sep.m_left_sep', sep.cov_left_sep) > settings.modules.smr.sep.rej_th)) )%|| ...
                %((Rx > M1p) && (Rx < M2p)))
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
DecP = eegc3_classify_sep(sep, NonRejP);
DecT = eegc3_classify_sep(sep, NonRejT);

[CM_P_class CM_P_all AccP ErrP] = eegc3_confusion_matrix(NonRejPk, DecP);
[CM_T_class CM_T_all AccT ErrT] = eegc3_confusion_matrix(NonRejTk, DecT);
CP_P = eegc3_channel_capacity(ErrP/100,rejP,2);
CP_T = eegc3_channel_capacity(ErrT/100,rejT,2);

disp(['[eegc3_train_sep] Training set: Accuracy --> ' num2str(AccP)...
    ' %, Rejection --> ' num2str(100*rejP)...
    ' %, Channel Capacity --> ' num2str(CP_P)]);
disp(['[eegc3_train_sep] Testing set: Accuracy --> ' num2str(AccT)...
    ' %, Rejection --> ' num2str(100*rejT)...
    ' %, Channel Capacity --> ' num2str(CP_T)]);    