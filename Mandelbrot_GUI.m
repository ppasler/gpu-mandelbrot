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

% Last Modified by GUIDE v2.5 10-Jun-2015 17:37:06

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
    set(handles.styleComputationAll,'value',0);


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


if(get(handles.styleComputationAll,'value') == 1)
    benchmark = BenchmarkTester(handles);
    % iterations = [10, 100, 1000]
    caption = benchmark.iterations;
    disp(caption);
    % objects
    objects = {'CPU', 'GPU', 'FunArray', 'CUDA'};
    
    % vtime
    %           | 10 | 100 | 1000 |
    % CPU       |    |     |      |
    % GPU       |    |     |      |
    % funArray  |    |     |      |
    % CUDA      |    |     |      |
    vTime = runBenchmark(benchmark);
    disp(vTime);
else


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
count = log( count );
calcTime = toc(t);

setName = 'mandelbrot';
if(get(handles.mandelbrot,'value') == 0)
    setName = 'julia';
end

fprintf( '%1.2f secs for calculating %s set with %s\n', calcTime, setName, methodString);
% END CALCULATION %

% --- test preparation [CPU ; GPU ; GPU_funArray ; CUDA]
vTime = [calcTime 0.9 0.8 ; 0.1 0.09 0.08 ; 0.05 0.04 0.035 ; 0.001 0.0009 0.0008];
% --- test preparation end

% rendering of the visualization and the benchmark plot
renderImage(count, handles);
end
renderBenchmarkPlot(vTime, handles);


% function for image rendedering
function[] = renderImage(count, handles)
    % START IMAGE RENDERING%
    % --- image rendering: selecting right plot and assign log of result
    axes(handles.plotImage);
    imagesc( count );
    
    setColormap(handles) 
    % END IMAGE RENDERING%
   
    
% function for changing the colormap    
function setColormap(handles)
    % START CHANGING COLORMAP PLOT RENDERING%
    % --- coloring of the image with different styles
    if get(handles.styleDrawingJet,'Value') % jet color vector
            colormap (handles.plotImage, ([jet();flipud( jet() );0 0 0]));
    elseif get(handles.styleDrawingHsv,'Value') % hsv color vector
            colormap (handles.plotImage, ([hsv();flipud( hsv() );0 0 0]));
    elseif get(handles.styleDrawingParula,'Value') % cool color vector
            map = colormap (handles.plotImage, ([parula();flipud( parula() );0 0 0]));
    elseif get(handles.styleDrawingCool,'Value') % hot color vector
            map = colormap (handles.plotImage, ([cool();flipud( cool() );0 0 0]));
    elseif get(handles.styleDrawingHot,'Value') % hot color vector
            map = colormap (handles.plotImage, ([hot();flipud( hot() );0 0 0]));
    elseif get(handles.styleDrawingSummer,'Value') %parula color vector
            map = colormap (handles.plotImage, ([summer();flipud( summer() );0 0 0]));        
    end
    
    % END CHANGING COLORMAP PLOT RENDERING%
    
    
