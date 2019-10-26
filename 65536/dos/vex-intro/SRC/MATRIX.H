#ifndef __MATRIX_H
#define __MATRIX_H

struct vector
{
  long v[3];
  long operator [](int i) const { return v[i]; }
  long& operator [](int i) { return v[i]; }
};

struct matrix
{
  long m[3][4];
//  const long (&operator [](int i) const)[4] { return m[i]; }
//  long (&operator [](int i))[4] { return m[i]; }
};

extern "C"
{
  vector &vecmove(vector& r, const vector* p, long t, int lev);
  void vecscl(vector& r, const vector& a, long s);
  void vecadd(vector& r, const vector& a, const vector& b);
  void vecsub(vector& r, const vector& a, const vector& b);
  long vecmul(const vector& a, const vector& b);
  long vecsqr(const vector& a);
  void vecnorm(vector &a);
  void vecxmul(vector& r, const vector& a, const vector& b);
  void veccopy(vector* r, const vector* v, int n);
  vector* vecxform(vector* r, const vector* v, const matrix& m, int n);
  vector* vecxformvec(vector* r, const vector* v, const matrix& m, int n);
  vector* vecxlate(vector* v, int n, const vector& dv);
  void vectsqr(matrix& r, const vector &v, long v4);
  matrix& matmul(matrix& r, const matrix& a, const matrix& b);
  matrix& matscl(matrix& r, const matrix& a, long b);
  matrix& matadd(matrix& r, const matrix& a, const matrix& b);
  matrix& matxlate(matrix& m, const vector& v);
  matrix& makematnorm(matrix& m);
  matrix& makematxlate(matrix& m, const vector& v);
  matrix& makematrotx(matrix& m, int a);
  matrix& makematroty(matrix& m, int a);
  matrix& makematrotz(matrix& m, int a);
}

#endif
