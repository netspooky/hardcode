#ifndef _TEXTURE_HPP_
#define _TEXTURE_HPP_

#ifndef OS_X
#include "GL/gl.h"
#else
#include "gl.h"
#endif

class Texture
{
public:
	Texture(int pwidth, int pheight, unsigned long *pdata);
	Texture(int pwidth, int pheight); 
	~Texture();
	void upload();
	int width;
    int height;
    GLuint ID;
    unsigned long *data;
};




#endif
