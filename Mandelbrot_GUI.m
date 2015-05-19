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

% Last Modified by GUIDE v2.5 18-May-2015 16:29:46

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

    
% return 2 lists of values from min to max in step
function [xGrid, yGrid] = initGridGPU(handles)
    x_min=str2double(get(handles.xMin,'String'));
    x_max=str2double(get(handles.xMax,'String'));
    x_step=str2double(get(handles.step,'String'));
    x_size = (x_max-x_min) / x_step;
    x=gpuArray.linspace(x_min, x_max, x_size);
    
    y_min=str2double(get(handles.yMin,'String'));
    y_max=str2double(get(handles.yMax,'String'));
    y_step=str2double(get(handles.step,'String'));
    y_size = (y_max-y_min) / y_step;
    y=gpuArray.linspace(y_min, y_max, y_size);
    
    [xGrid, yGrid]=meshgrid(x,y); 
    
% return 2 lists of values from min to max in step
function [xGrid, yGrid] = initGrid(handles)
    x_min=str2double(get(handles.xMin,'String'));
    x_max=str2double(get(handles.xMax,'String'));
    x_step=str2double(get(handles.step,'String'));
    x=x_min:x_step:x_max;
    
    y_min=str2double(get(handles.yMin,'String'));
    y_max=str2double(get(handles.yMax,'String'));
    y_step=str2double(get(handles.step,'String'));
    y=y_min:y_step:y_max;
    
    [xGrid, yGrid]=meshgrid(x,y);


    
function [c] = initC(xGrid, yGrid, handles)
    cX = str2double(get(handles.cX,'String'));
    cY = str2double(get(handles.cY,'String'));
    if get(handles.mandelbrot,'value')==1
        c=cX.*xGrid+cY.*yGrid.*1i;
    else
    	c=cX+cY*1i;
    end

% --- MANDELBROT FORMULA ---
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% prepare tracking of progress
% START INIT %

% initialize variables for calculation
if(get(handles.styleComputationCpu,'value') == 1)
    disp('using cpu');
    [xGrid, yGrid]=initGrid(handles);
elseif(get(handles.styleComputationGpu1,'value') == 1)
    disp('using gpu');
    [xGrid, yGrid]=initGridGPU(handles);
elseif(get(handles.styleComputationGpu2,'value') == 1)
    disp('using arrayFun');
    [xGrid, yGrid]=initGridGPU(handles);
else
    [xGrid, yGrid]=initGrid(handles);
end
    
c=initC(xGrid, yGrid, handles); % init formula
z=xGrid+yGrid.*1i; % init z
count = ones( size(z) );

% get relevant calculation values from GUI
conjugate = get(handles.conjugate,'Value');
index=str2double(get(handles.index,'string'));
iterations=str2double(get(handles.iterations,'string'));

% end and prepare tracking of progress>
progressStep=1/iterations;
h=waitbar(0,'Please wait...');
progress=0;

% END INIT %


disp('Calculation')
tic;  % END CALCULATION %

% use array fun
if(get(handles.styleComputationGpu2,'value') == 1)
    count = arrayfun( @processMandelbrotElement, ...
                  xGrid, yGrid, iterations);
% use 
else    
    % calculate the set with the defined number of iterations
    for j=1:iterations
        % calculate with conjugation, if set
        % more information: http://de.mathworks.com/help/matlab/ref/conj.html
        if conjugate==1
            z=conj(z.^index+c);
        else
            z=z.^index+c;
        end

        inside = abs( z )<=2;
        count = count + inside;

        % track progress for label and waitbar
        progress=progress+progressStep;
        waitbar(progress, h, strcat('',num2str(j),{' of '},num2str(iterations),{' iterations done'}));
    end
end

toc;
waitbar(progress, h, 'Rendering image');
close(h);
cla;
% END ITERATION %

renderImage(count, 1); % image rendering of 


% function for image rendedering
function[] = renderImage(count, style)
    % START IMAGE RENDERING%

    count = log( count );
    imagesc( count );
    
    % coloring of the image with different styles
    switch(style)
        case 1 % jet color vector
            colormap([jet();flipud( jet() );0 0 0]); 
        case 2 %hsv color vector
            colormap([hsv();flipud( hsv() );0 0 0]);
        otherwise
    end
    
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


function conjugate_Callback(hObject, eventdata, handles)

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

