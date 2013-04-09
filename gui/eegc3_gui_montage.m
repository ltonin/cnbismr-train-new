function varargout = eegc3_gui_montage(varargin)
% EEGC3_GUI_MONTAGE M-file for eegc3_gui_montage.fig
%      EEGC3_GUI_MONTAGE, by itself, creates a new EEGC3_GUI_MONTAGE or raises the existing
%      singleton*.
%
%      H = EEGC3_GUI_MONTAGE returns the handle to a new EEGC3_GUI_MONTAGE or the handle to
%      the existing singleton*.
%
%      EEGC3_GUI_MONTAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EEGC3_GUI_MONTAGE.M with the given input arguments.
%
%      EEGC3_GUI_MONTAGE('Property','Value',...) creates a new EEGC3_GUI_MONTAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eegc3_gui_montage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eegc3_gui_montage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eegc3_gui_montage

% Last Modified by GUIDE v2.5 26-Jan-2011 18:18:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eegc3_gui_montage_OpeningFcn, ...
                   'gui_OutputFcn',  @eegc3_gui_montage_OutputFcn, ...
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


% --- Executes just before eegc3_gui_montage is made visible.
function eegc3_gui_montage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eegc3_gui_montage (see VARARGIN)

% Choose default command line output for eegc3_gui_montage
handles.output = hObject;

dir = pwd;
% Populate the listbox
handles = load_listbox(dir, handles);

handles.SelectedPath = [];
handles.SelectedFileName = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eegc3_gui_montage wait for user response (see UIRESUME)
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
function varargout = eegc3_gui_montage_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.montage;
varargout{2} = handles.laplacian;
varargout{3} = handles.SelectedFileName;
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

% Check that the montage is a valid one
if(~isempty(handles.SelectedPath))
    tmp_montage = load(handles.SelectedPath);
    if(~isfield(tmp_montage,'montage') || ~isnumeric(tmp_montage.montage))
        handles.SelectedPath = [];
        handles.SelectedFileName = [];
        set(handles.SelectedFile,'String','None');
        msg = 'The selected MAT file does not seem to be a valid CNBI Laplaican montage MAT file...';
        disp(msg);
        uiwait(msgbox(msg,'Icon','error'));
    end
    
    % Second test
    isOK = 0;
    try
        eegc3_montage(tmp_montage.montage);
        disp('Laplacian Montage computed without problems.');
        isOK = 1;
    catch
        disp('Laplacian Montage could not be computed...');
        isOK = 0;
    end
    
    if(~isOK)
        handles.SelectedPath = [];
        handles.SelectedFileName = [];
        set(handles.SelectedFile,'String','None');
        msg = 'The selected MAT file does not seem to be a valid CNBI Laplaican montage MAT file...';
        disp(msg);
        uiwait(msgbox(msg,'Icon','error'));
    end
else
    msg = 'No Laplacian Montage was selected! Default gTec16 will be used';
    disp(msg);
    uiwait(msgbox(msg,'Icon','warn'));
end

% Load the montage and put it in the settings
if(~isempty(handles.SelectedPath))
    handles.montage = tmp_montage.montage;
else
    % Default
    handles.montage = [0 0 1 0 0; ...
           	  		1 1 1 1 1; ...
        			1 1 1 1 1;...
        			1 1 1 1 1];
   handles.SelectedFileName = 'gTec16.mat';
end
handles.laplacian = ...
        eegc3_montage(handles.montage);
    
guidata(gcf,handles);
uiresume(handles.figure1);
