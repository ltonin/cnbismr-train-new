function laplacian = eegc3_montage(montage, pattern)


if(nargin < 2)
    disp(['[eegc3_montage] No neighbor pattern provided, defaulting to cross Laplacian.'])
    pattern = [0 1 0; 1 0 1; 0 1 0];
end

if(nargin < 1)
    disp(['[eegc3_montage] No montage provided! Returning empty.']);
    laplacian = [];
    return;
end

if(ischar(pattern))
    switch(pattern)
        case 'cross'
            pattern = [0 1 0; 1 0 1; 0 1 0];
        case 'X'
            pattern = [1 0 1; 0 0 0;1 0 1];
        case 'all'            
            pattern = [1 1 1; 1 0 1;1 1 1];  
        otherwise
            disp(['[eegc3_montage] Unknown neighbor pattern, defaulting to cross Laplacian!']);            
            pattern = [0 1 0; 1 0 1; 0 1 0];            
    end
end

% Check if montage provided in 0/1 format
if(isequal(unique(montage(:)),[0 1]') || isequal(unique(montage(:)),[1]))
    disp(['[eegc3_montage] Warning: montage provided in 0/1 format. Converting assuming row-wise indices']);
    tmpmontage = montage';tmpmontage = tmpmontage(:);
    tmpmontage(tmpmontage==1) = [1:1:sum(tmpmontage(:))];
    montage = reshape(tmpmontage',[size(montage,2) size(montage,1)])'; 
end

% Find number of channels
N = max(montage(:));

% Check for montage sanity
if(~isequal(unique(montage(:)),[0:1:N]') && ~isequal(unique(montage(:)),[1:1:N]'))
    disp(['[eegc3_montage] Warning: channels are missing from the Laplacian montage!']);
end

% Check for pattern sanity
if(~isequal(size(pattern),[3 3]))
    disp(['[eegc3_montage] Neighbor pattern must be a 3x3 matrix!']);
    laplacian = [];
    return;
end

if(~isequal(unique(pattern(:)),[0 1]') && ~isequal(unique(pattern(:)),[1]) )
    disp(['[eegc3_montage] Invalid neighbor pattern! It must be a 3x3 matrix of 1s and 0s']);
    laplacian = [];
    return;
end

% Find set of neighbor coordinates wrt to a channel, given the pattern
NeighborLoc = [];
for x=-1:1
    for y=-1:1
        if(pattern(2+y,2+x)==1)
            NeighborLoc = [NeighborLoc ; [x y]];
        end
    end
end

% Make a list of neighbors for each channel
NoNeighbors = [];
for ch=1:N
    Neighbors{ch} = [];
    % Find location of channel
    [chy chx] = find(montage==ch);
    if(isempty(chx) || isempty(chy))
        continue;
    end
    % Check if possible neighbor locations exist, and have a channel
    for pnb=1:size(NeighborLoc,1)
        if(  (chx+NeighborLoc(pnb,1)>0) && (chx+NeighborLoc(pnb,1)<=size(montage,2)) && ... 
             (chy+NeighborLoc(pnb,2)>0) && (chy+NeighborLoc(pnb,2)<=size(montage,1)) ) 

            if(montage(chy+NeighborLoc(pnb,2),chx+NeighborLoc(pnb,1))~=0)
                    Neighbors{ch} = [Neighbors{ch} montage(chy+NeighborLoc(pnb,2),chx+NeighborLoc(pnb,1))];
            end
        end
    end
    
    if(isempty(Neighbors{ch}))
        NoNeighbors = [NoNeighbors; ch];
    end
end

if(~isempty(NoNeighbors))
    if(length(NoNeighbors)==1)
        disp(['[eegc3_montage] Warning: Channel ' num2str(NoNeighbors)...
        ' has no neighbors, your Laplacian derivation might be suboptimal.']);
    else
        Chnstr = sprintf('%d,',NoNeighbors);Chnstr=Chnstr(1:end-1);
        disp(['[eegc3_montage] Warning: Channels ' Chnstr...
        ' have no neighbors, your Laplacian derivation might be suboptimal.']);        
    end
    
end

% Initialize laplacian as a NxN unit matrix
laplacian = eye(N);
for col=1:N
    if(~isempty(Neighbors{col}))
        laplacian(sort(Neighbors{col},'ascend'),col) = -1.0/length(Neighbors{col});
    end
end
