#include "utility.h"
#include <stdlib.h>

float sin(float x) {
	_asm {
    	fld x
        fsin
        fstp x
    }
	return x;
}

float cos(float x) {
	_asm {
    	fld x
        fcos
        fstp x
    }
	return x;
}

float tan(float x) {
	_asm {
    	fld x
		fptan
		fstp x	// 1.0 now on stack
		fstp x
	}
	return x;
}

float sqrt(float x) {
	_asm {
    	fld x
		fsqrt
		fstp x
	}
	return x;
}

float fabs(float x) {
	_asm {
		fld x
		fabs
		fstp x
	}
	return x;
}

float randf(float min, float max) {
	return min + (max - min) * ((float)rand() / (float)RAND_MAX);
}

/*void clamp(float* x, float vmin, float vmax) {
	*x = min(max(*x, vmin), vmax);
}*/

float clamp(float x, float vmin, float vmax) {
	return min(max(x, vmin), vmax);
}

void upload_texture(int* map) {

	GLuint	tex;

	glGenTextures(1, &tex);
	glBindTexture(GL_TEXTURE_2D, tex);

	gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, TEXTURE_RES, TEXTURE_RES, GL_BGRA_EXT, GL_UNSIGNED_BYTE, map);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
//	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, TEXTURE_RES, TEXTURE_RES, 0, GL_BGRA_EXT, GL_UNSIGNED_BYTE, map);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
}