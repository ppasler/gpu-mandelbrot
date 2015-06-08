classdef GPUArrayFunCalculator
    properties
       c
       xGrid
       yGrid
       index
    end    
    methods
        function obj = GPUArrayFunCalculator(handles)
            gridProvider = GridProvider;
            [obj.xGrid, obj.yGrid] = initGridGPU(gridProvider, handles);

            obj.index = str2double(get(handles.index,'string'));
        end    
        function [count] = calc(obj, iterations)
            count = arrayfun( @processMandelbrotElement, ...
            obj.xGrid, obj.yGrid, iterations); 
        end
    end
end
