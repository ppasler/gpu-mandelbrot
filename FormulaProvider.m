classdef FormulaProvider
    methods
        function [c, z, count] = getFormula(obj, xGrid, yGrid, handles)
            c = initC(obj, xGrid, yGrid, handles); % init formula
            z=xGrid+yGrid.*1i; % init z
            count = ones( size(z) );
        end
    
        function [c] = initC(obj, xGrid, yGrid, handles)
            cX = str2double(get(handles.cX,'String'));
            cY = str2double(get(handles.cY,'String'));
            if get(handles.mandelbrot,'value')==1
                c=cX.*xGrid+cY.*yGrid.*1i;
            else
                c=cX+cY*1i;
            end
        end
    end
end
