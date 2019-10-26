/*
 *
 *      VecSys Memory
 *
 *      - k„ttely„ muistin kanssa
 *
 */

#include "vec_mem.h"
#include "vec_file.h"

#include <stdlib.h>
#include <string.h>

#ifdef KUU
uint8 *vec_alloc_texture(int bpp)
{
    uint8       *desoto,*plaza;
    long        len=(bpp+7)/8 * 0x10000 + 0x800;
    vec_texhdr  *hdr;

    if(!(desoto=malloc(len + (bpp==8 ? 0x300 : 0))))
        return NULL;
    plaza=(uint8 *)(((long)desoto&~0x3ff)+0x800);

    hdr=VEC_TH(plaza);
    memset(hdr->name,0,13);
    hdr->addr=desoto;
    hdr->width=hdr->height=256;
    hdr->bpp=bpp;

    if(bpp == 8)
        hdr->palette=plaza+0x300;
    else
        hdr->palette=NULL;

    return plaza;
}

void vec_free_texture(uint8 *texmex)
{
    if(texmex)
        free(VEC_TH(texmex)->addr);
}

uint8 *vec_get_texture(const char *data,int bpp)
{
    uint8   *ret;

    vec_set_source(VEC_SRC_MEM);
    ret=vec_load_texture(data,bpp);
    vec_set_source(VEC_SRC_FILE);

    return ret;
}

vec_obj *vec_get_object(const char *data)
{
    vec_obj *ret;

    vec_set_source(VEC_SRC_MEM);
    ret=vec_load_object(data);
    vec_set_source(VEC_SRC_FILE);

    return ret;
}

#endif

int vec_get_objects(const char *data,vec_world *objs)
{
    int     ret;

    vec_set_source(VEC_SRC_MEM);
    ret=vec_load_objects(data,objs);
    vec_set_source(VEC_SRC_FILE);

    return ret;
}

int vec_get_camera(const char *data,long num,vec_cam *camel)
{
    int     ret;

    vec_set_source(VEC_SRC_MEM);
    ret=vec_load_camera(data,num,camel);
    vec_set_source(VEC_SRC_FILE);

    return ret;
}

#ifdef KUU

int vec_get_cam_kf(const char *data,char *camname,vec_ckf *ckf)
{
    int     ret;

    vec_set_source(VEC_SRC_MEM);
    ret=vec_load_cam_kf(data,camname,ckf);
    vec_set_source(VEC_SRC_FILE);

    return ret;
}

int vec_get_obj_kf(const char *data,char *objname,vec_okf *okf)
{
    int     ret;

    vec_set_source(VEC_SRC_MEM);
    ret=vec_load_obj_kf(data,objname,okf);
    vec_set_source(VEC_SRC_FILE);

    return ret;
}

int vec_get_kf(const char *data,vec_cam *cam)
{
    int     ret;

    vec_set_source(VEC_SRC_MEM);
    ret=vec_load_kf(data,cam);
    vec_set_source(VEC_SRC_FILE);

    return ret;
}

int vec_get_materials(const char *data,vec_world *world)
{
    int     ret;

    vec_set_source(VEC_SRC_MEM);
    ret=vec_load_materials(data,world);
    vec_set_source(VEC_SRC_FILE);

    return ret;
}
#endif
