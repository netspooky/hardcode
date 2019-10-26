#ifndef _3DMATH_H_
#define _3DMATH_H_

#pragma warning (disable: 4244)

// math functions ... should be pretty stabel

//#define USEISSE
//#include <math.h>
#include "nrline.h"

class Matrix;
class Vector;

class Quaternion
{
public:	
    float x,y,z,w;
	

	inline Quaternion() {
      Identity();
	}
	
	inline Quaternion(float x, float y, float z,float w)
	{
		this->x=x; 
		this->y=y; 
		this->z=z;
        this->w=w;
	}

	inline void Identity()
	{
		x=y=z=0.f;
		w=1.0f;
	};
	
};


class Vector
{
public:	
	union {
		struct {float x,y,z, dummy0;};
		struct {float r,g,b, dummy1;};
		float longvec[4];
	};	

	inline Vector() {
	}
	
	inline Vector(const float x, const float y, const float z)
	{
		this->x=x; 
		this->y=y; 
		this->z=z;
	}

	inline Vector(unsigned int c) {
		r = (float)((c&0xff)*(1.0f/255.0f));
		g = (float)(((c>>8)&0xff)*(1.0f/255.0f));
		b = (float)(((c>>16)&0xff)*(1.0f/255.0f));
	}

	inline float& operator[](const int i)
	{
		if(i==0) return x;
		if(i==1) return y;
		return z;
	}
	
	inline void Set(float x, float y, float z)
	{
		this->x=x; 
		this->y=y;
		this->z=z;
	}
	
	inline Vector Abs () {
		Vector r;
		if (x<0) r.x = -x; else r.x = x;
		if (y<0) r.y = -y; else r.y = y;
		if (z<0) r.z = -z; else r.z = z;
		return r;
	}

	inline unsigned int AsRGB32()
	{
		return ((int)(b*255.f)<<16)|((int)(g*255.f)<<8)|(int)(r*255.f);
	}
	
	inline void Null()
	{
		x=y=z=0.f;
	}
	
	inline void Negate()
	{
		x=-x;
		y=-y;
		z=-z;
	}
	
	inline Vector Negated()
	{
		return Vector(-x, -y, -z);
	}

	inline void Square()
	{
		x*=x;
		y*=y;
		z*=z;
	}

	inline Vector Squared()
	{
		return Vector(x*x, y*y, z*z);
	}

	inline void Invert()
	{
		x=1.f/x;
		y=1.f/y;
		z=1.f/z;
	}

	inline Vector Inverted()
	{
		return Vector(1.f/x, 1.f/y, 1.f/z);
	}

	inline void clampf () {
		if (r>1) r = 1;
		if (g>1) g = 1;
		if (b>1) b = 1;
	}

	inline void Scale(Vector s)
	{
		x*=s.x;
		y*=s.y;
		z*=s.z;
	}
	
	inline Vector Scaled(Vector s)
	{
		return Vector(x*=s.x, y*=s.y, z*=s.z);
	}

	inline float Magnitude()
	{
		return sqrt(x*x+y*y+z*z);
	};
	
	inline float MagnitudeSquare() {
		return (float)(x*x+y*y+z*z);
	};
	
	inline void Normalise() {				
		#ifdef USEISSE			
			_asm {
				mov esi, this				
				movups xmm0, [esi]										
				shufps xmm0, xmm0, 0x24 // set uppermost float to valid value !
				movaps xmm2, xmm0
				mulps xmm2, xmm2
				movaps xmm1, xmm2
				shufps xmm2, xmm2, 39h
				addss xmm1, xmm2
				shufps xmm2, xmm2, 39h
				addss xmm1, xmm2
				rsqrtss xmm1, xmm1
				shufps xmm1, xmm1, 0
				mulps xmm0, xmm1				
				movups [esi], xmm0
			}
		#else
			float invlen=1.f/Magnitude();
			x*=invlen;
			y*=invlen;
			z*=invlen;	
		#endif		
	};

	inline void Normalise_Aligned() {						
		//StartCounter ("23Normalise");
		#ifdef USEISSE									
			_asm {
				mov esi, this // fuck pp
				movaps xmm0, [esi]		// 4					
				shufps xmm0, xmm0, 0x24 // set uppermost float to valid value !
				movaps xmm2, xmm0		// 1
				mulps xmm2, xmm2		// 5
				movaps xmm1, xmm2		// 1
				shufps xmm2, xmm2, 39h	// 2
				addss xmm1, xmm2		// 4
				shufps xmm2, xmm2, 39h	// 2
				addss xmm1, xmm2		// 4
				rsqrtss xmm1, xmm1		// 2
				shufps xmm1, xmm1, 0	// 2
				mulps xmm0, xmm1		// 5			
				movaps [esi], xmm0		// 4
			}			
		#else
			Normalise ();
		#endif		
		//StopCounter ("23Normalise");
	};

