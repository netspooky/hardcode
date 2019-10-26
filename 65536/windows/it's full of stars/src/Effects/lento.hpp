#ifndef _LENTO_HPP_
#define _LENTO_HPP_

#include "../stuff.hpp"

struct Kiertolainen
{
public:
	float startkulma1;
	float endkulma1;
	float startkulma2;
	float endkulma2;
	float radius;

	Vector startrot;
	Vector endrot;
	float size;

	Vector color;
	int type;
	
};

void lento(float aika);
void lento_init();
void lento_free();

#endif 
