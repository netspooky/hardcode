
#ifndef WAVEFRONT_H
#define WAVEFRONT_H

#include <math.h>

#define TYPE_OBJECT 1
#define TYPE_PIVOT 2
#define TYPE_POINT 3

typedef struct mtl_type
{
    float   ambient[4],
            diffuse[4],
            specular[4],
            opacity,
            shininess;

    char name[1000];

    struct mtl_type *next;
} MTL;

typedef struct face_type
{
    int     num,
            *index,
            *normal;

    struct face_type *next;
} FACE;

typedef struct part_type
{
    FACE    *faces;
    MTL     *material;

    char    name[1000];

    struct part_type *next;
} PART;

typedef struct obj_type
{
    int     type;

    PART    *parts;

    char    name[1000];

    struct obj_type *next,
                    *pivot;

    float   rot,        /* Parameters for glRotate (used with pivot) */
            x,y,z;
    float   tx,ty,tz;   /* Parameters for glTranslate (pivot) */
} OBJ;

typedef struct scene_type
{
    float   *v,
            *vn;

    int     vs,
            vns,
            lighting;

    OBJ     *objects;

    MTL     *materials;
} SCENE;

int load_scene(SCENE *s,char *name);
int get_scene(SCENE *s,char *obj,char *mtl);
void delete_scene(SCENE *s);
void pivot_vectors(SCENE *s,OBJ *o);
OBJ *find_object(SCENE *s,char *name);

#endif
