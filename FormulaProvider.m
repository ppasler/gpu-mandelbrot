classdef FormulaProvider
    methods
        function [c, z, count] = getFormula(obj, xGrid, yGrid, handles)
            c = initC(obj, xGrid, yGrid, handles); % init formula
            z = complex(xGrid,yGrid); % init z
            count = ones( size(z) );
        end
    
        function [c] = initC(obj, xGrid, yGrid, handles)
            a = str2double(get(handles.a,'String'));
            b = str2double(get(handles.b,'String'));
            if get(handles.mandelbrot,'value')==1
                c=complex(a.*xGrid, b.*yGrid);
            else
                c=complex(a,b);
            end
        end
    end
end
