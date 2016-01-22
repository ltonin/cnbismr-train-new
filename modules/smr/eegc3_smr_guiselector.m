function varargout = eegc3_smr_guiselector(varargin)
% EEGC3_SMR_GUISELECTOR M-file for eegc3_smr_guiselector.fig
%      EEGC3_SMR_GUISELECTOR, by itself, creates a new EEGC3_SMR_GUISELECTOR or raises the existing
%      singleton*.
%
%      H = EEGC3_SMR_GUISELECTOR returns the handle to a new EEGC3_SMR_GUISELECTOR or the handle to
%      the existing singleton*.
%
%      EEGC3_SMR_GUISELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EEGC3_SMR_GUISELECTOR.M with the given input arguments.
%
%      EEGC3_SMR_GUISELECTOR('Property','Value',...) creates a new EEGC3_SMR_GUISELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eegc3_smr_guiselector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eegc3_smr_guiselector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eegc3_smr_guiselector

% Last Modified by GUIDE v2.5 01-Dec-2010 07:42:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eegc3_smr_guiselector_OpeningFcn, ...
                   'gui_OutputFcn',  @eegc3_smr_guiselector_OutputFcn, ...
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


% --- Executes just before eegc3_smr_guiselector is made visible.
function eegc3_smr_guiselector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eegc3_smr_guiselector (see VARARGIN)

% Choose default command line output for eegc3_smr_guiselector
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eegc3_smr_guiselector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = eegc3_smr_guiselector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonAdd.
function buttonAdd_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list = get(handles.listboxSelected, 'String');
if(isempty(list) == true)
    list = {};
end

other = get(handles.listboxFolders, 'String');
selected = get(handles.listboxFolders, 'Value');
list{end+1} = other{selected};
set(handles.listboxSelected, 'String', list);
if(selected < length(other))
    set(handles.listboxFolders, 'Value', selected + 1);
end

% --- Executes on selection change in listboxFolders.
function listboxFolders_Callback(hObject, eventdata, handles)
% hObject    handle to listboxFolders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxFolders contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxFolders


% --- Executes during object creation, after setting all properties.
function listboxFolders_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxFolders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listboxSelected.
function listboxSelected_Callback(hObject, eventdata, handles)
% hObject    handle to listboxSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxSelected contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxSelected


% --- Executes during object creation, after setting all properties.
function listboxSelected_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPath_Callback(hObject, eventdata, handles)
% hObject    handle to editPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPath as text
%        str2double(get(hObject,'String')) returns contents of editPath as a double
update_folders(handles, get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function editPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonBrowse.
function pushbuttonBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder = uigetdir;
if(folder)
    update_folders(handles, folder);
end

% --- Executes on button press in pushbuttonClear.
function pushbuttonClear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.listboxFolders, 'String', '');
set(handles.listboxFolders, 'Value', 1);

function update_folders(handles, folder)
set(handles.editPath, 'String', folder);
logfiles = subdir([folder '/*.log']);

if(isempty(logfiles))
    return;
end

list = get(handles.listboxFolders, 'String');
if(isempty(list) == true)
    list = {};
end

for i = 1:length(logfiles)
    list{end+1} = logfiles(i).name;
end
set(handles.listboxFolders, 'String', list);


% --- Executes on button press in pushbuttonRemove.
function pushbuttonRemove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
old = get(handles.listboxSelected, 'String');
removed = get(handles.listboxSelected, 'Value');
new = {};
for i = 1:length(old)
    if(i ~= removed)
        new{end+1} = old{i};
    end
end
set(handles.listboxSelected, 'String', new);
set(handles.listboxSelected, 'Value', 1);


% --- Executes on button press in pushbuttonAddAll.
function pushbuttonAddAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all = get(handles.listboxFolders, 'String');
set(handles.listboxSelected, 'String', all);


% --- Executes on button press in pushbuttonExport.
function pushbuttonExport_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base', get(handles.editExport, 'String'), get(handles.listboxSelected, 'String'));


% --- Executes on button press in pushbuttonSimloop.
function pushbuttonSimloop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSimloop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f = 1;
logfiles = get(handles.listboxSelected, 'String');
for i = 1:length(logfiles)
    session = eegc3_cl_loadlog(logfiles{i});

    if(isempty(session) == false)
        for i = 1:length(session.runs.online)
            if(session.trace.eegcversion == 2)
                bci = eegc3_smr_simloop(...
                    session.runs.online{i}.xdf, ...
                   	session.runs.online{i}.txt, ...
					session.runs.online{i}.classifier, ...
					str2num(session.runs.online{i}.rejection), ... 
					str2num(session.runs.online{i}.integration), ...
					1000 + i);
            else
                bci = eegc3_smr_simloop(...
                    	session.runs.online{i}.xdf, ...
                        [], ...
                        session.runs.online{i}.classifier, ...
                        str2num(session.runs.online{i}.rejection), ... 
                        str2num(session.runs.online{i}.integration), ...
                       1000 + i);
            end
            f = f + 1;
        end
    end
end



function editExport_Callback(hObject, eventdata, handles)
% hObject    handle to editExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editExport as text
%        str2double(get(hObject,'String')) returns contents of editExport as a double


% --- Executes during object creation, after setting all properties.
function editExport_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

logfiles = get(handles.listboxSelected, 'String');
f = 1;
for i = 1:length(logfiles)
    session = eegc3_cl_loadlog(logfiles{i});

    if(isempty(session) == false)
        for i = 1:length(session.runs.online)
            if(session.trace.eegcversion == 2)
                bci = eegc3_smr_simloop(...
                    session.runs.online{i}.xdf, ...
                   	session.runs.online{i}.txt, ...
					session.runs.online{i}.classifier, ...
					str2num(session.runs.online{i}.rejection), ... 
					str2num(session.runs.online{i}.integration), ...
					1000 + f);
            else
                bci = eegc3_smr_simloop(...
                    	session.runs.online{i}.xdf, ...
                        [], ...
                        session.runs.online{i}.classifier, ...
                        str2num(session.runs.online{i}.rejection), ... 
                        str2num(session.runs.online{i}.integration), ...
                       1000 + f);
            end
            f = f + 1;
            
            [taskset, resetevents] = eegc3_smr_guesstask(bci.lbl, bci.settings);
            eegc3_smr_simprotocol(bci, taskset.cues, taskset.colors, ...
             [], [], 1, 2000 + f);
              f = f + 1;
       
        end
    end
end