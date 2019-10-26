#ifndef PARTICLE_H
#define PARTICLE_H

#include "vec.h"

typedef struct particle_s {
	vec		pos;
	vec		opos;
	vec		force;
	float	invm;
	vec		tex;
} particle;

void particle_set(particle* p, vec* x, float im);

#endif