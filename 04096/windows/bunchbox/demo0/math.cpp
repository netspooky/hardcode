// BUNCHBOX, Brad Smith 9/18/2009

#include "math.h"

// vec3 implementation

vec3 vec3::neg() const { return vec3(-x,-y,-z); }
vec3 vec3::operator + ( const vec3 & b ) const { return vec3(x+b.x,y+b.y,z+b.z); }
vec3 vec3::operator - ( const vec3 & b ) const { return *this + b.neg(); }
vec3 vec3::operator * ( const float s ) const { return vec3(x*s,y*s,z*s); }
float vec3::dot( const vec3 & b ) const { return x*b.x + y*b.y + z*b.z; }

vec3 vec3::crs( const vec3 & b ) const
{
	return vec3(
			y*b.z - b.y*z,
			b.x*z - x*b.z,
			x*b.y - b.x*y
		);
}

vec3 vec3::nrm() const
{
	float l2 = dot( *this );
	return *this * (1.0f / fsqrt( dot(*this) ));	
}

void vminmax( vec3 * min, vec3 * max )
{
	for ( int i=0; i < 3; ++i )
	{
		float minv = min->v[i];
		float maxv = max->v[i];
		if ( minv > maxv )
		{
			min->v[i] = maxv;
			max->v[i] = minv;
		}
	}
}

// random

unsigned int seed;

unsigned int rndi()
{
	seed = (seed * 196314165UL) + 907633515UL;
	return seed;
}

float rndf()
{
	// replace exponent of random integer with 127
	return float(( rndi() & 255 ) / 255);
}


// end of file
