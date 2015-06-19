classdef CPUCalculator
    properties
       c
       z
       count
       index
    end    
    methods
        function obj = CPUCalculator(handles)
            gridProvider = GridProvider;
            [xGrid, yGrid] = initGrid(gridProvider, handles);
            
            formula = FormulaProvider;
            [obj.c, obj.z, obj.count] = getFormula(formula, xGrid, yGrid, handles);

            obj.index = str2double(get(handles.index,'string'));
        end 
        function [count] = calc(obj, iterations)
            count = processMandelbrotElement ( ...
            obj.count, obj.z, obj.c, obj.index, iterations);
        end
    end
end
