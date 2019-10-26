// --------------------------------------------------------------------------------------
// Vectors.h
// Algebra classes
// --------------------------------------------------------------------------------------

#ifndef _VECTORS_H_
#define _VECTORS_H_

#include <math.h>

// Notes on handedness and stuff
// The way to transform a vertex is: v' = v*M

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
struct TVector2
{
  float x, y;

  inline TVector2()                    { }
  inline TVector2(float _x, float _y)  { x = _x; y = _y; }

  inline const TVector2& Zero      ()                    { x = 0.f; y = 0.f; return *this; }
  inline const TVector2& Set       (float _x, float _y)  { x = _x; y = _y; return *this; }
  inline const TVector2& SetAngDist(float a, float d)    { x = d*float(cos(a)); y = d*float(sin(a)); return *this; }
  inline const TVector2& Normalize ()                    { float f = InvMod(); x *= f; y *= f; return *this; }
  inline const TVector2& Rotate    (float a)             { float c = float(cos(a)), s = float(sin(a)); float tx = x*c - y*s; y = x*s + y*c; x = tx; return *this; }
  inline const TVector2& Rotate    (float c, float s)    { float tx = x*c - y*s; y = x*s + y*c; x = tx; return *this; }

  inline       TVector2 GetNormalized  () const          { float f = InvMod(); return TVector2(x * f, y * f); }

  inline       TVector2 operator + (const TVector2 &v) const   { return TVector2(x + v.x, y + v.y); }
  inline       TVector2 operator - (const TVector2 &v) const   { return TVector2(x - v.x, y - v.y); }
  inline       TVector2 operator * (float f) const             { return TVector2(x * f, y * f); }
  inline       TVector2 operator / (float f) const             { float f1 = 1.f/f; return TVector2(x * f1, y * f1); }

  friend TVector2 operator * (float f, const TVector2 &v);
  friend TVector2 operator / (float f, const TVector2 &v);

  inline const TVector2 &operator += (const TVector2 &v)   { x += v.x; y += v.y; return *this; }
  inline const TVector2 &operator -= (const TVector2 &v)   { x -= v.x; y -= v.y; return *this; }
  inline const TVector2 &operator *= (float f)             { x *= f; y *= f; return *this; }
  inline const TVector2 &operator /= (float f)             { float f1 = 1.f/f; x *= f1; y *= f1; return *this; }

  inline       bool      operator == (const TVector2 &v) const   { return x == v.x && y == v.y; }


  inline float       Angle       () const                  { return float(atan2(y, x)); }
  inline float       Mod2        () const                  { return x*x + y*y; }
  inline float       Mod         () const                  { return float(sqrt(x*x + y*y)); }
  inline float       InvMod2     () const                  { return 1.f/(x*x + y*y); }
  inline float       InvMod      () const                  { return 1.f/float(sqrt(x*x + y*y)); }

  inline float       DotProd     (const TVector2 &v) const { return x*v.x + y*v.y; }
  inline float       CrossProd   (const TVector2 &v) const { return x*v.y - y*v.x; }

};

// --------------------------------------------------------------------------------------

inline TVector2 operator * (float f, const TVector2 &v)  { return TVector2(v.x * f, v.y * f); }
inline TVector2 operator / (float f, const TVector2 &v)  { float f1 = 1.f/f; return TVector2(v.x * f1, v.y * f1); }

// --------------------------------------------------------------------------------------

static const TVector2 V2_Zero (0.f, 0.f);
static const TVector2 V2_XAxis(1.f, 0.f);
static const TVector2 V2_YAxis(0.f, 1.f);


// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
struct TVector3: public TVector2
{
  float z;

  inline TVector3()                             { }
  inline TVector3(float _x, float _y, float _z) { x = _x; y = _y; z = _z; }

