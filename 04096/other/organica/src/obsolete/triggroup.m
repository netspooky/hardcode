function [x y z] = triggroup()

endrange = 2*pi;
amount = 800;
t=0:(endrange/amount):endrange;

x=cos(t);
y=sin(t);
z=sin(3*t);