#ifndef _NORMAL_H
#define _NORMAL_H

#include <math.h>

typedef float Lib3dsFloat;
typedef double Lib3dsDouble;
typedef float Lib3dsVector[3];
#define LIB3DS_EPSILON (1e-49)

#ifdef __cplusplus
extern "C" {
#endif

/*
void lib3ds_vector_sub(Lib3dsVector c, Lib3dsVector a, Lib3dsVector b);

void lib3ds_vector_add(Lib3dsVector c, Lib3dsVector a, Lib3dsVector b);

void lib3ds_vector_cross(Lib3dsVector c, Lib3dsVector a, Lib3dsVector b);

void lib3ds_vector_normalize(Lib3dsVector c);

void lib3ds_vector_normal(Lib3dsVector n, Lib3dsVector a, Lib3dsVector b, Lib3dsVector c);
*/


void vector_sub(float *c, float *a, float *b);

void vector_add(float *c, float *a, float *b);

void vector_cross(float *c, float *a, float *b);

void vector_normalize(float *c);

void vector_normal(float *n, float *a, float *b, float *c);

#ifdef __cplusplus
};
#endif

#endif
