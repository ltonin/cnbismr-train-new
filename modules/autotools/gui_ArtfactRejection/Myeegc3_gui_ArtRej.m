function varargout = Myeegc3_gui_ArtRej(varargin)
% MYEEGC3_GUI_ARTREJ MATLAB code for Myeegc3_gui_ArtRej.fig
%      MYEEGC3_GUI_ARTREJ, by itself, creates a new MYEEGC3_GUI_ARTREJ or raises the existing
%      singleton*.
%
%      H = MYEEGC3_GUI_ARTREJ returns the handle to a new MYEEGC3_GUI_ARTREJ or the handle to
%      the existing singleton*.
%
%      MYEEGC3_GUI_ARTREJ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYEEGC3_GUI_ARTREJ.M with the given input arguments.
%
%      MYEEGC3_GUI_ARTREJ('Property','Value',...) creates a new MYEEGC3_GUI_ARTREJ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Myeegc3_gui_ArtRej_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Myeegc3_gui_ArtRej_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Myeegc3_gui_ArtRej

% Last Modified by GUIDE v2.5 19-Dec-2012 10:08:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Myeegc3_gui_ArtRej_OpeningFcn, ...
                   'gui_OutputFcn',  @Myeegc3_gui_ArtRej_OutputFcn, ...
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


% --- Executes just before Myeegc3_gui_ArtRej is made visible.
function Myeegc3_gui_ArtRej_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Myeegc3_gui_ArtRej (see VARARGIN)

% Choose default command line output for Myeegc3_gui_Main
handles.output = hObject;

% Get inputs
handles.data = varargin{1};

handles.variance = 0;
handles.meanOfVariance = 0;

% Initialize response values
handles.response.reject = 0;
handles.response.interpolate = 0;

% Initialize outputs (no action)
handles.data_New = handles.data;
handles.data_Curr = handles.data;
handles.rej_Trial = 0;
handles.interpol_Chan = 0;
handles.susp_Trial = 0;
handles.susp_Chan = 0;
handles.rej_Trial = 0;
handles.interpol_Chan = 0;
handles.statistics = 0;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes Myeegc3_gui_Main wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = Myeegc3_gui_ArtRej_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.data_New;
varargout{2} = handles.output;

delete(handles.figure1);


% --- Executes on button press in reject.
function reject_Callback(hObject, eventdata, handles)
% hObject    handle to reject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Store response
handles.response.reject = get(hObject,'Value');

% Perform trial rejection
[data_New, rej_Trial] = Myeegc3_DiscardTrials(handles.data_Curr, handles.susp_Trial);

% Store results
handles.data_Curr = data_New;
handles.data_New = data_New;
handles.rej_Trial = rej_Trial;

[handles.variance, handles.meanOfVariance] = Myeegc3_Variance(handles.data_Curr);

[susp_Trial, susp_Chan, statistics] = Myeegc3_JudgeVariance(handles.data_Curr, handles.variance, handles.meanOfVariance, handles.thresholds);

% Store results
handles.susp_Trial = susp_Trial;
handles.susp_Chan = susp_Chan;
handles.statistics = statistics;

% Show results on the text boxes
sChan = cell(1,size(handles.susp_Trial,2));
sTrial = cell(1,size(handles.susp_Trial,2));

toShow_Chan = [];
toShow_Trial = [];

for i = 1:size(handles.susp_Trial,2)
    indChan = find(handles.susp_Chan{i} == 1);
    sChan{i} = {['Run ' num2str(i) ': ' num2str(indChan)]};
    
    indTrial = find(handles.susp_Trial{i} == 1);
    sTrial{i} = {['Run ' num2str(i) ': ' num2str(indTrial)]};
    
    toShow_Chan = [toShow_Chan ; sChan{i}];
    toShow_Trial = [toShow_Trial ; sTrial{i}];
end

set(handles.suspChan, 'String', toShow_Chan);
set(handles.suspTrial, 'String', toShow_Trial);

% Plot results
plotting1(hObject, handles); 
plotting2(hObject, handles);

guidata(hObject, handles)

% --- Executes on button press in interpolate.
function interpolate_Callback(hObject, eventdata, handles)
% hObject    handle to interpolate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.response.interpolate = get(hObject,'Value');

