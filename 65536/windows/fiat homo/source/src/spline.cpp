#include "spline.hpp"

Spline::Spline(int controlpoints)
{
	int i;
	pointcount = controlpoints;
	points = new Vector[pointcount];

	for (i=0;i<pointcount;i++)
	{
		points[i] = Vector(0, 0, 0);
	}
}
Spline::~Spline()
{
	delete [] points;

}

void Spline::setPoint(int index, Vector &point)
{
	points[index] = point;
}

Vector Spline::getValue(float t)
{
	int nodepos = (int)floor((t*(pointcount-1)));

	Vector p0 = points[nodepos];
	Vector p1 = points[nodepos+1];
	Vector p2 = points[nodepos+2];
	Vector p3 = points[nodepos+3];

	float x = catmullromValue(t, p0.x, p1.x, p2.x, p3.x);
	float y = catmullromValue(t, p0.y, p1.y, p2.y, p3.y);
	float z = catmullromValue(t, p0.z, p1.z, p2.z, p3.z);

	return Vector(x, y, z);

}
