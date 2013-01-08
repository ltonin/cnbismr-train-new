function train_classifier()
% 2012 Ricardo Chavarriaga <ricardo.chavarriaga@epfl.ch>
% 2012 Andrea Biasiucci <andrea.biasiucci@epfl.ch>

%--------------------------------------------------------------------------
% FILEPATHS -> File location. 
%--------------------------------------------------------------------------
[FilePaths, PathName] =uigetfile('*.gdf','Select recordings [*.gdf]','MultiSelect','on');
if (iscell(PathToFiles))
     disp('[train_classifier] Selected files for training:');
    % add path (dirty)
     for file_idx=1:length(PathToFiles)
         PathToFiles(file_idx) = strcat(PathName,PathToFiles(file_idx));
     end
     cd(PathName)
     disp (PathToFiles)
else
  disp('[train_classifier] Error!! No files selected. Aborting...')
  return
end

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Don't edit below this line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Auto-train
eegc3_smr_autotrain(FilePaths,presets);

%% Update xml config file
setClassifier
