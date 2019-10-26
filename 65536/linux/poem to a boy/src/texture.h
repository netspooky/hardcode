#ifndef TEXTURE_H
#define TEXTURE_H

#include <GL/gl.h>

typedef struct {
	unsigned char *data;
	unsigned short height;
	unsigned short width;
} image_t;

extern "C" {
	extern image_t *read_jpeg(const unsigned char *data, int data_size);
}

class texture {
	image_t *image;
	bool repeat;
	GLuint num;

public:
	texture(const unsigned char* jpeg_data, int size, bool repeat, GLenum format);

	inline int get_num() {
		return num;
	}

	~texture();

};

#endif
