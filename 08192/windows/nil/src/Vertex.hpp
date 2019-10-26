#ifndef VERTEX_HPP
#define VERTEX_HPP

struct Vertex
{
	double x, y, z;
	double a, r, g, b;
	double u, v;
	double viewerDistance;

	void Rotate( const double rx, const double ry, const double rz );
};


#endif