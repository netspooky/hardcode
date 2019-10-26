//#ifndef _Y16I_COMMON_
//#define _Y16I_COMMON_
#include <math.h>


///////////////////////////////////////////////////////////////////////////////////////////
// classÇêÈåæ

////////////////////////////////////////////////////////////////////////////////
// 2 points
class cVec2f{
public:
	float x, y;
	
public:
	cVec2f(){
	}
	~cVec2f(){
	}
	cVec2f(float a, float b) : x(a),y(b){}
	inline float& operator[](int i){
		return (&x)[i];
	}
	
	inline const cVec2f& operator=(const cVec2f a){
		x=a.x;	y=a.y;
		return *this;
	}
	inline const cVec2f operator+(const cVec2f& a) const{
		return cVec2f(x+a.x, y+a.y);
	}
	inline const cVec2f operator-(const cVec2f& a) const{
		return cVec2f(x-a.x, y-a.y);
	}
	inline const cVec2f& operator/(const float a){
		x/=a;	y/=a;
		return *this;
	}
	inline const cVec2f& operator*(const float a){
		x*=a;	y*=a;
		return *this;
	}
	inline const cVec2f& operator+=(const cVec2f& a){
		x+=a.x;	y+=a.y;
		return *this;
	}
	inline const cVec2f& operator-=(const cVec2f& a){
		x-=a.x;	y-=a.y;
		return *this;
	}
};


////////////////////////////////////////////////////////////////////////////////
// 3 points
class cVec3f{
public:
	float x, y, z;
	
public:
	cVec3f(){
	}
	~cVec3f(){
	}
	cVec3f(float a, float b, float c) : x(a),y(b),z(c){}
	inline float& operator[](int i){
		return (&x)[i];
	}

	inline const cVec3f& operator=(const cVec3f a){
		x=a.x;	y=a.y;	z=a.z;
		return *this;
	}
	inline const cVec3f operator+(const cVec3f& a) const{
		return cVec3f(x+a.x, y+a.y, z+a.z);
	}
	inline const cVec3f operator-(const cVec3f& a) const{
		return cVec3f(x-a.x, y-a.y, z-a.z);
	}

	inline const cVec3f& operator=(const float a){
		x=a;	y=a;	z=a;
		return *this;
	}
	inline const cVec3f operator+(const float& a) const{
		return cVec3f(x+a, y+a, z+a);
	}
	inline const cVec3f operator-(const float& a) const{
		return cVec3f(x-a, y-a, z-a);
	}

	inline const cVec3f operator/(const float a) const{
//		x/=a;	y/=a;	z/=a;
//		return *this;
		cVec3f tmp=cVec3f(x/a, y/a, z/a);
//		tmp.x=x/a;
//		tmp.y=y/a;
//		tmp.z=z/a;
		return tmp;
	}


	inline const cVec3f operator*(const float a) const{
		cVec3f tmp=cVec3f(x*a, y*a, z*a);
//		tmp.x = x*a;
//		tmp.y = y*a;
//		tmp.z = z*a;
		return tmp;
	}
	inline const cVec3f operator*(const cVec3f a) const{
		cVec3f tmp=cVec3f(x*a.z, y*a.y, z*a.z);
//		tmp.x=x*a.z;
//		tmp.y=y*a.y;
//		tmp.z=z*a.z;
		return tmp;
	}


	inline const cVec3f& operator*=(const cVec3f a){
		x*=a.x;	y*=a.y;	z*=a.z;
		return *this;
	}
	inline const cVec3f& operator*=(const float a){
		x*=a;	y*=a;	z*=a;
		return *this;
	}

	inline const cVec3f& operator+=(const float& a){
		x+=a;	y+=a;	z+=a;
		return *this;
	}
	inline const cVec3f& operator+=(const cVec3f& a){
		x+=a.x;	y+=a.y;	z+=a.z;
		return *this;
	}

	inline const cVec3f& operator-=(const cVec3f& a){
		x-=a.x;	y-=a.y;	z-=a.z;
		return *this;
	}
	inline const cVec3f& operator-=(const float& a){
		x-=a;	y-=a;	z-=a;
		return *this;
	}
	
	inline const void normalize(void){
		float dmp=sqrt(x*x + y*y + z*z);
		if(dmp!=0){
			x/=dmp;
			y/=dmp;
			z/=dmp;
		}
		else{
			x=y=z=1.0;
		}
	}
};


////////////////////////////////////////////////////////////////////////////////
// size w, h
class cSize2f{
public:
	float w, h;
	
public:
	cSize2f(){
	}
	~cSize2f(){
	}
	cSize2f(float a, float b) : w(a),h(b){}
	inline float& operator[](int i){
		return (&w)[i];
	}
	inline const cSize2f& operator=(const cSize2f a){
		w=a.w;	h=a.h;
		return *this;
	}
	inline const cSize2f operator+(const cSize2f& a) const{
		return cSize2f(w+a.w, h+a.h);
	}
	inline const cSize2f operator-(const cSize2f& a) const{
		return cSize2f(w-a.w, h-a.h);
	}
	inline const cSize2f& operator/(const float a){
		w/=a;	h/=a;
		return *this;
	}

	inline const cSize2f& operator*(const float a){
		w*=a;	h*=a;
		return *this;
	}
	inline const cSize2f& operator+=(const cSize2f& a){
		w+=a.w;	h+=a.h;
		return *this;
	}
	inline const cSize2f& operator-=(const cSize2f& a){
		w-=a.w;	h-=a.h;
		return *this;
	}
};

class cSize3f{
public:
	float w, h, d;

public:
	cSize3f(){
	}
	~cSize3f(){
	}
	cSize3f(float a, float b, float c) : w(a),h(b),d(c){}
	inline float& operator[](int i){
		return (&w)[i];
	}
	inline const cSize3f& operator=(const cSize3f a){
		w=a.w;	h=a.h;	d=a.d;
		return *this;
	}
	inline const cSize3f operator+(const cSize3f& a) const{
		return cSize3f(w+a.w, h+a.h, d+a.d);
	}
	inline const cSize3f operator-(const cSize3f& a) const{
		return cSize3f(w-a.w, h-a.h, d-a.d);
	}
	inline const cSize3f& operator/(const float a){
		w/=a;	h/=a;	d/=a;
		return *this;
	}

	inline const cSize3f& operator*(const float a){
		w*=a;	h*=a;	d*=a;
		return *this;
	}
	inline const cSize3f& operator+=(const cSize3f& a){
		w+=a.w;	h+=a.h;	d+=a.d;
		return *this;
	}
	inline const cSize3f& operator-=(const cSize3f& a){
		w-=a.w;	h-=a.h;	d-=a.d;
		return *this;
	}
};
////////////////////////////////////////////////////////////////////////////////
// RGBA COLOR SET
class cColor4f{
public:
	float r, g, b, a;
	
public:
	cColor4f(){
	}
	~cColor4f(){
	}
	cColor4f(float i, float j, float k, float l) : r(i),g(j),b(k),a(l){}
	inline const cColor4f& operator=(const float val){
		r=val;	g=val;	b=val;	a=val;
		return *this;
	}
};




////////////////////////////////////////////////////////////////////////////////
// for GL Vertex array
/*
struct sVertexArray{
	GLfloat x, y, z;
	GLfloat r, g, b, a;
	GLfloat u, v;
	GLfloat nx, ny, nz;
};
*/

class cVertex{
public:
	cVec3f v;
	cColor4f c;
	cVec3f n;
	cVec2f t;
	
public:
	cVertex()
	{
	}
	~cVertex()
	{
	}
};


//#endif _Y16I_COMMON_

