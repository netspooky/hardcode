function [x y z] = hopalong()

a = -80;
b = 15;
c = -144; % juokseta tätä

x(1) = 0;
y(1) = 0;
z(1) = 0;

for i=2:2000
    x(i) = y(i-1) - sign(x(i-1))*sqrt(abs(b*x(i-1)-c));
    y(i) = a - x(i-1);
    z(i) = 0;
end