classdef GPUCalculator
    properties
       c
       z
       count
       index
    end    
    methods
        function obj = GPUCalculator(handles)
            gridProvider = GridProvider;
            [xGrid, yGrid] = initGridGPU(gridProvider, handles);
            
            formula = FormulaProvider;
            [obj.c, obj.z, obj.count] = getFormula(formula, xGrid, yGrid, handles);

            obj.index = str2double(get(handles.index,'string'));
        end    
        function [count] = calc(obj, iterations)
            count = obj.count;
            
            for j=1:iterations
                obj.z=obj.z.^obj.index+obj.c;

                inside = abs( obj.z )<=2;
                count = count + inside;
            end
        end
    end
end
