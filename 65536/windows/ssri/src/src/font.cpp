#include "font.hpp"
#include "fonttext.h"
#include "fontgreetings.h"
#include <string.h>

int font_inc = 0;

struct FONT_TEXTURES {
	unsigned int tex;
	int w,h;
};
FONT_TEXTURES font_textures[10];

void font_texture(const unsigned char *texture, unsigned int w, unsigned int h)
{
	glEnable(GL_TEXTURE_2D);

	GLuint tex;
	glGenTextures(1, &tex);
	glBindTexture(GL_TEXTURE_2D, tex);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);


	gluBuild2DMipmaps(GL_TEXTURE_2D, 4, w, h, GL_RGBA, GL_UNSIGNED_BYTE, texture);
	font_textures[font_inc].w = w;
	font_textures[font_inc].h = h;
	font_textures[font_inc].tex = tex;

	font_inc++;

	glBindTexture(GL_TEXTURE_2D, 0);
	glDisable(GL_TEXTURE_2D);
}

int fonttext(const char *string)
{
	if (!strcmp("traction",string)) { return 0; }
	else if (!strcmp("SSRI",string)) { return 1; }
	else if (!strcmp("fluoxetine: preacher",string)) { return 2; }
	else if (!strcmp("fluvoxamine: grip",string)) { return 3; }
	else if (!strcmp("greetings",string)) { return 4; }
	return 4;
}

void font_write(float xpos, float ypos, const char *string)
{
	glPushMatrix();
	int tex = fonttext(string);

	glEnable(GL_TEXTURE_2D);
	perspective2D(640,480);

/*	glTranslatef(240*xpos,240+240*ypos,0);*/
/*x * (640/4) + (640/2)
y * (640/4) + (480/2)*/
//glTranslatef(-xpos * (640/4) + (640/2)+200, ypos * (640/4) + (480/2), 0);
//glTranslatef(xpos * 320, ypos * (640/4) + (480/2), 0);
glTranslatef(320 - ((xpos-1.3)*320), (ypos + 1) * 240, 0);

	glBindTexture(GL_TEXTURE_2D, font_textures[tex].tex);

	glBegin(GL_QUADS);
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0, 0);
	glTexCoord2f(0.0f, 0.0f); glVertex2f(0, font_textures[tex].h);
	glTexCoord2f(1.0f, 0.0f); glVertex2f(font_textures[tex].w, font_textures[tex].h);
	glTexCoord2f(1.0f, 1.0f); glVertex2f(font_textures[tex].w, 0);
	glEnd();

	perspective3D();
	glDisable(GL_TEXTURE_2D);
	glPopMatrix();
}

void font_write3d(const char *string)
{
	glPushMatrix();
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	int tex = fonttext(string);

	glBindTexture(GL_TEXTURE_2D, font_textures[tex].tex);

	glBegin(GL_QUADS);
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0, 0);
	glTexCoord2f(0.0f, 0.0f); glVertex2f(0, font_textures[tex].h);
	glTexCoord2f(1.0f, 0.0f); glVertex2f(font_textures[tex].w, font_textures[tex].h);
	glTexCoord2f(1.0f, 1.0f); glVertex2f(font_textures[tex].w, 0);
	glEnd();

	glDisable(GL_TEXTURE_2D);
	glPopMatrix();
}

void font_init() /* what a cutie */
{
	font_texture(traction_image.pixel_data, traction_image.width, traction_image.height);
	font_texture(ssri_image.pixel_data, ssri_image.width, ssri_image.height);
	font_texture(preacher_image.pixel_data, preacher_image.width, preacher_image.height);
	font_texture(grip_image.pixel_data, grip_image.width, grip_image.height);
	font_texture(greetings_image.pixel_data, greetings_image.width, greetings_image.height);
}

void font_free() {}
