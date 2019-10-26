#ifndef _KAUPUNKI_HPP_
#define _KAUPUNKI_HPP_

#include "../stuff.hpp"

class CitySystem
{
public:

	CitySystem(int count);
	~CitySystem();
	
	void draw(float aika, float alpha);

private:

	bool safeget(int xt, int yt, int zt);
	float starttime;
	float endtime;
	int pointcount;
	Vector *points;
	Vector *points2;
	Vector *colors;
	float *alphas;
};


void kaupunki(float aika);
void kaupunki_init();
void kaupunki_free();

#endif 
