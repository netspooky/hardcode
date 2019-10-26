function [x y z] = martin_neg()

a = pi-0.001;

x(1) = 0;
y(1) = 0;
z(1) = 0;

for i=2:2000
    x(i) = y(i-1) - sin(x(i-1));
    y(i) = a - x(i-1);
    z(i) = 0;
end