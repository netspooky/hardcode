/*
 *
 *      VecSys Camera
 *
 *      - rutiinit maailman k„sittelyyn
 *
 */

#include "vecsys.h"
#include "vec_def.h"
#include "vec_cam.h"
#include "vec_matr.h"
#include "vec_poly.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static long vec_worlds=0;

static void vec_lookat(vec_cam *cam);
static int  vec_cmpdist(const void *v1,const void *v2);
static void vec_calc_ematr(vec_cam *cam,vec_nod *node);

int vec_init(vec_world *world)
{
    if(world==NULL || (!vec_worlds && vec_init_sys()==VEC_ERR))
        return VEC_ERR;

    memset(world,0,sizeof(vec_world));      //      nollataan kaikki

#ifndef VEC_NO_FLOAT
    world->dirmode=VEC_CAM_LOOKAT;
#else
    world->dirmode=VEC_CAM_ANGLES;
#endif

    if(!(world->objlist=malloc(sizeof(vec_ol))))
        return VEC_ERR;
    world->objlist->first=NULL;
    world->objlist->objects=0;

    world->fwd[Zi]=-1;
    world->up[Yi]=1;

    vec_init_qmatr(world->matr);

    world->xres=320;            //      Asetetaan normaali reso
    world->yres=200;
    world->cdepth=8;
    world->aspect=0x100;        //      Asetetaan normaali muoto

    vec_worlds++;               //      Itse asiassa kameleita

    return VEC_OK;
}

int vec_init_cam(vec_cam *cam,vec_world *world)
{
    if(cam==NULL || world==NULL)
        return VEC_ERR;

    *cam=*world;

    return VEC_OK;
}

void vec_close(vec_world *world)
{
    if(world == NULL)
        return;

    /*vec_free_objects(world);
    free(world->objlist);*/

    if(!(--vec_worlds))         //      Kun kaikki maailmat on sul-
        vec_close_sys();        //      jettu, suljetaan systeemi
}

void vec_close_cam(vec_cam *cam)
{
    if(cam == NULL)
        return;

    // vec_free_kf(cam);
    vec_set_zbuffer(cam,0);
}

int vec_add_object(vec_world *world,vec_obj *obz,int hierarchy)
{
    vec_nod **obp,*node,*parent=NULL;

    if(world==NULL || obz==NULL)
        return VEC_ERR;

    if(!(node=malloc(sizeof(vec_nod))))
        return VEC_ERR;
    memset(node,0,sizeof(vec_nod));

    for(obp=&world->objlist->first; *obp; obp=&(*obp)->nextnode)
    {
        if(hierarchy > (*obp)->hierarchy)
            parent=*obp;
    }

    *obp=node;

    node->obj=obz;
    node->parentnode=parent;
    node->hierarchy=hierarchy;
    node->linkmode=VEC_LINK_ALL;

    obz->sharedat[VEC_SHARE_OBJ]++;
    world->objlist->objects++;

    return VEC_OK;
}

