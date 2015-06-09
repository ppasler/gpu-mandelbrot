classdef FormulaProvider
    methods
        function [c, z, count] = getFormula(obj, xGrid, yGrid, handles)
            c = initC(obj, xGrid, yGrid, handles); % init formula
            z=xGrid+yGrid.*1i; % init z
            count = ones( size(z) );
        end
    
        function [c] = initC(obj, xGrid, yGrid, handles)
            a = str2double(get(handles.a,'String'));
            b = str2double(get(handles.b,'String'));
            if get(handles.mandelbrot,'value')==1
                c=a.*xGrid+b.*yGrid.*1i;
            else
                c=a+b*1i;
            end
        end
    end
end
