#ifndef UTILITY_H
#define UTILITY_H

#include "particlesystem.h"

#define PI	3.141f
//#define	PI	3.1415926535897932

float	sin(float x);
float	cos(float x);
float	tan(float x);
float	sqrt(float x);
float   fabs(float x);
float	randf(float min, float max);
float	clamp(float x, float vmin, float vmax);
void	upload_texture(int* map);

#endif