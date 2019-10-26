close all;
clear;

x = 0:0.1:120;
y = ((sin(clamp((x/10).^1.8-pi/2, -pi/2, pi/2))-1)*1.5 + 5).*cos(clamp(0.04*(x), 0, pi)); %clamp(exp(-((x-10)*0.02).^2)+0.45,0,1);

%((sin(clamp(x/30, 0, pi))+1)*0.5).^3

%y2 = clamp(exp(-((x-10)*0.02).^2)+0.2,0,1)
y1 = sin(clamp((x/10).^1.8-pi/2, -pi/2, pi/2))-1;

y2 = cos(clamp(0.04*(x), 0, pi));

y3 = ((sin(clamp(x/30, 0, pi))+1)*0.5).^3

plot(x,y)
hold on
plot(x,y1)
plot(x,y2)
%plot(x,y3)

x = 0:0.1:120;
y = ((sin(clamp(x/10-pi/2, -pi/2, 0.1))-1)*1.5 + 5).*cos(clamp(0.04*(x-6.6), 0.4, pi)); %clamp(exp(-((x-10)*0.02).^2)+0.45,0,1);

%((sin(clamp(x/30, 0, pi))+1)*0.5).^3

%y2 = clamp(exp(-((x-10)*0.02).^2)+0.2,0,1)
y1 = sin(clamp(x/10-pi/2, -pi/2, 0))-1;

y2 = cos(clamp(0.04*(x-6.6), 0.4, pi));

y3 = ((sin(clamp(x/30, 0, pi))+1)*0.5).^3
