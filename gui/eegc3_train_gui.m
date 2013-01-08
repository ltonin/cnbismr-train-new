function varargout = eegc3_train_gui(varargin)
% EEGC3_TRAIN_GUI M-file for eegc3_train_gui.fig
%      EEGC3_TRAIN_GUI, by itself, creates a new EEGC3_TRAIN_GUI or raises the existing
%      singleton*.
%
%      H = EEGC3_TRAIN_GUI returns the handle to a new EEGC3_TRAIN_GUI or the handle to
%      the existing singleton*.
%
%      EEGC3_TRAIN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EEGC3_TRAIN_GUI.M with the given input arguments.
%
%      EEGC3_TRAIN_GUI('Property','Value',...) creates a new EEGC3_TRAIN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eegc3_train_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eegc3_train_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eegc3_train_gui

% Last Modified by GUIDE v2.5 08-Jan-2013 18:42:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eegc3_train_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @eegc3_train_gui_OutputFcn, ...
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


% --- Executes just before eegc3_train_gui is made visible.
function eegc3_train_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eegc3_train_gui (see VARARGIN)

% Choose default command line output for eegc3_train_gui
handles.output = hObject;

% Load default classifier/feature settings and save to handles
settings = eegc3_newsettings();
settings = eegc3_smr_newsettings(settings);
handles.settings = settings;

handles.settings.modules.smr.options.selection.usegui = 1;
handles.settings.modules.smr.options.extraction.trials = 1;
handles.usedlg = false;

set(handles.Prep_DC,'Value',1);
set(handles.Prep_Laplacian,'Value',1);
set(handles.UseDlg,'Value',0);
set(handles.SelectGUI,'Value',1);
set(handles.EnableSettings,'Value',0);
set(handles.OnlyTrials,'Value',1);
set(handles.OnlyTrials,'Enable','off');
set(handles.FastTrain,'Value',1);
set(handles.FeaturePanel,'Visible','off');

% Populate the Run listbox
dir = pwd;
handles.SelectedPaths = cell(0);
set(handles.Selected,'String',{});
% Populate the listbox
handles = load_listbox(dir,handles);


% Prepare the Classifier cell array for requested classifiers
Classifier = cell(1,7);
for i=1:7
    Classifier{i}.Enable = false;
    Classifier{i}.filename = '';
    Classifier{i}.filepath = '';
end

Classifier{1}.modality = 'rhlh';
Classifier{2}.modality = 'rhbf';
Classifier{3}.modality = 'lhbf';
Classifier{4}.modality = 'rhrst';
Classifier{5}.modality = 'lhrst';
Classifier{6}.modality = 'mod1';
Classifier{7}.modality = 'mod2';

Classifier{1}.task_right = 770;
Classifier{1}.task_left = 769;

Classifier{2}.task_right = 770;
Classifier{2}.task_left = 771;

Classifier{3}.task_right = 771;
Classifier{3}.task_left = 769;

Classifier{4}.task_right = 770;
Classifier{4}.task_left = 783;

Classifier{5}.task_right = 783;
Classifier{5}.task_left = 769;

Classifier{6}.task_right = 0;
Classifier{6}.task_left = 0;

Classifier{7}.task_right = 0;
Classifier{7}.task_left = 0;

handles.Classifier = Classifier;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eegc3_tr
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = eegc3_train_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% First output is the selected GDFs
varargout{1} = handles.SelectedPaths;

% Second output is the selected settings MAT filepath
varargout{2} = handles.settings;

% Third output is the info on the requested classifiers
varargout{3} = handles.Classifier;

% Third output is the info on the requested classifiers
varargout{4} = handles.usedlg;

delete(handles.figure1);

% --- Executes on selection change in Runs_GDFs.
function Runs_GDFs_Callback(hObject, eventdata, handles)
% hObject    handle to Runs_GDFs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Runs_GDFs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        Runs_GDFs

index_selected = get(handles.Runs_GDFs,'Value');
file_list = get(handles.Runs_GDFs,'String');
filename = file_list{index_selected};
if  handles.is_dir(handles.sorted_index(index_selected))
    cd (filename)
    handles = load_listbox(pwd,handles);
    guidata(gcf,handles);
