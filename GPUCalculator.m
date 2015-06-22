classdef GPUCalculator
    properties
       c
       z
       count
       index
       xGrid
       yGrid
    end    
    methods
        function obj = GPUCalculator(handles)
            gridProvider = GridProvider;
            [obj.xGrid, obj.yGrid] = initGridGPU(gridProvider, handles);
            
            formula = FormulaProvider;
            [obj.c, obj.z, obj.count] = getFormula(formula, obj.xGrid, obj.yGrid, handles);

            obj.index = str2double(get(handles.index,'string'));
        end    
        function [count] = calc(obj, iterations)
            count = processMandelbrotElement ( ...
            obj.count, obj.z, obj.c, obj.index, iterations);
        end
        
    end
end
