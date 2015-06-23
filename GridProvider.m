classdef GridProvider
    methods
        % return 2 lists of values from min to max in step
        function [xGrid, yGrid] = initGridGPU(obj, handles)
            x_min=str2double(get(handles.xMin,'String'));
            x_max=str2double(get(handles.xMax,'String'));
            x_step=str2double(get(handles.step,'String'));
            x_size = round((x_max-x_min) / x_step);
            x=gpuArray.linspace(x_min, x_max, x_size);

            y_min=str2double(get(handles.yMin,'String'));
            y_max=str2double(get(handles.yMax,'String'));
            y_step=str2double(get(handles.step,'String'));
            y_size = round((y_max-y_min) / y_step);
            y=gpuArray.linspace(y_min, y_max, y_size);

            [xGrid, yGrid]=meshgrid(x,y); 
        end
        % return 2 lists of values from min to max in step
        function [xGrid, yGrid] = initGrid(obj, handles)
            x_min=str2double(get(handles.xMin,'String'));
            x_max=str2double(get(handles.xMax,'String'));
            x_step=str2double(get(handles.step,'String'));
            x_size = round((x_max-x_min) / x_step);
            x=linspace(x_min,x_max,x_size);

            y_min=str2double(get(handles.yMin,'String'));
            y_max=str2double(get(handles.yMax,'String'));
            y_step=str2double(get(handles.step,'String'));
            y_size = round((y_max-y_min) / y_step);
            y=linspace(y_min,y_max,y_size);

            [xGrid, yGrid]=meshgrid(x,y);
       end
    end
end
