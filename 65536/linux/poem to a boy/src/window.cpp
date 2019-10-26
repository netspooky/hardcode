#include "window.h"
#include "poem.h"

#include <GL/glut.h>
#include <GL/glx.h>
#include <unistd.h>

#include <SDL/SDL.h>


window::window() {
	
		Uint32 flags;

		if ( SDL_Init(SDL_INIT_VIDEO) < 0) {
				printf("eeek, kunne ikke inite sdl: %s\n", SDL_GetError());
				_exit(1);
		}
		
		flags = SDL_OPENGL;
		
		if(FULLSCREEN) {
				flags |= SDL_FULLSCREEN;
		}
		
		SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 1);
		if(SDL_SetVideoMode(640,480,0,flags) == NULL) {
				printf("Eeek, kunne ikke sette 640x480");
				_exit(1);
		}

		resize(640,480);

		SDL_ShowCursor(0);
		
		setclearcolor(0.0, 0.0, 0.0);
}

window::~window() {
		SDL_Quit();
}

void window::resize(int x, int y) {

	dprint("resize x: " << x << " y: " << y <<'\n');

	if(!x) x++;
	if(!y) y++;

	width = x;
	height = y;

	glViewport(0, 0, width, height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(45.0f,(GLfloat)width/(GLfloat)height,0.1f,100.0f);
}

void window::draw() {
}

void window::predraw() {
	glClearColor(clear[R], clear[G], clear[B], clear[A]);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void window::postdraw() {
}

void window::setclearcolor(float r, float g, float b, float a) {
	clear[R] = r;
	clear[G] = g;
	clear[B] = b;
	clear[A] = a;
}

void window::setclearcolor(float r, float g, float b) {
	clear[R] = r;
	clear[G] = g;
	clear[B] = b;
	clear[A] = 1.0;
}
