#include "particle.h"
#include "global.h"

void particle_set(particle* p, vec* x, float im) {

	p->invm	= im;
	vec_cpy(&p->opos, x);
	vec_cpy(&p->pos, x);
	vec_set(&p->tex, 0.0f, 0.0f, 0.0f);
	vec_set(&p->force, 0.0f, 0.0f, 0.0f);
}