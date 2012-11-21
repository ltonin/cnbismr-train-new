function subjectID = eegc3_subjectID(Paths)

% Check type of argument
if(iscell(Paths))
    FileNum = length(Paths);
elseif(ischar(Paths))
    FileNum = 1;
else
    disp('Cannot execute eegc3_subjectID, problematic argument');
end

% Check whether it is filepath or filenames
for i=1:FileNum

    if(iscell(Paths))
        Name = Paths{i};
    else
        Name = Paths;
    end
    
    % Check if it is filepath or filename
    Slash = strfind(Name,'/');
    
    if(~isempty(Slash))  
        % Assume it is filepath
        Start = Slash(end);
        Name = Name(Start+1:end);
    end
    
    eegcv = check_GDFNameType(Name);
    
    subjectID{i} = retrieve_name(Name, eegcv);
end

function eegcv = check_GDFNameType(Name)

if(length(strfind(Name,'.')) > 1)
    eegcv = 3;
    disp(['[eegc3_subjectID] eegc3 GDF naming convention detected']);
else
    eegcv = 2;
    disp(['[eegc3_subjectID] eegc3 GDF naming convention detected']);
end

function subID = retrieve_name(Name, eegcv)

if(eegcv == 2)
    Symbol = '_';
else
    Symbol = '.';
end

SymFind = strfind(Name, Symbol);
if(length(SymFind)~=0)
       
    Pos = SymFind(1);
    subID = Name(1:Pos-1);
else
    disp('Invalid input, this is not a valid name for a CNBI run GDF file...');
    subID = {};
end

   