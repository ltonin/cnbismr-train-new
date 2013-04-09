% WP4_PERF_STAT statistics on online performance for WP4 data
%
% USAGE:
% perf = wp4_perf_stat(Path)
%
% For a given directory containing subdirs that contain the .gdf online files,
% the function loads each gdf and extracts the number of hits and the overall
% number of trials in that run.
% Results are stored in a structure and later saved into a text file.
%
% perf:
% perf{x}.id: file id
% perf{x}.acc: number of hits/number of total trials
% perf{x}.hits: number of hits
% perf{x}.tot: number of trials in the run

function [acc hits tot id] = wp4_perf_stat(Path)
% 2013 Andrea Biasiucci <andrea.biasiucci@epfl.ch>

d = dir(Path);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = []; % remove '.' and '..'

Ndirs = length(nameFolds);

for dir_idx = 1:Ndirs
    % Enter in current directory
    cur_dir = nameFolds{dir_idx};
    cd(cur_dir)
    
    % Get files list
    f = dir('.');
    nameFiles = {f.name}';
    Nfiles = length(nameFiles);
    
    % Identify online gdfs
    isGdf = zeros(Nfiles,1);
    for file_idx = 1:Nfiles
        if ( (strfind(nameFiles{file_idx},'gdf') > 0) & ...
                (strfind(nameFiles{file_idx},'online') > 0))
            isGdf(file_idx) = 1;
        end
    end
    
    % For online gdfs, if any, compute and store accuracy
    if (sum(isGdf)>0)
        
        gdfs_idx = find(isGdf == 1);
        Ngdfs = length(gdfs_idx);
        
        acc = zeros(1,Ngdfs);
        hits = zeros(1,Ngdfs); 
        tot = zeros(1,Ngdfs); 
        id = cell(1,Ngdfs);
        
        % Extract the names of online gdf files
        gdfFiles = cell(1,Ngdfs);
        for cur_file = 1:Ngdfs
            gdfFiles{cur_file} = nameFiles{gdfs_idx(cur_file)};
        end
        
        % iterate files and compute performance
        for cur_file = 1:Ngdfs
            [acc(cur_file) hits(cur_file) tot(cur_file) id{cur_file}] = ...
                wp4_performance(gdfFiles{cur_file});
            printf(['File: ' id '\n']);
            printf('Accuracy: %.1f \n Hits: %.0f \n Tot: %.0f \n',...
                acc,hits,tot);
            
        end
        
    end
    
    % Go back to parent directory
    cd('..');
end
