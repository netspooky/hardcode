#include "texturemanager.h"
#include "perlin.h"
#include "nrline.h"

TextureManager::TextureManager(int number)
{
	Textures = new unsigned char[number*256*256];
	perlin = new Perlin();
	blendmap = new unsigned char [256*256];
	int o=0;
	for (int y=-128; y<128; y++)
		for (int x=-128; x<128; x++) 
		{
			float r1 = maxi (x,y) / 128.0f; 
			float r2 = (x*x + y*y)/16000.0f;
			float r=r1*r2;
			float k = (float)(1.0f - r*r*r*r);
			if (k<0) k=0;
			if (k>1) k=1;
			blendmap[o++] = (unsigned char)(k*255);
		}

	for(int i=0; i<number; i++)
	{
		int ot = i*256*256;
		int t=GetTickCount();
		for(int v=0; v<256; v++)
			for(int u=0; u<256; u++)
			{
				int om = u + (v<<8);
				int n = perlin->GetI3DI ((u+t*2)<<8,(v+t)<<8,t)*8;	
				int b = blendmap[om]*n;
				b>>=11;				
				if (b>0xff) b=0xff;
				Textures[ot+u+(v<<8)]=b;
			}
	}
}

TextureManager::~TextureManager(void)
{
}

unsigned char*TextureManager::GetTexture(int number)
{
	return Textures+number*256*256;
}
