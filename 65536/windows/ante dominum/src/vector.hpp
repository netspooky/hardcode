#ifndef _VECTOR_HPP_
#define _VECTOR_HPP_

//--------------------------------------------------------------------------------------------
//  Headers
//--------------------------------------------------------------------------------------------

#include <math.h>
#include "matrix.hpp"

//--------------------------------------------------------------------------------------------
//  This code belongs to our library namespace: TRACTION_DEMOTRACTOR
//--------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------
//  Vector class
//--------------------------------------------------------------------------------------------

	class Vector
	{
		friend class Matrix;	

		public:
			Vector();
			Vector(float px, float py, float pz);
			Vector(const Vector &example);
			~Vector();

			Vector crossProduct(const Vector &vect);
			float dotProduct(const Vector &vect);

			Vector operator + (Vector const &vect);
			Vector operator - (Vector const &vect);
			Vector operator += (Vector const &vect);
			Vector operator -= (Vector const &vect);

			Vector operator * (Matrix const &mat);
			Vector operator *= (Matrix const &mat);
			Vector operator * (const float &value);
			Vector operator *= (float const &value);
			Vector operator / (const float &value);

			bool operator == (Vector const &vect);
			void operator = (Vector const &vect);
			
			Vector normalize();
			float length();

			float x, y, z;

			float a; // tämän ei pitäisi olla tässä! läst minute häk
		private:
	};

#endif
