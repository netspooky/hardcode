#ifndef _PERLIN_H_
#define _PERLIN_H_


#define IBUFSIZE (1<<16)

#include "3dmath.h"

class Perlin
{
public:
	float buffer[4096];
	unsigned char ucbuf[IBUFSIZE];
  unsigned char wtb[256];
	Perlin(void);
	~Perlin(void);
	float Get(float x);
	float Get2D (float x, float y);
	float Get3D (float x, float y, float t);
	unsigned char GetI3D (float x, float y, float t);
	unsigned char GetI3DI (unsigned int xfp, unsigned int yfp, unsigned int tfp);
};
#endif //_PERLIN_H_