%%%% UNCOMMENT WHEN Myeegc3_InterpolateChan READY !!!
% % % Perform channel interpolation
% % [data_New, interpol_Chan] = Myeegc3_InterpolateChan(handles.data_Curr, handles.susp_Chan);
% % 
% % % Store results
% % handles.data_Curr = data_New;
% % handles.data_New = data_New;
% % handles.interpol_Chan = interpol_Chan;
% % 
% % [handles.variance, handles.meanOfVariance] = Myeegc3_Variance(handles.data_Curr);
% % 
% % [susp_Trial, susp_Chan, statistics] = Myeegc3_JudgeVariance(handles.data_Curr, handles.variance, handles.meanOfVariance, handles.thresholds);
% % 
% % % Store results
% % handles.susp_Trial = susp_Trial;
% % handles.susp_Chan = susp_Chan;
% % handles.statistics = statistics;
% % 
% % % Show results on the text boxes
% % sChan = cell(1,size(handles.susp_Trial,2));
% % sTrial = cell(1,size(handles.susp_Trial,2));
% % 
% % toShow_Chan = [];
% % toShow_Trial = [];
% %
% % for i = 1:size(handles.susp_Trial,2)
% %     indChan = find(handles.susp_Chan{i} == 1);
% %     sChan{i} = {['Run ' num2str(i) ': ' num2str(indChan)]};
% %     
% %     indTrial = find(handles.susp_Trial{i} == 1);
% %     sTrial{i} = {['Run ' num2str(i) ': ' num2str(indTrial)]};
% %     
% %     toShow_Chan = [toShow_Chan ; sChan{i}];
% %     toShow_Trial = [toShow_Trial ; sTrial{i}];
% % end
% % 
% % set(handles.suspChan, 'String', toShow_Chan);
% % set(handles.suspTrial, 'String', toShow_Trial);
% % 
% % % Plot results
% % plotting1(hObject, handles); 
% % plotting2(hObject, handles);

guidata(hObject, handles)


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Store output
handles.output.thresholds = handles.thresholds;
handles.output.susp_Trial = handles.susp_Trial;
handles.output.susp_Chan = handles.susp_Chan;
handles.output.statistics = handles.statistics;
handles.output.rej_Trial = handles.rej_Trial;
handles.output.interpol_Chan = handles.interpol_Chan;
handles.output.response = handles.response;
handles.output.variance = variance;
handles.output.meanOfVariance = handles.meanOfVariance;

guidata(hObject, handles);  

uiresume(handles.figure1);

% --- Executes on button press in resetDataset.
function resetDataset_Callback(hObject, eventdata, handles)
% hObject    handle to resetDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data_Curr = handles.data;
handles.data_New = handles.data;
handles.rej_Trial = 0;
handles.interpol_Chan = 0;
handles.response.reject = 0;
handles.response.interpolate = 0;

[handles.variance, handles.meanOfVariance] = Myeegc3_Variance(handles.data_Curr);

[susp_Trial, susp_Chan, statistics] = Myeegc3_JudgeVariance(handles.data_Curr, handles.variance, handles.meanOfVariance, handles.thresholds);

% Store results
handles.susp_Trial = susp_Trial;
handles.susp_Chan = susp_Chan;
handles.statistics = statistics;

% Show results on the text boxes
sChan = cell(1,size(handles.susp_Trial,2));
sTrial = cell(1,size(handles.susp_Trial,2));

toShow_Chan = [];
toShow_Trial = [];

for i = 1:size(handles.susp_Trial,2)
    indChan = find(handles.susp_Chan{i} == 1);
    sChan{i} = {['Run ' num2str(i) ': ' num2str(indChan)]};
    
    indTrial = find(handles.susp_Trial{i} == 1);
    sTrial{i} = {['Run ' num2str(i) ': ' num2str(indTrial)]};
    
    toShow_Chan = [toShow_Chan ; sChan{i}];
    toShow_Trial = [toShow_Trial ; sTrial{i}];
end

set(handles.suspChan, 'String', toShow_Chan);
set(handles.suspTrial, 'String', toShow_Trial);

% Plot results
plotting1(hObject, handles); 
plotting2(hObject, handles);

guidata(hObject,handles)


