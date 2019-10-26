// 3x3 Matrixluokka kaikilla leluilla
//
//   no okei, ei ihan kaikilla. Mutta determinantin laskua tuskin tarvitaan demokoodauksessa :) 
//
//

#ifndef _MATRIX_HPP_
#define _MATRIX_HPP_

//--------------------------------------------------------------------------------------------
//  Headers
//--------------------------------------------------------------------------------------------

#include <math.h>

//--------------------------------------------------------------------------------------------
//  This code belongs to our library namespace: TRACTION_DEMOTRACTOR
//--------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------
//  Matrix class
//--------------------------------------------------------------------------------------------

	class Matrix
	{
		public:
			Matrix();
			Matrix(float val);
			Matrix(float m0, float m1, float m2, float m3, float m4, float m5, float m6, float m7, float m8);
			~Matrix();

			Matrix makeIdentity();
			Matrix makeRotation(float x, float y, float z);
			Matrix makeTranspose();

			Matrix operator + (Matrix const &mat);
			Matrix operator += (Matrix const &mat);
			Matrix operator - (Matrix const &mat);
			Matrix operator -= (Matrix const &mat);
			Matrix operator * (Matrix const &mat);
			Matrix operator *= (Matrix const &mat);
			Matrix operator * (float const &value);
			Matrix operator *= (float const &value);

			void operator = (Matrix const &mat);
			void operator = (float const &value);

			bool operator == (Matrix const &mat);

			float data[3][3];
	};

#endif