  inline const TVector3& Zero      ()                             { x = 0.f; y = 0.f; z = 0.f; return *this; }
  inline const TVector3& Set       (float _x, float _y, float _z) { x = _x; y = _y; z = _z; return *this; }
  inline const TVector3& SetAngDist(float ax, float az, float d)  { float r = d*float(cos(az)); x = r*float(cos(ax)); y = r*float(sin(ax)); z = d*float(sin(az)); return *this; }
  inline const TVector3& Normalize ()                             { float f = InvMod(); x *= f; y *= f; z *= f; return *this; }
                                                          
  inline       TVector3 GetNormalized  () const          { float f = InvMod(); return TVector3(x * f, y * f, z * f); }

  inline       TVector3 operator + (const TVector3 &v) const   { return TVector3(x + v.x, y + v.y, z + v.z); }
  inline       TVector3 operator - (const TVector3 &v) const   { return TVector3(x - v.x, y - v.y, z - v.z); }
  inline       TVector3 operator * (float f) const             { return TVector3(x * f, y * f, z * f); }
  inline       TVector3 operator / (float f) const             { float f1 = 1.f/f; return TVector3(x * f1, y * f1, z * f1); }

  friend TVector3 operator * (float f, const TVector3 &v);
  friend TVector3 operator / (float f, const TVector3 &v);

//  const TVector3 &operator =(const TVector3 &v) const   { x = v.x; y = v.y; return *this; }

  inline const TVector3 &operator += (const TVector3 &v)   { x += v.x; y += v.y; z += v.z; return *this; }
  inline const TVector3 &operator -= (const TVector3 &v)   { x -= v.x; y -= v.y; z -= v.z; return *this; }
  inline const TVector3 &operator *= (float f)             { x *= f; y *= f; z *= f; return *this; }
  inline const TVector3 &operator /= (float f)             { float f1 = 1.f/f; x *= f1; y *= f1; z *= f1; return *this; }

  inline       bool      operator == (const TVector3 &v) const   { return x == v.x && y == v.y && z == v.z; }


  inline float       Mod2        () const                  { return x*x + y*y + z*z; }
  inline float       Mod         () const                  { return float(sqrt(x*x + y*y + z*z)); }
  inline float       InvMod2     () const                  { return 1.f/(x*x + y*y + z*z); }
  inline float       InvMod      () const                  { return 1.f/float(sqrt(x*x + y*y + z*z)); }

  inline float       DotProd     (const TVector3 &v) const { return x*v.x + y*v.y + z*v.z; }
  inline TVector3    CrossProd   (const TVector3 &v) const { return TVector3(y*v.z - z*v.y, z*v.x - x*v.z, x*v.y - y*v.x); }

};


inline TVector3 operator * (float f, const TVector3 &v)  { return TVector3(v.x * f, v.y * f, v.z * f); }
inline TVector3 operator / (float f, const TVector3 &v)  { float f1 = 1.f/f; return TVector3(v.x * f1, v.y * f1, v.z * f1); }

static const TVector3 V3_Zero (0.f, 0.f, 0.f);
static const TVector3 V3_XAxis(1.f, 0.f, 0.f);
static const TVector3 V3_YAxis(0.f, 1.f, 0.f);
static const TVector3 V3_ZAxis(0.f, 0.f, 1.f);

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
union TMatrix4
{
  float m[4][4];
  struct
  {
    float _11, _12, _13, _14;
    float _21, _22, _23, _24;
    float _31, _32, _33, _34;
    float _41, _42, _43, _44;
  };
};

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
struct TMatrix3
{
  float m[4][3];

  inline TMatrix3()                                   { }
  inline TMatrix3(float m00, float m01, float m02,
                  float m10, float m11, float m12,
                  float m20, float m21, float m22,
                  float m30, float m31, float m32)
  {
    m[0][0] = m00; m[0][1] = m01; m[0][2] = m02;
    m[1][0] = m10; m[1][1] = m11; m[1][2] = m12;
    m[2][0] = m20; m[2][1] = m21; m[2][2] = m22;
    m[3][0] = m30; m[3][1] = m31; m[3][2] = m32;
  }
  inline TMatrix3(float m00, float m01, float m02,
                  float m10, float m11, float m12,
                  float m20, float m21, float m22)
  {
    m[0][0] = m00; m[0][1] = m01; m[0][2] = m02;
    m[1][0] = m10; m[1][1] = m11; m[1][2] = m12;
    m[2][0] = m20; m[2][1] = m21; m[2][2] = m22;
  }

