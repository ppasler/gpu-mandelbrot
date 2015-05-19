function count = processMandelbrotElement(x0,y0,iterations)
z0 = complex(x0,y0);
z = z0;
count = 1;
while (count <= iterations) && (abs(z) <= 2)
    count = count + 1;
    z = z*z + z0;
end
