#ifndef _KASVU_HPP_
#define _KASVU_HPP_

#include "../stuff.hpp"

struct KasvuItem
{
public:
	int count;
	Vector *vertices;

	Vector position;

	Vector color1;
	Vector color2;

	float starttime;
	float endtime;

	void draw(float alpha, float aika);
};




void kasvu_init();
void kasvu_free();
void kasvu(float aika);

#endif
