function HDR = GDFWriteBlock(HDR, data)
% GDFWriteBlock writes data to file
% 
% HDR = GDFWriteBlock(HDR, data);
%
% input:
%   HDR        file handle to gdf
%   data       data block to be stored [samp x ch]
% output:
%   HDR        file handle to gdf

% R.Leeb, 08-May-09, initial version
% R.Leeb, 11-May-09, data is stored in 'short' instead of 'float64'

if  ~isempty(HDR)
    for k = 1 : size(data,1)
        % write signal to disk
        fwrite(HDR.FILE.FID, data(k,HDR.DataSample.InCh), 'short'); %Usually 'short'  'float64'
        % update sample counter
        HDR.DataSample.SmplCnt = HDR.DataSample.SmplCnt + 1;
    end  
end

             