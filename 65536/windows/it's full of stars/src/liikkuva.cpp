#include "liikkuva.hpp"

/*

class Liikkuva
{
public:
	Vector startpos;
	Vector endpos;
	Vector pos;

	float starttime;
	float endtime;

	float speed;
	float phase;
	float t;

	void calcPos(float aika);
	void calcPosPhase(float aika);

	
};
*/


void Liikkuva::calcPos(float aika)
{
	t = calcPosFloat(aika, starttime, endtime);
	pos = lerpVector(startpos, endpos, t);
}

void Liikkuva::calcPosRepeat(float aika)
{
	t = aika*speed + phase;
	t -= (float)int(t);
	pos = lerpVector(startpos, endpos, t);


} 
 
 
