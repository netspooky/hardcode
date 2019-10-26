//--------------------------------------------------------------------------------------------
//  Headers
//--------------------------------------------------------------------------------------------

#include "matrix.hpp"

//--------------------------------------------------------------------------------------------
//  Use our library namespace: TRACTION_DEMOTRACTOR
//--------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------
//  Class code
//--------------------------------------------------------------------------------------------

Matrix::Matrix()
{
	data[0][0]=0;
	data[0][1]=0;
	data[0][2]=0;
	data[1][0]=0;
	data[1][1]=0;
	data[1][2]=0;
	data[2][0]=0;
	data[2][1]=0;
	data[2][2]=0;
}

Matrix::Matrix(float m0, float m1, float m2, float m3, float m4, float m5, float m6, float m7, float m8)
{
	data[0][0]=m0;
	data[0][1]=m1;
	data[0][2]=m2;
	data[1][0]=m3;
	data[1][1]=m4;
	data[1][2]=m5;
	data[2][0]=m6;
	data[2][1]=m7;
	data[2][2]=m8;
}

Matrix::Matrix(float value)
{
	data[0][0] = value;
	data[0][1] = value;
	data[0][2] = value;
	data[1][0] = value;
	data[1][1] = value;
	data[1][2] = value;
	data[2][0] = value;
	data[2][1] = value;
	data[2][2] = value;
}


Matrix::~Matrix()
{

}

Matrix Matrix::makeIdentity()
{
	data[0][0]=1;
	data[0][1]=0;
	data[0][2]=0;
	data[1][0]=0;
	data[1][1]=1;
	data[1][2]=0;
	data[2][0]=0;
	data[2][1]=0;
	data[2][2]=1;

	return Matrix(data[0][0], data[0][1], data[0][2], 
					data[1][0], data[1][1], data[1][2], 
					data[2][0], data[2][1], data[2][2]); 
}
Matrix Matrix::makeScale(float x, float y, float z)
{
	data[0][0]=x;
	data[0][1]=0;
	data[0][2]=0;
	data[1][0]=0;
	data[1][1]=y;
	data[1][2]=0;
	data[2][0]=0;
	data[2][1]=0;
	data[2][2]=z;

	return Matrix(data[0][0], data[0][1], data[0][2], 
					data[1][0], data[1][1], data[1][2], 
					data[2][0], data[2][1], data[2][2]); 
}

Matrix Matrix::makeRotation(float x, float y, float z)
{
	float sx = (float)sin(x);
	float cx = (float)cos(x);
	float sy = (float)sin(y);
	float cy = (float)cos(y);
	float sz = (float)sin(z);
	float cz = (float)cos(z);

	data[0][0]=cy*cz;
	data[0][1]=cy*sz;
	data[0][2]=-sy;

	data[1][0]=sx*sy*cz-cx*sz;
	data[1][1]=sx*sy*sz+cx*cz;
	data[1][2]=sx*cy;

	data[2][0]=cx*sy*cz+sx*sz;
	data[2][1]=cx*sy*sz-sx*cz;
	data[2][2]=cx*cy;

	return Matrix(data[0][0], data[0][1], data[0][2], 
					data[1][0], data[1][1], data[1][2], 
					data[2][0], data[2][1], data[2][2]); 

}

Matrix Matrix::makeTranspose()
{
	float t0, t1, t2, t3, t4, t5, t6, t7, t8;

	t0 = data[0][0];
	t1 = data[0][1];
	t2 = data[0][2];
	t3 = data[1][0];
	t4 = data[1][1];
	t5 = data[1][2];
	t6 = data[2][0];
	t7 = data[2][1];
	t8 = data[2][2];

	return Matrix(t0, t1, t2, t3, t4, t5, t6, t7, t8);
}

void Matrix::operator = (Matrix const &mat)
{
	data[0][0]=mat.data[0][0];
	data[0][1]=mat.data[0][1];
	data[0][2]=mat.data[0][2];
	data[1][0]=mat.data[1][0];
	data[1][1]=mat.data[1][1];
	data[1][2]=mat.data[1][2];
	data[2][0]=mat.data[2][0];
	data[2][1]=mat.data[2][1];
	data[2][2]=mat.data[2][2];
}

