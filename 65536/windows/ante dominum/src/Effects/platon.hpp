#ifndef _PLATON_HPP_
#define _PLATON_HPP_

#include "../stuff.hpp"

class platonStruct
{
public:
	Vector startpos;
	Vector endpos;
	Vector startrot;
	Vector endrot;

	float starttime;
	float endtime;

	int type;
	void draw(float aika, float alpha);

};

void platon(float aika);
void platon_init();
void platon_free();

#endif 