function[] = renderBenchmarkPlot(vTime, handles)
    % START BENCHMARK PLOT RENDERING%
    %set(datacursormode(gcf), 'DisplayStyle','datatip', 'SnapToDataVertex','off','Enable','on', 'UpdateFcn',{@showlabel,label}); 
    axes(handles.plotResults); %select plotImage as current plot
    labelMethod = {'CPU', 'GPU', 'FunArray', 'CUDA'};
    labelIterations = {'10', '100', '1000'};
    
    % --- create a bar chart, depending on grouping options
    if get(handles.bmGroupMethod,'Value') %bar chart for method bars
        bar(vTime);
        set(gca,'XTickLabel',labelMethod);
        set(gca,'YScale','log');
        ylabel('time [sec]');
        xlabel('computation method');
        legend(handles.plotResults, labelIterations);
    elseif get(handles.bmGroupIterations,'Value') %bar chart for iter. bars
        bar(vTime.');
        set(gca,'XTickLabel',labelIterations);
        set(gca,'YScale','log');
        ylabel('time [sec]');
        xlabel('iterations');
        legend(handles.plotResults,labelMethod);
    end
    
    colormap (handles.plotResults, summer);
    
    % --- calculate and print comparison factor cpu/cuda into text field
    factor = sum(vTime(1, :))/sum(vTime(4,:));
    set(handles.panelResults,'visible','On');
    strComparison = strcat('CUDA is in average', {' '}, int2str(factor) ,' times faster than the CPU.');
    set(handles.textResult,'String',strComparison); 
    
    % END BENCHMARK PLOT RENDERING%
    
    
    
    
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


function a_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b (see GCBO)
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
set(handles.a,'String',1)
set(handles.b,'String',1)
set(handles.xMin,'String',-2)
set(handles.xMax,'String',0.5)
set(handles.yMin,'String',-1.2)
set(handles.yMax,'String',1.2)

% --- Executes on button press in julia.
function julia_Callback(hObject, eventdata, handles)
% hObject    handle to julia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of julia
set(handles.mandelbrot,'value',0)
set(handles.julia,'value',1)
set(handles.a,'String',-0.7)
set(handles.b,'String',0.3)
set(handles.xMin,'String',-1.5)
set(handles.xMax,'String',1.5)
set(handles.yMin,'String',-1.5)
set(handles.yMax,'String',1.5)


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
set(handles.styleComputationAll,'value', 0);
set(handles.benchmarkPanel,'visible','Off');


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
set(handles.styleComputationAll,'value', 0);
set(handles.benchmarkPanel,'visible','Off');


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
set(handles.styleComputationAll,'value', 0);
set(handles.benchmarkPanel,'visible','Off');


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
set(handles.benchmarkPanel,'visible','Off');


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
set(handles.benchmarkPanel,'visible','On');


% --- Executes on button press in styleDrawingJet.
function styleDrawingJet_Callback(hObject, eventdata, handles)
% hObject    handle to styleDrawingJet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleDrawingJet

set(handles.styleDrawingJet,'value',1);
set(handles.styleDrawingHsv,'value',0);
set(handles.styleDrawingParula,'value',0);
set(handles.styleDrawingCool,'value',0);
set(handles.styleDrawingHot,'value',0);
set(handles.styleDrawingSummer,'value',0);

setColormap(handles)

% --- Executes on button press in styleDrawingHsv.
function styleDrawingHsv_Callback(hObject, eventdata, handles)
% hObject    handle to styleDrawingHsv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleDrawingHsv

set(handles.styleDrawingJet,'value',0);
set(handles.styleDrawingHsv,'value',1);
set(handles.styleDrawingParula,'value',0);
set(handles.styleDrawingCool,'value',0);
set(handles.styleDrawingHot,'value',0);
set(handles.styleDrawingSummer,'value',0);

setColormap(handles)

% --- Executes on button press in styleDrawingParula.
function styleDrawingParula_Callback(hObject, eventdata, handles)
% hObject    handle to styleDrawingParula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleDrawingParula
set(handles.styleDrawingJet,'value',0);
set(handles.styleDrawingHsv,'value',0);
set(handles.styleDrawingParula,'value',1);
set(handles.styleDrawingCool,'value',0);
set(handles.styleDrawingHot,'value',0);
set(handles.styleDrawingSummer,'value',0);

setColormap(handles)

% --- Executes on button press in styleDrawingCool.
function styleDrawingCool_Callback(hObject, eventdata, handles)
% hObject    handle to styleDrawingCool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleDrawingCool

set(handles.styleDrawingJet,'value',0);
set(handles.styleDrawingHsv,'value',0);
set(handles.styleDrawingParula,'value',0);
set(handles.styleDrawingCool,'value',1);
set(handles.styleDrawingHot,'value',0);
set(handles.styleDrawingSummer,'value',0);

setColormap(handles)

% --- Executes on button press in styleDrawingHot.
function styleDrawingHot_Callback(hObject, eventdata, handles)
% hObject    handle to styleDrawingHot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleDrawingHot

set(handles.styleDrawingJet,'value',0);
set(handles.styleDrawingHsv,'value',0);
set(handles.styleDrawingParula,'value',0);
set(handles.styleDrawingCool,'value',0);
set(handles.styleDrawingHot,'value',1);
set(handles.styleDrawingSummer,'value',0);

setColormap(handles)

% --- Executes on button press in styleDrawingSummer.
function styleDrawingSummer_Callback(hObject, eventdata, handles)
% hObject    handle to styleDrawingSummer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of styleDrawingSummer

set(handles.styleDrawingJet,'value',0);
set(handles.styleDrawingHsv,'value',0);
set(handles.styleDrawingParula,'value',0);
set(handles.styleDrawingCool,'value',0);
set(handles.styleDrawingHot,'value',0);
set(handles.styleDrawingSummer,'value',1);

setColormap(handles)

% --- Executes on button press in bmGroupMethod.
function bmGroupMethod_Callback(hObject, eventdata, handles)
% hObject    handle to bmGroupMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bmGroupMethod

set(handles.bmGroupMethod,'value',1);
set(handles.bmGroupIterations,'value',0);

% --- Executes on button press in bmGroupIterations.
function bmGroupIterations_Callback(hObject, eventdata, handles)
% hObject    handle to bmGroupIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bmGroupIterations

set(handles.bmGroupMethod,'value',0);
set(handles.bmGroupIterations,'value',1);


% --- Executes on button press in radiobutton24.
function radiobutton24_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton24


% --- Executes on button press in radiobutton25.
function radiobutton25_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton25


% --------------------------------------------------------------------
% --- save the image in the local directory
function saveImage_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to saveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

imwrite(count, 'img.png', 'png');