vec_obj *vec_copy_object(vec_world *world,vec_obj *obz,int hierarchy)
{
    vec_obj *obj=malloc(sizeof(vec_obj));

    if(obj==NULL || obz==NULL)
        return NULL;

    *obj=*obz;

    obj->vcoord=malloc(obj->vertices*3*sizeof(vec_fp));
    obj->scoord=malloc(obj->vertices*2*sizeof(vec_fp));
    if(obj->normal)
    {
        obj->sharedat[VEC_SHARE_NORM]++;
        obj->ncoord=malloc(obj->vertices*3*sizeof(vec_fp));
    }
    obj->sharedat[VEC_SHARE_DATA]++;

    if(vec_add_object(world,obj,-1) == VEC_ERR)
    {
        vec_free_object(obj);
        return NULL;
    }

    /*vec_add_texture(obj->env);
    vec_add_texture(obj->texture);
    vec_add_texture(obj->bump);*/

    return obj;
}
/*
void vec_del_object(vec_world *world,vec_obj *obz)
{
    vec_nod **obp,*node;

    if(!world || !obz || !(obp=&world->objlist->first))
        return;

    while((*obp)->obj != obz)
    {
        obp=&(*obp)->nextnode;
        if(*obp == NULL)
            return;
    }

    node=(*obp)->nextnode;
    obz->sharedat[VEC_SHARE_OBJ]--;
    world->objlist->objects--;
    free(*obp);
    *obp=node;
}

void vec_free_objects(vec_world *world)
{
    vec_nod *next,*node=world->objlist->first;
    vec_obj *obj;

    if(world == NULL)
        return;

    while(node != NULL)
    {
        obj=node->obj;
        next=node->nextnode;
        vec_del_object(world,obj);
        vec_free_object(obj);
        node=next;
    }
}
*/
void vec_seek_set(vec_cam *cam)
{
    cam->curnode=NULL;
}

vec_obj *vec_seek_obj(vec_cam *cam)
{
    if(cam->curnode == NULL)
        cam->curnode=cam->objlist->first;
    else
        cam->curnode=cam->curnode->nextnode;

    if(cam->curnode)
        return cam->curnode->obj;
    else
        return NULL;
}

int vec_set_camaspect(vec_cam *cam,int aspect)
{
    if(vec_set_aspect(aspect) == VEC_ERR)
        return VEC_ERR;

    cam->aspect=aspect;

    return VEC_OK;
}

int vec_set_camres(vec_cam *cam,long xres,long yres,int cdepth)
{
    if(vec_set_res(xres,yres,cdepth) == VEC_ERR)
        return VEC_ERR;

    cam->xres=xres;
    cam->yres=yres;
    cam->cdepth=cdepth;

    if(cam->zbuf)
    {
        vec_set_zbuffer(cam,0);
        vec_set_zbuffer(cam,1);
    }

    return VEC_OK;
}

int vec_set_dbuffer(vec_cam *cam,void *dbuf)
{
    if(dbuf == NULL)
        return VEC_ERR;

    cam->dbuf=dbuf;

    return VEC_OK;
}

int vec_set_zbuffer(vec_cam *cam,int state)
{
    long    zlen=cam->xres*cam->yres;

    if(state)
    {
        if(cam->zbuf)
            vec_set_zbuffer(cam,0);
        if(!(cam->zbuf=malloc(zlen*sizeof(vec_fp))))
            return VEC_ERR;
        for(/*zlen*/; zlen>=0; zlen--)
            cam->zbuf[zlen]=0;
    }
    else
    {
        // free(cam->zbuf);
        cam->zbuf=NULL;
    }

    return VEC_OK;
}

void vec_lookat(vec_cam *cam)
{
    vec_fp  matr[4][4],lookdir[3];
    int     n;

    switch(cam->dirmode)
    {
#ifndef VEC_NO_FLOAT
        case VEC_CAM_AXIS:
            vec_init_qmatr(cam->matr);
            vec_calc_qtoaxis(cam->matr,cam->fwd,cam->up);
            break;

        case VEC_CAM_LOOKAT:
            vec_init_qmatr(cam->matr);
            for(n=Xi; n<=Zi; n++)
                lookdir[n]=cam->l[n] - cam->w[n];
            vec_calc_qtodir(cam->matr,lookdir,cam->az);
            break;
#endif
        case VEC_CAM_ANGLES:
            vec_calc_qrot(cam->matr,cam->ax,cam->ay,cam->az);
            vec_matrixmul_4x4(cam->matr,matr,cam->matr);
    }

    for(n=Xi; n<=Zi; n++)
        cam->matr[n][3]=-cam->d[n];
}

