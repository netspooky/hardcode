/*
 *
 *      VecSys File
 *
 *      - objektien ja tekstuurien lataus
 *
 */

#ifndef VEC_FILE_H
#define VEC_FILE_H

#include "vecsys.h"
#include "vec_cam.h"
#include "vec_kf.h"

enum
{
    VEC_IFF,
    VEC_JPEG,

    VEC_MATLIST,

    VEC_3DS,
    VEC_MATLIB,
    VEC_MATERIAL,
    VEC_PROJECT,

    VEC_UNKNOWN
};

enum
{
    VEC_SRC_FILE,
    VEC_SRC_MEM
};

extern void     vec_set_source(int type);
extern int      vec_tell_filetype(const char *filename);

extern uint8    *vec_load_texture(const char *filename,int bpp);
extern vec_obj  *vec_load_object(const char *filename);

extern int      vec_load_objects(const char *filename,vec_world *world);
extern int      vec_convert_matinfo(const char *filename,const char *outfile);
extern int      vec_load_materials(const char *filename,vec_world *world);

extern int      vec_load_camera(const char *filename,int num,vec_cam *cam);
extern int      vec_load_cam_kf(const char *filename,const char *camname,
                    vec_ckf *ckf);
extern int      vec_load_obj_kf(const char *filename,const char *objname,
                    vec_okf *okf);
extern int      vec_load_kf(const char *filename,vec_cam *cam);

#endif