void Matrix::operator = (float const &value)
{
	data[0][0] = value;
	data[0][1] = value;
	data[0][2] = value;
	data[1][0] = value;
	data[1][1] = value;
	data[1][2] = value;
	data[2][0] = value;
	data[2][1] = value;
	data[2][2] = value;
}

Matrix Matrix::operator + (Matrix const &mat)
{
	float t0, t1, t2, t3, t4, t5, t6, t7, t8;

	t0 = data[0][0] + mat.data[0][0];
	t1 = data[0][1] + mat.data[0][1];
	t2 = data[0][2] + mat.data[0][2];
	t3 = data[1][0] + mat.data[1][0];
	t4 = data[1][1] + mat.data[1][1];
	t5 = data[1][2] + mat.data[1][2];
	t6 = data[2][0] + mat.data[2][0];
	t7 = data[2][1] + mat.data[2][1];
	t8 = data[2][2] + mat.data[2][2];

	return Matrix(t0, t1, t2, t3, t4, t5, t6, t7, t8);
}

Matrix Matrix::operator += (Matrix const &mat)
{
	data[0][0]+=mat.data[0][0];
	data[0][1]+=mat.data[0][1];
	data[0][2]+=mat.data[0][2];
	data[1][0]+=mat.data[1][0];
	data[1][1]+=mat.data[1][1];
	data[1][2]+=mat.data[1][2];
	data[2][0]+=mat.data[2][0];
	data[2][1]+=mat.data[2][1];
	data[2][2]+=mat.data[2][2];
	return Matrix(data[0][0], data[0][1], data[0][2], 
					data[1][0], data[1][1], data[1][2], 
					data[2][0], data[2][1], data[2][2]); 
}

Matrix Matrix::operator - (Matrix const &mat)
{
	float t0, t1, t2, t3, t4, t5, t6, t7, t8;

	t0 = data[0][0] - mat.data[0][0];
	t1 = data[0][1] - mat.data[0][1];
	t2 = data[0][2] - mat.data[0][2];
	t3 = data[1][0] - mat.data[1][0];
	t4 = data[1][1] - mat.data[1][1];
	t5 = data[1][2] - mat.data[1][2];
	t6 = data[2][0] - mat.data[2][0];
	t7 = data[2][1] - mat.data[2][1];
	t8 = data[2][2] - mat.data[2][2];

	return Matrix(t0, t1, t2, t3, t4, t5, t6, t7, t8);
}

Matrix Matrix::operator -= (Matrix const &mat)
{
	data[0][0]-=mat.data[0][0];
	data[0][1]-=mat.data[0][1];
	data[0][2]-=mat.data[0][2];
	data[1][0]-=mat.data[1][0];
	data[1][1]-=mat.data[1][1];
	data[1][2]-=mat.data[1][2];
	data[2][0]-=mat.data[2][0];
	data[2][1]-=mat.data[2][1];
	data[2][2]-=mat.data[2][2];
	return Matrix(data[0][0], data[0][1], data[0][2], 
					data[1][0], data[1][1], data[1][2], 
					data[2][0], data[2][1], data[2][2]); 
}

Matrix Matrix::operator * (Matrix const &mat)
{
	float t0, t1, t2, t3, t4, t5, t6, t7, t8;

	t0 = data[0][0] * mat.data[0][0] + data[0][1]*mat.data[1][0] + data[0][2]*mat.data[2][0];
	t1 = data[0][0] * mat.data[0][1] + data[0][1]*mat.data[1][1] + data[0][2]*mat.data[2][1];
	t2 = data[0][0] * mat.data[0][2] + data[0][1]*mat.data[1][2] + data[0][2]*mat.data[2][2];

	t3 = data[1][0] * mat.data[0][0] + data[1][1]*mat.data[1][0] + data[1][2]*mat.data[2][0];
	t4 = data[1][0] * mat.data[0][1] + data[1][1]*mat.data[1][1] + data[1][2]*mat.data[2][1];
	t5 = data[1][0] * mat.data[0][2] + data[1][1]*mat.data[1][2] + data[1][2]*mat.data[2][2];

	t6 = data[2][0] * mat.data[0][0] + data[2][1]*mat.data[1][0] + data[2][2]*mat.data[2][0];
	t7 = data[2][0] * mat.data[0][1] + data[2][1]*mat.data[1][1] + data[2][2]*mat.data[2][1];
	t8 = data[2][0] * mat.data[0][2] + data[2][1]*mat.data[1][2] + data[2][2]*mat.data[2][2];

	return Matrix(t0, t1, t2, t3, t4, t5, t6, t7, t8);
}

