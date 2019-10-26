#include "heart.h"

#include <GL/gl.h>

#include "texture.h"
#include "htex.h"

texture *htex;

void heart_init() {
	htex = new texture(HTEX_DATA, HTEX_LEN, true, GL_RGB);
}

void heart_draw() {
	glPushMatrix();
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, htex->get_num());
	glTranslatef(0.0, 0.0, -2.4);
	glBegin(GL_POLYGON); {
		glTexCoord2i(0, 1);
		glVertex3f(-1.0, -1.0, 0.0);
		glTexCoord2i(1, 1);
		glVertex3f(1.0, -1.0, 0.0);
		glTexCoord2i(1, 0);
		glVertex3f(1.0, 1.0, 0.0);
		glTexCoord2i(0, 0);
		glVertex3f(-1.0, 1.0, 0.0);
	} glEnd();
	glDisable(GL_TEXTURE_2D);
	glPopMatrix();
}
