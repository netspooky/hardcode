#ifndef _DLA_HPP_
#define _DLA_HPP_

#include "../stuff.hpp"

class DLASystem
{
public:

	DLASystem(int count);
	~DLASystem();
	
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


void dla(float aika);
void dla_init();
void dla_free();

#endif 
 
