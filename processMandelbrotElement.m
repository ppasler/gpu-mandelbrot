function count = processMandelbrotElement(count, z, c, index ,iterations)
    for n = 1:iterations
            z=z.^index+c;

            inside = abs( z )<=2;
            count = count + inside;
    end