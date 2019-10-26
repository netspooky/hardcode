#ifndef _LINESTRIP_HPP_
#define _LINESTRIP_HPP_

struct LineStrip
{
public:
	int count;
	int count2;
	Vector *vertices;
	Vector *vertices2;

	float *alphas;

	float starttime;
	float endtime;

};


#endif 
