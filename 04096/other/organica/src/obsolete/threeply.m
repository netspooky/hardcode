function [x y z] = threeply()

a = -35;
b = -1;
c = -16; %juokseta tätä

x(1) = -0.1;
y(1) = 0;
z(1) = 0;

for i=2:2000
    x(i) = y(i-1) - sign(x(i-1))*abs(sin(x(i-1))*cos(b) + c - x(i-1)*sin(a+b+c));
    y(i) = a - x(i-1);
    z(i) = 0;
end