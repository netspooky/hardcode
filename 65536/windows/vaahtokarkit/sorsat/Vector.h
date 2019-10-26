#ifndef _Vector_h_
#define _Vector_h_

#include <math.h>

typedef struct {
  float x,y,z;
} Vector;

typedef Vector Vertex;

inline void vectorNormalize(Vector *v) {
  float m = 1.0f/sqrtf(v->x*v->x + v->y*v->y + v->z*v->z);
  v->x *= m;
  v->y *= m;
  v->z *= m;
}

inline float vectorNormalizeAndGetLength(Vector *v) {
  float l = sqrtf(v->x*v->x + v->y*v->y + v->z*v->z);
  float m = 1.0f/l;
  v->x *= m;
  v->y *= m;
  v->z *= m;
  return l;
}

inline float vectorNormalizeAndGetLengthAndMul(Vector *v,float &mul) {
  float l = sqrtf(v->x*v->x + v->y*v->y + v->z*v->z);
  mul = 1.0f/l;
  v->x *= mul;
  v->y *= mul;
  v->z *= mul;
  return l;
}

inline void vectorSet(Vector *v,float x,float y,float z) {
  v->x=x; v->y=y; v->z=z;
}

inline void vectorScale(Vector *v,float s) {
  v->x*=s; v->y*=s; v->z*=s;
}

inline void vectorNegative(Vector *v) {
  v->x=-v->x; v->y=-v->y; v->z=-v->z;
}

inline float vectorLength(Vector *v) {
  return sqrtf(v->x*v->x + v->y*v->y + v->z*v->z);
}

inline float vectorDotProduct(Vector *a,Vector *b) {
  return a->x*b->x + a->y*b->y + a->z*b->z;
}

inline void vectorCrossProduct(Vector *dest,Vector *a,Vector *b) {
  dest->x = a->y*b->z - b->y*a->z;
  dest->y = a->z*b->x - b->z*a->x;
  dest->z = a->x*b->y - b->x*a->y;
}

inline void vectorAdd(Vector *a,Vector *b) {
  a->x += b->x;
  a->y += b->y;
  a->z += b->z;
}

inline void vectorSub(Vector *a,Vector *b) {
  a->x -= b->x;
  a->y -= b->y;
  a->z -= b->z;
}

#endif