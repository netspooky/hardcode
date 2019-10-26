#ifndef _ATOMI_HPP_
#define _ATOMI_HPP_

#include "../stuff.hpp"

class Atomi
{
	public:

	Atomi(int randseed, int ecount, int ycount, float radiusmul, Vector pos);
	~Atomi();

	void draw(float aika, float alpha);

	float **rotates;
	float *speeds;
	float *positions;
	float *radii;
	Vector *ydin;

	Vector position;

	int electroncount;
	int ydincount;
};

void atomi(float aika);
void atomi_init();
void atomi_free();

#endif
