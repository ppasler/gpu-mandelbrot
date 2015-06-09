classdef CUDACalculator
    properties
       c
       xGrid
       yGrid
       index
    end    
    methods
        function obj = CUDACalculator(handles)
            gridProvider = GridProvider;
            [obj.xGrid, obj.yGrid] = initGridGPU(gridProvider, handles);

            obj.index = str2double(get(handles.index,'string'));
        end    
        function [count] = calc(obj, iterations)
            % Load the kernel
            cudaFilename = 'processMandelbrotElement.cu';
            ptxFilename = 'processMandelbrotElement.ptx';
            kernel = parallel.gpu.CUDAKernel( ptxFilename, cudaFilename );
            % Make sure we have sufficient blocks to cover all of the locations
            numElements = numel( obj.xGrid );
            kernel.ThreadBlockSize = [kernel.MaxThreadsPerBlock,1,1];
            kernel.GridSize = [ceil(numElements/kernel.MaxThreadsPerBlock),1];

            % Call the kernel
            count = zeros( size(obj.xGrid), 'gpuArray' );
            count = feval( kernel, count, obj.xGrid, obj.yGrid, iterations, numElements );

            % Show
            count = gather( count ); % Fetch the data back from the GPU   
        end
    end
end