	/*
	inline Vector Normalised()
	{			
		Vector r;		
		#ifdef USEISSE					
			void *blongvec = (void*)(r.longvec);
			_asm {
				mov esi, this
				mov edi, blongvec
				movups xmm0, [esi]										
				shufps xmm0, xmm0, 0x24
				movaps xmm2, xmm0
				mulps xmm2, xmm2
				movaps xmm1, xmm2
				shufps xmm2, xmm2, 39h
				addss xmm1, xmm2
				shufps xmm2, xmm2, 39h
				addss xmm1, xmm2
				rsqrtss xmm1, xmm1
				shufps xmm1, xmm1, 0
				mulps xmm0, xmm1				
				movups [edi], xmm0
			}
		#else
			float invlen=1.f/Magnitude();
			r.x=x*invlen;
			r.y=y*invlen;
			r.z=z*invlen;	
		#endif		
		return r;
	};	
	*/
	
	inline void AddCompMul(Vector a, Vector b)
	{		
		x+=a.x*b.x;
		y+=a.y*b.y;
		z+=a.z*b.z;		
	}

	inline Vector Reflect(Vector n) 
	{ 
		Vector r;
		float d=-2.0f*(n.x*x+n.y*y+n.z*z);
		r.x=(d * n.x)+x;
		r.y=(d * n.y)+y;
		r.z=(d * n.z)+z;
		return r;
	}
	
	inline Vector &operator+=(const Vector &a)
	{		
		x+=a.x;
		y+=a.y;
		z+=a.z;
    return *this;
	}
	
	inline Vector &operator-=(const Vector &a)
	{
		x-=a.x;
		y-=a.y;
		z-=a.z;
    return *this;
	}
	
	inline Vector &operator*=(const float a)
	{
		x*=a;
		y*=a;
		z*=a;
    return *this;
	}
	
	inline Vector &operator*=(const Matrix m);
	inline Vector &operator/=(const Matrix m);

};

inline Vector operator-(const Vector &a)
{
	return Vector( -a.x, -a.y, -a.z);
}

inline Vector operator+(const Vector &a, const Vector &b)
{
  return Vector(a.x+b.x,a.y+b.y,a.z+b.z);
}

inline Vector operator-(const Vector &a, const Vector &b)
{
  return Vector(a.x-b.x,a.y-b.y,a.z-b.z);
}

inline Vector operator*(const Vector &a, const float b)
{
  return Vector(a.x*b, a.y*b, a.z*b);
}

inline Vector operator*(float a, const Vector &b)
{
  return Vector(a*b.x, a*b.y, a*b.z);
}

inline Vector operator/(const Vector &a, const float b)
{
	float ib=1.f/b;
	return Vector(a.x*ib, a.y*ib, a.z*ib);
}

inline float operator*(const Vector &a, const Vector &b)
{
  return a.x*b.x+a.y*b.y+a.z*b.z;
}

inline Vector operator%(const Vector &a, const Vector &b)
{
	return Vector(	a.y*b.z-a.z*b.y, 
					a.z*b.x-a.x*b.z, 
					a.x*b.y-a.y*b.x);
}

inline float operator|(Vector &a, Vector &b)
{
  float l=(a.x*a.x+a.y*a.y+a.z*a.z)*(b.x*b.x+b.y*b.y+b.z*b.z);
  if (l)
    l=1.f/sqrt(l);
	return (a.x*b.x+a.y*b.y+a.z*b.z)*l;
}


inline Matrix operator*(Matrix a, Matrix b);

class Matrix
{
public:
	float xx,xy,xz;
	float yx,yy,yz;
	float zx,zy,zz;
	float wx,wy,wz;

	inline Matrix()
	{
		Identity();
	};

	inline Matrix(Vector v)
	{
		Translation(v);
	};

	inline void Identity()
	{
		   xy=xz=0.f;
		yx=   yz=0.f;
		zx=zy   =0.f;
		wx=wy=wz=0.0f;
		xx=yy=zz=1.0f;
	};