else
    [path,name,ext,ver] = fileparts(filename);
    if(strcmp(ext,'.gdf'))
        
        % Edit the "selected" list
        file_path = [pwd filesep filename];
        new_path = add2listbox(file_path,filename, handles);
        handles.SelectedPaths = new_path;
        
        % Reset subject ID, sampling rate and channel number
        sID = eegc3_subjectID(file_path);
        handles.settings.info.subject = sID{1};
        set(handles.Subject_code,'String',sID);
        
        [SR ChanNum TrChanNum] = eegc3_GDFInfo(file_path);
        handles.settings.acq.sf = SR;
        handles.settings.acq.channels_eeg = ChanNum;
        set(handles.EEG_Fs,'String',SR);
        set(handles.EEG_Channels,'String',num2str(ChanNum));
        
        guidata(gcf,handles);
    end
        
 end

% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------
function mod_handles = load_listbox(path,handles)
cd (path)
dir_struct = dir(path);
% Get rid of hidden files/folders
% This codes assumes that '.' and '..' are always in the beginning
Names = {dir_struct.name};
Cropind = setdiff(strmatch('.',Names) , strmatch('.',Names,'exact'));
Cropind = setdiff(Cropind , strmatch('..',Names,'exact'));
dir_struct(Cropind) = [];
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
set(handles.Runs_GDFs,'String',handles.file_names,...
	'Value',1)
mod_handles = handles;


% ------------------------------------------------------------
% Add a GDF/run to the selected listbox
% ------------------------------------------------------------
function next_path = add2listbox(path, name, handles)
cur_string = get(handles.Selected,'String');
next_path = handles.SelectedPaths;

if iscell(cur_string)
    next_string = cur_string;
    
    % Search if it already exists
    existsGDF = 0;
    for s=1:length(next_string)
        if(strcmp(next_string{s},name))
            existsGDF = 1;
            break;
        end
    end
    if (~existsGDF)
        next_string{end + 1} = name;
        next_path{end + 1} = path;
    end
    
else
    next_string{end+1} = name;
    next_path{end+1} = path;
end
set(handles.Selected,'String',next_string,...
	'Value',1)

% --- Executes during object creation, after setting all properties.
function Runs_GDFs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Runs_GDFs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Selected.
function Selected_Callback(hObject, eventdata, handles)
% hObject    handle to Selected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Selected contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Selected
index_selected = get(handles.Selected,'Value');
% Remove selected entry

paths = handles.SelectedPaths;
if (length(paths) >=1)    
    list = get(handles.Selected,'String');
    for s = index_selected:length(list)-1
        paths{s} = paths{s+1};
        list{s} = list{s+1};
    end
    paths(end) = [];
    list(end) = [];
    set(handles.Selected,'String',list, 'Value',1);
    handles.SelectedPaths = paths;
    guidata(handles.figure1,handles)
end


% --- Executes during object creation, after setting all properties.
function Selected_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Selected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Clear.
function Clear_Callback(hObject, eventdata, handles)
% hObject    handle to Clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SelectedPaths = {};
list = {};
set(handles.Selected,'String',list, 'Value',1);
guidata(handles.figure1,handles)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LdLog.
function LdLog_Callback(hObject, eventdata, handles)
% hObject    handle to LdLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[LogfilePath LogfileName RunPaths RunNames] = eegc3_gui_logfile;
for i=1:length(RunPaths)
    new_path = add2listbox(RunPaths{i},RunNames{i}, handles);
    handles.SelectedPaths = new_path;
end
guidata(gcf,handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LdClassMod2.
function LdClassMod2_Callback(hObject, eventdata, handles)
% hObject    handle to LdClassMod2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.Classifier{5}.filepath handles.Classifier{5}.filename] = eegc3_gui_initclass();
if(~isempty(handles.Classifier{5}.filepath))
    set(handles.ClassLbl_Mod2,'String',handles.Classifier{5}.filename);
else
    set(handles.ClassLbl_Mod2,'String','None');
end
guidata(gcf,handles);

% --- Executes on button press in LdClassMod1.
function LdClassMod1_Callback(hObject, eventdata, handles)
% hObject    handle to LdClassMod1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.Classifier{4}.filepath handles.Classifier{4}.filename] = eegc3_gui_initclass();
if(~isempty(handles.Classifier{4}.filepath))
    set(handles.ClassLbl_Mod1,'String',handles.Classifier{4}.filename);
