function [gau, auc] = Myeegc3_train_gau(settings, data, labels, trial, has_init, SubID, sessionNum)

% function gau = eegc3_train_gau(settings, data, labels, has_init)
%
% Function to train a CNBI Gaussian Classifier. From the input data,
% the first 70% is used for training and the remaining 30% for testing. No
% shuffliung of data is taking place. Function utlilizes the
% gauInitiallization, gauUpdate, gauEval functions.
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
% has_init: Boolean showing whether a classififier will be trained from
% scratch using SOM initialization (false), or a previously existing
% classifier will be updated with the current data (true). In the latter
% case, the pre-computed classifier settings can be found in the settings
% structure (CNBI classifier)
%
% Outputs:
%
% gau: MATLAB struct containing the means and covariances of the Gaussian
% classifier prototypes
%

if(nargin < 4)
    has_init = false;
end

% % Find number of runs included
% NRun = max(trial(:,1));
%
% if(NRun > 1)
%
%     % Split by run, keep last run for testing always
%     Pind = find(ismember(trial(:,1),[1:NRun-1]));
%     Tind = find(trial(:,1)==NRun);
%
%     disp(['[eegc3_train_gau] Using ' num2str(NRun) ': Training set: first ' ...
%         num2str(NRun-1) ' runs, Testing set: last run']);
% else
%
%
%     % There is only one run, split by trials
%     NTrial = max(trial(:,2));
%     NTrain = floor(0.70*NTrial);
%
%     Pind = find(ismember(trial(:,2),[1:NTrain]));
%     Tind = find(ismember(trial(:,2),[NTrain+1:NTrial]));
%
%     disp(['[eegc3_train_gau] Using a single run. Trainig set: first ' ...
%         num2str(NTrain) ' trials, Testing set: last ' ...
%         num2str(NTrial-NTrain) ' trials']);
% end

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


gau = {};

% Gaussian classifier
disp('[eegc3_train_gau] Training CNBI Gaussian Classifier');
M = {};
C = {};

if(~has_init)
    
    disp('[eegc3_train_gau] Initializing with SOM.');
    [M{1}, C{1}] = gauInitialization([P Pk], ...
        settings.modules.smr.gau.somunits, ...
        settings.modules.smr.gau.sharedcov, 0);
    
else
    
    disp('[eegc3_train_gau] Initializing with loaded initial classifier.');
    M{1} = settings.bci.smr.gau.M;
    C{1} = settings.bci.smr.gau.C;
end

perfP = nan(1, settings.modules.smr.gau.epochs);
perfT = perfP;
rejP = perfP;
rejT = perfP;
ccP = perfP;
ccT = perfP;
confP = {};
confT = {};
epMax = 0;

for ep = 1:settings.modules.smr.gau.epochs
    [perfP(ep), rejP(ep), confP{ep}] = eval_GAU(settings, P, Pk, M{end}, C{end});
    [perfT(ep), rejT(ep), confT{ep}] = eval_GAU(settings, T, Tk, M{end}, C{end});
    
    ccP(ep) = eegc3_channel_capacity(1 - perfP(ep), rejP(ep), 2);
    ccT(ep) = eegc3_channel_capacity(1 - perfT(ep), rejT(ep), 2);
    
    fprintf('  Epoch %d/%d: %.3f/%.3f %.3f/%.3f\n', ...
        ep, settings.modules.smr.gau.epochs, ...
        perfP(ep), rejP(ep), perfT(ep), rejT(ep));
    
    %plot_GAU(settings, 60, perfP, rejP, perfT, rejT, ccP, ccT);
    
    
    if(settings.modules.smr.gau.terminate)
        if(perfP(end) >= perfP(end-1) && perfT(end) <= perfT(end-1) && ep > 1)
            epMax = ep - 1;
            break;
        end
    end
    
    [M{end+1}, C{end+1}] = gauUpdate(M{end}, C{end}, [P Pk], ...
        settings.modules.smr.gau.mimean, ...
        settings.modules.smr.gau.micov, ...
        settings.modules.smr.gau.sharedcov);
end


if(~settings.modules.smr.gau.terminate)
    fprintf('  Termination criterion met\n');
