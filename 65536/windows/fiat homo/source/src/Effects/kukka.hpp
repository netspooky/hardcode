#ifndef _KUKKA_HPP_
#define _KUKKA_HPP_

#include "../stuff.hpp"

void kukka_init();
void kukka_free();
void kukka(float aika);
void draw_kukka(float aika, float alpha);

class Flower
{
public:
	Vector pos;
	Vector color;
	Vector rotate;
	int teralehtia;

	float teralehtipituus;
	float teralehtikulma;
	float teralehtipower;		//sivut
	float teralehtipower2;	//keskusta
	float teralehtikayristyma; //"kuppimaisuus"
	float korkeus;

	float starttime;
	float endtime;

	float *petalcolors;
	float *petalvariation;

	int hedecount;
	Vector *heteet;

	int varsicount;
	Vector *varsi;

	void draw(float aika, float alpha);
};


#endif