function thres_Trial_Callback(hObject, eventdata, handles)
% hObject    handle to thres_Trial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thres_Trial as text
%        str2double(get(hObject,'String')) returns contents of thres_Trial as a double
var = str2double(get(hObject, 'String'));
if isnan(var)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save new value
handles.thresholds.thres_Trial = var;

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function thres_Trial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thres_Trial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thres_Chan_Callback(hObject, eventdata, handles)
% hObject    handle to thres_Chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thres_Chan as text
%        str2double(get(hObject,'String')) returns contents of thres_Chan as a double
var = str2double(get(hObject, 'String'));
if isnan(var)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save new value
handles.thresholds.thres_Chan = var;

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function thres_Chan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thres_Chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxChan_Callback(hObject, eventdata, handles)
% hObject    handle to maxChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxChan as text
%        str2double(get(hObject,'String')) returns contents of maxChan as a double
num = str2double(get(hObject, 'String'));
if isnan(num)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save new value
handles.thresholds.maxChan = num;

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function maxChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in default.
function default_Callback(hObject, eventdata, handles)
% hObject    handle to default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
initialize_gui(gcbf, handles, true);

% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)
% hObject    handle to go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[handles.variance, handles.meanOfVariance] = Myeegc3_Variance(handles.data_Curr);

[susp_Trial, susp_Chan, statistics] = Myeegc3_JudgeVariance(handles.data_Curr, handles.variance, handles.meanOfVariance, handles.thresholds);

% Store results
handles.susp_Trial = susp_Trial;
handles.susp_Chan = susp_Chan;
handles.statistics = statistics;

% Show results on the text boxes
sChan = cell(1,size(handles.susp_Trial,2));
sTrial = cell(1,size(handles.susp_Trial,2));

toShow_Chan = [];
toShow_Trial = [];

for i = 1:size(handles.susp_Trial,2)
    indChan = find(handles.susp_Chan{i} == 1);
    sChan{i} = {['Run ' num2str(i) ': ' num2str(indChan)]};
    
    indTrial = find(handles.susp_Trial{i} == 1);
    sTrial{i} = {['Run ' num2str(i) ': ' num2str(indTrial)]};
    
    toShow_Chan = [toShow_Chan ; sChan{i}];
    toShow_Trial = [toShow_Trial ; sTrial{i}];
end

set(handles.suspChan, 'String', toShow_Chan);
set(handles.suspTrial, 'String', toShow_Trial);

% Plot results
plotting1(hObject, handles); 
plotting2(hObject, handles);

guidata(hObject,handles)


function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.

if isfield(handles, 'thresholds') && ~isreset
    return;
end

% Set the default thresholds (uncomment the one you want: always same or changing according to dataset?)
[handles.variance, handles.meanOfVariance] = Myeegc3_Variance(handles.data_Curr);
 
handles.thresholds.thres_Trial = 2*max(handles.meanOfVariance{1,1});
handles.thresholds.thres_Chan  = 2*max(handles.meanOfVariance{1,1});
% handles.thresholds.thres_Trial = 800;
% handles.thresholds.thres_Chan  = 800;

handles.thresholds.maxChan = 3;

set(handles.thres_Trial, 'String', handles.thresholds.thres_Trial);
set(handles.thres_Chan,  'String', handles.thresholds.thres_Chan);
set(handles.maxChan, 'String', handles.thresholds.maxChan);

% Update handles structure
guidata(handles.figure1, handles);


% Plots of first row of GUI (Number of Suspected Channels vs. Trials)
function plotting1(fighandle, handles) 

ax(1) = handles.axes1;
ax(2) = handles.axes3;
ax(3) = handles.axes5;
ax(4) = handles.axes7;

for i = 1:4
    axes(ax(i));
    cla;
    trials = 1:length(handles.statistics{1,i}.numSuspChanPerTrial);
    scatter(trials,handles.statistics{1,i}.numSuspChanPerTrial, 'filled');
    hold on;
    %axis([0 length(handles.statistics{i}.numSuspChanPerTrial) 0 16]);
    grid on
    xlabel('Trial Number');
    ylabel('Number of Suspected Channels');
end

% Plots of second row of GUI (Number of Suspected Trials vs. Channels)
function plotting2(fighandle, handles)

ax(1) = handles.axes2;
ax(2) = handles.axes4;
ax(3) = handles.axes6;
ax(4) = handles.axes8;

for i = 1:4
    axes(ax(i));
    cla;
    channels = 1:length(handles.statistics{1,i}.numSuspTrialPerChan);
    scatter(channels,handles.statistics{1,i}.numSuspTrialPerChan, 'filled');
    hold on;
    grid on
    xlabel('Channel Number');
    ylabel('Number of Suspected Trials');
end
