function varargout = Mandelbrot_GUI(varargin)
% MANDELBROT_GUI M-file for Mandelbrot_GUI.fig
%      MANDELBROT_GUI, by itself, creates a new MANDELBROT_GUI or raises the existing
%      singleton*.
%
%      H = MANDELBROT_GUI returns the handle to a new MANDELBROT_GUI or the handle to
%      the existing singleton*.
%
%      MANDELBROT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANDELBROT_GUI.M with the given input arguments.
%
%      MANDELBROT_GUI('Property','Value',...) creates a new MANDELBROT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Mandelbrot_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Mandelbrot_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Mandelbrot_GUI

% Last Modified by GUIDE v2.5 28-Apr-2015 14:10:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Mandelbrot_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Mandelbrot_GUI_OutputFcn, ...
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


% --- Executes just before Mandelbrot_GUI is made visible.
function Mandelbrot_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Mandelbrot_GUI (see VARARGIN)

% Choose default command line output for Mandelbrot_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Mandelbrot_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(handles.conjugate,'value',0)
set(handles.mandelbrot,'value',1)
set(handles.julia,'value',0)

% --- Outputs from this function are returned to the command line.
function varargout = Mandelbrot_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- MANDELBROT FORMULA ---
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Init')
tic;
x_min=str2double(get(handles.xMin,'String'));
x_max=str2double(get(handles.xMax,'String'));
x_step=str2double(get(handles.step,'String'));

y_min=str2double(get(handles.yMin,'String'));
y_max=str2double(get(handles.yMax,'String'));
y_step=str2double(get(handles.step,'String'));

x=x_min:x_step:x_max;
y=y_min:y_step:y_max;
[X, Y]=meshgrid(x,y);
Z=X+Y.*1i;
cX = str2double(get(handles.cX,'String'));
cY = str2double(get(handles.cY,'String'));
conjugate = get(handles.conjugate,'Value');

toc;

disp('Calc')
tic;


if get(handles.mandelbrot,'value')==1
    C=cX.*X+cY.*Y.*1i;
else
    C=cX+cY*1i;
end

index=str2double(get(handles.index,'string'));
iterations=str2double(get(handles.iterations,'string'));
progressStep=1/iterations;
h=waitbar(0,'Please wait...');
progress=0;
toc;

disp('Iter')
tic;
for j=1:iterations
    if conjugate==1
        % http://de.mathworks.com/help/matlab/ref/conj.html
        Z=conj(Z.^index+C);
    else
        Z=Z.^index+C;
    end
    % progress for label and waitbar
    progress=progress+progressStep;
    waitbar(progress, h, strcat('',num2str(j),{' of '},num2str(iterations),{' iterations done'}));
end
waitbar(progress, h, 'Rendering image');
close(h)
cla;
toc;

disp('Image')
tic;
% im_Z=zeros(size(Z));
% AA=size(Z);
MAG_Z=abs(Z);
MAG_Z(MAG_Z<=2)=1;
MAG_Z(MAG_Z>2)=2;
MAG_Z(isnan(MAG_Z))=0;
fig=pcolor(MAG_Z);
set(fig,'edgecolor','none')
colormap([0 0 0; 0 0 0; 1 1 1])
toc;

axis equal
% x_lim = (abs(x_min)+abs(x_max))/x_step;
% y_lim = (abs(y_min)+abs(y_max))/y_step;
% xlim([0 x_lim])
% ylim([0 y_lim])


function iterations_Callback(hObject, eventdata, handles)
% hObject    handle to iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iterations as text
%        str2double(get(hObject,'String')) returns contents of iterations as a double


% --- Executes during object creation, after setting all properties.
function iterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function index_Callback(hObject, eventdata, handles)
% hObject    handle to index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of index as text
%        str2double(get(hObject,'String')) returns contents of index as a double


% --- Executes during object creation, after setting all properties.
function index_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function xMin_Callback(hObject, eventdata, handles)
% hObject    handle to xMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xMin as text
%        str2double(get(hObject,'String')) returns contents of xMin as a double


% --- Executes during object creation, after setting all properties.
function xMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xMax_Callback(hObject, eventdata, handles)
% hObject    handle to xMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xMax as text
%        str2double(get(hObject,'String')) returns contents of xMax as a double


% --- Executes during object creation, after setting all properties.
function xMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yMin_Callback(hObject, eventdata, handles)
% hObject    handle to yMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yMin as text
%        str2double(get(hObject,'String')) returns contents of yMin as a double


% --- Executes during object creation, after setting all properties.
function yMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yMax_Callback(hObject, eventdata, handles)
% hObject    handle to yMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yMax as text
%        str2double(get(hObject,'String')) returns contents of yMax as a double


% --- Executes during object creation, after setting all properties.
function yMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in conjugate.
function conjugate_Callback(hObject, eventdata, handles)
% hObject    handle to conjugate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of conjugate


function cX_Callback(hObject, eventdata, handles)
% hObject    handle to cX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cX as text
%        str2double(get(hObject,'String')) returns contents of cX as a double


% --- Executes during object creation, after setting all properties.
function cX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cY_Callback(hObject, eventdata, handles)
% hObject    handle to cY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cY as text
%        str2double(get(hObject,'String')) returns contents of cY as a double


% --- Executes during object creation, after setting all properties.
function cY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function step_Callback(hObject, eventdata, handles)
% hObject    handle to step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of step as text
%        str2double(get(hObject,'String')) returns contents of step as a double


% --- Executes during object creation, after setting all properties.
function step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mandelbrot.
function mandelbrot_Callback(hObject, eventdata, handles)
% hObject    handle to mandelbrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mandelbrot
set(handles.mandelbrot,'value',1)
set(handles.julia,'value',0)

% --- Executes on button press in julia.
function julia_Callback(hObject, eventdata, handles)
% hObject    handle to julia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of julia
set(handles.julia,'value',1)
set(handles.mandelbrot,'value',0)
