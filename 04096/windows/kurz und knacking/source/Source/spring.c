#include "spring.h"

void spring_set(spring* s, particle* a, particle* b) {

	vec tmp;

	s->p1			= a;
	s->p2			= b;

	vec_sub(&tmp, &a->pos, &b->pos);
	s->restLength = vec_length(&tmp);
}