  inline const TMatrix3 &SetTranslation   (float x, float y, float z) { m[3][0] = x; m[3][1] = y; m[3][2] = z; return *this; }
  inline const TMatrix3 &ZeroTranslation  ()                          { m[3][0] = 0; m[3][1] = 0; m[3][2] = 0; return *this; }

  inline const TMatrix3 &SetRotationX     (float a)
  {
    float c = float(cos(a));
    float s = float(sin(a)); 
    m[0][0] =  1; m[0][1] =  0; m[0][2] =  0;
    m[1][0] =  0; m[1][1] =  c; m[1][2] = -s;
    m[2][0] =  0; m[2][1] =  s; m[2][2] =  c;
    return *this;
  }
  inline const TMatrix3 &SetRotationY     (float a)
  {
    float c = float(cos(a));
    float s = float(sin(a)); 
    m[0][0] =  c; m[0][1] =  0; m[0][2] = -s;
    m[1][0] =  0; m[1][1] =  1; m[1][2] =  0;
    m[2][0] =  s; m[2][1] =  0; m[2][2] =  c;
    return *this;
  }
  inline const TMatrix3 &SetRotationZ     (float a)
  {
    float c = float(cos(a));
    float s = float(sin(a)); 
    m[0][0] =  c; m[0][1] = -s; m[0][2] =  0;
    m[1][0] =  s; m[1][1] =  c; m[1][2] =  0;
    m[2][0] =  0; m[2][1] =  0; m[2][2] =  1;
    return *this;
  }

  inline const TMatrix3 &SetRotationXY    (float x, float y)
  {
    float cx = float(cos(x));
    float sx = float(sin(x)); 
    float cy = float(cos(y));
    float sy = float(sin(y)); 

    m[0][0] =     cy; m[0][1] =      0; m[0][2] = -sy;
    m[1][0] = -sx*sy; m[1][1] =     cx; m[1][2] = -sx*cy;
    m[2][0] =  cx*sy; m[2][1] =     sx; m[2][2] =  cx*cy;

    return *this;
  }

  inline const TMatrix3 &SetScale         (float x, float y, float z)
  {
    m[0][0] =  x; m[0][1] =  0; m[0][2] =  0;
    m[1][0] =  0; m[1][1] =  y; m[1][2] =  0;
    m[2][0] =  0; m[2][1] =  0; m[2][2] =  z;
    return *this;
  }


  inline const TMatrix3 &SetRotationAxisAngle (TVector3 v, float a)
  {
    float c = float(cos(a));
    float s = float(sin(a));
    float ic = 1.f - c;
    float xs = v.x*s;
    float ys = v.y*s;
    float zs = v.z*s;

    m[0][0] = ( v.x * v.x ) * ic + c;
    m[0][1] = ( v.x * v.y ) * ic - zs;
    m[0][2] = ( v.x * v.z ) * ic + ys;

    m[1][0] = ( v.y * v.x ) * ic + zs;
    m[1][1] = ( v.y * v.y ) * ic + c;
    m[1][2] = ( v.y * v.z ) * ic - xs;

    m[2][0] = ( v.z * v.x ) * ic - ys;
    m[2][1] = ( v.z * v.y ) * ic + xs;
    m[2][2] = ( v.z * v.z ) * ic + c;
    return *this;
  } 

