#ifndef _PYORRE_HPP_
#define _PYORRE_HPP_

#include "../stuff.hpp"

struct PyorreItem
{
	float startangle;

	float startradius;
	float endradius;

	float phase;
};


void pyorre(float aika);
void pyorre_init();
void pyorre_free();

#endif
