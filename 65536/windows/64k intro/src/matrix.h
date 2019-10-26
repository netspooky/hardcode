#include <math.h>
///////////////////////////////////////////////////////////////////////////////////////////
// matrix.h
// |a|=sqrt((a.x-0)*(a.x-0) + (a.y-0)*(a.y-0) + (a.z-0)*(a.z-0))
// θ=1/(sin((a・b) / (|a|・|b|)))

// Cross product
inline cVec3f crosprod(cVec3f* f, cVec3f* b)
{
	cVec3f tmp=cVec3f(
					f->y * b->z - f->z * b->y,
					f->z * b->x - f->x * b->z,
					f->x * b->y - f->y * b->x
					);
	return tmp;
}

// Dot product
inline float dotprod(cVec3f* f, cVec3f* b)
{
	return f->x*b->x + f->y*b->y + f->z*b->z;
}

// compute angle from 2 vectors
inline float getAngle(cVec3f* a, cVec3f* b)
{
	float amag = sqrt(a->x*a->x + a->y*a->y + a->z*a->z);
	float bmag = sqrt(b->x*b->x + b->y*b->y + b->z*b->z);
	float ablen = amag*bmag;
	if(ablen==0)	return 180;
	
	float adotb=dotprod(a, b);
 	return float( 57.2958 * acosf(adotb/ablen) );
}

// Addition vector
inline void add(cVec3f* a, cVec3f* s, cVec3f* d)
{
	a->x=s->x + d->x;
	a->y=s->y + d->y;
	a->z=s->z + d->z;
}

// Subtrantion vector
inline void sub(cVec3f* a, cVec3f* s, cVec3f* d)
{
	a->x=s->x - d->x;
	a->y=s->y - d->y;
	a->z=s->z - d->z;
}

// Division vector
inline void divide(cVec3f* d, cVec3f* o, float divs)
{
	float I=1.0/divs;
	d->x=o->x*I;
	d->y=o->y*I;
	d->z=o->z*I;
}

// Compute length
inline float length(cVec3f* c)
{
	return sqrt(c->x*c->x + c->y*c->y + c->z*c->z);
}


// Turning Optional Axis
/*
"A" is axis.
|x| |Ax*Ax*(1-cos(r))+cos(r),		Ax*Ay*(1-cos(r))-Az*sin(r),	Ax*Az*(1-cos(r))+Ay*sin(r)|
|y|*|Ay*Ax*(1-cos(r))+Az*sin(r),	Ay*Ay*(1-cos(r))+cos(r),	Ay*Az*(1-cos(r))-Ax*sin(r)|
|z| |Az*Ax*(1-cos(r))-Ay*sin(r).	Az*Ay*(1-cos(r))+Ax*sin(r),	Az*Az*(1-cos(r))+cos(r)   |
*/
inline cVec3f turnOptAxis(float angle, cVec3f src, float x, float y, float z)
{
	// normalize
	if(x>1 || y>1 || z>1){
		cVec3f nrm=cVec3f(x, y, z);
		nrm.normalize();
		x=nrm.x;	y=nrm.y;	z=nrm.z;
	}
	
	cVec3f tmp;
	float rad=angle*PI/180;
	float one=1-yCos(rad);
	tmp = cVec3f(
			src.x * (x*x*one + yCos(rad)) +
			src.y * (y*x*one + z*ySin(rad)) +
			src.z * (z*x*one - y*ySin(rad)),
			
			src.x * (x*y*one - z*ySin(rad)) +
			src.y * (y*y*one + yCos(rad)) +
			src.z * (z*y*one + x*ySin(rad)),
			
			src.x * (x*z*one + y*ySin(rad)) +
			src.y * (y*z*one - x*ySin(rad)) +
			src.z * (z*z*one + yCos(rad))
			);
	return tmp;
}

///////////////////////////////////////////////////////////////////////
// calculate normalizes from 3 points
inline void cal2n(cVec3f aspect[2], cVec3f f, cVec3f c, cVec3f b)	// 曲線上にある点で直交する２法線 front, center, back
{
	cVec3f fl=cVec3f(f.x-c.x, f.y-c.y, f.z-c.z);
	cVec3f bl=cVec3f(b.x-c.x, b.y-c.y, b.z-c.z);
	
//	cVec3f c0, c1;
	cVec3f c0=crosprod(&fl, &bl);				//外積
	cVec3f c1=crosprod(&fl, &c0);				//外積
	
	c0.normalize();
	c1.normalize();
	aspect[0]=c0;
	aspect[1]=c1;
}

