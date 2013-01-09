function varargout = Myeegc3_gui_1(varargin)
% MYEEGC3_GUI_1 M-file for Myeegc3_gui_1.fig
%      MYEEGC3_GUI_1, by itself, creates a new MYEEGC3_GUI_1 or raises the existing
%      singleton*.
%
%      H = MYEEGC3_GUI_1 returns the handle to a new MYEEGC3_GUI_1 or the handle to
%      the existing singleton*.
%
%      MYEEGC3_GUI_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYEEGC3_GUI_1.M with the given input arguments.
%
%      MYEEGC3_GUI_1('Property','Value',...) creates a new MYEEGC3_GUI_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Myeegc3_gui_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Myeegc3_gui_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Myeegc3_gui_1

% Last Modified by GUIDE v2.5 12-Dec-2012 14:29:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Myeegc3_gui_1_OpeningFcn, ...
                   'gui_OutputFcn',  @Myeegc3_gui_1_OutputFcn, ...
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


% --- Executes just before Myeegc3_gui_1 is made visible.
function Myeegc3_gui_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has radiobutton2 output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Myeegc3_gui_1 (see VARARGIN)

% Choose default command line output for Myeegc3_gui_1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Myeegc3_gui_1 wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Myeegc3_gui_1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(handles.figure1);



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% switch get(get(handles.uipanel1,'SelectedObject'),'Tag')
%     case 'radiobutton1', output = 1;
%     case 'radiobutton2', output = 0;
% end
% handles.userResp = output;
handles.output = handles.res;

guidata(hObject, handles);

uiresume(handles.figure1);
% close(handles.figure1);


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton1' 
        handles.res = 1;
    case 'radiobutton2'
        handles.res = 0;
end
guidata(hObject,handles);

% 
% 
% 
% function figure1_CloseRequestFcn(hObject, eventdata, handles)
% % hObject    handle to figure1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% if isequal(get(hObject, 'waitstatus'), 'waiting')
%     % The GUI is still in UIWAIT, us UIRESUME
%     uiresume(hObject);
% else
%     % The GUI is no longer waiting, just close it
%     handles.res = 0;
%     handles.output = handles.res;
%     guidata(hObject,handles);
%     delete(gcbf);
% end
