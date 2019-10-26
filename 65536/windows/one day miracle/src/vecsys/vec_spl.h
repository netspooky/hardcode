/*
 *
 *      VecSys Spline
 *
 *      - splinej„.. nam..
 *
 */

#ifndef VEC_SPL_H
#define VEC_SPL_H

#include "vec_type.h"

#define VEC_SPL_MAX     3               //  max num

extern void     vec_spline(vec_fp *p0,vec_fp *p1,vec_fp *p2,vec_fp *p3,
                    vec_fp *dest,vec_fp t,int num);

#endif
