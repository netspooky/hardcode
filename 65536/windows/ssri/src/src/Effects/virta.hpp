#ifndef _VIRTA_HPP_
#define _VIRTA_HPP_

#include "../stuff.hpp"

struct Neuron
{
	Vector pos;

	int naapuricount;
	int *pathvertices;
	Vector **vertices;
};



struct VirtaLine
{
public:
	Vector startrot;
	Vector endrot;
	float length;

	float phase, phase2;
	float frequency, frequency2;
	float radiusphase, radiusfrequency;

	Vector v1;
	Vector v2;
	Vector displace;

	float linephase;
	float alpha;
	float pos;
};


void virta(float aika);
void virta_init();
void virta_free();

void virtaplasma(float *dest, float aika);
void virtaplasma2(float *dest, float aika);

#endif
