#include "poem.h"
#include "texture.h"

#include <cstdlib>

#include <GL/gl.h>
#include <GL/glu.h>

texture::texture(const unsigned char* jpeg_data, int size, bool repeat, GLenum format) {
	dprint("loading texture...");
	image = ::read_jpeg(jpeg_data, size);
	dprint("done.\n");
	this->repeat = repeat;

	glEnable(GL_TEXTURE_2D);
	glGenTextures(1, &num);
	glBindTexture(GL_TEXTURE_2D, num);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, repeat ? GL_REPEAT : GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, repeat ? GL_REPEAT : GL_CLAMP_TO_EDGE);
	
	dprint("building mipmap ..\n ");
	gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, image->width, image->height, GL_RGB, GL_UNSIGNED_BYTE, image->data);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glDisable(GL_TEXTURE_2D);
	dprint("done.\n");

}

texture::~texture() {
	free(image->data);
	free(image);
}

