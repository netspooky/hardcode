#include "pastelcolor.h"
#include "nrline.h"
#include "3dmath.h"

PastelColor::PastelColor(Vector v)
{
	colormap=new unsigned int[256];
	unsigned char r,g,b;
		
	for(int i=0; i<256; i++)
	{
		r = 255-(unsigned char)((float)(i)*v.x);
		g = 255-(unsigned char)((float)(i)*v.y);
		b = 255-(unsigned char)((float)(i)*v.z);
		colormap[i] = 0x00000000 + (r<<16) + (g<<8) + b;
	}
}

PastelColor::~PastelColor(void)
{
	delete [] colormap;
}
