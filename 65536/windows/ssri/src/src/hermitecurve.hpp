#ifndef _HERMITECURVE_HPP_
#define _HERMITECURVE_HPP_

#include "stuff.hpp"

class HermiteCurve
{
public:
	HermiteCurve();
	HermiteCurve(Vector &point1, Vector &point2, Vector &point3, Vector &point4);
	~HermiteCurve();

	void set(Vector &point1, Vector &point2, Vector &point3, Vector &point4);

	Vector getValue(float t);
	Vector getDerivative(float t);

private:

	Vector P1, P2, P3, P4;

	inline float value(float p1, float p2, float p3, float p4, float t);
	inline float derivativeValue(float p1, float p2, float p3, float p4, float t);
};


#endif
