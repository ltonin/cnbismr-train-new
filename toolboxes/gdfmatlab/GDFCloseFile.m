function HDR = GDFCloseFile(HDR)
% GDFCloseFile close the GDF file
% 
% HDR = GDFCloseFile(HDR);
%
% input:
%   HDR        file handle to gdf
% output:
%   HDR        file handle to gdf

% R.Leeb, 08-May-09, initial version

if  ~isempty(HDR)
    % Events
    if HDR.EVENT.N > 0
    	HDR.EVENT.POS = HDR.EVENT.POS(1:HDR.EVENT.N);
        HDR.EVENT.TYP = HDR.EVENT.TYP(1:HDR.EVENT.N);
        HDR.EVENT = rmfield(HDR.EVENT, 'DUR');
        HDR.EVENT = rmfield(HDR.EVENT, 'CHN');
    else
        HDR = rmfield(HDR, 'EVENT');
    end
    % closes the file
    HDR = sclose(HDR);
    HDR = [];
end          