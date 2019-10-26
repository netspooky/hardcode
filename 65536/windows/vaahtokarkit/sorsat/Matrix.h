#ifndef _Matrix_h_
#define _Matrix_h_

#include "Vector.h"

class Matrix
{
public:
  void identity();
  void inverse();
//  void rotateX(float angle);
//  void rotateY(float angle);
//  void rotateZ(float angle);
  void multipleMatrix(Matrix &b);
  void multipleVector(Vector &v);
  void fix();

  float m[3][3];
};

#define vectorMultipleMatrix(d,mat,v) \
(d).x = (mat).m[0][0] * (v).x + (mat).m[1][0] * (v).y + (mat).m[2][0] * (v).z; \
(d).y = (mat).m[0][1] * (v).x + (mat).m[1][1] * (v).y + (mat).m[2][1] * (v).z; \
(d).z = (mat).m[0][2] * (v).x + (mat).m[1][2] * (v).y + (mat).m[2][2] * (v).z; \

#endif
