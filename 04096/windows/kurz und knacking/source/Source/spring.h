#ifndef SPRING_H
#define SPRING_H

#include "particle.h"

typedef struct spring_s {
	particle*	p1;
	particle*	p2;
	float		restLength;
} spring;

void spring_set(spring* s, particle* a, particle* b);

#endif