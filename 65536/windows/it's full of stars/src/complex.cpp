//--------------------------------------------------------------------------------------------
//  Headers
//--------------------------------------------------------------------------------------------

#include "complex.hpp"

//--------------------------------------------------------------------------------------------
//  Use our library namespace: TRACTION_DEMOTRACTOR
//--------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------
//  Class code
//--------------------------------------------------------------------------------------------

Complex::Complex()
{
	r = i = 0.0f;
}
Complex::Complex(float pr, float pi)
{
	r = pr;
	i = pi;
}
Complex::Complex(const Complex &example)
{
	r = example.r;
	i = example.i;
}

Complex::~Complex()
{
}

Complex Complex::operator + (Complex const &c)
{
	float tr, ti;
	tr = r + c.r;
	ti = i + c.i;

	return Complex(tr, ti);
}
Complex Complex::operator - (Complex const &c)
{
	float tr, ti;
	tr = r - c.r;
	ti = i - c.i;

	return Complex(tr, ti);
}
Complex Complex::operator += (Complex const &c)
{
	r += c.r;
	i += c.i;

	return Complex (r, i);

}
Complex Complex::operator -= (Complex const &c)
{
	r -= c.r;
	i -= c.i;

	return Complex (r, i);
}

Complex Complex::operator * (float const &value)
{
	float tr, ti;
	tr = r*value;
	ti = i*value;

	return Complex(tr, ti);
}
Complex Complex::operator *= (float const &value)
{
	r *= value;
	i *= value;

	return Complex(r, i);
}
Complex Complex::operator / (float const &value)
{
	if(value <= 0.0001f) 
		return Complex(0.0f, 0.0f);

	float tr, ti;
	tr = r / value;
	ti = i / value;

	return Complex(tr, ti);
}
Complex Complex::operator /= (float const &value)
{
	if(value <= 0.0001f) 
		return Complex(0.0f, 0.0f);

	r /= value;
	i /= value;

	return Complex(r, i);
}
Complex Complex::operator * (Complex const &c)
{
	float real = r*c.r - i*c.i;
	float imag = r*c.i + i*c.r;

	return Complex(real, imag);
}

Complex Complex::operator *= (Complex const &c)
{
	float real = r*c.r - i*c.i;
	float imag = r*c.i + i*c.r;

	r = real;
	i = imag;

	return Complex(real, imag);

}
Complex Complex::operator / (Complex const &c)
{
	float divisor = c.r*c.r + c.i*c.i;
	if (divisor < 0.00001f)
		return Complex(1000000, 1000000);

	float rdivisor = 1.0f / divisor;

	float real = (r*c.r + i*c.i)*rdivisor;
	float imag = (i*c.r - r*c.i)*rdivisor;

	return Complex(real, imag);
}
Complex Complex::operator /= (Complex const &c)
{
	float divisor = c.r*c.r + c.i*c.i;
	if (divisor < 0.00001f)
		return Complex(1000000, 1000000);

	float rdivisor = 1.0f / divisor;

	float real = (r*c.r + i*c.i)*rdivisor;
	float imag = (i*c.r - r*c.i)*rdivisor;

	r = real;
	i = imag;

	return Complex(real, imag);
}

void Complex::operator = (Complex const &c)
{
	r = c.r;
	i = c.i;
}

float Complex::abs()
{
	return (float)sqrt(r*r+i*i);
}

float Complex::angle()
{
	return (float)atan(i/r);//2(i, r);
}

Complex Complex::power(float n)
{
	//z^n = |z|^n * (cos(n*theta) + i*sin(n*theta))
	float mul = (float)pow(this->abs(), n);
	float angle = this->angle();

	Complex temp;
	temp.r = mul * (float)cos(n*angle);
	temp.i = mul * (float)sin(n*angle);
	return temp;

} 
 
