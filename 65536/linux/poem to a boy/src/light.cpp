#include "light.h"

#include "GL/gl.h"

light::light(float *startpos) {
	for(int i = 0; i < 3; i++)
		this->pos[i] = startpos[i];
	pos[W] = 1.0;
	this->ambient[R] = 0.0;
	this->ambient[G] = 0.0;
	this->ambient[B] = 0.0;
	this->ambient[A] = 1.0;
	this->diffuse[R] = 1.0;
	this->diffuse[G] = 1.0;
	this->diffuse[B] = 1.0;
	this->diffuse[A] = 1.0;
	this->enabled = true;
}

light::light() {
	pos[X] = 0.0;
	pos[Y] = 0.0;
	pos[Z] = 2.0;
	pos[W] = 1.0;
	this->ambient[R] = 0.0;
	this->ambient[G] = 0.0;
	this->ambient[B] = 0.0;
	this->ambient[A] = 1.0;
	this->diffuse[R] = 1.0;
	this->diffuse[G] = 1.0;
	this->diffuse[B] = 1.0;
	this->diffuse[A] = 1.0;
	this->enabled = true;
}

light::light(float x, float y, float z) {
	this->pos[X] = x;
	this->pos[Y] = y;
	this->pos[Z] = z;
	pos[W] = 1.0;
	this->ambient[R] = 0.0;
	this->ambient[G] = 0.0;
	this->ambient[B] = 0.0;
	this->ambient[A] = 1.0;
	this->diffuse[R] = 1.0;
	this->diffuse[G] = 1.0;
	this->diffuse[B] = 1.0;
	this->diffuse[A] = 1.0;
	this->enabled = true;
}

void light::show() {
	if(!enabled) {
		glDisable(GL_LIGHT1);
		return;
	}
	float pos2[] = { 0.0, 0.0, 2.0, 1.0 };
	
	glLightfv(GL_LIGHT1, GL_POSITION, pos);
	glLightfv(GL_LIGHT1, GL_DIFFUSE, diffuse);
	glLightfv(GL_LIGHT1, GL_AMBIENT, ambient);
	glEnable(GL_LIGHT1);
}
