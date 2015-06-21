classdef CUDACalculator
    properties
       c
       a
       b
       xGrid
       yGrid
       index
       mandelbrot
    end    
    methods
        function obj = CUDACalculator(handles)
            gridProvider = GridProvider;
            [obj.xGrid, obj.yGrid] = initGridGPU(gridProvider, handles);

            obj.a = str2double(get(handles.a,'string'));
            obj.b = str2double(get(handles.b, 'string'));
            
            obj.index = str2double(get(handles.index,'string'));
            obj.mandelbrot = str2double(get(handles.mandelbrot,'string'));
         end    
        function [count] = calc(obj, iterations)
            % Load the kernel
            cudaFilename = 'processMandelbrotElement_3.cu';
            ptxFilename = 'processMandelbrotElement_3.ptx';
            kernel = parallel.gpu.CUDAKernel( ptxFilename, cudaFilename );
            % Make sure we have sufficient blocks to cover all of the locations
            numElements = numel( obj.xGrid );
            kernel.ThreadBlockSize = [kernel.MaxThreadsPerBlock,1,1];
            kernel.GridSize = [ceil(numElements/kernel.MaxThreadsPerBlock),1];

            % Call the kernel
            count = zeros( size(obj.xGrid), 'gpuArray' );
            count = feval( kernel, count, obj.xGrid, obj.yGrid, obj.a, ...
                obj.b, obj.index, iterations, obj.mandelbrot, numElements );

            % Show
            count = gather( count ); % Fetch the data back from the GPU   
        end
    end
end
