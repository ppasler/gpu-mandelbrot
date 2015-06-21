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
__device__ unsigned int doIterations( double const x0, 
                                      double const y0, 
                                      double const a, 
                                      double const b,
                                      unsigned int const k,                                       
                                      unsigned int const maxIters ) {
    // Initialise: z = z0
    // depending on x0, y0 we calc the mandelbrot or julia set
    double x = x0;
    double y = y0;

    unsigned int count = 0;
    // Loop until escape
    while ( ( count <= maxIters )
            && ((x*x + y*y) <= 4.0) ) {
        ++count;
        // Update: z = z*z + z0;
        double const oldx = x;
        // real part
        x = x*x - y*y + a;
        // imaginary part
        y = 2.0*oldx*y + b;
    }
    return count;
}


/** Main entry point.
 * Works out where the current thread should read/write to global memory
 * and calls doIterations to do the actual work.
 */
__global__ void processMandelbrotElementTest( 
                      double * out, 
                      const double * x, 
                      const double * y,
                      const double a, 
                      const double b,
                      const unsigned int k,
                      const unsigned int maxIters,
                      const unsigned int mandelbrot,
                      const unsigned int numel ) {
    // Work out which thread we are
    size_t const globalThreadIdx = calculateGlobalIndex();

    // If we're off the end, return now
    if (globalThreadIdx >= numel) {
        return;
    }
    
    // Get our X and Y coords
    double x0 = x[globalThreadIdx];
    double y0 = y[globalThreadIdx];

    double aVal = a;
    double bVal = b;

    if(mandelbrot == 1){
      aVal = a*x0;
      bVal = b*y0;
    }

    // Run the itearations on this location
    unsigned int const count = doIterations( x0, y0, aVal, bVal, k, maxIters );
    out[globalThreadIdx] = log( double( count + 1 ) );
}
