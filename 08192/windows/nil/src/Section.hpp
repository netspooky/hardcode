#ifndef SECTION_HPP
#define SECTION_HPP

#include "Vertex.hpp"

struct Section
{
	Vertex* verts;
	int type;
	int start, end;

	void Render();
	void RenderAsParticles( const float particleSize );
//	void Rotate( const double x, const double y, const double z );
//	void Translate( const double x, const double y, const double z );
//	void SetColor( const double r, const double g, const double b, 
//		const double a );
	void SetViewerDistance( const double vx, const double vy, 
		const double vz );
//	void CopyFrom( Section& otherSection );

//	void GenLineCube( const int iterations, const double size );
//	void GenShell( const int iterations, const double size );

//	void Suction( const double strength, 
//		const double cx, const double cy, const double cz );
};


#endif