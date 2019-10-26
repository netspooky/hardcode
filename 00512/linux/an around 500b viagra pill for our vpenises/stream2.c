#include"SDL/SDL.h"
#include"SDL/SDL_opengl.h"
#include"math.h"
main(t,z,a,e){if(fork()){for(;;){static GLUquadricObj*q;q=gluNewQuadric();SDL_Event k;SDL_SetVideoMode(1024,768,32,0x80000002);glEnable(3042);glBlendFunc(770,1);do{glClear(16640);e=2;do{glLoadIdentity();z=120;do{glTranslatef(e/18.,0,sin(t/999.)*.1);glRotatef(360*sin(t/500.)/20,1,1,1);SDL_PollEvent(&k);glColor4f(cos(z/30.+t/999.),.3,.4,.1);gluSphere(q,1-z/119.,6,6);}while(z--);}while(e--);t+=20;SDL_GL_SwapBuffers();}while(k.type!=2);SDL_Quit();remove("y");remove("x.c");kill(0,15);}}else{for(;;a++){putchar(128+60*sin(.05*a)+69*tanh(2+sin(.2023*a)+sin(.101*a)));}}}