int vec_cmpdist(const void *v1,const void *v2)
{
    vec_nod **o1=(void *)v1,**o2=(void *)v2;
    vec_obj *obj;
    int     bool;

    bool=(*o1)->obj->objdist > (*o2)->obj->objdist;

    if(bool^(vec_tell_zbuffer() != NULL))
    {
        obj=(*o1)->obj;
        (*o1)->obj=(*o2)->obj;
        (*o2)->obj=obj;
    }

    return 0;
}

void vec_calc_ematr(vec_cam *cam,vec_nod *node)
{
    void    *mmatr;
    vec_obj *obz=node->obj;
    int     i;

    memcpy(obz->ematr,obz->omatr,16*sizeof(vec_fp));

    if(node->parentnode)
        mmatr=node->parentnode->obj->ematr;
    else
    {
        vec_mirror_object(obz);

        mmatr=cam->matr;
        for(i=Xi; i<=Zi; i++)
            obz->ematr[i][3]+=obz->w[i]-cam->w[i];
    }

    vec_matrixmul_4x4(mmatr,obz->ematr,obz->ematr);
    
}

int vec_update_camera(vec_cam *cam)
{
    long    n,i,nof=cam->objlist->objects;
    int     sorttype=vec_tell_sorttype();
    vec_fp  xk=3*64/128,yk=cam->aspect/128,
            *zen,*wcoord;
    vec_nod *node,**nodeptr=NULL;
    vec_obj *obz;

    if(!(wcoord=malloc(3*nof*sizeof(vec_fp))))
        return VEC_ERR;
    memset(wcoord,0,3*nof*sizeof(vec_fp));

    if(sorttype == VEC_COUNTING)
    {
        if(!(nodeptr=malloc(nof*sizeof(void *))))
        {
            free(wcoord);
            return VEC_ERR;
        }
    }

    vec_lookat(cam);

    for(n=0,node=cam->objlist->first; node; n+=3,node=node->nextnode)
    {
        obz=node->obj;

        vec_rotate_object(obz);
        vec_translate_object(obz);
        vec_calc_ematr(cam,node);

        for(i=Xi; i<=Zi; i++)
            wcoord[n+i]=-obz->mmatr[i][3];

        vec_transf_vects(1,obz->ematr,&wcoord[n],&wcoord[n]);
    }

    for(n=i=0,node=cam->objlist->first; node; n+=3,node=node->nextnode)
    {
        obz=node->obj;
        zen=&wcoord[n];

        if( (abs(zen[Xi])-obz->maxvtxlen*91/64)*xk > -zen[Zi] ||
            (abs(zen[Yi])-obz->maxvtxlen*91/64)*yk > -zen[Zi] ||
            !obz->vertices )
            obz->objdist=VEC_INVISIBLE;
        else
        {
            obz->objdist=-zen[Zi];
            if(sorttype == VEC_COUNTING)
                nodeptr[i++]=node;
        }
    }

    if(sorttype == VEC_COUNTING)
    {
        qsort(nodeptr,i,sizeof(void *),vec_cmpdist);

        free(nodeptr);
    }

    free(wcoord);

    if( vec_set_aspect(cam->aspect)==VEC_ERR ||
        vec_set_res(cam->xres,cam->yres,cam->cdepth)==VEC_ERR ||
        vec_set_bufs(cam->dbuf,cam->zbuf)==VEC_ERR )
        return VEC_ERR;

    return VEC_OK;
}

void vec_render_world(vec_cam *cam)
{
    vec_obj *obj;
    vec_nod *node;

    vec_init_sort();
    vec_update_camera(cam);

    for(node=cam->objlist->first; node; node=node->nextnode)
    {
        obj=node->obj;

        if(obj->objdist < VEC_INVISIBLE)
        {
            vec_project_object(obj,cam->xres,cam->yres,cam->aspect);
            vec_visicalc(obj);
#ifdef  VEC_LSRC_H
            if(obj->type & (VEC_GOURAUD+VEC_FLAT))
                vec_init_shading(obj);
#endif
        }
    }

    vec_draw_objects();
}