else
    set(handles.ClassLbl_Mod1,'String','None');
end
guidata(gcf,handles);

% --- Executes on button press in LdClassLHBF.
function LdClassLHBF_Callback(hObject, eventdata, handles)
% hObject    handle to LdClassLHBF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.Classifier{3}.filepath handles.Classifier{3}.filename] = eegc3_gui_initclass();
if(~isempty(handles.Classifier{3}.filepath))
    set(handles.ClassLbl_lhbf,'String',handles.Classifier{3}.filename);
else
    set(handles.ClassLbl_lhbf,'String','None');
end
guidata(gcf,handles);

% --- Executes on button press in LdClassRHBF.
function LdClassRHBF_Callback(hObject, eventdata, handles)
% hObject    handle to LdClassRHBF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.Classifier{2}.filepath handles.Classifier{2}.filename] = eegc3_gui_initclass();

if(~isempty(handles.Classifier{2}.filepath))
    set(handles.ClassLbl_rhbf,'String',handles.Classifier{2}.filename);
else
    set(handles.ClassLbl_rhbf,'String','None');
end
guidata(gcf,handles);

% --- Executes on button press in LdClassRHLH.
function LdClassRHLH_Callback(hObject, eventdata, handles)
% hObject    handle to LdClassRHLH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.Classifier{1}.filepath handles.Classifier{1}.filename] = eegc3_gui_initclass();
if(~isempty(handles.Classifier{1}.filepath))
    set(handles.ClassLbl_rhlh,'String',handles.Classifier{1}.filename);
else
    set(handles.ClassLbl_rhlh,'String','None');
end
guidata(gcf,handles);

% --- Executes on button press in LdClassRHRST.
function LdClassRHRST_Callback(hObject, eventdata, handles)
% hObject    handle to LdClassRHRST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.Classifier{1}.filepath handles.Classifier{1}.filename] = eegc3_gui_initclass();
if(~isempty(handles.Classifier{1}.filepath))
    set(handles.ClassLbl_rhrst,'String',handles.Classifier{1}.filename);
else
    set(handles.ClassLbl_rhrst,'String','None');
end
guidata(gcf,handles);

% --- Executes on button press in LdClassRHRST.
function LdClassLHRST_Callback(hObject, eventdata, handles)
% hObject    handle to LdClassLHRST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.Classifier{1}.filepath handles.Classifier{1}.filename] = eegc3_gui_initclass();
if(~isempty(handles.Classifier{1}.filepath))
    set(handles.ClassLbl_lhrst,'String',handles.Classifier{1}.filename);
else
    set(handles.ClassLbl_lhrst,'String','None');
end
guidata(gcf,handles);

function Mod1Ltrig_Callback(hObject, eventdata, handles)
% hObject    handle to Mod1Ltrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mod1Ltrig as text
%        str2double(get(hObject,'String')) returns contents of Mod1Ltrig as a double

if(~isempty(get(hObject,'String')) && ~isnan(str2double(get(hObject,'String'))) && ...
        str2double(get(hObject,'String')) > 0 )

        handles.Classifier{4}.task_left  = str2double(get(hObject,'String'));
else
    uiwait(msgbox('Trigger code should be a positive integer!','Attention!','error'));
    set(hObject,'String','0');
    handles.Classifier{4}.task_left  = 0;
end
guidata(gcf,handles);


% --- Executes during object creation, after setting all properties.
function Mod1Ltrig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mod1Ltrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Mod2Rtrig_Callback(hObject, eventdata, handles)
% hObject    handle to Mod2Rtrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mod2Rtrig as text
%        str2double(get(hObject,'String')) returns contents of Mod2Rtrig as
%        a double
% Reserved for multiple classes as "right"
if(~isempty(get(hObject,'String')))

        handles.Classifier{5}.task_right  = str2double(get(hObject,'String'));
else
    uiwait(msgbox('Trigger code should be a positive integer!','Attention!','error'));
    set(hObject,'String','0');
    handles.Classifier{5}.task_right  = 0;
end
guidata(gcf,handles);


