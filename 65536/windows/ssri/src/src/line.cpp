#include "line.hpp"

void Line::calcPos(float t, Vector *d1, Vector *d2)
{
	float linet = calcPosFloat(t, starttime, endtime);

	Vector rot = lerpVector(startrot, endrot, linet);
	Vector pos = lerpVector(startpos, endpos, linet);

	Matrix rotate;
	rotate.makeRotation(rot.x, rot.y, rot.z);

	Vector t1 = pos + Vector(length, 0, 0)*rotate;
	Vector t2 = pos + Vector(-length, 0, 0)*rotate;

	*d1 = t1;
	*d2 = t2;
}
