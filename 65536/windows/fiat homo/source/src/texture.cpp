#include "stuff.hpp"
#include "texture.hpp"

Texture::Texture(int pwidth, int pheight, unsigned long *pdata)
{
	int i;
	width = pwidth;
	height = pheight;

	data = new unsigned long[width*height];
	for (i=0;i<width*height;i++)
	{
		data[i] = pdata[i];
	}
}

Texture::Texture(int pwidth, int pheight)
{
	int i;
	width = pwidth;
	height = pheight;

	data = new unsigned long[width*height];
	for (i=0;i<width*height;i++)
	{
		data[i] = 0xFF000000;
#ifdef BIGENDIAN
		data[i] = (((data[i]&0x000000FF)<<24)+((data[i]&0x0000FF00)<<8)+((data[i]&0x00FF0000)>>8)+((data[i]&0xFF000000)>>24));
#endif
	}
}

Texture::~Texture()
{
	delete [] data;

}

void Texture::upload()
{
	glEnable(GL_TEXTURE_2D);
	glGenTextures(1, &ID);
	glBindTexture(GL_TEXTURE_2D, ID);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	if((width == 512 && height == 512) || 
       (width == 256 && height == 256) || 
       (width == 128 && height == 128) || 
       (width == 64 &&  height == 64))
    {
		gluBuild2DMipmaps(GL_TEXTURE_2D, 4, width, height, GL_RGBA, GL_UNSIGNED_BYTE, (unsigned char *)data); 

   	}
   	else
   	{
		glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

		gluBuild2DMipmaps(GL_TEXTURE_2D, 4, width, height, GL_RGBA, GL_UNSIGNED_BYTE, (unsigned char *)data); 
   	}



}
