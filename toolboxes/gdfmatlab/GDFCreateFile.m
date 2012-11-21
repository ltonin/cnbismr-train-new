function HDR = GDFCreateFile(info, filename)
% GDFCreateFile create the file header structure
% 
% HDR = GDFCreateFile(info, filename);
%
% input:
%   info       information structure about subject, amplifier, inputs,...
%   filename   name of the file 
% output:
%   HDR        file handle to gdf

% R.Leeb, 08-May-09, initial version
% R.Leeb, 11-May-09, data is stored in 'short' instead of 'float64'
% L.Tonin 29-May-09, commented 'disp(['# file ' HDR.FileName ' created.'])' - row 69

%   Modified from the rtsBCI/BIOSIG-toolbox http://biosig.sf.net/
%	Copyright (C) 2001-2009 by Reinhold Scherer, Alois Schlögl, Robert Leeb
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Library General Public
% License as published by the Free Software Foundation; either
% Version 3 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Library General Public License for more details.
%
% You should have received a copy of the GNU Library General Public
% License along with this library; if not, write to the
% Free Software Foundation, Inc., 59 Temple Place - Suite 330,
% Boston, MA  02111-1307, USA.
 
if nargin < 2
    error([ mfilename ' --> filename not specified.']);
end

HDR = [];

[p, n, header_type] = fileparts(filename);
if isempty(header_type)
	header_type = '.gdf';
	filename = [filename header_type];
end
if ~strcmp(upper(header_type(2:end)),'GDF')
    error('unknown file type!');
end

% check if file already exist
if exist(filename)
    disp(['The filename ' filename ' already exists. Please specifiy a different name!']);
	% Edited by M. Tavella <michele.tavella@epfl.ch> on 11/05/09 23:14:06
	%
	% Robert, sorry for taking this out, but I run matlab via SSH and when the
	% connection is slow the alert blocks the matlab thread....
	% Check gauInitialization.m, eventually. There you can choose wether to 
	% use GUIs or not.
	%
	%ButtonName=warndlg(['The filename ' filename ...
    %                ' already exists. Please specifiy a different name!'], ...
    %                'Information', 'modal');
	return    
end

% Creates GDF header
HDR = GDF(info, filename);
% Creates file
HDR = sopen(HDR, 'w');
% disp(['# file ' HDR.FileName ' created.']) -- L. Tonin modify
HDR.Status = 1;

% define event table
table_len = 8192;
HDR.EVENT.N	= 0;
HDR.EVENT.POS = zeros(table_len, 1); 
HDR.EVENT.TYP = zeros(table_len, 1);    

% set sample counter
HDR.DataSample.InCh = [1:HDR.NS];
HDR.DataSample.SmplCnt = 0; % sample counter




function HDR = GDF(info, filename)

clear HDR;

% select file format 
HDR.TYPE='GDF';

% set Filename
HDR.FileName = filename;

% person identification, max 80 char
HDR.PID = info.Subject.Name;	% e.g. 'MCH-0234567 F 02-MAY-1951 Haagse_Harry'
HDR.PID = HDR.PID(1:min(80, length(HDR.PID)));

% recording identification, max 80 char.
HDR.RID = 'recording identification';	% e.g. 'EMG561 BK/JOP Sony. MNC R Median Nerve.'
HDR.RID = [info.Equipment.Computer '; ' info.Equipment.Amplifier];

% recording time [YYYY MM DD hh mm ss.ccc]
HDR.T0 = clock;	

% number of channels
HDR.NS = length(info.AnalogChannel);

% Samples within 1 block
%HDR.SPR = [100;100;100;100;100];	% samples per block;
HDR.SampleRate = info.SampleRate;	% samples per block;

% Duration of one block in seconds
HDR.Dur = 1/HDR.SampleRate;

% channel identification, max 80 char. per channel
HDR.Label=[];
% filter settings of each channel 
HDR.PreFilt=[];
for i=1:length(info.AnalogChannel)
    HDR.Label{i} = info.AnalogChannel{i}{2};
    HDR.PreFilt = str2mat(HDR.PreFilt, sprintf('%.2f - %.2f Hz', info.AnalogChannel{i}{4}, info.AnalogChannel{i}{5}));
end

% HDR.Patient.Birthday = zeros(1,6);
HDR.Patient.Birthday = [str2num(info.Subject.YearOfBirth),0,0,0,0,0];
%HDR.Label = HDR.Label(2:end);
HDR.PreFilt = HDR.PreFilt(2:end,:);

% Transducer, mx 80 char per channel
HDR.Transducer = repmat({'        '}, length(info.AnalogChannel), 1);

% define datatypes (GDF only, see GDFDATATYPE.M for more details)
% 3 for short, 17 for float64
HDR.GDFTYP = 3*ones(1,HDR.NS);

% define scaling factors 
HDR.PhysMax = [];
HDR.PhysMin = [];
for i=1:length(info.AnalogChannel)
    HDR.PhysMax(i) = +info.AnalogChannel{i}{3};
    HDR.PhysMin(i) = -info.AnalogChannel{i}{3};
    HDR.DigMax(i) = pow2(info.DAQbits-1)-1;
    HDR.DigMin(i) = -pow2(info.DAQbits-1);   
end

% 
HDR.DigMax = HDR.PhysMax; 
HDR.DigMin = HDR.PhysMin; 

% define physical dimension
HDR.PhysDimCode = repmat(physicalunits('uV'), length(info.AnalogChannel), 1);
HDR.AS.SPR=ones(length(info.AnalogChannel), 1);
HDR.SPR=1;

