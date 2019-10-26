function [x y z] = quadrup()

a = -15; % juokseta tätä
b = -1;
c = -5;

x(1) = -0.1;
y(1) = 0.5;
z(1) = 0;

for i=2:2000
    x(i) = y(i-1) - sign(x(i-1))*sin(log(abs(b*x(i-1)-c)))*atan((c*x(i-1)-b)^2);
    y(i) = a - x(i-1);
    z(i) = 0;
end