#ifndef FYLLGL_H
#define FYLLGL_H

#include <GL/glut.h>

namespace gl {

	void init(int &argc, char**);

	void exit();

	void predraw();
	
	void draw();

	void postdraw();

	void resize(int, int);

	void run();

	void keypressed(unsigned char, int, int);
}

#endif