    inline void fromQuaternion(Quaternion *q)
    {
      /*
      qt_matrix: convert a unit quaternion to rotation matrix.

          ( 1-yy-zz , xy+wz   , xz-wy   )
      T = ( xy-wz   , 1-xx-zz , yz+wx   )
          ( xz+wy   , yz-wx   , 1-xx-yy )
      */
      float fx2, fy2, fz2, fwx, fwy, fwz,
        fxx, fxy, fxz, fyy, fyz, fzz;

      fx2 = q->x + q->x; fy2 = q->y + q->y; fz2 = q->z + q->z;
      fwx = q->w * fx2;   fwy = q->w * fy2;   fwz = q->w * fz2;
      fxx = q->x * fx2;   fxy = q->x * fy2;   fxz = q->x * fz2;
      fyy = q->y * fy2;   fyz = q->y * fz2;   fzz = q->z * fz2;

      xx = (float) 1.0 - (fyy + fzz);
      yx = (float)fxy - fwz;
      zx = (float)fxz + fwy;
      wx = 0.0f;
      xy = (float)fxy + fwz;
      yy = (float)1.0f - (fxx + fzz);
      zy = (float)fyz - fwx;
      wy = 0.0f;
      xz = (float)fxz - fwy;
      yz = (float)fyz + fwx;
      zz = (float)1.0f - (fxx + fyy);
      wz = 0.0f;
    }


	inline void Inverse()
	{
		Matrix r;
		float d=1.0f/( 
			xx * ( yy * zz - yz * zy ) -
			xy * ( yx * zz - yz * zx ) +
			xz * ( yx * zy - yy * zx ) );
		
		r.xx =  d * ( yy * zz - yz * zy );
		r.xy = -d * ( xy * zz - xz * zy );
		r.xz =  d * ( xy * yz - xz * yy );
		
		r.yx = -d * ( yx * zz - yz * zx );
		r.yy =  d * ( xx * zz - xz * zx );
		r.yz = -d * ( xx * yz - xz * yx );
		
		r.zx =  d * ( yx * zy - yy * zx );
		r.zy = -d * ( xx * zy - xy * zx );
		r.zz =  d * ( xx * yy - xy * yx );
		
		r.wx = -( wx * r.xx + wy * r.yx + wz * r.zx );
		r.wy = -( wx * r.xy + wy * r.yy + wz * r.zy );
		r.wz = -( wx * r.xz + wy * r.yz + wz * r.zz );	
		*this=r;
	};	
		
	inline Matrix Translation(Vector v)
	{
		wx+=v.x;
		wy+=v.y;
		wz+=v.z;
		return *this;
	};

	
    inline Matrix PreTranslation(Vector v)
    {
		
      wx = xx*v.x + yx*v.y + zx*v.z + wx;
      wy = xy*v.x + yy*v.y + zy*v.z + wy;
      wz = xz*v.x + yz*v.y + zz*v.z + wz;
	  /*

      wx = xx*v.x + xy*v.y + xz*v.z + wx;
      wy = yx*v.x + yy*v.y + yz*v.z + wy;
      wz = zx*v.x + zy*v.y + zz*v.z + wz;
*/
      return *this;
    };


	inline Vector GetTranslation()
	{
		return Vector(wx, wy, wz);
	};

	inline Matrix Scale(float s)
	{
		Identity();
		xx=s;
		yy=s;
		zz=s;
		return *this;
	};

	inline Matrix Scale(Vector v)
	{
		Identity();
		xx=v.x;
		yy=v.y;
		zz=v.z;
		return *this;
	};

	inline Matrix NoScale(Vector v)
	{
		xx=1.f;
		yy=1.f;
		zz=1.f;
		return *this;
	};

	inline Matrix Rotation(Vector v)
	{
		float sx=sin(v.x);
		float sy=sin(v.y);
		float sz=sin(v.z);
		float cx=cos(v.x);
		float cy=cos(v.y);
		float cz=cos(v.z);

		xx=cy*cz; 
		xy=cy*sz; 
		xz=-sy;
		yx=sx*sy*cz-cx*sz; 
		yy=sx*sy*sz+cx*cz; 
		yz=sx*cy;
		zx=cx*sy*cz+sx*sz; 
		zy=cx*sy*sz-sx*cz; 
		zz=cx*cy;

		return *this;
	};


	inline void Space(Vector space)
	{
		float dot=Vector(0, 1, 0)*space;
		Vector up=Vector(0, 1, 0)-dot*space;
		up.Normalise();
		Vector right=up%space;    
		
		Identity();
		xx=right.x;
		xy=up.x;
		xz=space.x;
		yx=right.y;
		yy=up.y;
		yz=space.y;
		zx=right.z;
		zy=up.z;
		zz=space.z;
		wx=0;
		wy=0;
		wz=0;
	};

