#ifndef _TEXTURE_HPP_
#define _TEXTURE_HPP_

#include "texture.hpp"

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
