#include "font.h"

#include <GL/glu.h>
#include <stdlib.h>
#include <math.h>

unsigned char *Font::bitmap_to_grayscale(unsigned char* data, const int &x, const int &y) {
	int i,bit,j = 0;
	unsigned char *rgb;
	rgb = (unsigned char*)calloc(x*y,sizeof(char));
	for  (i = 0; i < y; i++) {
		for (bit = (int)pow(2, x-1); bit >= 1; bit /= 2) {
			rgb[j]= (data[i] & bit) ? 255 : 0;
			j++;
		}
	}
	return rgb;
}

Font::Font(unsigned char *fontdata, const int &x, const int &y) {
	
	letters = new GLuint[256];

	glGenTextures(255, letters);

	dprint("Generating font..");
	for(int i = 1; i <= 128; i++) {
		unsigned char *rgb = bitmap_to_grayscale(&fontdata[(i-1)*y], x, y);
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, letters[i]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

		gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, x, y, GL_LUMINANCE, GL_UNSIGNED_BYTE, rgb);
		glDisable(GL_TEXTURE_2D);
		free(rgb);
	}
	dprint(" OK!\n");
}

Font::~Font() {
	delete[] letters;
}
