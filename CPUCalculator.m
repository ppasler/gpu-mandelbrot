classdef CPUCalculator
    properties
       c
       z
       count
       index
       xGrid
       yGrid
    end    
    methods
        function obj = CPUCalculator(handles)
            [obj.xGrid, obj.yGrid] = initGrid(GridProvider, handles);
            
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
