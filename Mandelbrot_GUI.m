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

% Last Modified by GUIDE v2.5 23-Jun-2015 11:18:28

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
    set(handles.index, 'enable', 'on');
    set(handles.iterations, 'enable', 'on');
    set(handles.benchmarkPanel,'visible','Off');
    dcm = datacursormode(gcf);
    datacursormode on;
    set(dcm, 'updatefcn', @updateDataTip);


% --- Outputs from this function are returned to the command line.
function varargout = Mandelbrot_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;

   
    
% --- MANDELBROT FORMULA ---
% --- Executes on button press in generateVisualization.
function generateVisualization_Callback(hObject, eventdata, handles)
% hObject    handle to generateVisualization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global legendIterations;
global legendMethods;
legendMethods = {'CPU', 'GPU', 'FunArray', 'CUDA'};
    

if(get(handles.styleComputationAll,'value') == 1)
    reset(gpuDevice(1));
    benchmark = BenchmarkTester(handles);
    % iterations = [10, 100, 1000]
    legendIterations = benchmark.iterations;
   
    % vtime
    %           | 10 | 100 | 1000 |
    % CPU       |    |     |      |
    % GPU       |    |     |      |
    % funArray  |    |     |      |
    % CUDA      |    |     |      |
    vTime = runBenchmark(benchmark);
    renderBenchmarkPlot(vTime, handles);
else
    % use simple gpuArray
    if(get(handles.styleComputationGpu1,'value') == 1)
        reset(gpuDevice(1));
        calculator = GPUCalculator(handles);
        methodString = 'simple GPU';
    % use array fun
    elseif(get(handles.styleComputationGpu2,'value') == 1)
        reset(gpuDevice(1));
        calculator = GPUArrayFunCalculator(handles);
        methodString = 'ArrayFun GPU';
    % use CUDA
    elseif(get(handles.styleComputationGpu3,'value') == 1)
        reset(gpuDevice(1));
        calculator = CUDACalculator(handles);
        methodString = 'CUDA';
    % use simple 
    else
        calculator = CPUCalculator(handles);
        methodString = 'simple CPU';
    end
    
    % get the iterations in both, string and double format
    strIterations = get(handles.iterations,'string');
    iterations = str2double(strIterations);

    t = tic();  % START CALCULATION %

    count = calc(calculator, iterations);
    count = log( count );
    calcTime = toc(t);

    setName = 'Mandelbrot';
    if(get(handles.mandelbrot,'value') == 0)
        setName = 'Julia';
    end

    fprintf( '%1.2f secs for calculating %s set with %s and gridsize %d x %d in %d iterations\n', calcTime, setName, methodString, length(calculator.xGrid), length(calculator.yGrid), iterations);
    % END CALCULATION %

    % --- TEST SECTION
    % --- test preparation [CPU ; GPU ; GPU_funArray ; CUDA]
    % iterations
    %legendIterations = [10, 100, 250, 500, 1000];
    %vTime = [0.58, 5.14, 13.32, 26.07, 54.98; 0.23, 2.64, 6.89, 13.58, 26.98; 0.22, 2.47, 6.39, 0, 0; 0.11, 0.22, 0.4, 0.68, 1.29];
    
    %set(handles.bmGroupMethod,'value',0);
    %set(handles.bmGroupIterations,'value',1);
    % --- test preparation end
    % renderBenchmarkPlot(vTime, handles);
    % --- test output end
    % --- TEST SECTION END
    
    % display computation time in the results section
    set(handles.panelResults,'visible','On')
    set(handles.panelResults, 'Title', 'Computation Time'); % change panel title
    strComputationTime = strcat('It took',{' '},num2str(calcTime, 3), ...
    ' s to calculate', {' '}, setName, ' set with the ', {' '}, methodString, '.');   
    set(handles.textResult,'String',strComputationTime);
    % rendering of the visualization and the benchmark plot
    renderImage(count, handles);
end



 
    

% function for image rendedering
function[] = renderImage(count, handles)
    % START IMAGE RENDERING %
    % --- image rendering: selecting right plot and assign log of result
    axes(handles.plotImage);
    imagesc( count );
    set(gca,'XTickLabel',''); % delete ticks (numbers around the plot)
    set(gca,'YTickLabel','');
    
    setColormap(handles); 
    % END IMAGE RENDERING %
  
    
