/*
 *
 *      VecSys Camera
 *
 *      - rutiinit maailman k„sittelyyn
 *
 */

#ifndef VEC_CAM_H
#define VEC_CAM_H

typedef struct VEC_CAM      vec_world;
typedef struct VEC_CAM      vec_cam;
typedef struct VEC_OBJNODE  vec_nod;

#include "vecsys.h"
#include "vec_kf.h"
#include "vec_type.h"

enum                        //      Linkmodet hierarkiaan
{                           
    VEC_LINK_POS =  1,      //      Vain paikka linkattu
    VEC_LINK_X   =  2,
    VEC_LINK_Y   =  4,
    VEC_LINK_Z   =  8,
    VEC_LINK_ALL =  15      //      My”s asento linkattu
};

struct VEC_OBJNODE
{
    vec_obj *obj;           //      N”den objekti

    vec_nod *nextnode,      //      Seuraava n”de
            *parentnode;    //      Hierarkian alempi taso

    int     hierarchy,      //      Hierarkiatason tunnus
            linkmode;       //      Eri rotaatiosuuntien linkkaus

    vec_okf kf;             //      Keyframet
};

typedef enum                //      Dirmodet kameraan
{                           
    VEC_CAM_LOOKAT,
    VEC_CAM_ANGLES,
    VEC_CAM_AXIS
} vec_dir;

typedef struct              //      Objektilistan juuri
{
    vec_nod *first;         //      Listan ensimm„inen node
    long    objects;
} vec_ol;

struct VEC_CAM
{
    vec_ol  *objlist;       //      Objektistruktuurit listassa
    vec_nod *curnode;       //      K„telt„v„n objektin node

    vec_dir dirmode;        //      Tapa jolla suunta esitet„„n

    vec_fp  w[3],           //      Kameran paikka

                            //      dirmode: VEC_CAM_LOOKAT
            l[3],           //      Kameran kohdepiste

                            //      dirmode: VEC_CAM_AXIS
            up[3],fwd[3],   //      Vektorit yl”s ja eteen

                            //      dirmode: VEC_CAM_ANGLES
            ax,ay,az,       //      Maailman katselukulman muutos
                            //      dirmode: VEC_CAM_LOOKAT
                            //      az on absoluuttinen kulma

            d[3],           //      Deltat, kameran koordinaatisto

            matr[4][4];     //      Kameran matriisi

    long    xres,yres;      //      Kameran resoluutio
    int     cdepth,         //      Kameran v„risyvyys
            aspect;         //      Kuvan muoto (y-suunnan kerroin)
                            //      256=normaali 4:3 muotoinen alue

    uint8   *dbuf;          //      Puskuri jonne piirret„„n
    vec_fp  *zbuf;          //      Z-buffer

    char    name[11];       //      Kameran nimi

    vec_ckf kf;             //      Keyframet
};

extern int      vec_init(vec_world *world);
extern int      vec_init_cam(vec_cam *cam,vec_world *world);
extern void     vec_close(vec_world *world);
extern void     vec_close_cam(vec_cam *cam);

extern int      vec_add_object(vec_world *world,vec_obj *obj,int hierarchy);
extern vec_obj  *vec_copy_object(vec_world *world,vec_obj *obj,int hierarchy);
extern void     vec_del_object(vec_world *world,vec_obj *obj);
extern void     vec_free_objects(vec_world *world);

extern void     vec_seek_set(vec_cam *cam);
extern vec_obj  *vec_seek_obj(vec_cam *cam);

extern int      vec_set_camaspect(vec_cam *cam,int aspect);
extern int      vec_set_camres(vec_cam *cam,long xres,long yres,int cdepth);
extern int      vec_set_dbuffer(vec_cam *cam,void *dbuf);
extern int      vec_set_zbuffer(vec_cam *cam,int state);

extern int      vec_update_camera(vec_cam *cam);

extern void     vec_render_world(vec_cam *cam);

#endif

