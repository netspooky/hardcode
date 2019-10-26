#include "gl.h"
#include "poem.h"
#include "window.h"
#include "demo.h"

#include <SDL/SDL.h>

window *w;

void gl::init(int &argc, char **argv) {
	dprint("gl::init()\n");
	
	w = new window();
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_LIGHTING);
	dprint("hei");
}

void gl::resize(int x, int y) {
	dprint("gl::resize()\n");
	w->resize(x, y);
}

void gl::predraw() {
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	w->predraw();
	return;
}

void gl::draw() {
	w->draw();
	return;
}

void gl::postdraw() {
	SDL_GL_SwapBuffers();
	w->postdraw();
	return;
}

void gl::run() {
}

