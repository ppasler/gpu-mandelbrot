function count = processMandelbrotElement(z0,iterations)
z = z0;
count = 1;
while (count <= iterations) && (abs(z) <= 2)
    count = count + 1;
    z = z*z + z0;
end
