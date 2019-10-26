#include "normal.h"
#include <math.h>

//#define LIB3DS_EPSILON (1e-8)
#define LIB3DS_EPSILON (1e-49)
/*
void lib3ds_vector_sub(Lib3dsVector c, Lib3dsVector a, Lib3dsVector b)
{
  int i;
  for (i=0; i<3; ++i) {
    c[i]=a[i]-b[i];
  }
}

void lib3ds_vector_add(Lib3dsVector c, Lib3dsVector a, Lib3dsVector b)
{
  int i;
  for (i=0; i<3; ++i) {
    c[i]=a[i]+b[i];
  }
}

void lib3ds_vector_cross(Lib3dsVector c, Lib3dsVector a, Lib3dsVector b)
{
  c[0]=a[1]*b[2] - a[2]*b[1];
  c[1]=a[2]*b[0] - a[0]*b[2];
  c[2]=a[0]*b[1] - a[1]*b[0];
}

void lib3ds_vector_normalize(Lib3dsVector c)
{
  Lib3dsFloat l,m;

  l=(Lib3dsFloat)sqrt(c[0]*c[0] + c[1]*c[1] + c[2]*c[2]);
  if (fabs(l)<LIB3DS_EPSILON) {
    c[0]=c[1]=c[2]=0.0f;
    if ((c[0]>=c[1]) && (c[0]>=c[2])) {
      c[0]=1.0f;
    }
    else
    if (c[1]>=c[2]) {
      c[1]=1.0f;
    }
    else {
      c[2]=1.0f;
    }
  }
  else {
    m=1.0f/l;
    c[0]*=m;
    c[1]*=m;
    c[2]*=m;
  }
}


void lib3ds_vector_normal(Lib3dsVector n, Lib3dsVector a, Lib3dsVector b, Lib3dsVector c)
{
  Lib3dsVector p,q;

  lib3ds_vector_sub(p,c,b);
  lib3ds_vector_sub(q,a,b);
  lib3ds_vector_cross(n,p,q);
  lib3ds_vector_normalize(n);
}
*/

void vector_sub(float *c, float *a, float *b)
{
	int		i;
	for (i=0; i<3; i++) 
	{
		c[i]=a[i]-b[i];
	}
}

void vector_add(float *c, float *a, float *b)
{
	int		i;
	for (i=0; i<3; ++i) 
	{
		c[i]=a[i]+b[i];
	}
}

void vector_cross(float *c, float *a, float *b)
{
	c[0]=a[1]*b[2] - a[2]*b[1];
	c[1]=a[2]*b[0] - a[0]*b[2];
	c[2]=a[0]*b[1] - a[1]*b[0];
}

void vector_normalize(float *c)
{
	float		l,m;

	l=(float) sqrt(c[0]*c[0] + c[1]*c[1] + c[2]*c[2]);
	if (fabs(l)<LIB3DS_EPSILON) 
	{
		c[0]=c[1]=c[2]=0.0f;
		if ((c[0]>=c[1]) && (c[0]>=c[2])) 
		{
			c[0]=1.0f;
		}
		else
		if (c[1]>=c[2]) 
		{
			c[1]=1.0f;
		}
		else 
		{
			c[2]=1.0f;
		}
	}
	else 
	{
		m=1.0f/l;
		c[0]*=m;
		c[1]*=m;
		c[2]*=m;
	}
}

void vector_normal(float *n, float *a, float *b, float *c)
{
	float	p[3],q[3];

	vector_sub(p,c,b);
	vector_sub(q,a,b);
	vector_cross(n,p,q);
	vector_normalize(n);
}