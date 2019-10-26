#ifndef _COMPLEX_HPP_
#define _COMPLEX_HPP_

//--------------------------------------------------------------------------------------------
//  Headers
//--------------------------------------------------------------------------------------------

#include <math.h>

//--------------------------------------------------------------------------------------------
//  Complex class
//--------------------------------------------------------------------------------------------

	class Complex
	{
		public:
			Complex();
			Complex(float pr, float pi);
			Complex(const Complex &example);
			~Complex();

			float abs(void);
			float angle(void);
			Complex power(float n);

			Complex operator + (Complex const &c);
			Complex operator - (Complex const &c);
			Complex operator += (Complex const &c);
			Complex operator -= (Complex const &c);

			Complex operator * (Complex const &c);
			Complex operator *= (Complex const &c);
			Complex operator / (const Complex &c);
			Complex operator /= (const Complex &c);

			Complex operator * (const float &value);
			Complex operator *= (float const &value);
			Complex operator / (const float &value);
			Complex operator /= (const float &value);

			bool operator == (Complex const &vect);
			void operator = (Complex const &vect);
			
			float r, i;

		private:
	};

#endif 
