#ifndef _CHANGER_HPP_
#define _CHANGER_HPP_

#include "stuff.hpp"

class Changer
{
public:
	Changer(int states);
	~Changer();

	void setState(int statenumber, float start, float end);
	float getValue(float t);
	int getStateNumber(float t);

private:
	int statecount;
	float *starts;
	float *ends;
};

#endif 
