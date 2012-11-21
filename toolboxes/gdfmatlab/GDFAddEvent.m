function HDR = GDFAddEvent(HDR, EVENT)
% GDFAddEvent add event to current GDF data position
% see eventcodes.txt in biosig/doc
% 
% HDR = GDFAddEvent(HDR, EVENT);
%
% input:
%   HDR        file handle to gdf
%   EVENT      list of EVENTS to stored in the gdf
% output: 
%   HDR        file handle to gdf

% R.Leeb, 08-May-09, initial version

% check events;
if  ~isempty(HDR)
    for i = 1 : length(EVENT)
        HDR.EVENT.N = HDR.EVENT.N + 1;
        HDR.EVENT.POS(HDR.EVENT.N) = HDR.DataSample.SmplCnt;
        HDR.EVENT.TYP(HDR.EVENT.N) = EVENT(i);
    end  
end

