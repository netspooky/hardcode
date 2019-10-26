#include "stdinc.hpp"

#include "Vertex.hpp"



void Vertex::Rotate( const double rx, const double ry, const double rz )
{
	// x rotation
	if( rx!= 0 )
	{
		double temp= y;
		y= y*cos( rx ) - z*sin( rx );
		z= temp*sin( rx ) + z*cos( rx );
	}
	
	// y rotation
	if( ry!= 0 )
	{
		double temp= x;
		x= x*cos( ry ) + z*sin( ry );
		z= -temp*sin( ry ) + z*cos( ry );
	}
	
	// z rotation
	if( rz!= 0 )
	{
		double temp= x;
		x= x*cos( rz ) - y*sin( rz );
		y= temp*sin( rz ) + y*cos( rz );
	}
}
