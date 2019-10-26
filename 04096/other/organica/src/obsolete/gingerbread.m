function [x y z] = gingerbread()

x(1) = -0.1;
y(1) = 0;
z(1) = 0;

for i=2:2000
    x(i) = 1 - y(i-1) + abs(x(i-1));
    y(i) = x(i-1);
    z(i) = 0;
end