/*
 *
 *      VecSys Math
 *
 *      - sini- ja neli”juuritaulukoiden lasku
 *
 */

#ifndef VEC_MATH_H
#define VEC_MATH_H

#ifndef VEC_NO_FLOAT

#include <math.h>

#ifndef M_PI
#define M_PI    3.14159265358979323846
#endif

#else

extern long     vec_sin[],*vec_cos;
extern void     vec_calc_sin(void);

#endif

extern long     vec_sqrt(long arg,long *shift);
extern void     vec_calc_sqrt(void);

#endif

