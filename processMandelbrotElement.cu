/**
 * @file pctdemo_processMandelbrotElement.cu
 * 
 * CUDA code to calculate the Mandelbrot Set on a GPU.
 * 
 * Copyright 2011 The MathWorks, Inc.
 */

/** Work out which piece of the global array this thread should operate on */ 
__device__ size_t calculateGlobalIndex() {
    // Which block are we?
    size_t const globalBlockIndex = blockIdx.x + blockIdx.y * gridDim.x;
    // Which thread are we within the block?
    size_t const localThreadIdx = threadIdx.x + blockDim.x * threadIdx.y;
    // How big is each block?
    size_t const threadsPerBlock = blockDim.x*blockDim.y;
    // Which thread are we overall?
    return localThreadIdx + globalBlockIndex*threadsPerBlock;

}

/** The actual Mandelbrot algorithm for a single location */ 
__device__ unsigned int doIterations( double const a, 
                                      double const b, 
                                      unsigned int const maxIters ) {
    // Initialize
    double x = a;
    double y = b;
    double x_old = x; 
    unsigned int count = 0;
    double x_old = x;
    // x_old --> save current x, since both formulas in the loop need  
    // to be calculated with same values

    // Loop until escape
    while ( ( count <= maxIters ) && ((x*x + y*y) <= 4.0) ) {
        ++count;
        
        x_old = x; 
        x = x*x - y*y + a;
        y = 2.0*x_old*y + b;
    }
    return count;
}


/** Main entry point.
 * Works out where the current thread should read/write to global memory
 * and calls doIterations to do the actual work.
 */
__global__ void processMandelbrotElement( 
                      double * out, 
                      const double * x, 
                      const double * y,
                      const unsigned int maxIters, 
                      const unsigned int numel ) {
    // Work out which thread we are
    size_t const globalThreadIdx = calculateGlobalIndex();

    // If we're off the end, return now
    if (globalThreadIdx >= numel) {
        return;
    }
    
    // Get our X and Y coords
    double const a = x[globalThreadIdx];
    double const b = y[globalThreadIdx];

    // Run the itearations on this location
    unsigned int const count = doIterations( a, b, maxIters );
    out[globalThreadIdx] = log( double( count + 1 ) );
}