  inline const TMatrix3 &SetLookAt (const TVector3 &vFrom, const TVector3 &vAt, TVector3 vUp)
  {
    TVector3 vView = vAt - vFrom;

    float len = vView.Mod();
    if (len < 1e-6f)
      return *this;

    vView /= len;

    float dot = vUp.DotProd(vView);
    TVector3 vLup = vUp - vView*dot;

    // If this vector has near-zero length because the input specified a bogus up vector,
    // let's try a default up vector. If still have near-zero length, resort to a different axis.
    len = vLup.Mod();
    if (len < 1e-6f)
    {
      vLup.Set(0, 1, 0) - vView*vView.y;
      len = vLup.Mod();
      if (len < 1e-6f)
      {
        vUp.Set(0, 0, 1) - vView*vView.z;
        len = vLup.Mod();
        if (len < 1e-6f)
          return *this;
      }
    }
    vLup /= len;

    TVector3 vRight = vLup.CrossProd(vView);
    m[0][0] = vRight.x; m[0][1] = vLup.x; m[0][2] = vView.x;
    m[1][0] = vRight.y; m[1][1] = vLup.y; m[1][2] = vView.y;
    m[2][0] = vRight.z; m[2][1] = vLup.z; m[2][2] = vView.z;
    m[3][0] = -vRight.DotProd(vFrom);
    m[3][1] = -vLup.DotProd(vFrom);
    m[3][2] = -vView.DotProd(vFrom);
    return *this;
  }

  friend       TVector3 operator * (const TVector3 &v, const TMatrix3 &m);
  inline       TVector3 operator * (const TVector3 &v) const
  {
    return TVector3(v.DotProd(GetRow(0)) + m[3][0],
                    v.DotProd(GetRow(1)) + m[3][1],
                    v.DotProd(GetRow(2)) + m[3][2]);
  }

/*
  // La multiplicacion de matrices asume que los vectores se multiplican por la derecha: v' = M*v
  // De esta forma, se rota la traslacion de la matriz parametro por nuestra rotacion.
  inline       TMatrix3 operator * (const TMatrix3 &_m) const
  {
    TMatrix3 r(m[0][0]*_m.m[0][0] + m[0][1]*_m.m[1][0] + m[0][2]*_m.m[2][0],
               m[0][0]*_m.m[0][1] + m[0][1]*_m.m[1][1] + m[0][2]*_m.m[2][1],
               m[0][0]*_m.m[0][2] + m[0][1]*_m.m[1][2] + m[0][2]*_m.m[2][2],
               
               m[1][0]*_m.m[0][0] + m[1][1]*_m.m[1][0] + m[1][2]*_m.m[2][0],
               m[1][0]*_m.m[0][1] + m[1][1]*_m.m[1][1] + m[1][2]*_m.m[2][1],
               m[1][0]*_m.m[0][2] + m[1][1]*_m.m[1][2] + m[1][2]*_m.m[2][2],
               
               m[2][0]*_m.m[0][0] + m[2][1]*_m.m[1][0] + m[2][2]*_m.m[2][0],
               m[2][0]*_m.m[0][1] + m[2][1]*_m.m[1][1] + m[2][2]*_m.m[2][1],
               m[2][0]*_m.m[0][2] + m[2][1]*_m.m[1][2] + m[2][2]*_m.m[2][2],
               
               m[0][0]*_m.m[3][0] + m[0][1]*_m.m[3][1] + m[0][2]*_m.m[3][2] + m[3][0],
               m[1][0]*_m.m[3][0] + m[1][1]*_m.m[3][1] + m[1][2]*_m.m[3][2] + m[3][1],
               m[2][0]*_m.m[3][0] + m[2][1]*_m.m[3][1] + m[2][2]*_m.m[3][2] + m[3][2]);
    return r;
  }
*/
  // La multiplicacion de matrices asume que los vectores se multiplican por la izquierdaa: v' = v*M
  // De esta forma, se rota nuestra traslacion por la rotacion de la matriz parametro.
  inline       TMatrix3 operator * (const TMatrix3 &_m) const
  {
    TMatrix3 r(m[0][0]*_m.m[0][0] + m[0][1]*_m.m[1][0] + m[0][2]*_m.m[2][0],
               m[0][0]*_m.m[0][1] + m[0][1]*_m.m[1][1] + m[0][2]*_m.m[2][1],
               m[0][0]*_m.m[0][2] + m[0][1]*_m.m[1][2] + m[0][2]*_m.m[2][2],
               
               m[1][0]*_m.m[0][0] + m[1][1]*_m.m[1][0] + m[1][2]*_m.m[2][0],
               m[1][0]*_m.m[0][1] + m[1][1]*_m.m[1][1] + m[1][2]*_m.m[2][1],
               m[1][0]*_m.m[0][2] + m[1][1]*_m.m[1][2] + m[1][2]*_m.m[2][2],
               
               m[2][0]*_m.m[0][0] + m[2][1]*_m.m[1][0] + m[2][2]*_m.m[2][0],
               m[2][0]*_m.m[0][1] + m[2][1]*_m.m[1][1] + m[2][2]*_m.m[2][1],
               m[2][0]*_m.m[0][2] + m[2][1]*_m.m[1][2] + m[2][2]*_m.m[2][2],
               
               _m.m[0][0]*m[3][0] + _m.m[1][0]*m[3][1] + _m.m[2][0]*m[3][2] + _m.m[3][0],
               _m.m[0][1]*m[3][0] + _m.m[1][1]*m[3][1] + _m.m[2][1]*m[3][2] + _m.m[3][1],
               _m.m[0][2]*m[3][0] + _m.m[1][2]*m[3][1] + _m.m[2][2]*m[3][2] + _m.m[3][2]);
    return r;
  }

