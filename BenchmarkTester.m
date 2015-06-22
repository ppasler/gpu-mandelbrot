classdef BenchmarkTester
    properties
        iterations 
        calculators
        cpuCalculator
        gpuCalculator
        gpuFunArrayCalculator
        cudaCalculator
    end    
    methods
        function obj = BenchmarkTester(handles)
            obj.iterations = [1, 10, 100];
            
            obj.cpuCalculator = CPUCalculator(handles);
            obj.gpuCalculator = GPUCalculator(handles);
            obj.gpuFunArrayCalculator = GPUArrayFunCalculator(handles);
            obj.cudaCalculator = CUDACalculator(handles);
            
            disp('init');
        end    
        function [benchmarkArray, count] = runBenchmark(obj)
            benchmarkArray = [];
            for iteration=obj.iterations
                benchmarkArray = [benchmarkArray, runForIteration(obj, iteration)];
            end
            count = 0;
        end
        function calcTimes = runForIteration(obj, iteration)
            fprintf( 'running with gridsize %d x %d and %1.0f iterations: ', length(obj.cpuCalculator.xGrid), length(obj.cpuCalculator.yGrid), iteration);
            calcTimes = [];
        	calcTimes = [calcTimes; runTest(obj, obj.cpuCalculator, iteration)];
            fprintf( '...CPU ');
            calcTimes = [calcTimes; runTest(obj, obj.gpuCalculator, iteration)];
            fprintf( '...GPU ');
            calcTimes = [calcTimes; runTest(obj, obj.gpuFunArrayCalculator, iteration)];
            fprintf( '...FunArray ');
            calcTimes = [calcTimes; runTest(obj, obj.cudaCalculator, iteration)];
            fprintf( '...CUDA\n');
        end
        function calcTime = runTest(obj, calculator, iteration)
            M = 2;
            N = 2;
            % make sure compiler made improvements and caching
            for i = 1:M
                calc(calculator, iteration);
            end
            
            % calc 5 times and take avg
            for i = 1:N
                t = tic();
                calc(calculator, iteration);
                calcTime = toc(t);
            end
            calcTime = calcTime / N;
        end        
    end
end
