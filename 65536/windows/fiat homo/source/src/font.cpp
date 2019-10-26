#include "font.hpp"
#include "stuff.hpp"
#include "data.h"
#include "font_data.hpp"
#include <string.h>
#include <SDL/SDL.h>
using namespace std;

GLuint fontbase;
GLuint fontbase2;

int font_inc = 0;

struct FONT_TEXTURES {
	unsigned int tex;
	int w,h;
};
FONT_TEXTURES font_textures[24];

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


	gluBuild2DMipmaps(GL_TEXTURE_2D, 3, w, h, GL_RGB, GL_UNSIGNED_BYTE, texture);
	font_textures[font_inc].w = w;
	font_textures[font_inc].h = h;
	font_textures[font_inc].tex = tex;

	font_inc++;

	glBindTexture(GL_TEXTURE_2D, 0);
	glDisable(GL_TEXTURE_2D);
}

int fonttext(const char *string)
{
	if (!strcmp("Traction as",string)) { return 0; }
	else if (!strcmp("Preacher",string)) { return 1; }
	else if (!strcmp("Kofeiini",string)) { return 2; }
	else if (!strcmp("Grip",string)) { return 3; }
	else if (!strcmp("\"Fiat Homo\"",string)) { return 4; }
	else if (!strcmp("ananasmurska",string)) { return 5; }
	else if (!strcmp("asd",string)) { return 6; }
	else if (!strcmp("conspiracy",string)) { return 7; }
	else if (!strcmp("demarche",string)) { return 8; }
	else if (!strcmp("faktory", string)) { return 9; }
	else if (!strcmp("fairlight",string)) { return 10; }
	else if (!strcmp("jumalauta", string)) { return 11; }
	else if (!strcmp("mfx", string)) { return 12; }
	else if (!strcmp("numedia cyclops",string)) { return 13; }
	else if (!strcmp("outbreak",string)) { return 14; }
	else if (!strcmp("promille design", string)) { return 15; }
	else if (!strcmp("plastic", string)) { return 16; }
	else if (!strcmp("static",string)) { return 17; }
	else if (!strcmp("hedelmae",string)) { return 18; }
	else if (!strcmp("ümlaut design",string)) { return 19; }
	else if (!strcmp("neuro.concept",string)) { return 20; }
	else if (!strcmp("Anna",string)) { return 21; }
	else if (!strcmp("matt current",string)) { return 22; }
	else if (!strcmp("gluterol",string)) { return 23; }
}

void font_write(float xpos, float ypos, const char *string)
{
	glPushMatrix();
	int tex = fonttext(string);

	glEnable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
	perspective2D(1024,768);

	glTranslatef(512+1024*xpos,384+768*ypos,0);

	glBindTexture(GL_TEXTURE_2D, font_textures[tex].tex);

	glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBegin(GL_QUADS);
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0, 0);
	glTexCoord2f(0.0f, 0.0f); glVertex2f(0, font_textures[tex].h);
	glTexCoord2f(1.0f, 0.0f); glVertex2f(font_textures[tex].w, font_textures[tex].h);
	glTexCoord2f(1.0f, 1.0f); glVertex2f(font_textures[tex].w, 0);
	glEnd();

	glBlendFunc(GL_ONE, GL_ONE);
	glBegin(GL_QUADS);
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0, 0);
	glTexCoord2f(0.0f, 0.0f); glVertex2f(0, font_textures[tex].h);
	glTexCoord2f(1.0f, 0.0f); glVertex2f(font_textures[tex].w, font_textures[tex].h);
	glTexCoord2f(1.0f, 1.0f); glVertex2f(font_textures[tex].w, 0);
	glEnd();

	perspective3D();
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	glPopMatrix();
}

void font_write3d(const char *string)
{
	glPushMatrix();
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	int tex = fonttext(string);

	glBindTexture(GL_TEXTURE_2D, font_textures[tex].tex);

	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glBegin(GL_QUADS);
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0, 0);
	glTexCoord2f(0.0f, 0.0f); glVertex2f(0, font_textures[tex].h);
	glTexCoord2f(1.0f, 0.0f); glVertex2f(font_textures[tex].w, font_textures[tex].h);
	glTexCoord2f(1.0f, 1.0f); glVertex2f(font_textures[tex].w, 0);
	glEnd();

	glBegin(GL_QUADS);
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0, 0);
	glTexCoord2f(0.0f, 0.0f); glVertex2f(0, font_textures[tex].h);
	glTexCoord2f(1.0f, 0.0f); glVertex2f(font_textures[tex].w, font_textures[tex].h);
	glTexCoord2f(1.0f, 1.0f); glVertex2f(font_textures[tex].w, 0);
	glEnd();

	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	glPopMatrix();
}

void font_init() /* what a cutie */
{
	font_texture(traction_as_image.pixel_data, traction_as_image.width, traction_as_image.height);
	font_texture(preacher_image.pixel_data, preacher_image.width, preacher_image.height);
	font_texture(kofeiini_image.pixel_data, kofeiini_image.width, kofeiini_image.height);
	font_texture(grip_image.pixel_data, grip_image.width, grip_image.height);
	font_texture(fiat_homo_image.pixel_data, fiat_homo_image.width, fiat_homo_image.height);
	font_texture(ananasmurska_image.pixel_data, ananasmurska_image.width, ananasmurska_image.height);
	font_texture(asd_image.pixel_data, asd_image.width, asd_image.height);
	font_texture(conspiracy_image.pixel_data, conspiracy_image.width, conspiracy_image.height);
	font_texture(demarche_image.pixel_data, demarche_image.width, demarche_image.height);
	font_texture(faktory_image.pixel_data, faktory_image.width, faktory_image.height);
	font_texture(fairlight_image.pixel_data, fairlight_image.width, fairlight_image.height);
	font_texture(jumalauta_image.pixel_data, jumalauta_image.width, jumalauta_image.height);
	font_texture(mfx_image.pixel_data, mfx_image.width, mfx_image.height);
	font_texture(numedia_cyclops_image.pixel_data, numedia_cyclops_image.width, numedia_cyclops_image.height);
	font_texture(outbreak_image.pixel_data, outbreak_image.width, outbreak_image.height);
	font_texture(promille_design_image.pixel_data, promille_design_image.width, promille_design_image.height);
	font_texture(plastic_image.pixel_data, plastic_image.width, plastic_image.height);
	font_texture(static_image.pixel_data, static_image.width, static_image.height);
	font_texture(hedelmae_image.pixel_data, hedelmae_image.width, hedelmae_image.height);
	font_texture(neuro_concept_image.pixel_data, neuro_concept_image.width, neuro_concept_image.height);
	font_texture(Anna_image.pixel_data, Anna_image.width, Anna_image.height);
	font_texture(matt_current_image.pixel_data, matt_current_image.width, matt_current_image.height);
	font_texture(gluterol_image.pixel_data, gluterol_image.width, gluterol_image.height);
}


void font_free() {}
