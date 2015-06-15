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
            obj.iterations = [1, 10];
            
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
            fprintf( 'running with %1.0f iterations\n', iteration);
            calcTimes = [];
        	calcTimes = [calcTimes; runTest(obj, obj.cpuCalculator, iteration)];
            disp('CPU');
            calcTimes = [calcTimes; runTest(obj, obj.gpuCalculator, iteration)];
            disp('GPU');
            calcTimes = [calcTimes; runTest(obj, obj.gpuFunArrayCalculator, iteration)];
            disp('FunArray');
            calcTimes = [calcTimes; runTest(obj, obj.cudaCalculator, iteration)];
            disp('CUDA');
        end
        function calcTime = runTest(obj, calculator, iteration)
            % make sure compiler is through
            %for i = 1:5
            %    calc(calculator, iteration);
            %end
            
            % calc 5 times and take avg
            for i = 1:1
                t = tic();
                calc(calculator, iteration);
                calcTime = toc(t);
            end
            calcTime = calcTime / 5;
        end        
    end
end
