#ifndef _CURVES_HPP_
#define _CURVES_HPP_

#include "../stuff.hpp"

class Curve
{
public:

	void draw(float aika, float alpha);

	int vertexcount;
	Vector *vertices;

	float starttime;
	float endtime;

	Vector pos;
	Vector startrot;
	Vector endrot;
	Vector color;

	float width;


};

void curves(float aika);
void curves_init();
void curves_free();

#endif 
