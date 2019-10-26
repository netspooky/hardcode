clear
close all

i = 0;

for t=0:0.1:8
	i = i+1;
	y(i) = sin(pi*t/16)
	x(i) = -cos(pi*t/16)+1
end

for t=0:0.1:8
	i = i+1;
	y(i) = 0.6+0.4*sin(pi/2 + pi*t/10)
	x(i) = t/6+1
end

plot(x,y)