classdef GPUArrayFunCalculator
    properties
       z0
       index
    end    
    methods
        function obj = GPUArrayFunCalculator(handles)
            gridProvider = GridProvider;
            [xGrid, yGrid] = initGridGPU(gridProvider, handles);

            obj.z0 = complex(xGrid, yGrid);
            obj.index = str2double(get(handles.index,'string'));
        end    
        function [count] = calc(obj, iterations)
            count = arrayfun( @processMandelbrotElement, ...
            obj.z0, iterations); 
        end
    end
end
