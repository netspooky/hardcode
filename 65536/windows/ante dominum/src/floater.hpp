#ifndef _FLOATER_HPP_
#define _FLOATER_HPP_

#include "stuff.hpp"

class Floater
{
public:
	Floater(bool ydim, float maxenergy, float maxsize);
	~Floater() {};

	Vector pos;
	Vector prevpos;
	float energy;
	float originalenergy;

	bool update(float dt, float maxrange, Vector suunta);
	void draw(float alpha);
	
};


#endif 
