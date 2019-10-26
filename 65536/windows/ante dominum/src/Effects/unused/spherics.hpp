#ifndef _SPHERICS_HPP_
#define _SPHERICS_HPP_

#include "../stuff.hpp"

class sphericsStruct
{
public:

	int count;
	Vector *vertices;

	Vector startpos;
	Vector endpos;
	Vector startrot;
	Vector endrot;

	float starttime;
	float endtime;

	int type;
	void draw(float aika, float alpha);

};

void spherics(float aika);
void spherics_init();
void spherics_free();

#endif