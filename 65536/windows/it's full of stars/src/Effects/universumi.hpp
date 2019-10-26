#ifndef _UNIVERSUMI_HPP_
#define _UNIVERSUMI_HPP_

#include "../stuff.hpp"
#include "../linestrip.hpp"

struct Universe
{
	Vector basepos;
	Vector basecolor;
	LineStrip lines;

	float *alphas;


};

void universumi(float aika);
void universumi_init();
void universumi_free();

#endif 