  inline TVector3        &GetRow(unsigned i)        { return *(TVector3*)m[i]; }
  inline const TVector3  &GetRow(unsigned i) const  { return *(TVector3*)m[i]; }

  // Convert to 4x4 Direct3D-style matrix.
  inline void            ToMatrix4 (TMatrix4 &om) const
  {
    om._11 = m[0][0]; om._12 = m[0][1]; om._13 = m[0][2]; om._14 = 0;
    om._21 = m[1][0]; om._22 = m[1][1]; om._23 = m[1][2]; om._24 = 0;
    om._31 = m[2][0]; om._32 = m[2][1]; om._33 = m[2][2]; om._34 = 0;
    om._41 = m[3][0]; om._42 = m[3][1]; om._43 = m[3][2]; om._44 = 1;
  }

};

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
inline TVector3 operator * (const TVector3 &v, const TMatrix3 &m)
{
  return TVector3(v.x*m.m[0][0] + v.y*m.m[1][0] + v.z*m.m[2][0] + m.m[3][0],
                  v.x*m.m[0][1] + v.y*m.m[1][1] + v.z*m.m[2][1] + m.m[3][1],
                  v.x*m.m[0][2] + v.y*m.m[1][2] + v.z*m.m[2][2] + m.m[3][2]);
}


// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
struct TQuaternion: public TVector3
{
  float w;

  inline TQuaternion()                                       { }
  inline TQuaternion(float _x, float _y, float _z, float _w) { x = _x; y = _y; z = _z; w = _w; }
  inline TQuaternion(const TVector3 &v, float a)             { Set(v, a); }

  inline const TQuaternion& Zero      ()                                        { x = 1.f; y = 0.f; z = 0.f; w = 0.f; return *this; }
  inline const TQuaternion& Normalize ()                                        { float f = InvMod(); x *= f; y *= f; z *= f; w *= f; return *this; }
  inline const TQuaternion& Neg       ()                                        { w = -w; return *this; }
  inline const TQuaternion& Invert    ()                                        { x = -x; y = -y; z = -z; w = -w; return *this; }
  inline const TQuaternion& Set       (float _x, float _y, float _z, float _w)  { x = _x; y = _y; z = _z; w = _w; return *this; }
  inline const TQuaternion& Set       (const TVector3 &v, float a)
  {
    float s = float(sin(a*.5f));
    w       = float(cos(a*.5f));
    x = v.x*s;
    y = v.y*s;
    z = v.z*s;
    return *this;
  }
                                                          
  inline       TQuaternion GetNormalized  () const                  { float f = InvMod(); return TQuaternion(x * f, y * f, z * f, w * f); }
  inline       TQuaternion GetNegated     () const                  { return TQuaternion(x, y, z, -w); }

  inline       float       DotProd    (const TQuaternion &o) const  { return x*o.x + y*o.y + z*o.z + w*o.w; }

