#include "text.h"
#include <GL/gl.h>
#include <cstring>

Text::Text(Font *f, const char *t) : font(f) {
	text = new char[strlen(t) + 2];
	strcpy(text, t);
	memset(pos, 0, sizeof(vector));
}

Text::~Text() {
	delete[] text;
}

void Text::draw(const int &i) {
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glDisable(GL_LIGHTING);
	glColor4f(1,1,1,1);
	glBlendFunc(GL_ONE, GL_ONE);

	#define dx 1
	#define dy 1

	glTranslatef(pos[X], pos[Y], pos[Z]);
	
	glBindTexture(GL_TEXTURE_2D, font->get_letters(text[i]));

	glTranslatef(((float)i+0.25)*dx, 0.0, 0.0);

	if (text[i] != ' ') {
		glBegin(GL_POLYGON);
			glTexCoord2f(0, 1);
			glVertex2f(dx, 0);
			glTexCoord2f(1, 1);
			glVertex2f(dx+(dx-dx/10), 0);
			glTexCoord2f(1, 0);
			glVertex2f(dx+(dx-dx/10), dy);
			glTexCoord2f(0, 0);
			glVertex2f(dx, dy);
		glEnd();
	}
	
	glTranslatef(-i*dx, 0.0, 0.0);
	
	glTranslatef(-pos[X], -pos[Y], -pos[Z]);

	for(int i = 0; i < strlen(text); i++) {

	}
	glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_LIGHTING);
}


void Text::draw() {
	for(int i = 0; i < strlen(text); i++) {
		draw(i);
	}
}

