#ifndef _LIIKKUVA_HPP_
#define _LIIKKUVA_HPP_

#include "stuff.hpp"

class Liikkuva
{
public:
	Vector startpos;
	Vector endpos;
	Vector pos;

	float starttime;
	float endtime;

	float phase;
	float speed;
	float t;

	int type;

	void calcPos(float aika);
	void calcPosRepeat(float aika);

	
};


#endif 
 
 