% --- Executes during object creation, after setting all properties.
function Mod2Rtrig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mod2Rtrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Mod2Ltrig_Callback(hObject, eventdata, handles)
% hObject    handle to Mod2Ltrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mod2Ltrig as text
%        str2double(get(hObject,'String')) returns contents of Mod2Ltrig as a double
if(~isempty(get(hObject,'String')))

        handles.Classifier{5}.task_left  = str2double(get(hObject,'String'));
else
    uiwait(msgbox('Trigger code should be a positive integer!','Attention!','error'));
    set(hObject,'String','0');
    handles.Classifier{5}.task_left  = 0;
end
guidata(gcf,handles);


% --- Executes during object creation, after setting all properties.
function Mod2Ltrig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mod2Ltrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Mod1Rtrig_Callback(hObject, eventdata, handles)
% hObject    handle to Mod1Rtrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mod1Rtrig as text
%        str2double(get(hObject,'String')) returns contents of Mod1Rtrig as a double

if(~isempty(get(hObject,'String')) && ~isnan(str2double(get(hObject,'String'))) && ...
        str2double(get(hObject,'String')) > 0 )

        handles.Classifier{4}.task_right  = str2double(get(hObject,'String'));
else
    uiwait(msgbox('Trigger code should be a positive integer!','Attention!','error'));
    set(hObject,'String','0');
    handles.Classifier{4}.task_right  = 0;
end

guidata(gcf,handles);



% --- Executes during object creation, after setting all properties.
function Mod1Rtrig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mod1Rtrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Mod2Lbl_Callback(hObject, eventdata, handles)
% hObject    handle to Mod2Lbl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mod2Lbl as text
%        str2double(get(hObject,'String')) returns contents of Mod2Lbl as a double
if(isempty(get(hObject,'String')) || (~isnan(str2double(get(hObject,'String')))))
    uiwait(msgbox('Modality should be alphanumeric and not empty!','Attention!','error'));
    handles.Classifier{5}.modality = 'mod2';
    set(hObject,'String','mod2');
else
    handles.Classifier{5}.modality = get(hObject,'String');
end
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function Mod2Lbl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mod2Lbl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Mod1Lbl_Callback(hObject, eventdata, handles)
% hObject    handle to Mod1Lbl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mod1Lbl as text
%        str2double(get(hObject,'String')) returns contents of Mod1Lbl as a double

if(isempty(get(hObject,'String')) || (~isnan(str2double(get(hObject,'String')))))
    uiwait(msgbox('Modality should be alphanumeric and not empty!','Attention!','error'));
    handles.Classifier{4}.modality = 'mod1';
    set(hObject,'String','mod1');
else
    handles.Classifier{4}.modality = get(hObject,'String');
end

guidata(gcf,handles);


% --- Executes during object creation, after setting all properties.
function Mod1Lbl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mod1Lbl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Mod2Check.
function Mod2Check_Callback(hObject, eventdata, handles)
% hObject    handle to Mod2Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Mod2Check
if(get(handles.Mod2Check,'Value')==1)
    set(handles.LdClassMod2,'Enable','on');
    set(handles.Mod2Check,'Value',1);
    set(handles.Mod2Lbl,'Enable','on');
    set(handles.Mod2Rtrig,'Enable','on');
    set(handles.Mod2Ltrig,'Enable','on');
    handles.Classifier{5}.Enable = true;
else
    set(handles.LdClassMod2,'Enable','off');
    set(handles.Mod2Check,'Value',0);
    set(handles.Mod2Lbl,'Enable','off');
    set(handles.Mod2Rtrig,'Enable','off');
    set(handles.Mod2Ltrig,'Enable','off');
    handles.Classifier{5}.Enable = false;
end
guidata(gcf,handles);


% --- Executes on button press in Mod1Check.
function Mod1Check_Callback(hObject, eventdata, handles)
% hObject    handle to Mod1Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Mod1Check
if(get(handles.Mod1Check,'Value')==1)
    set(handles.LdClassMod1,'Enable','on');
    set(handles.Mod1Check,'Value',1);
    set(handles.Mod1Lbl,'Enable','on');
    set(handles.Mod1Rtrig,'Enable','on');
    set(handles.Mod1Ltrig,'Enable','on');
    handles.Classifier{4}.Enable = true;
