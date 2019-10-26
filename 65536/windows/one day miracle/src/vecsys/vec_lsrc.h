/*
 *
 *      VecSys Light source
 *
 *      - Licht sorsa
 *
 */

#ifndef VEC_LSRC_H
#define VEC_LSRC_H

#include "vecsys.h"

extern void     vec_set_lsrc(vec_fp ls[]);
extern void     vec_set_range(long first,long num);
extern void     vec_init_shading(vec_obj *obz);
extern vec_fp   vec_shade(vec_obj *obz,long fan);

#endif

