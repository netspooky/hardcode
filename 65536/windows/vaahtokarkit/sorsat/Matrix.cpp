#include "Matrix.h"

#include <math.h>

void Matrix::identity()
{
  m[0][0]=1;  m[0][1]=0;  m[0][2]=0;
  m[1][0]=0;  m[1][1]=1;  m[1][2]=0;
  m[2][0]=0;  m[2][1]=0;  m[2][2]=1;
}

void Matrix::inverse()
{
  Matrix tmp;
  int i,j;

  for(i=0;i<3;i++)
    for(j=0;j<3;j++)
      tmp.m[i][j]=m[i][j];
  for(i=0;i<3;i++)
    for(j=0;j<3;j++)
      m[i][j]=tmp.m[j][i];
}
/*
void Matrix::rotateX(float angle)
{
  Matrix t;
  t.identity();

  float s=sinf(3.141592f*2.0f*angle/360.0f),c=cosf(3.141592f*2.0f*angle/360.0f);
  t.m[1][1]=c;  t.m[1][2]=s;
  t.m[2][1]=-s; t.m[2][2]=c;

  multipleMatrix(t);
}

void Matrix::rotateY(float angle)
{
  Matrix t;
  t.identity();

  float s=sinf(3.141592f*2.0f*angle/360.0f),c=cosf(3.141592f*2.0f*angle/360.0f);
  t.m[0][0]=c; t.m[0][2]=-s;
  t.m[2][0]=s; t.m[2][2]=c;

  multipleMatrix(t);
}

void Matrix::rotateZ(float angle)
{
  Matrix t;
  t.identity();

  float s=sinf(3.141592f*2.0f*angle/360.0f),c=cosf(3.141592f*2.0f*angle/360.0f);
  t.m[0][0]=c;  t.m[0][1]=s;
  t.m[1][0]=-s; t.m[1][1]=c;

  multipleMatrix(t);
}
*/
void Matrix::multipleMatrix(Matrix &b)
{
  Matrix m2=*this;

  m[0][0] = m2.m[0][0]*b.m[0][0] + m2.m[0][1]*b.m[1][0] + m2.m[0][2]*b.m[2][0];
  m[0][1] = m2.m[0][0]*b.m[0][1] + m2.m[0][1]*b.m[1][1] + m2.m[0][2]*b.m[2][1];
  m[0][2] = m2.m[0][0]*b.m[0][2] + m2.m[0][1]*b.m[1][2] + m2.m[0][2]*b.m[2][2];

  m[1][0] = m2.m[1][0]*b.m[0][0] + m2.m[1][1]*b.m[1][0] + m2.m[1][2]*b.m[2][0];
  m[1][1] = m2.m[1][0]*b.m[0][1] + m2.m[1][1]*b.m[1][1] + m2.m[1][2]*b.m[2][1];
  m[1][2] = m2.m[1][0]*b.m[0][2] + m2.m[1][1]*b.m[1][2] + m2.m[1][2]*b.m[2][2];

  m[2][0] = m2.m[2][0]*b.m[0][0] + m2.m[2][1]*b.m[1][0] + m2.m[2][2]*b.m[2][0];
  m[2][1] = m2.m[2][0]*b.m[0][1] + m2.m[2][1]*b.m[1][1] + m2.m[2][2]*b.m[2][1];
  m[2][2] = m2.m[2][0]*b.m[0][2] + m2.m[2][1]*b.m[1][2] + m2.m[2][2]*b.m[2][2];
}

void Matrix::multipleVector(Vector &v)
{
  float xx=v.x, yy=v.y;

  v.x = m[0][0] * xx + m[1][0] * yy + m[2][0] * v.z;
  v.y = m[0][1] * xx + m[1][1] * yy + m[2][1] * v.z;
  v.z = m[0][2] * xx + m[1][2] * yy + m[2][2] * v.z;
}

void Matrix::fix()
{
  float l;
  l = 1.0f / sqrtf(m[0][0]*m[0][0] + m[0][1]*m[0][1] + m[0][2]*m[0][2]);
  m[0][0] *= l;
  m[0][1] *= l;
  m[0][2] *= l;
  l = 1.0f / sqrtf(m[1][0]*m[1][0] + m[1][1]*m[1][1] + m[1][2]*m[1][2]);
  m[1][0] *= l;
  m[1][1] *= l;
  m[1][2] *= l;
  l = 1.0f / sqrtf(m[2][0]*m[2][0] + m[2][1]*m[2][1] + m[2][2]*m[2][2]);
  m[2][0] *= l;
  m[2][1] *= l;
  m[2][2] *= l;
}