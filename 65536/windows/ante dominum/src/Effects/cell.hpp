#ifndef _CELL_HPP_
#define _CELL_HPP_

#include "../stuff.hpp"

class CellItem
{
public:
	CellItem() {};
	~CellItem() {};

	float power;

	float powerspeed;
	float powerphase;

	float radius;
	float angle;
	float anglespeed;
	float anglephase;

	Vector color;
	Vector pos;


};

void cell(float aika);
void cell_init();
void cell_free();

#endif 
