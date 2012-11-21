function varargout = eegc3_select_gui(varargin)
% eegc3_select_gui M-file for eegc3_select_gui.fig
%      eegc3_select_gui, by itself, creates a new eegc3_select_gui or raises the existing
%      singleton*.
%
%      H = eegc3_select_gui returns the handle to a new eegc3_select_gui or the handle to
%      the existing singleton*.
%
%      eegc3_select_gui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in eegc3_select_gui.M with the given input arguments.
%
%      eegc3_select_gui('Property','Value',...) creates a new eegc3_select_gui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eegc3_select_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eegc3_select_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eegc3_select_gui

% Last Modified by GUIDE v2.5 09-Feb-2011 20:36:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eegc3_select_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @eegc3_select_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before eegc3_select_gui is made visible.
function eegc3_select_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eegc3_select_gui (see VARARGIN)

% Choose default command line output for eegc3_select_gui
handles.output = hObject;
	
	% Asses inputs
	if(nargin < 4)
		disp('Invalid number of input arguments. Try again!');
	end

	handles.SessionPlotMats = varargin{1};
	handles.DPPlotMat = varargin{2};
	handles.SelectedMat = varargin{3};
	handles.settings = varargin{4};


    set(handles.ModeGroup,'SelectionChangeFcn',@ModeChangeFcn);
    % Set mode to automatic
    handles.mode = 'auto';
    set(handles.AutoBtn,'Value',1);
    set(handles.ManBtn,'Value',0);
    
    % SessionPlots is a cell array of matrices (DPa mats)
    DPLength = length(handles.SessionPlotMats);
    for i=1:DPLength
        subplot(1,DPLength,i,'Parent',handles.SessionPlot),...
            imagesc(handles.SessionPlotMats{i});
        set(gca, 'YTick',      1:handles.settings.acq.channels_eeg);
        set(gca, 'YTickLabel', {});
        set(gca, 'XTick',      [1:1:length(handles.settings.modules.smr.psd.freqs)]);
        set(gca, 'XTickLabel', {});
        xlabel('');
        ylabel('');
        %plotPresent(handles);
    end
    
    % Generate the overall DPPlot form the AllDPa matrix
    axes(handles.DPPlot);
    imagesc(handles.DPPlotMat);
    set(handles.DPPlot,'Tag','DPPlot');
    plotPresent(handles);
    
    % Set up data cursor
    handles.dcm = datacursormode(hObject);
    set(handles.dcm,'UpdateFcn',@featureHandler,'Enable','off');
    
    % Set up threshold slider
    set(handles.ThSlide,'Value',handles.settings.modules.smr.dp.threshold,'Enable','on');
    
    % Set up selection plot
    axes(handles.SelectionPlot);
    handles.SelectedHim = imagesc(handles.SelectedMat);
    set(handles.SelectionPlot,'Tag','SelectionPlot');
    computeSelection(hObject,handles);
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eegc3_select_gui wait for user response (see UIRESUME)
uiwait(handles.GUIPanel);



% Callback to handle the data cursor clicks
function txt = featureHandler(obj,event_obj)

ImageHandle = event_obj.Target;

Pos = get(event_obj,'Position');
txt = {['Frequency bin: ' num2str(Pos(1))], ['Electrode: ' num2str(Pos(2))]};


if(~strcmp(get(get(ImageHandle,'Parent'),'Tag'),'SelectionPlot')) % Means it is not the Selection Plot

    % Only way I found to retrieve the GUI handle in this callback
    
    if(strcmp(get(get(ImageHandle,'Parent'),'Tag'),'DPPlot'))        
        GUIHandle = get(get(ImageHandle,'Parent'),'Parent');
    else
        GUIHandle = get(get(get(ImageHandle,'Parent'),'Parent'),'Parent');
    end
    
    GUIdata = guidata(GUIHandle);
    SelPlotImHandle = findobj(findobj(GUIHandle,'Tag','SelectionPlot'),'Type','image');
    SelectedData = get(SelPlotImHandle,'CData');
    
    
    % Toggle selection
    if(SelectedData(Pos(2),Pos(1)) == 0)
        SelectedData(Pos(2),Pos(1)) = 1;
    else
        SelectedData(Pos(2),Pos(1)) = 0;
    end
    
    set(SelPlotImHandle,'CData',SelectedData);
    guidata(GUIHandle,GUIdata);
    return;
else
    return;
    % Do nothing
end


% --- Outputs from this function are returned to the command line.
function varargout = eegc3_select_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

%Put the final selection in the settings structure, return it and close
% Retrieve data 
SelPlotImHandle = findobj(findobj(hObject,'Tag','SelectionPlot'),'Type','image');
SelectedData = get(SelPlotImHandle,'CData');

