#include "vec3.hpp"

//------------------------------------------------------------
// Vec3
//------------------------------------------------------------
vec3::vec3():
  x(0),
  y(0),
  z(0)
{

}

vec3::vec3(float xx, float yy, float zz):
  x(xx),
  y(yy),
  z(zz)
{

}

float &vec3::operator()(int i)
{
    switch(i)
    {
        case 0:
            return x;
        case 1:
            return y;
        default:
            return z;
    }
}

float vec3::operator()(int i) const
{
    switch(i)
    {
        case 0:
            return x;
        case 1:
            return y;
        default:
            return z;
    }
}

vec3 &vec3::operator-=(const vec3 &v)
{
    x -= v.x;
    y -= v.y;
    z -= v.z;
    return *this;
}

vec3 vec3::operator-(const vec3 &v)
{
    vec3 r;
    r.x = x - v.x;
    r.y = y - v.y;
    r.z = z - v.z;
    return r;
}

vec3 vec3::operator +(const vec3& v)
{
  vec3 r;
  r.x = x + v.x;
  r.y = y + v.y;
  r.z = z + v.z;
  return r;
}

vec3 vec3::operator *(float s)
{
  vec3 r;
  r.x = x*s;
  r.y = y*s;
  r.z = z*s;
  return r;
}

vec3::~vec3()
{

}