else
    set(handles.LdClassMod1,'Enable','off');
    set(handles.Mod1Check,'Value',0);
    set(handles.Mod1Lbl,'Enable','off');
    set(handles.Mod1Rtrig,'Enable','off');
    set(handles.Mod1Ltrig,'Enable','off');
    handles.Classifier{4}.Enable = false;
end
guidata(gcf,handles);

% --- Executes on button press in LHBFCheck.
function LHBFCheck_Callback(hObject, eventdata, handles)
% hObject    handle to LHBFCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LHBFCheck
if(get(handles.LHBFCheck,'Value')==1)
    set(handles.LdClassLHBF,'Enable','on');
    set(handles.LHBFCheck,'Value',1);
    handles.Classifier{3}.Enable = true;
else
    set(handles.LdClassLHBF,'Enable','off');
    set(handles.LHBFCheck,'Value',0);
    handles.Classifier{3}.Enable = false;
end
guidata(gcf,handles);

% --- Executes on button press in RHBFCheck.
function RHBFCheck_Callback(hObject, eventdata, handles)
% hObject    handle to RHBFCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RHBFCheck
if(get(handles.RHBFCheck,'Value')==1)
    set(handles.LdClassRHBF,'Enable','on');
    set(handles.RHBFCheck,'Value',1);
    handles.Classifier{2}.Enable = true;
else
    set(handles.LdClassRHBF,'Enable','off');
    set(handles.RHBFCheck,'Value',0);
    handles.Classifier{2}.Enable = false;
end
guidata(gcf,handles);

% --- Executes on button press in RHLHCheck.
function RHLHCheck_Callback(hObject, eventdata, handles)
% hObject    handle to RHLHCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RHLHCheck
if(get(handles.RHLHCheck,'Value')==1)
    set(handles.LdClassRHLH,'Enable','on');
    set(handles.RHLHCheck,'Value',1);
    handles.Classifier{1}.Enable = true;
else
    set(handles.LdClassRHLH,'Enable','off');
    set(handles.RHLHCheck,'Value',0);
    handles.Classifier{1}.Enable = false;
end
guidata(gcf,handles);

% --- Executes on button press in RHRSTCheck.
function RHRSTCheck_Callback(hObject, eventdata, handles)
% hObject    handle to RHRSTCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RHRSTCheck
if(get(handles.RHRSTCheck,'Value')==1)
    set(handles.LdClassRHRST,'Enable','on');
    set(handles.RHRSTCheck,'Value',1);
    handles.Classifier{1}.Enable = true;
else
    set(handles.LdClassRHRST,'Enable','off');
    set(handles.RHRSTCheck,'Value',0);
    handles.Classifier{1}.Enable = false;
end
guidata(gcf,handles);

% --- Executes on button press in LHRSTCheck.
function LHRSTCheck_Callback(hObject, eventdata, handles)
% hObject    handle to LHRSTCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LHRSTCheck
if(get(handles.LHRSTCheck,'Value')==1)
    set(handles.LdClassLHRST,'Enable','on');
    set(handles.LHRSTCheck,'Value',1);
    handles.Classifier{1}.Enable = true;
else
    set(handles.LdClassLHRST,'Enable','off');
    set(handles.LHRSTCheck,'Value',0);
    handles.Classifier{1}.Enable = false;
end
guidata(gcf,handles);

