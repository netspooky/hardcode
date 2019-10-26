#ifndef _TEXTURE_HPP_
#define _TEXTURE_HPP_

class Texture
{
public:
	Texture(int pwidth, int pheight, unsigned long *pdata);
	Texture(int pwidth, int pheight); 
	~Texture();
	void upload();
	int width;
    int height;
    unsigned int ID;
    unsigned long *data;
};




#endif 