else
    fprintf('  Checking for max channel capacity\n');
    
    %Note by M.Tavella <michele.tavella@epfl.ch> on 01/09/09 11:03:11
    % Avoid overtraining
    %[perfMax, epMax] = max(ccP);
    [perfMax, epMax] = max(ccP(2:end));
    epMax = epMax + 1;
end
gau.M = M{epMax};
gau.C = C{epMax};

fprintf('  Epoch %d: %.3f/%.3f [%.3f/%.3f %.3f/%.3f]\n', ...
    epMax, ...
    ccP(epMax), ccT(epMax), ...
    perfP(epMax), rejP(epMax), ...
    perfT(epMax), rejT(epMax));

%%%%%%%%%%%%%%%% Evaluation
auc = MyGauEvaluation(gau.M, gau.C, T, Tk, SubID, sessionNum);

function auc = MyGauEvaluation(M, C, testData, testLabels, SubID, sessionNum)
post = zeros(size(testData,1),2);

for sample = 1:size(testData, 1)
    [act post(sample, :)] = gauClassifier(M, C, testData(sample, :));
end

testLabels(find(testLabels==2)) = 0;

fprintf('testLabels [%d x %d]\n', size(testLabels,1), size(testLabels,2));
fprintf('post [%d x %d]\n', size(testLabels,1), size(testLabels,2));

% ROC curve
[tpr, fpr, thresholds] = Myroc(testLabels', post(:,1)');

fprintf('tpr [%d x %d]\n', size(tpr,1), size(tpr,2));
fprintf('fpr [%d x %d]\n', size(fpr,1), size(fpr,2));

% Calculate AUC
auc = trapz(fpr, tpr);

% Plot ROC curve
x = (0:0.1:1);
figure()
figNum = get(0,'CurrentFigure');
set(figNum,'Visible','off');
hold on;
plot(fpr,tpr, 'Linewidth', 2);
hold on;
h = plot(x,x,'r');
set(h, 'color', [0.5 0.5 0.5], 'Linewidth', 2);
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title('ROC Curve (Gaussian Classifier)')

disp(['[Myeegc3_train_lda2] Saving ROC curve']);

%saveas(figNum,['/homes/vliakoni/Results_GAU_Rejection/' SubID{1,1} '_' 'Session' num2str(sessionNum) '_GAU' '.png'])
saveas(figNum,[getenv('TOLEDO_DATA') '/Results/' SubID{1,1} '/Results_GAU_CVA_Rejection_'  SubID{1,1} '_' 'Session' num2str(sessionNum) '_GAU' '.png']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [perf, rej] = eval_GAU2(settings, dataset, labels, M, C)

post = zeros(eegc2_cdataset_size(dataset, 's'), 2);

for s = 1:size(dataset, 1)
    [act post(s, :)] = gauClassifier(M, C, dataset(s, :));
end

[perf, rej] = eegc2_prob_soft(labels, post, ...
    [1 2], settings.modules.smr.gau.th);

function [perf, rej, conf] = eval_GAU(settings, dataset, labels, M, C)
[cm, pv] = gauEval(M, C, [dataset labels], ...
    settings.modules.smr.gau.th);
perf = 1.00 - pv(2);
rej = pv(3);
conf = cm(end/2:end, :);

function plot_GAU(settings, fig, pP, rP, pT, rT, ccP, ccT)
eegc3_figure(fig);
clf;
subplot(2, 1, 1);
hold on;
plot(pP, 'k', 'LineWidth', 1);
plot(rP, 'r', 'LineWidth', 1);
plot(pT, 'k', 'LineWidth', 2);
plot(rT, 'r', 'LineWidth', 2);
hold off;
axis([1 settings.modules.smr.gau.epochs 0.00 1.00]);
grid on;
title('GAU training');
ylabel('Accuracy/Rejection')
subplot(2, 1, 2);
hold on;
plot(ccP, 'b', 'LineWidth', 1);
plot(ccT, 'b', 'LineWidth', 2);
hold off;
axis([1 settings.modules.smr.gau.epochs 0.00 1.00]);
grid on;
xlabel('Epochs')
ylabel('Channel Capacity')
drawnow;
