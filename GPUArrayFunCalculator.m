classdef GPUArrayFunCalculator
    properties
       c
       z
       count
       index
    end    
    methods
        function obj = GPUArrayFunCalculator(handles)
            gridProvider = GridProvider;
            [xGrid, yGrid] = initGridGPU(gridProvider, handles);

            formula = FormulaProvider;
            [obj.c, obj.z, obj.count] = getFormula(formula, xGrid, yGrid, handles);

            obj.index = str2double(get(handles.index,'string'));
        end    
        function [count] = calc(obj, iterations)
            count = arrayfun( @processMandelbrotElement, ...
            obj.count, obj.z, obj.c, obj.index, iterations); 
        end
    end
end
