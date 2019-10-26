// BUNCHBOX, Brad Smith 9/18/2009

#ifndef MATH_H
#define MATH_H

class vec3
{
	public:
	union
	{
		struct { float x,y,z; };
		float v[3];
	};

	inline vec3() {}
	inline vec3(float x_, float y_, float z_) : x(x_), y(y_), z(z_) {}
	inline vec3(int x_, int y_, int z_) : x(float(x_)), y(float(y_)), z(float(z_)) {}

	vec3 neg() const;
	vec3 operator + ( const vec3 & b ) const;
	vec3 operator - ( const vec3 & b ) const;
	vec3 operator * ( const float s ) const;
	float dot( const vec3 & b ) const;
	vec3 crs( const vec3 & b ) const;
	vec3 nrm() const;
};

extern void vminmax( vec3 * min, vec3 * max );

// random
extern unsigned int seed;
extern unsigned int rndi();
extern float rndf();

inline float fabs( float x )
{
	return ( x < 0.0f ) ? ( -x ) : x;
}

__forceinline float fsin( float x )
{
	__asm fld x;
	__asm fsin; // compute sin(rad), return in register
}

__forceinline float fcos( float x )
{
	__asm fld x;
	__asm fcos; // compute cos(rad), return in register
}

__forceinline float fsqrt( float x )
{
	__asm fld x;
	__asm fsqrt; // compute sqrt(x), return in register
}

const float TWO_PI = (2.0f * 3.14159f);

#endif // MATH_H
