/*
 *
 *      VecSys Material
 *
 *      - tekstuurilistan k„sittely
 *      - bumpin k„sittely
 *
 */

#ifndef VEC_MATERIAL_H
#define VEC_MATERIAL_H

#include "vecsys.h"

extern int      vec_add_texture(uint8 *texture);
extern int      vec_del_texture(uint8 *texture);
extern uint8    *vec_query_texture(const char *name,int bpp);

/*      Bump:       */

extern uint8    *vec_init_bump(vec_obj *obj);
extern void     vec_close_bump(vec_obj *obj);

#endif

