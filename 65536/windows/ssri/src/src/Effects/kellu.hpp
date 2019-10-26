#ifndef _KELLU_HPP_
#define _KELLU_HPP_

#include "../stuff.hpp"

struct Palanen
{
	Vector pos;
	Vector startrot;
	Vector endrot;

	float length;
	Vector color;

	Vector pos2;
	float phase;
	float speed;
};

void kellu(float aika);
void kellu_init();
void kellu_free();

#endif
