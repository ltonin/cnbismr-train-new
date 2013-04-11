function [aucSub, output] = Mytrain_classifier_All()

%% FilePaths -> Add files location here
% FilePaths = {...
%   '/homes/abiasiuc/Desktop/testAutotools/Sub1.20111122.145104.offline.mi.mi_rlrest.gdf' ...
% };
% 
% FilePaths = {...
%   '/homes/vliakoni/Project/toledoData/Sub1/20111122/Sub1.20111122.145104.offline.mi.mi_rlrest.gdf' ...
% };

% FilePaths = '/mnt/data/abiasiuc/raw/clinics/toledo/Sub2/20111122/AR/';
% files = dir('/mnt/data/abiasiuc/raw/clinics/toledo/Sub2/20111122/AR/*.gdf');

% FilePaths = '/mnt/data/abiasiuc/raw/clinics/toledo/Sub4/20111123/AR/';
% files = dir('/mnt/data/abiasiuc/raw/clinics/toledo/Sub4/20111123/AR/*.gdf');

% %%%%%%%%%%% Sub5: First 4 gdfs corrupted. Comment for loop and edit paths
% %%%%%%%%%%% manually (below)
% FilePaths = '/mnt/data/abiasiuc/raw/clinics/toledo/Sub5/20111123/';
% files = dir('/mnt/data/abiasiuc/raw/clinics/toledo/Sub5/20111123/*.gdf');
% paths = {[FilePaths files(5,1).name], [FilePaths files(6,1).name], [FilePaths files(7,1).name], [FilePaths files(8,1).name]};
% sessionNum = 2;

% FilePaths = '/mnt/data/abiasiuc/raw/clinics/toledo/Sub6/20111123/AR/';
% files = dir('/mnt/data/abiasiuc/raw/clinics/toledo/Sub6/20111123/AR/*.gdf');

% FilePaths = '/mnt/data/abiasiuc/raw/clinics/toledo/Sub7/20111123/AR/';
% files = dir('/mnt/data/abiasiuc/raw/clinics/toledo/Sub7/20111123/AR/*.gdf');

% FilePaths = '/mnt/data/abiasiuc/raw/clinics/toledo/Sub8/AR/';
% files = dir('/mnt/data/abiasiuc/raw/clinics/toledo/Sub8/AR/*.gdf');

% %%%%%%%%%%%%% Sub9: only 7 gdfs!
% FilePaths = '/mnt/data/abiasiuc/raw/clinics/toledo/Sub9/AR/';
% files = dir('/mnt/data/abiasiuc/raw/clinics/toledo/Sub9/AR/*.gdf');
 
FilePaths = '/mnt/data/abiasiuc/raw/clinics/toledo/Sub23/AR/';
files = dir('/mnt/data/abiasiuc/raw/clinics/toledo/Sub23/AR/*.gdf');

%%%%%%%%%%%%%%% Sub15: only 7 gdfs!

%% Auto-train
for i = 1:2
    %%%%% Uncomment for Sub9 (and comment next line)
%     if i==1
%         paths = {[FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name]};
%     else
%         paths = {[FilePaths files((i-1)*4,1).name], [FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name]};
%     end
 %%%%% Uncomment for Sub15, Sub30 and Sub33 (and comment next line)
%        if i==1
%             paths = {[FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name], [FilePaths files((i-1)*4+4,1).name]};
%        else
%             paths = {[FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name]};
%        end
% %%% Uncomment for Sub19 (and comment next line)
%        if i==1
%             paths = {[FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name], [FilePaths files((i-1)*4+4,1).name], [FilePaths files((i-1)*4+5,1).name]};
%        else
%             paths = {[FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name], [FilePaths files((i-1)*4+4,1).name], [FilePaths files((i-1)*4+5,1).name]};
%        end
    paths = {[FilePaths files((i-1)*4+1,1).name], [FilePaths files((i-1)*4+2,1).name], [FilePaths files((i-1)*4+3,1).name], [FilePaths files((i-1)*4+4,1).name]};
    sessionNum = i;
%   [auc,output] = Myeegc3_smr_autotrain(paths,sessionNum);
    [auc,output] = Myeegc3_smr_autotrain_UseLda(paths,sessionNum);
%   [auc,output] = Myeegc3_smr_autotrain_UseGau(paths,sessionNum);
    aucSub(sessionNum) = auc;
end
