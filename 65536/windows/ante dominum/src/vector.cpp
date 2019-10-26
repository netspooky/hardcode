//--------------------------------------------------------------------------------------------
//  Headers
//--------------------------------------------------------------------------------------------

#include "vector.hpp"

//--------------------------------------------------------------------------------------------
//  Use our library namespace: TRACTION_DEMOTRACTOR
//--------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------
//  Class code
//--------------------------------------------------------------------------------------------

Vector::Vector()
{
	x = y = z = 0.0f;
}
Vector::Vector(float px, float py, float pz)
{
	x = px;
	y = py;
	z = pz;
}
Vector::Vector(const Vector &example)
{
	x = example.x;
	y = example.y;
	z = example.z;
}


Vector::~Vector()
{

}

float Vector::length()
{
	return (float)sqrt(x*x+y*y+z*z);
}

Vector Vector::normalize()
{
	float l = length();
	if (l==0)
		return Vector(0,0,0);
	x /= l;
	y /= l;
	z /= l;

	return Vector(x, y, z);
}

float Vector::dotProduct(const Vector &vect)
{
	return x*vect.x + y*vect.y + z*vect.z;
}

Vector Vector::crossProduct(const Vector &vect)
{
	float tx = y*vect.z-z*vect.y;
	float ty = x*vect.z-z*vect.x;
	float tz = x*vect.y-y*vect.x;
	return Vector(tx, ty, tz);
}
Vector Vector::operator + (Vector const &vect)
{
	float tx, ty, tz;
	tx = x + vect.x;
	ty = y + vect.y;
	tz = z + vect.z;

	return Vector(tx, ty, tz);
}
Vector Vector::operator - (Vector const &vect)
{
	float tx, ty, tz;
	tx = x - vect.x;
	ty = y - vect.y;
	tz = z - vect.z;
	return Vector(tx, ty, tz);
}
Vector Vector::operator += (Vector const &vect)
{
	x += vect.x;
	y += vect.y;
	z += vect.z;

	return Vector(x, y, z);
}
Vector Vector::operator -= (Vector const &vect)
{
	x -= vect.x;
	y -= vect.y;
	z -= vect.z;

	return Vector(x, y, z);
}
Vector	Vector::operator * (Matrix const &mat)
{
	float tx, ty, tz;
	tx = mat.data[0][0]*x + mat.data[0][1]*y + mat.data[0][2]*z;
	ty = mat.data[1][0]*x + mat.data[1][1]*y + mat.data[1][2]*z;
	tz = mat.data[2][0]*x + mat.data[2][1]*y + mat.data[2][2]*z;
	return Vector(tx, ty, tz);
}

Vector	Vector::operator *= (Matrix const &mat)
{
	float tx, ty, tz;
	tx = mat.data[0][0]*x + mat.data[0][1]*y + mat.data[0][2]*z;
	ty = mat.data[1][0]*x + mat.data[1][1]*y + mat.data[1][2]*z;
	tz = mat.data[2][0]*x + mat.data[2][1]*y + mat.data[2][2]*z;

	x = tx;
	y = ty;
	z = tz;
	return Vector(x, y, z);
}
Vector Vector::operator * (float const &value)
{
	float tx, ty, tz;
	tx = x * value;
	ty = y * value;
	tz = z * value;

	return Vector(tx, ty, tz);
}
Vector Vector::operator *= (float const &value)
{
	x *= value;
	y *= value;
	z *= value;

	return Vector(x, y, z);
}
Vector Vector::operator / (float const &value)
{
	if(value <= 0) return Vector(0.0f, 0.0f, 0.0f);

	float tx, ty, tz;
	tx = x / value;
	ty = y / value;
	tz = z / value;

	return Vector(tx, ty, tz);
}
bool Vector::operator == (Vector const &vect)
{
	if (x == vect.x && y == vect.y && z == vect.z)
		return true;
	else return false;

}

void Vector::operator = (Vector const &vect)
{
	x = vect.x;
	y = vect.y;
	z = vect.z;
}
