classdef GridProvider
    methods
        function [xGrid, yGrid] = getGrid(obj, handles)
            % initialize variables for calculation
            if(get(handles.styleComputationCpu,'value') == 1)
                disp('using cpu');
                [xGrid, yGrid]=initGrid(obj, handles);
            elseif(get(handles.styleComputationGpu1,'value') == 1)
                disp('using gpu');
                [xGrid, yGrid]=initGridGPU(obj, handles);
            elseif(get(handles.styleComputationGpu2,'value') == 1)
                disp('using arrayFun');
                [xGrid, yGrid]=initGridGPU(obj, handles);
            elseif(get(handles.styleComputationGpu3,'value') == 1)
                disp('using CUDA');
                [xGrid, yGrid]=initGridGPU(obj, handles);
            else
                [xGrid, yGrid]=initGrid(obj, handles);
            end
        end
    
        % return 2 lists of values from min to max in step
        function [xGrid, yGrid] = initGridGPU(obj, handles)
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
        end
        % return 2 lists of values from min to max in step
        function [xGrid, yGrid] = initGrid(obj, handles)
            x_min=str2double(get(handles.xMin,'String'));
            x_max=str2double(get(handles.xMax,'String'));
            x_step=str2double(get(handles.step,'String'));
            x=x_min:x_step:x_max;

            y_min=str2double(get(handles.yMin,'String'));
            y_max=str2double(get(handles.yMax,'String'));
            y_step=str2double(get(handles.step,'String'));
            y=y_min:y_step:y_max;

            [xGrid, yGrid]=meshgrid(x,y);
        end
    end
end
