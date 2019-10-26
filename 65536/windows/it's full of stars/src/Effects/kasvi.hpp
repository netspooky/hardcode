#ifndef _KASVI_HPP_
#define _KASVI_HPP_

#include "../stuff.hpp"
#include "../linestrip.hpp"

struct Kukka
{
	int stripcount;
	LineStrip *strips;

	float starttime;
	float endtime;
	Vector color;
	Vector pos;
};

void kasvi(float aika);
void kasvi_init();
void kasvi_free();

#endif 
 