handles.settings.bci.smr.channels = [];
handles.settings.bci.smr.bands = cell(1,size(SelectedData,1));
bnidx = cell(1,size(SelectedData,1));
tot = 0;

tot = 0;
for ch=1:size(SelectedData,1)
    for bn = 1:size(SelectedData,2)
        
        if(SelectedData(ch,bn)>0) % if this feature selected...
            
            tot = tot + 1;
            
            if(isempty(find(handles.settings.bci.smr.channels == ch)))
                % Add this channel
                handles.settings.bci.smr.channels = [handles.settings.bci.smr.channels ch];
            end
            
            % Add band to this channel
	    bnidx{ch} = [bnidx{ch} bn];
            handles.settings.bci.smr.bands{ch} = [handles.settings.bci.smr.bands{ch} (2*(bn-1)+4)];
            
            
        end
    end
end

% Set the final value of the threshold to be saved
if(strcmp(handles.mode,'man'))
	handles.settings.modules.smr.dp.threshold = 0; % Denotes manual selection
end
% Otherwise keep the current value, which is the correct one

guidata(hObject,handles);
varargout{1} = handles.settings;
varargout{2} = bnidx;
varargout{3} = tot;
delete(hObject)

% --- Executes on button press in ClassifyBtn.
function ClassifyBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ClassifyBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;

% --- Executes on slider movement.
function ThSlide_Callback(hObject, eventdata, handles)
% hObject    handle to ThSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
computeSelection(hObject,handles);
handles.settings.modules.smr.dp.threshold  = get(hObject,'Value');
guidata(get(hObject,'Parent'),handles);

% --- Executes during object creation, after setting all properties.
function ThSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function DPPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DPPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate DPPlot


% --- Executes during object creation, after setting all properties.
function SelectionPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectionPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate SelectionPlot


function ModeChangeFcn(hObject, eventdata)

%retrieve GUI data, i.e. the handles structure
handles = guidata(hObject); 
 
switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'AutoBtn'
        handles.mode = 'auto';
        set(handles.dcm,'Enable','off');
        % Get rid of annoying remaining datatips...
        delete(findall(gcf,'Type','hggroup','HandleVisibility','off'));
        
        % Enable threshold slider
        set(handles.ThSlide,'Value',handles.settings.modules.smr.dp.threshold,'Enable','on');
        % Code to compute selection here...
        
        computeSelection(get(hObject,'Parent'),handles);
        
    case 'ManBtn'
        handles.mode = 'man';
        set(handles.dcm,'UpdateFcn',@featureHandler,'Enable','on','DisplayStyle','datatip');
        % Disable slider
        set(handles.ThSlide,'Enable','off');
    otherwise
       % Code for when there is no match.
 
end
%updates the handles structure
guidata(hObject, handles);


function computeSelection(hObject,handles)

Alldpa = reshape(handles.DPPlotMat, size(handles.DPPlotMat,1), ...
	size(handles.DPPlotMat,2));

dpath = (get(handles.ThSlide,'Value')) * max(max(Alldpa));
[cidx, bidx] = eegc3_contribute_matrix(Alldpa, dpath);


handles.SelectedMat = zeros(size(Alldpa));

Allchannels = sort(unique(cidx));
Allbandsidx = {};
for ch = cidx
	Allbandsidx{ch} = [];
end

Alltot = 0;
for i = 1:length(cidx)
	ch = cidx(i);
	bn = bidx(i);
	Allbandsidx{ch} = sort([Allbandsidx{ch} bn]);
	handles.SelectedMat(ch, bn) = Alldpa(ch, bn)/Alldpa(ch, bn);
	Alltot = Alltot + 1;
end


Allbands = {};
for ch = cidx
	Allbands{ch} = ...
	handles.settings.modules.smr.psd.freqs(Allbandsidx{ch});
end

axes(handles.SelectionPlot);
handles.SelectedHim = imagesc(handles.SelectedMat);
set(handles.SelectionPlot,'Tag','SelectionPlot');
plotPresent(handles);
guidata(hObject,handles);


% --- Executes when user attempts to close GUIPanel.
function GUIPanel_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to GUIPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(hObject);

function plotPresent(handles)
    set(gca, 'YTick',      1:handles.settings.acq.channels_eeg);
    set(gca, 'YTickLabel', 1:handles.settings.acq.channels_eeg);
    set(gca, 'XTick',      [1:1:length(handles.settings.modules.smr.psd.freqs)]);
    set(gca, 'XTickLabel', handles.settings.modules.smr.psd.freqs);
    xlabel('Band [Hz]');
    ylabel('Channel');
