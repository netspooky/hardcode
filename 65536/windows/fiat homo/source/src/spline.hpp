#ifndef _SPLINE_HPP_
#define _SPLINE_HPP_

#include "stuff.hpp"

//Catmull-Rom spline
class Spline
{
public:
	Spline(int controlpoints);
	~Spline();
	void setPoint(int index, Vector &point);
	Vector getValue(float t);

private:

	int pointcount;
	Vector *points;
	

};





#endif