function Feat_Win_Callback(hObject, eventdata, handles)
% hObject    handle to Feat_Win (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Feat_Win as text
%        str2double(get(hObject,'String')) returns contents of Feat_Win as a double
if(~isempty(get(hObject,'String')) && ~isnan(str2double(get(hObject,'String'))) && ...
        str2double(get(hObject,'String')) > 0)

        handles.settings.modules.smr.win.size  = str2double(get(hObject,'String'));
else
    uiwait(msgbox('Window Size should be a positive number (in seconds)!','Attention!','error'));
    set(hObject,'String','1');
    handles.settings.modules.smr.win.size  = 1;
end
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function Feat_Win_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Feat_Win (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Feat_Win_Shift_Callback(hObject, eventdata, handles)
% hObject    handle to Feat_Win_Shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Feat_Win_Shift as text
%        str2double(get(hObject,'String')) returns contents of
%        Feat_Win_Shift as a double
if(~isempty(get(hObject,'String')) && ~isnan(str2double(get(hObject,'String'))) && ...
        str2double(get(hObject,'String')) > 0)

        handles.settings.modules.smr.win.shift  = str2double(get(hObject,'String'));
else
    uiwait(msgbox('Window Shift should be a positive number (in seconds)!','Attention!','error'));
    set(hObject,'String','0.0625');
    handles.settings.modules.smr.win.shift  = 1/16;
end
guidata(gcf,handles);


% --- Executes during object creation, after setting all properties.
function Feat_Win_Shift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Feat_Win_Shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSD_Win_Callback(hObject, eventdata, handles)
% hObject    handle to PSD_Win (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PSD_Win as text
%        str2double(get(hObject,'String')) returns contents of PSD_Win as a
%        double
if(~isempty(get(hObject,'String')) && ~isnan(str2double(get(hObject,'String'))) && ...
        str2double(get(hObject,'String')) > 0)

        handles.settings.modules.smr.psd.win  = str2double(get(hObject,'String'));
else
    uiwait(msgbox('PSD Window Size should be a positive number!','Attention!','error'));
    set(hObject,'String','0.5');
    handles.settings.modules.smr.psd.win  = 0.5;
end
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function PSD_Win_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSD_Win (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSD_Overlap_Callback(hObject, eventdata, handles)
% hObject    handle to PSD_Overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PSD_Overlap as text
%        str2double(get(hObject,'String')) returns contents of PSD_Overlap as a double
handles.settings.modules.smr.psd.ovl  = str2double(get(hObject,'String'));
if(~isempty(get(hObject,'String')) && ~isnan(str2double(get(hObject,'String'))) && ...
        str2double(get(hObject,'String')) > 0)

        handles.settings.modules.smr.psd.ovl  = str2double(get(hObject,'String'));
else
    uiwait(msgbox('PSD Window Overlapping should be a positive number!','Attention!','error'));
    set(hObject,'String','0.5');
    handles.settings.modules.smr.psd.ovl  = 0.5;
end
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function PSD_Overlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSD_Overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSD_Freqs_Callback(hObject, eventdata, handles)
% hObject    handle to PSD_Freqs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PSD_Freqs as text
%        str2double(get(hObject,'String')) returns contents of PSD_Freqs as a double
text = get(hObject,'String');
SemiColons = strfind(text,':');
if(length(SemiColons) ~= 2)
    uiwait(msgbox(['Invalid frequency array specification! Format should'...
        ' be: [Low Freq : Bin Size : High Freq]. Restoring default...'],'Attention!','error'));
    handles.settings.modules.smr.psd.freqs  = [4:2:48];
    set(hObject,'String','4:2:48');
else
    
    if(isnan(str2double(text(1:SemiColons(1)-1))) || ...
            isnan(str2double(text(SemiColons(1)+1:SemiColons(2)-1))) || ... 
        isnan(str2double(text(SemiColons(2)+1:end))))
    
        uiwait(msgbox(['Invalid frequency array specification! Format should'...
        ' be: [Low Freq : Bin Size : High Freq]. Restoring default...'],'Attention!','error'));
        handles.settings.modules.smr.psd.freqs  = [4:2:48];
        set(hObject,'String','4:2:48');
    end
    
    handles.settings.modules.smr.psd.freqs  = ...
        [str2double(text(1:SemiColons(1)-1))...
        :str2double(text(SemiColons(1)+1:SemiColons(2)-1)):...
        str2double(text(SemiColons(2)+1:end))];
end
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function PSD_Freqs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSD_Freqs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Subject_code_Callback(hObject, eventdata, handles)
% hObject    handle to Subject_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Subject_code as text
%        str2double(get(hObject,'String')) returns contents of Subject_code as a double
if(isempty(get(hObject,'String')) || (~isnan(str2double(get(hObject,'String')))))
    uiwait(msgbox('Subject code should be alphanumeric and not empty!','Attention!','error'));
    handles.settings.info.subject = 'unknown';
    set(hObject,'String','unknown');
else
    handles.settings.info.subject = get(hObject,'String');
end
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function Subject_code_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Subject_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Prep_DC.
function Prep_DC_Callback(hObject, eventdata, handles)
% hObject    handle to Prep_DC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Prep_DC
Val = get(hObject,'Value');
if(Val == 0)
    handles.settings.modules.smr.options.prep.dc = 0;
else
    handles.settings.modules.smr.options.prep.dc = 1;
end
guidata(gcf,handles);

% --- Executes on button press in Prep_CAR.
function Prep_CAR_Callback(hObject, eventdata, handles)
% hObject    handle to Prep_CAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Prep_CAR
Val = get(hObject,'Value');
if(Val == 0)
    handles.settings.modules.smr.options.prep.car = 0;
else
    handles.settings.modules.smr.options.prep.car = 1;
end
guidata(gcf,handles);

% --- Executes on button press in Prep_Laplacian.
function Prep_Laplacian_Callback(hObject, eventdata, handles)
% hObject    handle to Prep_Laplacian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Prep_Laplacian
Val = get(hObject,'Value');
if(Val == 0)
    handles.settings.modules.smr.options.prep.laplacian = 0;
    set(handles.Lbl_Montage,'Enable','off');
    set(handles.Montage_File,'Enable','off');
    set(handles.Ld_Montage,'Enable','off');
else
    handles.settings.modules.smr.options.prep.laplacian = 1;
    set(handles.Lbl_Montage,'Enable','on');
    set(handles.Montage_File,'Enable','on');
    set(handles.Ld_Montage,'Enable','on');
end
guidata(gcf,handles);


function EEG_Fs_Callback(hObject, eventdata, handles)
% hObject    handle to EEG_Fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EEG_Fs as text
%        str2double(get(hObject,'String')) returns contents of EEG_Fs as a
%        double
if(~isempty(get(hObject,'String')) && ~isnan(str2double(get(hObject,'String'))) && ...
        str2double(get(hObject,'String')) > 0 )

        handles.settings.acq.sf  = str2double(get(hObject,'String'));
else
    uiwait(msgbox('Sampling frequency should be a positive integer (in Hz)!','Attention!','error'));
    set(hObject,'String','512');
    handles.settings.acq.sf  = 512;
end
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function EEG_Fs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EEG_Fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EEG_Channels_Callback(hObject, eventdata, handles)
% hObject    handle to EEG_Channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EEG_Channels as text
%        str2double(get(hObject,'String')) returns contents of EEG_Channels
%        as a double
if(~isempty(get(hObject,'String')) && ~isnan(str2double(get(hObject,'String'))) && ...
        str2double(get(hObject,'String')) > 0)

        handles.settings.acq.channels_eeg  = str2double(get(hObject,'String'));
else
    uiwait(msgbox('Number of channels should be a positive integer!','Attention!','error'));
    set(hObject,'String','16');
    handles.settings.acq.channels_eeg  = 16;
end
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function EEG_Channels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EEG_Channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Btn_DefaultSettings.
function Btn_DefaultSettings_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_DefaultSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
settings = eegc3_newsettings();
settings = eegc3_smr_newsettings(settings);
handles.settings = settings;
set(handles.Subject_code,'String','unknown');
set(handles.Feat_Win,'String','1');
set(handles.Feat_Win_Shift,'String','0.0625');
set(handles.PSD_Win,'String','0.5');
set(handles.PSD_Overlap,'String','0.5');
set(handles.PSD_Freqs,'String','4:2:48');
set(handles.Prep_DC,'Value',1);
set(handles.Prep_CAR,'Value',0);
set(handles.Prep_Laplacian,'Value',1);
set(handles.EEG_Fs,'String','512');
set(handles.EEG_Channels,'String','16');
set(handles.Montage_File,'String','gTec16.mat');
set(handles.Lbl_Montage,'Enable','on');
set(handles.Montage_File,'Enable','on');
set(handles.Ld_Montage,'Enable','on');
guidata(gcf,handles);


function Montage_File_Callback(hObject, eventdata, handles)
% hObject    handle to Montage_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Montage_File as text
%        str2double(get(hObject,'String')) returns contents of Montage_File as a double


% --- Executes during object creation, after setting all properties.
function Montage_File_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Montage_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Ld_Montage.
function Ld_Montage_Callback(hObject, eventdata, handles)
% hObject    handle to Ld_Montage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.settings.modules.smr.montage handles.settings.modules.smr.laplacian ...
    SelectedFileName] = eegc3_gui_montage();

set(handles.Montage_File,'String',SelectedFileName);


% --- Executes on button press in Btn_Classify.
function Btn_Classify_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_Classify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Basic checks before closing the GUI and proceeding with training
if(isempty(handles.SelectedPaths))
    msg = 'No runs were selected for training! Please select training runs.';
    disp(msg);
    uiwait(msgbox(msg,'Attention!','error'));
    return;
end

% Warn that only features will be computed
isEnabled = false;
for i=1:5
    if(handles.Classifier{i}.Enable)
        isEnabled = true;
    end
end


if(~isEnabled)
    msg = 'No classifier type has been selected! Do you want to simply extract PSD features of the selected runs?';
    disp(msg);
    button_name = questdlg(msg,'Warning!','Yes','No','Yes');
    if(strcmp(button_name,'No'))
        return;
    end
end

if(strcmp(handles.settings.info.subject,'unknown'))
    msg = 'It seems you have not selected a valid subject code. Do you want to train classifier(s) for unknown?';
    disp(msg);
    button_name = questdlg(msg,'Warning!','Yes','No','Yes');
    if(strcmp(button_name,'No'))
        return;
    end
end

guidata(gcf,handles);
uiresume(gcf)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% In case the close is pressed, return dummy outputs

handles.SelectedPaths = {};
setts = eegc3_newsettings();
handles.settings = eegc3_smr_newsettings(setts);
handles.Classifier = {};
guidata(gcf, handles);
uiresume(gcf);


% --- Executes on button press in UseDlg.
function UseDlg_Callback(hObject, eventdata, handles)
% hObject    handle to UseDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseDlg
Val = get(hObject,'Value');
if(Val == 0)
    handles.usedlg = false;
else
    handles.usedlg = true;
end
guidata(gcf,handles);

% --- Executes on button press in SelectGUI.
function SelectGUI_Callback(hObject, eventdata, handles)
% hObject    handle to SelectGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectGUI
Val = get(hObject,'Value');
if(Val == 0)
    handles.settings.modules.smr.options.selection.usegui = 0;
else
    handles.settings.modules.smr.options.selection.usegui = 1;
end
guidata(gcf,handles);


% --- Executes on button press in EnableSettings.
function EnableSettings_Callback(hObject, eventdata, handles)
% hObject    handle to EnableSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EnableSettings
Val = get(hObject,'Value');
if(Val == 0)
    set(handles.FeaturePanel,'Visible','off');
else
    set(handles.FeaturePanel,'Visible','on');
end
guidata(gcf,handles);


% --- Executes on button press in OnlyTrials.
function OnlyTrials_Callback(hObject, eventdata, handles)
% hObject    handle to OnlyTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OnlyTrials
Val = get(hObject,'Value');
if(Val == 0)
    handles.settings.modules.smr.options.extraction.trials = 0;
else
    handles.settings.modules.smr.options.extraction.trials = 1;
end
guidata(gcf,handles);


% --- Executes on button press in FastTrain.
function FastTrain_Callback(hObject, eventdata, handles)
% hObject    handle to FastTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FastTrain
Val = get(hObject,'Value');
if(Val == 0)
    handles.settings.modules.smr.options.extraction.fast = 0;
    set(handles.OnlyTrials, 'Enable','on');
else
    handles.settings.modules.smr.options.extraction.fast = 1;
    set(handles.OnlyTrials, 'Enable','off');
end
guidata(gcf,handles);

% --- Executes on button press in FastTrain.
function WP4CheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to FastTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FastTrain
Val = get(hObject,'Value');
if(Val == 0)
    handles.settings.modules.wp4.datatype = 0;
else
    handles.settings.modules.wp4.datatype = 1;
end
guidata(gcf,handles);


% --- Executes on button press in LdClassRHRST.
function LdClassRHRST_Callback(hObject, eventdata, handles)
% hObject    handle to LdClassRHRST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LdClassLHRST.
function LdClassLHRST_Callback(hObject, eventdata, handles)
% hObject    handle to LdClassLHRST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
