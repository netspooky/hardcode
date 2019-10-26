#pragma once
class Perlin;
class TextureManager
{
	unsigned char *blendmap;
	Perlin *perlin;
	
	int maxi (int a, int b) 
	{
		if (a<0) a=-a; if (b<0) b=-b;
		if (a>b) return a;
		return b;
	}
public:
	TextureManager(int number);
	~TextureManager(void);
	unsigned char *GetTexture(int number);
	unsigned char* Textures;
};
