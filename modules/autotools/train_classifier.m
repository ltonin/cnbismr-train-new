%--------------------------------------------------------------------------
% FILEPATHS -> File location. 
%--------------------------------------------------------------------------
FilePaths = {...
'/mnt/data/abiasiuc/processed/toledo/Sub10/AR/Sub10.20111124.161048.offline.mi.mi_rlrest.gdf'
};

%--------------------------------------------------------------------------
% PRESETS -> Trains a Classifier using these features, only. 
%--------------------------------------------------------------------------
presets.channels = [7 8 10 11 13 15];
presets.bands = {...           
                            [] ...
           []        []     []    []        [] ...
        [8 10 12] [8 10 12] [] [8 10 12] [8 10 12] ... 
           []      [10 12]  []  [10 12]     [] ...
           };

%--------------------------------------------------------------------------
% presets.usecva -> use - not use CVA selection of features 
%                   if 'true', presets.channels and presets.bands will be
%                   automagically selected and the manual selection will be
%                   ignored
%--------------------------------------------------------------------------
presets.usecva = false;

eegc3_smr_autotrain(FilePaths,presets);