% function for changing the colormap    
function map = setColormap(handles)
    % START CHANGING COLORMAP PLOT RENDERING%
    % --- coloring of the image with different styles
    if get(handles.styleDrawingJet,'Value') % jet color vector
            map = colormap (handles.plotImage, ([jet();flipud( jet() );0 0 0]));
    elseif get(handles.styleDrawingHsv,'Value') % hsv color vector
            map = colormap (handles.plotImage, ([hsv();flipud( hsv() );0 0 0]));
    elseif get(handles.styleDrawingParula,'Value') % cool color vector
            map = colormap (handles.plotImage, ([parula();flipud( parula() );0 0 0]));
    elseif get(handles.styleDrawingCool,'Value') % hot color vector
            map = colormap (handles.plotImage, ([cool();flipud( cool() );0 0 0]));
    elseif get(handles.styleDrawingHot,'Value') % hot color vector
            map = colormap (handles.plotImage, ([hot();flipud( hot() );0 0 0]));
    elseif get(handles.styleDrawingSummer,'Value') %parula color vector
            map = colormap (handles.plotImage, ([summer();flipud( summer() );0 0 0]));        
    end
    
    % END CHANGING COLORMAP PLOT RENDERING %

    
function renderBenchmarkPlot(vTime, handles)
    % START BENCHMARK PLOT RENDERING%
    disp(vTime);
    axes(handles.plotResults); %select plotImage as current plot
    colormap (handles.plotResults, summer);
    benchmarkGroupingLayout(vTime, handles);
    
    % --- calculate and print comparison factor cpu/cuda into text field
    factor = sum(vTime(1, :))/sum(vTime(4,:));
    set(handles.panelResults,'visible','On');
    set(handles.panelResults, 'Title', 'Efficiency Comparison'); % change panel title
    strComparison = strcat('CUDA is in average', {' '}, int2str(factor) ,' times faster than the CPU.');
    set(handles.textResult,'String',strComparison); 
    
    % END BENCHMARK PLOT RENDERING %

    