  inline       TQuaternion operator * (const TQuaternion &o) const
  {
    return TQuaternion( x*o.x + y*o.z - z*o.y + w*o.x,
                       -x*o.z + y*o.w + z*o.x + w*o.y,
                        x*o.y - y*o.x + z*o.w + w*o.z,
                       -x*o.x - y*o.y - z*o.z + w*o.w);
  }

  inline const TQuaternion& operator *= (const TQuaternion &o)
  {
    TQuaternion k = *this;
    *this = k*o;
    return *this;
  }

  inline       TMatrix3   ToMatrix() const
  {
    TMatrix3 m;
	  float s = 2.f*(x*x + y*y + z*z + w*w);
	  float xs = x * s;
	  float ys = y * s;
	  float zs = z * s;
	  float wx = w * xs;
	  float wy = w * ys;
	  float wz = w * zs;
	  float xx = x * xs;
	  float xy = x * ys;
	  float xz = x * zs;
	  float yy = y * ys;
	  float yz = y * zs;
	  float zz = z * zs;

	  m.m[0][0] = 1.f - (yy + zz); 
	  m.m[0][1] = xy - wz; 
	  m.m[0][2] = xz + wy; 

	  m.m[1][0] = xy + wz; 
	  m.m[1][1] = 1.f - (xx + zz); 
	  m.m[1][2] = yz - wx; 

	  m.m[2][0] = xz - wy;
	  m.m[2][1] = yz + wx;
	  m.m[2][2] = 1.f - (xx + yy);
    return m;
  }

  inline float       Mod2        () const                  { return x*x + y*y + z*z + w*w; }
  inline float       Mod         () const                  { return float(sqrt(x*x + y*y + z*z + w*w)); }
  inline float       InvMod2     () const                  { return 1.f/(x*x + y*y + z*z + w*w); }
  inline float       InvMod      () const                  { return 1.f/float(sqrt(x*x + y*y + z*z + w*w)); }

};

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
inline TQuaternion QuatLERP     (const TQuaternion &q0, const TQuaternion &q1, float a)
{
  TQuaternion q;
	float c = q0.DotProd(q1);
	if (c > 0.f)
  {
		q.x = q0.x + a * (q1.x - q0.x);
		q.y = q0.y + a * (q1.y - q0.y);
		q.z = q0.z + a * (q1.z - q0.z);
		q.w = q0.w + a * (q1.w - q0.w);
	}
	else
  {
		q.x = q0.x - a * (q1.x + q0.x);
		q.y = q0.y - a * (q1.y + q0.y);
		q.z = q0.z - a * (q1.z + q0.z);
		q.w = q0.w - a * (q1.w + q0.w);
	}
  return q;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
inline TQuaternion QuatSLERP    (TQuaternion q0, TQuaternion q1, float a)
{
  TQuaternion q;
	float w, c, s, sclp, sclq;
	
	c = q0.DotProd(q1);

  if (c < .0f)
  {
      // Flip start quaternion
      q0.x = -q0.x; q0.y = -q0.y; q0.z = -q0.z; q0.w = -q0.w;
      c = -c;
  }

	if ((1.f + c) > .01f)
  {
    // If the quaternions are close, use linear interploation
		if ((1.f - c) < .01f)
    {
			sclp = 1.f - a;
			sclq = a;
		}
		else
    {
			w = float(acos(c));
			s = 1.f / float(sqrt(1.f - c*c));
			sclp = s*float(sin((1.f - a)*w));
			sclq = s*float(sin(a*w));
		} 
	} 
	else
  {
		q1.x = -q0.y; 
		q1.y =  q0.x;
		q1.z = -q0.w; 
		q1.w =  q0.z;
		sclp = float(sin((.5f - a)*PI));
		sclq = float(sin(a*PI));
	}
	q.x = sclp * q0.x + sclq * q1.x;
	q.y = sclp * q0.y + sclq * q1.y;
	q.z = sclp * q0.z + sclq * q1.z;
	q.w = sclp * q0.w + sclq * q1.w;

  return q;
}

#endif //_VECTORS_H_
