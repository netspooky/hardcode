/*
 *
 *      VecSys Memory
 *
 *      - objektien ja tekstuurien repiminen muistista
 *
 */

#ifndef VEC_MEM_H
#define VEC_MEM_H

#include "vecsys.h"
#include "vec_cam.h"

typedef struct          //      Tekstuurin "headeri"
{        
    void    *addr;
    uint8   *palette;
    int     bpp,
            width,
            height;
    char    name[13];
} vec_texhdr;

#define VEC_TH(tex)     ((vec_texhdr *)(tex)-1)

extern uint8    *vec_alloc_texture(int bpp);
extern void     vec_free_texture(uint8 *texture);

extern uint8    *vec_get_texture(const char *data,int bpp);

extern vec_obj  *vec_get_object(const char *data);

extern int      vec_get_objects(const char *data,vec_world *world);
extern int      vec_get_materials(const char *data,vec_world *world);

extern int      vec_get_camera(const char *data,long num,vec_cam *cam);
extern int      vec_get_cam_kf(const char *data,char *camname,vec_ckf *ckf);
extern int      vec_get_obj_kf(const char *data,char *objname,vec_okf *okf);
extern int      vec_get_kf(const char *data,vec_cam *cam);

#endif