% --- create a bar chart, depending on grouping options
function benchmarkGroupingLayout(data, handles)   
    % START BENCHMARK GROUP LAYOUT CONFIGURATION %
    global legendIterations;
    global legendMethods;
    
    % choose the result plot as the current plot for modification
    axes(handles.plotResults);
    
    if get(handles.bmGroupMethod,'Value') %bar chart for method bars
        bar(data);
        set(handles.plotResults,'XTickLabel',legendMethods);
        set(handles.plotResults,'YScale','log');
        ylabel('time [sec]');
        xlabel('computation method');
        labelIterationString = strtrim(cellstr(num2str(legendIterations'))');
        legend(handles.plotResults, labelIterationString, 'Location', 'northeast');
    elseif get(handles.bmGroupIterations,'Value') %bar chart for iter. bars
        bar(data.');
        set(handles.plotResults,'XTickLabel',legendIterations);
        set(handles.plotResults,'YScale','log');
        ylabel('time [sec]');
        xlabel('iterations');
        legend(handles.plotResults,legendMethods, 'Location', 'northwest');
    end
    % END BENCHMARK GROUP LAYOUT CONFIGURATION %
    
    
    
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

set(handles.mandelbrot,'value',1);
set(handles.julia,'value',0);
set(handles.a,'String',1);
set(handles.b,'String',1);
set(handles.xMin,'String',-2);
set(handles.xMax,'String',0.5);
set(handles.yMin,'String',-1.25);
set(handles.yMax,'String',1.25);

% --- Executes on button press in julia.
function julia_Callback(hObject, eventdata, handles)

set(handles.mandelbrot,'value',0);
set(handles.julia,'value',1);
set(handles.a,'String',-0.7);
set(handles.b,'String',0.3);
set(handles.xMin,'String',-1.5);
set(handles.xMax,'String',1.5);
set(handles.yMin,'String',-1.5);
set(handles.yMax,'String',1.5);

function resetComputation(handles)
set(handles.styleComputationCpu,'value',0);
set(handles.styleComputationGpu1,'value',0);
set(handles.styleComputationGpu2,'value',0);
set(handles.styleComputationGpu3,'value',0);
set(handles.styleComputationAll,'value', 0);
set(handles.index, 'enable', 'on');
set(handles.iterations, 'enable', 'on');
set(handles.benchmarkPanel,'visible','Off');


function styleComputationCpu_Callback(hObject, eventdata, handles)
resetComputation(handles);
set(handles.styleComputationCpu,'value',1);

function styleComputationGpu1_Callback(hObject, eventdata, handles)
resetComputation(handles);
set(handles.styleComputationGpu1,'value',1);

function styleComputationGpu2_Callback(hObject, eventdata, handles)
resetComputation(handles);
set(handles.styleComputationGpu2,'value',1);

function styleComputationGpu3_Callback(hObject, eventdata, handles)
resetComputation(handles);
set(handles.styleComputationGpu3,'value',1);


% --- Executes on button press in styleComputationAll.
function styleComputationAll_Callback(hObject, eventdata, handles)
resetComputation(handles);
set(handles.styleComputationAll,'value',1);
set(handles.index, 'enable', 'off');
set(handles.iterations, 'enable', 'off');
set(handles.benchmarkPanel,'visible','On');

function resetDrawing(handles)
set(handles.styleDrawingJet,'value',0);
set(handles.styleDrawingHsv,'value',0);
set(handles.styleDrawingParula,'value',0);
set(handles.styleDrawingCool,'value',0);
set(handles.styleDrawingHot,'value',0);
set(handles.styleDrawingSummer,'value',0);


function styleDrawingJet_Callback(hObject, eventdata, handles)
resetDrawing(handles);
set(handles.styleDrawingJet,'value',1);
setColormap(handles);

function styleDrawingHsv_Callback(hObject, eventdata, handles)
resetDrawing(handles);
set(handles.styleDrawingHsv,'value',1);
setColormap(handles);

function styleDrawingParula_Callback(hObject, eventdata, handles)
resetDrawing(handles);
set(handles.styleDrawingParula,'value',1);
setColormap(handles);

function styleDrawingCool_Callback(hObject, eventdata, handles)
resetDrawing(handles);
set(handles.styleDrawingCool,'value',1);
setColormap(handles);

function styleDrawingHot_Callback(hObject, eventdata, handles)
resetDrawing(handles);
set(handles.styleDrawingHot,'value',1);
setColormap(handles);

function styleDrawingSummer_Callback(hObject, eventdata, handles)
resetDrawing(handles);
set(handles.styleDrawingSummer,'value',1);
setColormap(handles);


% --- Executes on button press in bmGroupMethod.
function bmGroupMethod_Callback(hObject, eventdata, handles)

set(handles.bmGroupMethod,'value',1);
set(handles.bmGroupIterations,'value',0);

% update grouping , if data already exists
if get(handles.plotResults,'visible')
    % retrieving data from the plot
    yOutput = get(get(handles.plotResults,'Children'),'YData');
    data = cell2mat(yOutput);
    
    benchmarkGroupingLayout(flipud(data), handles);
end

% --- Executes on button press in bmGroupIterations.
function bmGroupIterations_Callback(hObject, eventdata, handles)

set(handles.bmGroupMethod,'value',0);
set(handles.bmGroupIterations,'value',1);

% update grouping , if data already exists
if get(handles.plotResults,'visible')
    % retrieving data from the plot    
    yOutput = get(get(handles.plotResults,'Children'),'YData');
    data = fliplr(cell2mat(yOutput).');
    
    benchmarkGroupingLayout(data, handles);
end


% --------------------------------------------------------------------
% --- save the image in the local directory
function saveImage_ClickedCallback(hObject, eventdata, handles)

% retrieve data and colormap
data = log(get(get(handles.plotImage, 'Children'),'CData'));
%h = handles.plotImage;
%cMap = setColormap(handles);

% scale matrix to the range of the map
%cMapSize = size(cMap,1);
%dataScaled = round(interp1(linspace(min(data(:)),max(data(:)),cMapSize),1:cMapSize,data));
%picture = reshape(cMapSize(dataScaled,:),[size(dataScaled) 3]); % Make RGB image from scaled data

imwrite(data, 'visualization.png', 'png');


% --------------------------------------------------------------------
function output_txt = updateDataTip ( obj,event_obj)

dataIndex = get(event_obj,'Target');
pos = get(event_obj,'Position');

if (strcmp(class(dataIndex), 'matlab.graphics.chart.primitive.Bar'))
    output_txt = {['Seconds: ',num2str(pos(2),4)]};
else
    % calculate the coordinates of the position
    output_txt = {[ 'X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)]};
end


% --------------------------------------------------------------------
function uitoggletool5_ClickedCallback(hObject, eventdata, handles)

datacursormode toggle;
