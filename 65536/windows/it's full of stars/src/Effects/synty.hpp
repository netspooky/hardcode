#ifndef _SYNTY_HPP_
#define _SYNTY_HPP_

#include "../stuff.hpp"

struct Cluster
{
public:
	int count;
	Vector *points;
	Vector *colors;

	float *starttimes;
	float *endtimes;

	int *indices;
};

void synty_draw(float aika, float rotateaika, float camadd, float scale, float alphamod);
void synty(float aika);
void synty_init();
void synty_free();

#endif 
