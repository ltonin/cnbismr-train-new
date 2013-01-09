function [MyNonRejTk, Post1, tpr, fpr, auc] = Mytrain_classifier()

%% FilePaths -> Add files location here
% FilePaths = {...
%   '/homes/abiasiuc/Desktop/testAutotools/Sub1.20111122.145104.offline.mi.mi_rlrest.gdf' ...
% };

% FilePaths = dir('mnt/data/abiasiuc/raw/clinics/toledo/Sub2/20111122/AR/*gdf');

FilePaths = {...
  '/homes/vliakoni/Project/toledoData/Sub1/20111122/Sub1.20111122.145104.offline.mi.mi_rlrest.gdf' ...
};

[MyNonRejTk, Post1, tpr, fpr, auc] = Myeegc3_smr_autotrain(FilePaths);

%% Auto-train
% for run = 1:8
%     
% aucSub1(run) = Myeegc3_smr_autotrain(FilePaths(run,1).name);
% end
