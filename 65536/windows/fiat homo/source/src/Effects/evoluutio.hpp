#ifndef _EVOLUUTIO_HPP_
#define _EVOLUUTIO_HPP_

#include "../stuff.hpp"

class Tuuliparticle
{
public:
	Vector startpos;
	Vector endpos;
	Vector color;
	float alpha;
};


void evoluutio_init();
void evoluutio_free();
void evoluutio(float aika);
void monoliitti(Vector kohta, float alpha);
Vector tuulifunktio(Vector pos, float aika);

#endif
