close all
clear

% some dot groups

%plotting
figure
[x y z] = triggroup();
subplot(3,3,1);
plot3(x,y,z,'k.')

[x y z] = hopalong();
subplot(3,3,2);
plot(x,y,'k.')

[x y z] = gingerbread();
subplot(3,3,3);
plot(x,y,'k.')

[x y z] = threeply();
subplot(3,3,4);
plot(x,y,'k.')

[x y z] = quadrup();
subplot(3,3,5);
plot(x,y,'k.')

[x y z] = martin_neg();
subplot(3,3,6);
plot(x,y,'k.')

[x y z] = martin_pos();
subplot(3,3,7);
plot(x,y,'k.')