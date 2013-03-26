function varargout = eegc3_gui_initclass(varargin)
% EEGC3_GUI_INITCLASS M-file for eegc3_gui_initclass.fig
%      EEGC3_GUI_INITCLASS, by itself, creates a new EEGC3_GUI_INITCLASS or raises the existing
%      singleton*.
%
%      H = EEGC3_GUI_INITCLASS returns the handle to a new EEGC3_GUI_INITCLASS or the handle to
%      the existing singleton*.
%
%      EEGC3_GUI_INITCLASS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EEGC3_GUI_INITCLASS.M with the given input arguments.
%
%      EEGC3_GUI_INITCLASS('Property','Value',...) creates a new EEGC3_GUI_INITCLASS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eegc3_gui_initclass_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eegc3_gui_initclass_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eegc3_gui_initclass

% Last Modified by GUIDE v2.5 26-Mar-2013 11:34:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eegc3_gui_initclass_OpeningFcn, ...
                   'gui_OutputFcn',  @eegc3_gui_initclass_OutputFcn, ...
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


% --- Executes just before eegc3_gui_initclass is made visible.
function eegc3_gui_initclass_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eegc3_gui_initclass (see VARARGIN)

% Choose default command line output for eegc3_gui_initclass
handles.output = hObject;

dir = pwd;
% Populate the listbox
handles = load_listbox(dir, handles);

handles.SelectedPath = [];
handles.SelectedFileName = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eegc3_gui_initclass wait for user response (see UIRESUME)
uiwait(handles.figure1);


% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------
function mod_handles = load_listbox(path, handles)
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
set(handles.BrowseList,'String',handles.file_names,...
	'Value',1)
mod_handles = handles;



% --- Outputs from this function are returned to the command line.
function varargout = eegc3_gui_initclass_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.SelectedPath;
varargout{2} = handles.SelectedFileName;
delete(handles.figure1);


% --- Executes on selection change in BrowseList.
function BrowseList_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BrowseList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BrowseList
index_selected = get(handles.BrowseList,'Value');
file_list = get(handles.BrowseList,'String');
filename = file_list{index_selected};
if  handles.is_dir(handles.sorted_index(index_selected))
    cd (filename)
    handles = load_listbox(pwd,handles);
else
    [path,name,ext] = fileparts(filename);
    if(strcmp(ext,'.mat'))
        
        % Edit the "selected" list
        file_path = [pwd filesep filename];
        handles.SelectedPath = file_path;
        handles.SelectedFileName = filename;
        set(handles.SelectedFile,'String',filename);
    end
        
end
 guidata(gcf, handles);



% --- Executes during object creation, after setting all properties.
function BrowseList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BrowseList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OK_Btn.
function OK_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to OK_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load and check that the MAT file is a valid one ('analysis or settings')
if(~isempty(handles.SelectedPath))
    tmp = load(handles.SelectedPath);
    if(~isfield(tmp,'analysis') && ~isfield(tmp,'settings'))
        handles.SelectedPath = [];
        handles.SelectedFileName = [];
        set(handles.SelectedFile,'String','None');
        guidata(gcf,handles);
        msg = 'The selected MAT file does not seem to be a valid CNBI classifier file...';
        disp(msg);
        uiwait(msgbox(msg,'Icon','error'));
        clear tmp;
    end
else
    msg = 'No classifier was selected! Training will begin from scratch!';
    disp(msg);
    uiwait(msgbox(msg,'Icon','warn'));
end

guidata(gcf,handles);
uiresume(handles.figure1);
