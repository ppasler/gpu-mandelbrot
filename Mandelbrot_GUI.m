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

% Last Modified by GUIDE v2.5 20-May-2015 12:06:26

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
    set(handles.mandelbrot,'value',1)
    set(handles.julia,'value',0)
    set(handles.styleComputationCpu,'value',1);
    set(handles.styleComputationGpu1,'value',0);
    set(handles.styleComputationGpu2,'value',0);
    set(handles.styleComputationGpu3,'value',0);

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

% use simple gpuArray
if(get(handles.styleComputationGpu1,'value') == 1)
    calculator = GPUCalculator(handles);
    methodString = 'simple GPU';
    
% use array fun
elseif(get(handles.styleComputationGpu2,'value') == 1)
    calculator = GPUArrayFunCalculator(handles);
    methodString = 'ArrayFun GPU';

% use CUDA
elseif(get(handles.styleComputationGpu3,'value') == 1)
    calculator = CUDACalculator(handles);
    methodString = 'CUDA';
    
% use simple 
else
    calculator = CPUCalculator(handles);
    methodString = 'simple CPU';
end

iterations = str2double(get(handles.iterations,'string'));

t = tic();  % START CALCULATION %
count = calc(calculator, iterations);
calcTime = toc(t);

setName = 'mandebrot';
if(get(handles.mandelbrot,'value') == 0)
    setName = 'julia';
end

fprintf( '%1.2f secs for calculating %s set with %s\n', calcTime, setName, methodString);
% END CALCULATION %

renderImage(count, 1, handles); % image rendering of 


% function for image rendedering
function[] = renderImage(count, style, handles)
    % START IMAGE RENDERING%
    %handles.plotImage; %select plotImage as current plot
    count = log( count );
    imagesc( count );
    %handles.plotImage.imagesc(count);
    
    % --- testing section
    %handles.plotImage(Visible, 'on');
    %set(handles.plotImage,'XDataSource', 'x');
    
    % coloring of the image with different styles
    % jet color vector
    if get(handles.styleDrawingJet,'Value')
            map = colormap([jet();flipud( jet() );0 0 0]); 
    elseif get(handles.styleDrawingHsv,'Value') %hsv color vector
            map = colormap([hsv();flipud( hsv() );0 0 0]);
    end
    %imwrite(count, 'img.png', 'png');
    % END IMAGE RENDERING% 
    
    
%% GUI element functions/callbacks
%--------------------------------------
%--------------------------------------

function iterations_Callback(hObject, eventdata, handles)

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


function cX_Callback(hObject, eventdata, handles)

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


% --- Executes on button press in styleComputationCpu.
function styleComputationCpu_Callback(hObject, eventdata, handles)
% hObject    handle to styleComputationCpu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleComputationCpu
set(handles.styleComputationCpu,'value',1);
set(handles.styleComputationGpu1,'value',0);
set(handles.styleComputationGpu2,'value',0);
set(handles.styleComputationGpu3,'value',0);
set(handles.styleComputationAll,'value',0);


% --- Executes on button press in styleComputationGpu1.
function styleComputationGpu1_Callback(hObject, eventdata, handles)
% hObject    handle to styleComputationGpu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleComputationGpu1
set(handles.styleComputationCpu,'value',0);
set(handles.styleComputationGpu1,'value',1);
set(handles.styleComputationGpu2,'value',0);
set(handles.styleComputationGpu3,'value',0);
set(handles.styleComputationAll,'value',0);


% --- Executes on button press in styleComputationGpu2.
function styleComputationGpu2_Callback(hObject, eventdata, handles)
% hObject    handle to styleComputationGpu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleComputationGpu2
set(handles.styleComputationCpu,'value',0);
set(handles.styleComputationGpu1,'value',0);
set(handles.styleComputationGpu2,'value',1);
set(handles.styleComputationGpu3,'value',0);
set(handles.styleComputationAll,'value',0);


% --- Executes on button press in styleComputationGpu3.
function styleComputationGpu3_Callback(hObject, eventdata, handles)
% hObject    handle to styleComputationGpu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleComputationGpu3
set(handles.styleComputationCpu,'value',0);
set(handles.styleComputationGpu1,'value',0);
set(handles.styleComputationGpu2,'value',0);
set(handles.styleComputationGpu3,'value',1);
set(handles.styleComputationAll,'value',0);


% --- Executes on button press in styleComputationAll.
function styleComputationAll_Callback(hObject, eventdata, handles)
% hObject    handle to styleComputationAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleComputationAll
set(handles.styleComputationCpu,'value',0);
set(handles.styleComputationGpu1,'value',0);
set(handles.styleComputationGpu2,'value',0);
set(handles.styleComputationGpu3,'value',0);
set(handles.styleComputationAll,'value',1);


% --- Executes on button press in styleDrawingJet.
function styleDrawingJet_Callback(hObject, eventdata, handles)
% hObject    handle to styleDrawingJet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleDrawingJet

set(handles.styleDrawingJet,'value',1);
set(handles.styleDrawingHsv,'value',0);

% --- Executes on button press in styleDrawingHsv.
function styleDrawingHsv_Callback(hObject, eventdata, handles)
% hObject    handle to styleDrawingHsv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleDrawingHsv

set(handles.styleDrawingJet,'value',0);
set(handles.styleDrawingHsv,'value',1);