Matrix Matrix::operator *= (Matrix const &mat)
{
	float t0, t1, t2, t3, t4, t5, t6, t7, t8;

	t0 = data[0][0] * mat.data[0][0] + data[0][1]*mat.data[1][0] + data[0][2]*mat.data[2][0];
	t1 = data[0][0] * mat.data[0][1] + data[0][1]*mat.data[1][1] + data[0][2]*mat.data[2][1];
	t2 = data[0][0] * mat.data[0][2] + data[0][1]*mat.data[1][2] + data[0][2]*mat.data[2][2];

	t3 = data[1][0] * mat.data[0][0] + data[1][1]*mat.data[1][0] + data[1][2]*mat.data[2][0];
	t4 = data[1][0] * mat.data[0][1] + data[1][1]*mat.data[1][1] + data[1][2]*mat.data[2][1];
	t5 = data[1][0] * mat.data[0][2] + data[1][1]*mat.data[1][2] + data[1][2]*mat.data[2][2];

	t6 = data[2][0] * mat.data[0][0] + data[2][1]*mat.data[1][0] + data[2][2]*mat.data[2][0];
	t7 = data[2][0] * mat.data[0][1] + data[2][1]*mat.data[1][1] + data[2][2]*mat.data[2][1];
	t8 = data[2][0] * mat.data[0][2] + data[2][1]*mat.data[1][2] + data[2][2]*mat.data[2][2];

	data[0][0] = t0;
	data[0][1] = t1;
	data[0][2] = t2;
	data[1][0] = t3;
	data[1][1] = t4;
	data[1][2] = t5;
	data[2][0] = t6;
	data[2][1] = t7;
	data[2][2] = t8;

	return Matrix(t0, t1, t2, t3, t4, t5, t6, t7, t8);
}

Matrix Matrix::operator * (float const &value)
{
	float t0, t1, t2, t3, t4, t5, t6, t7, t8;

	t0 = data[0][0] * value;
	t1 = data[0][1] * value;
	t2 = data[0][2] * value;
	t3 = data[1][0] * value;
	t4 = data[1][1] * value;
	t5 = data[1][2] * value;
	t6 = data[2][0] * value;
	t7 = data[2][1] * value;
	t8 = data[2][2] * value;
	return Matrix(t0, t1, t2, t3, t4, t5, t6, t7, t8);
}

Matrix Matrix::operator *= (float const &value)
{
	data[0][0] *= value;
	data[0][1] *= value;
	data[0][2] *= value;
	data[1][0] *= value;
	data[1][1] *= value;
	data[1][2] *= value;
	data[2][0] *= value;
	data[2][1] *= value;
	data[2][2] *= value;
	return Matrix(data[0][0], data[0][1], data[0][2], 
					data[1][0], data[1][1], data[1][2], 
					data[2][0], data[2][1], data[2][2]); 
}

bool Matrix::operator == (Matrix const &mat)
{
	if (data[0][0] == mat.data[0][0] &&
		data[0][1] == mat.data[0][1] &&
		data[0][2] == mat.data[0][2] &&
		data[1][0] == mat.data[1][0] &&
		data[1][1] == mat.data[1][1] &&
		data[1][2] == mat.data[1][2] &&
		data[2][0] == mat.data[2][0] &&
		data[2][1] == mat.data[2][1] &&
		data[2][2] == mat.data[2][2])
		return true;
	else return false;
}
