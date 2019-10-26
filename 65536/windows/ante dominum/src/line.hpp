#ifndef _LINE_HPP_
#define _LINE_HPP_

#include "stuff.hpp"

class Line
{
public:

	Vector startrot;
	Vector endrot;

	Vector startpos;
	Vector endpos;

	float starttime;
	float endtime;

	float length;

	void calcPos(float t, Vector *d1, Vector *d2);
};


#endif
 