	inline Vector TransInverseBase (Vector v) {
		Vector r;
		/*
		r.x=v.x*zz+ v.y*zy+ v.z*zx;
		r.y=v.x*yz+ v.y*yy+ v.z*yx;
		r.z=v.x*xz+ v.y*xy+ v.z*yy;
		*/

		r.x=v.x*xx+ v.y*xy+ v.z*xz;
		r.y=v.x*yx+ v.y*yy+ v.z*yz;
		r.z=v.x*zx+ v.y*zy+ v.z*zz;

		return r;
	};
	
	inline void Camera(float roll, Vector position, Vector target)
	{
		Vector worldup(sin(-roll), cos(-roll), 0.0f);    
		Vector view=-(target-position);
		view.Normalise();
		float dot=worldup*view;
		Vector up=worldup-dot*view;
		up.Normalise();
		Vector right=up%view;    
		
		Identity();
		xx=right.x;
		xy=up.x;
		xz=view.x;
		yx=right.y;
		yy=up.y;
		yz=view.y;
		zx=right.z;
		zy=up.z;
		zz=view.z;
		wx=-(position*right);
		wy=-(position*up);
		wz=-(position*view);
		
		//Inverse();
	};
	
	void RaytraceCamera(float roll, Vector position, Vector target)
	{
		Vector worldup(sin(-roll), cos(-roll), 0.0f);    
		Vector view=-(target-position);
		view.Normalise();
		float dot=worldup*view;
		Vector up=worldup-dot*view;
		up.Normalise();
		Vector right=up%view;    
		
		Identity();
		xx=right.x;
		xy=up.x;
		xz=view.x;
		yx=right.y;
		yy=up.y;
		yz=view.y;
		zx=right.z;
		zy=up.z;
		zz=view.z;
		wx=0;
		wy=0;
		wz=0;
		Inverse();
	};

	Matrix operator *=(Matrix m)
	{
		*this=*this*m;
		return *this;
	};
};

inline Vector operator*(Vector &v, Matrix &m)
{
	Vector r;
	r.x=v.x*m.xx+ v.y*m.yx+ v.z*m.zx+ m.wx;
	r.y=v.x*m.xy+ v.y*m.yy+ v.z*m.zy+ m.wy;
	r.z=v.x*m.xz+ v.y*m.yz+ v.z*m.zz+ m.wz;
	return r;
}


//ok, we know / makes no sence, what we mean is a multiplication without translation!!!
inline Vector operator/(Vector v, Matrix m)
{
	Vector r;
	r.x=v.x*m.xx+ v.y*m.yx+ v.z*m.zx;
	r.y=v.x*m.xy+ v.y*m.yy+ v.z*m.zy;
	r.z=v.x*m.xz+ v.y*m.yz+ v.z*m.zz;
	return r;
}


inline Vector &Vector::operator*=(const Matrix m)
{
	Vector r;
	r.x=x*m.xx+ y*m.yx+ z*m.zx+ m.wx;
	r.y=x*m.xy+ y*m.yy+ z*m.zy+ m.wy;
	r.z=x*m.xz+ y*m.yz+ z*m.zz+ m.wz;
	*this=r;
	return *this;
}

//ok, we know / makes no sence, what we mean is a multiplication without translation!!!
inline Vector &Vector::operator/=(const Matrix m)
{
	Vector r;
	r.x=x*m.xx+ y*m.yx+ z*m.zx;
	r.y=x*m.xy+ y*m.yy+ z*m.zy;
	r.z=x*m.xz+ y*m.yz+ z*m.zz;
	*this=r;
	return *this;
}


inline Matrix operator*(Matrix a, Matrix b)
{
	Matrix temp;
	temp.xx=a.xx*b.xx+a.yx*b.xy+a.zx*b.xz;
	temp.yx=a.xx*b.yx+a.yx*b.yy+a.zx*b.yz;
	temp.zx=a.xx*b.zx+a.yx*b.zy+a.zx*b.zz;
	temp.wx=a.xx*b.wx+a.yx*b.wy+a.zx*b.wz+a.wx;
	temp.xy=a.xy*b.xx+a.yy*b.xy+a.zy*b.xz;
	temp.yy=a.xy*b.yx+a.yy*b.yy+a.zy*b.yz;
	temp.zy=a.xy*b.zx+a.yy*b.zy+a.zy*b.zz;
	temp.wy=a.xy*b.wx+a.yy*b.wy+a.zy*b.wz+a.wy;
	temp.xz=a.xz*b.xx+a.yz*b.xy+a.zz*b.xz;
	temp.yz=a.xz*b.yx+a.yz*b.yy+a.zz*b.yz;
	temp.zz=a.xz*b.zx+a.yz*b.zy+a.zz*b.zz;
	temp.wz=a.xz*b.wx+a.yz*b.wy+a.zz*b.wz+a.wz;
	return temp;
}



#endif //_3DMATH_H_