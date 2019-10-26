/*------------------------------------------------------------------------

        Projekti        :       Vector System
        Versio          :       1.3 - ehk„ joskus
        Aika            :       26.6.1996 -
        Tekij„t         :       Pete/Fit ja muut

-------------------------------------------------------------------------*/

#include "vecsys.h"
#include "vec_math.h"
#include "vec_matr.h"
#include "vec_mtrl.h"
#include "radix.h"

#include <string.h>
#include <stdlib.h>

static long     vec_xres=320,vec_yres=200;
static int      vec_aspect=0x100;
static vec_fp   vec_xm,vec_ym;

static int      vec_mirror=0;
static int      vec_sorttype;   //  Radix tai pelkk„ Counting sort

//  Radix sort -taulukot (unsigned koska radix.h niin haluaa)
static unsigned sort_arr[4*VEC_MAX_FACES],*sort_res,
                face_z[VEC_MAX_FACES];
static long     face_n[VEC_MAX_FACES], viz_face=0;
static vec_obj  *face_obj[VEC_MAX_FACES];

static void vec_transf_object(vec_obj *obz);
static void vec_sort_objects(void);
static int  vec_tell_visiblity(vec_obj *obz,long face);
static int  vec_prep_vertex(vec_obj *obz,long type,vec_vtx v[],
                long vtx_idx,int vtx_num,long face_idx,
                int facedir,long vtx_idx_t[]);
static void vec_frontclip(vec_obj *obz,vec_vtx v[],int clip_idx,
                int vtx_cnt,long vtx_idx_t[]);
static void vec_fill_objects(void);

int vec_init_sys(void)
{
    vec_calc_sqrt();
#ifdef  VEC_NO_FLOAT
    vec_calc_sin();
#else
    if(sizeof(float) != 4)
        return VEC_ERR;
#endif
    vec_sorttype=VEC_COUNTING;
#ifdef  VEC_POLY_H
    vec_init_fill();
#endif
    return VEC_OK;
}

void vec_close_sys(void)
{
#ifdef  VEC_POLY_H
    vec_close_fill();
#endif
}

void vec_rotate(long num,vec_fp *so,vec_fp *de,
        vec_fp ax,vec_fp ay,vec_fp az)
{
    static vec_fp   matr[4][4];

    vec_init_qmatr(matr);
    vec_calc_qrot(matr,ax,ay,az);
    vec_transf_vects(num,matr,so,de);
}

void vec_move(long num,vec_fp *so,vec_fp dlt[])
{
    long    n,m;

    for(m=0; m<3*num; m+=3)
        for(n=Xi; n<=Zi; n++)
            so[m+n]+=dlt[n];
}

void vec_project(long num,vec_fp *so,vec_fp *de,
        long xsize,long ysize,vec_fp asp)
{
    long    n,m, xp=xsize<<7,yp=ysize<<7;
    vec_fp  xker=xsize*3*64,yker=ysize*asp, dist;

    for(n=0,m=0,num*=2; n<num; n+=2,m+=3)
    {
        if((dist=-so[m+Zi]) >= -VEC_FRONTCLIP)
        {
            de[n+Xi] = (vec_fp)xp + so[m+Xi]*xker/dist;
            de[n+Yi] = (vec_fp)yp - so[m+Yi]*yker/dist;
        }
        else
        {
            de[n+Xi] = xp;
            de[n+Yi] = yp;
        }
    }
}

void vec_rotate_object(vec_obj *obz)
{
    static vec_fp   matr[4][4];

    if(obz->ax || obz->ay || obz->az)
    {
        vec_init_qmatr(matr);
        vec_calc_qrot(matr,obz->ax,obz->ay,obz->az);
        obz->ax=obz->ay=obz->az=0;
        vec_matrixmul_4x4(matr,obz->omatr,obz->omatr);

#ifndef VEC_LSRC_H
        if(obz->type&VEC_GOURAUD+VEC_FLAT && obz->ncoord)
        {
            memcpy(matr,obz->omatr,16*sizeof(vec_fp));
            matr[0][3]=matr[1][3]=matr[2][3]=0;
            vec_transf_vects(obz->vertices,matr,obz->normal,
                obz->ncoord);
        }
#endif
    }
}

void vec_translate_object(vec_obj *obz)
{
    int     n;

    for(n=Xi; n<=Zi; n++)
    {
        obz->omatr[n][3]+=obz->d[n];
        obz->d[n]=0;
    }
}

void vec_transf_object(vec_obj *obz)
{
    vec_fp  matr[4][4];

    vec_transf_vects(obz->vertices,obz->ematr,obz->vertex,obz->vcoord);

    if((obz->type&(VEC_ENV+VEC_BUMP)) && obz->ncoord)
    {
        memcpy(matr,obz->ematr,16*sizeof(vec_fp));
        matr[Xi][3]=matr[Yi][3]=matr[Zi][3]=0;
        vec_transf_vects(obz->vertices,matr,obz->normal,obz->ncoord);
    }
}

void vec_project_object(vec_obj *obz,long xsize,long ysize,vec_fp asp)
{
    vec_transf_object(obz);

    vec_project(obz->vertices,obz->vcoord,obz->scoord,xsize,ysize,asp);
}

void vec_set_mirror(vec_fp mirror[4][4])
{
    if(mirror)
        vec_mirror=1;
    else
        vec_mirror=0;
}

void vec_mirror_object(vec_obj *obz)
{
    static vec_fp   matr[4][4];

    if(vec_mirror)
    {
        vec_init_qmatr(matr);
        matr[2][2]=-1;
        vec_matrixmul_4x4(matr,obz->ematr,obz->ematr);
    }
}

#ifdef  VEC_POLY_H

int vec_set_aspect(int aspect)
{
    if(aspect < 0)
        return VEC_ERR;

    vec_aspect=aspect;

    return VEC_OK;
}

int vec_set_res(long x,long y,int cdepth)
{
    if(vec_set_fillres(x,y,cdepth) == VEC_ERR)
        return VEC_ERR;

    vec_xres=x;
    vec_yres=y;

    return VEC_OK;
}

int vec_tell_visiblity(vec_obj *obz,long face)
{
    vec_fp  Ax,Ay,Bx,By, *sc=obz->scoord;

    Ax = sc[obz->face[face+1]*2+Xi] - sc[obz->face[face+0]*2+Xi];
    Ay = sc[obz->face[face+1]*2+Yi] - sc[obz->face[face+0]*2+Yi];
    Bx = sc[obz->face[face+2]*2+Xi] - sc[obz->face[face+1]*2+Xi];
    By = sc[obz->face[face+2]*2+Yi] - sc[obz->face[face+1]*2+Yi];

    return (Ay*Bx <= By*Ax)^vec_mirror;
}

long vec_visicalc(vec_obj *obz)
{
    long    m,n, dist=0,face,fcd;
    int     sortdir=vec_tell_zbuffer() && !(obz->type&VEC_ANATAUS),
            booli, viz=1;
    vec_fp  vd[3];

    if(vec_sorttype == VEC_COUNTING)
        dist=(obz->maxvtxlen - obz->objdist)*3;

    for(m=face=0; m<obz->faces; m++,face=m*VEC_MAX_VPF)
    {
        for(n=fcd=0; n<3; n++)
        {
            vd[n]=obz->vcoord[obz->face[face+n]*3+Zi];
            fcd+=vd[n];
        }

        if((viz=(vd[0] > VEC_FRONTCLIP)+
                (vd[1] > VEC_FRONTCLIP)+
                (vd[2] > VEC_FRONTCLIP)) == 3)
            continue;

        if(!viz)
            booli=vec_tell_visiblity(obz,face);
        else
            booli=1;

        if(booli || obz->type&VEC_ANATAUS)
        {
            if(viz_face >= VEC_MAX_FACES)
                break;

            if(vec_sorttype != VEC_COUNTING)
                fcd=sortdir ? min(0,fcd) : max(0,-fcd);
            else
                fcd=min(RANGE-1,max(0,dist-fcd) >> 13);

            face_z[viz_face]=fcd >> 8;
            face_n[viz_face]=booli ? face : ~face;
            face_obj[viz_face++]=obz;
        }
    }

    return viz_face;
}

int vec_tell_sorttype(void)
{
    return vec_sorttype;
}

void vec_init_sort(void)
{
    vec_sorttype=VEC_RADIX;
    viz_face=0;
}

void vec_sort_objects(void)
{
    sort_res=byte_radix(viz_face,face_z,sort_arr,VEC_SORTBYTES);
}

void vec_draw_object(vec_obj *obz)
{
    vec_sorttype=VEC_COUNTING;
    viz_face=0;
    vec_visicalc(obz);
    sort_res=counting_sort(viz_face,face_z,sort_arr);

#ifdef  VEC_LSRC_H
    if(obz->type & (VEC_GOURAUD+VEC_FLAT))
        vec_init_shading(obz);
#endif
    vec_fill_objects();
}

void vec_draw_objects(void)
{
    if(vec_tell_zbuffer())
        vec_clear_zbuffer();

    // setrgb(0,0,10,0);
    vec_sort_objects();
    // setrgb(0,0,0,10);
    vec_fill_objects();
    // setrgb(0,0,0,0);
}

int vec_prep_vertex(vec_obj *obz,long type,vec_vtx v[],long vtx_idx,
        int vtx_num,long face_idx,int facedir,long vtx_idx_t[])
{
    static long vtx_cnt,clip_idx;
    static int  prev_visible;
    long        i=vtx_idx;
    int         n;
    vec_vtx     *vp;

    //  alustus alussa
    if(vtx_num == 0)
    {
        vtx_cnt=0;
        clip_idx=vtx_idx_t[2]=-1;
        prev_visible=1;
    }

    //  jos piste on etuklippaustason takana
    if(obz->vcoord[i*3+Zi] > VEC_FRONTCLIP)
    {
        if(prev_visible)
        {
            if(clip_idx < 0)
            {
                clip_idx=vtx_cnt;
                vtx_cnt+=2;
                for(n=2; n<VEC_MAXV; n++)
                    ((vec_ff *)&v[clip_idx])[n]=VEC_INVISIBLE;
            }
            else
            {
                vtx_idx_t[2]=vtx_idx_t[1];
                v[clip_idx+1]=v[clip_idx];
            }
            vtx_idx_t[1]=i*3;
            vp=&v[clip_idx];
        }
        else
        {
            vtx_idx_t[2]=i*3;
            vp=&v[clip_idx+1];
        }
        prev_visible=0;
    }
    else
    {
        if(clip_idx <= 0)
            vtx_idx_t[0]=i*3;
        if(!prev_visible || !vtx_cnt)
            vtx_idx_t[3]=i*3;
        vp=&v[vtx_cnt++];
        prev_visible=1;
    }

    switch(type)
    {
        case VEC_GOURAUD:
#ifdef  VEC_LSRC_H
            vp->i=vec_shade(obz,face_idx);
#else
            vp->i=max(1,-obz->ncoord[i*3+Zi]);
#endif
            break;
        case VEC_GOURAUD+VEC_TEXTURE:
#ifdef  VEC_LSRC_H
            vp->i=vec_shade(obz,face_idx);
#else
            vp->i=obz->ncoord[i*3+Zi]/8;
#endif
        case VEC_TEXTURE:
            vp->u1=obz->tcoord[i*2+Xi];
            vp->v1=obz->tcoord[i*2+Yi];
            break;
        case VEC_BUMP:
        case VEC_ENV+VEC_TEXTURE:
            vp->u1=obz->tcoord[i*2+Xi];
            vp->v1=obz->tcoord[i*2+Yi];
        case VEC_ENV:
            if(facedir < 0)
            {
                vp->u2=0x8000-obz->normal[i*3+Xi];
                vp->v2=0x8000+obz->normal[i*3+Yi];
            }
            else
            {
                vp->u2=0x8000+obz->ncoord[i*3+Xi];
                vp->v2=0x8000-obz->ncoord[i*3+Yi];
            }
            break;
    }

    if(vec_tell_zbuffer() || obz->type&VEC_PCORRECT)
        vp->z=-obz->vcoord[i*3+Zi];

    vp->x=obz->scoord[i*2+Xi];
    vp->y=obz->scoord[i*2+Yi];

    return vtx_cnt;
}

void vec_frontclip(vec_obj *obz,vec_vtx v[],int clip_idx,int vtx_cnt,
        long vtx_idx_t[])
{
    vec_fp  t1,t2, *vco=obz->vcoord;
    vec_ff  *v1=(vec_ff *)&v[clip_idx], *v2=v1 + VEC_MAXV,
            *pv=v1 - VEC_MAXV*((clip_idx > 0) ? 1 : 1-vtx_cnt),
            *nv=v2 + VEC_MAXV*((clip_idx+2 < vtx_cnt) ? 1 : 1-vtx_cnt);
    long    *i=vtx_idx_t;
    int     n, c=clip_idx;

    if(i[2] < 0)
    {
        i[2]=i[1];
        v[c+1]=v[c];
    }

    t1=(vco[i[1]+Zi]-VEC_FRONTCLIP) / (vco[i[1]+Zi]-vco[i[0]+Zi]);
    v[c].x += (vco[i[1]+Xi] + t1*(vco[i[0]+Xi]-vco[i[1]+Xi]))*vec_xm;
    v[c].y -= (vco[i[1]+Yi] + t1*(vco[i[0]+Yi]-vco[i[1]+Yi]))*vec_ym;

    t2=(vco[i[2]+Zi]-VEC_FRONTCLIP) / (vco[i[2]+Zi]-vco[i[3]+Zi]);
    v[c+1].x += (vco[i[2]+Xi] + t2*(vco[i[3]+Xi]-vco[i[2]+Xi]))*vec_xm;
    v[c+1].y -= (vco[i[2]+Yi] + t2*(vco[i[3]+Yi]-vco[i[2]+Yi]))*vec_ym;

    for(n=2; n<VEC_MAXV; n++)
        if(v1[n] != VEC_INVISIBLE)
        {
            v1[n] += t1*(pv[n]-v1[n]);
            v2[n] += t2*(nv[n]-v2[n]);
        }
}

void vec_fill_objects(void)
{
    vec_obj *obz;
    vec_vtx v[VEC_MAX_VPF+1];
    long    i,vi,fvi, vtx_idx_t[4],
            n, fnum,facedir, hype;
    int     vtx_cnt=0, clip_idx;

    vec_xm=(vec_fp)(-vec_xres * 3*64) / VEC_FRONTCLIP;
    vec_ym=(vec_fp)(-vec_yres * vec_aspect) / VEC_FRONTCLIP;

    for(n=viz_face; n>0; n--)
    {
        obz=face_obj[sort_res[2*n-1]];
        fnum=facedir=face_n[sort_res[2*n-1]];

        //  asetetaan fillaustyyppi
        hype=obz->type | (vec_tell_zbuffer() ? VEC_ZBUFFER:0);
        if(vec_set_filltype(hype &~VEC_ANATAUS) == VEC_ERR)
            continue;

        hype=obz->type &~(VEC_ZBUFFER+VEC_PCORRECT+
            VEC_TRANSPARENT+VEC_ANATAUS+VEC_FLAT);

        //  asetetaan tekstuurit
        switch(hype)
        {
            case VEC_BUMP:
                vec_set_texture(obz->bump,3);
            case VEC_ENV+VEC_TEXTURE:
                vec_set_texture(obz->env,2);
            case VEC_TEXTURE:
            case VEC_TEXTURE+VEC_GOURAUD:
            case VEC_IMAGE:
                vec_set_texture(obz->texture,1);
                break;
            case VEC_ENV:
                vec_set_texture(obz->env,1);
        }

        //  anataus n„kyy toisinkin p„in
        if(obz->type&VEC_ANATAUS && facedir<0)
        {
            fnum=~fnum;
            if(obz->anataus)
                vec_set_texture(obz->anataus,1);
        }

        for(i=0,clip_idx=-1; i<VEC_MAX_VPF; i++)
        {
            //  k„„nnet„„n 2-puoleinen taso
            fvi=((facedir>=0)^vec_mirror || i&1) ? i:2-i;

            //  jos on kolmio, hyp„t„„n pois
            if((vi=obz->face[fnum+fvi]) < 0)
                break;

            vtx_cnt=vec_prep_vertex(obz,hype,v,vi,i,fnum+fvi,
                facedir,vtx_idx_t);
            if(vtx_cnt>i+1 && clip_idx<0)
                clip_idx=i;
        }

        if(clip_idx >= 0)
        {
            if(vtx_cnt > VEC_MAX_VPF)
                continue;

            vec_frontclip(obz,v,clip_idx,vtx_cnt,vtx_idx_t);
        }

        if(obz->type & VEC_FLAT)
        {
#ifdef VEC_LSRC_H
            v[0].i=vec_shade(obz,fnum);
#else
            v[0].i=abs(obz->ncoord[obz->face[fnum]*3+Zi]+
                obz->ncoord[obz->face[fnum+1]*3+Zi]+
                obz->ncoord[obz->face[fnum+2]*3+Zi])*43/128;
#endif
        }

        vec_poly(vtx_cnt,v,obz->colour);
    }
}

#endif

vec_obj *vec_alloc_object(long vc,long fc,int tex)
{
    vec_obj *obz;

    if(fc>VEC_MAX_FACES || !(obz=malloc(sizeof(vec_obj))))
        return NULL;

    /*      nollataan kaikki        */
    memset(obz,0,sizeof(vec_obj));

    /*      sharedat-kent„t         */
    if(!(obz->sharedat=malloc(3*sizeof(int))))
    {
        free(obz);
        return NULL;
    }
    memset(obz->sharedat,0,3*sizeof(int));

    /*      tekstuurikoordinaatit   */
    obz->tcoord=tex ? malloc(vc*2*sizeof(vec_fp)) : NULL;
    /*      rottakoordinaatit       */
    obz->vcoord=malloc(vc*3*sizeof(vec_fp));
    /*      ruutukoordinaatit       */
    obz->scoord=malloc(vc*2*sizeof(vec_fp));

    if( (fc && !(obz->face=malloc(fc*VEC_MAX_VPF*sizeof(long)))) ||
        (vc && !(obz->vertex=malloc(vc*3*sizeof(vec_fp)))) )
    {
        vec_free_object(obz);
        return NULL;
    }

    obz->vertices=vc;
    obz->faces=fc;

    return obz;
}

void vec_init_object(vec_obj *obz)
{
    long    l,m,n;
    vec_fp  v[3];

    obz->type=VEC_FLAT;
    obz->colour=0x808080;
    obz->objdist=-obz->w[Zi];
    vec_init_qmatr(obz->omatr);
    vec_init_qmatr(obz->ematr);

    for(m=l=0; m<obz->faces; m++,l+=VEC_MAX_VPF)    //  kyersae!
    {
        n=obz->face[l];
        obz->face[l]=obz->face[l+2];
        obz->face[l+2]=n;
    }

    for(m=0,obz->maxvtxlen=0; m<obz->vertices*3; m+=3)
    {
        for(n=Xi; n<=Zi; n++)
            v[n] = obz->vertex[m+n] + obz->mmatr[n][3];

        obz->maxvtxlen=max(obz->maxvtxlen,
            v[Xi]*v[Xi] + v[Yi]*v[Yi] + v[Zi]*v[Zi]);
    }
#ifndef VEC_NO_FLOAT
    obz->maxvtxlen=sqrt(obz->maxvtxlen)+1;
#else
    obz->maxvtxlen=(vec_sqrt(obz->maxvtxlen,&m) << m-8) + (1 << m);
#endif
#ifdef  VEC_CALC_NORMALS
    if(obz->vertices)
        vec_calc_normals(obz);
#endif
}

void vec_free_object(vec_obj *obz)
{
    uint8   *texs[3];

    if(obz && !obz->sharedat[VEC_SHARE_OBJ])
    {
        if(obz->sharedat[VEC_SHARE_NORM])       
            obz->sharedat[VEC_SHARE_NORM]--;    //  on kopio
        else
            free(obz->normal);

        if(obz->sharedat[VEC_SHARE_DATA])       
            obz->sharedat[VEC_SHARE_DATA]--;    //  on kopio
        else
        {
            free(obz->face);
            free(obz->vertex);
            free(obz->tcoord);
            free(obz->sharedat);
        }

        free(obz->vcoord);
        free(obz->scoord);
        free(obz->ncoord);

        texs[0]=obz->env;
        texs[1]=obz->texture;
        texs[2]=obz->bump;
        /*for(n=0; n<3; n++)
            if(!vec_del_texture(texs[n]))
                vec_free_texture(texs[n]);*/

        free(obz);
    }
}

int vec_calc_normals(vec_obj *obz)
{
    long    m,n,i,j, f[3], *w_faces,
            vc=obz->vertices,fc=obz->faces;
    vec_fp  *nermal, A[3],B[3],N[3];

    if(obz->normal == NULL)
    {
        obz->normal=malloc(vc*3*sizeof(vec_fp));
        obz->ncoord=malloc(vc*3*sizeof(vec_fp));
        obz->sharedat[VEC_SHARE_NORM]=0;
    }

    w_faces=malloc(vc*16*sizeof(long));
    nermal=malloc(fc*3*sizeof(vec_fp));
    if(!w_faces || !nermal)
    {
        if(!obz->sharedat[VEC_SHARE_NORM])
        {
            free(obz->normal);
            free(obz->ncoord);
            obz->normal=obz->ncoord=NULL;
        }
        free(w_faces);
        free(nermal);
        return VEC_ERR;
    }

    for(m=0; m<fc; m++)
    {
        /*      Lasketaan tasojen normaalit     */

        for(j=0; j<3; j++)
            f[j]=obz->face[m*VEC_MAX_VPF+j]*3;

        for(i=Xi; i<=Zi; i++)
        {
            A[i] = obz->vertex[f[1]+i] - obz->vertex[f[0]+i];
            B[i] = obz->vertex[f[2]+i] - obz->vertex[f[0]+i];
        }

        vec_crossproduct(A,B,N);

        /*      Nermalisoidaan nermaalit        */

#ifdef  VEC_NO_FLOAT
        for(i=Xi; i<=Zi; i++)
            N[i]>>=6;
        vec_normalizevector(N);
        for(i=Xi; i<=Zi; i++)
            nermal[m*3+i]=N[i];
#else
        vec_normalizevector(N);
        for(i=Xi; i<=Zi; i++)
            nermal[m*3+i]=121*256*N[i];
#endif
    }

    memset(w_faces,0,vc*16*sizeof(long));
    for(j=0; j<fc; j++)
        for(n=0; n<VEC_MAX_VPF; n++)
        {
            if((m=obz->face[j*VEC_MAX_VPF+n]<<4) < 0)
                continue;

            if(w_faces[m] < 15)
                w_faces[m+(++w_faces[m])]=j*3;
        }

    memset(obz->normal,0,vc*3*sizeof(vec_fp));
    for(m=0; m<vc; m++)
    {
        for(n=1,j=m<<4; n<=w_faces[j]; n++)
            for(i=Xi; i<=Zi; i++)
                obz->normal[m*3+i]+=nermal[w_faces[j+n]+i];
        if(--n)
            for(i=Xi; i<=Zi; i++)
                obz->normal[m*3+i]/=n;
    }

    free(w_faces);
    free(nermal);
    return VEC_OK;
}

void vec_center_object(vec_obj *obj)
{
    long    n,vc;
    vec_fp  s[3]={0,0,0};

    if(!obj->vertices)
        return;

    for(n=Xi; n<Zi; n++)
        for(vc=0; vc<obj->vertices; vc++)
            s[n]+=obj->vertex[vc*3+n];
    for(n=Xi; n<Zi; n++)
    {
        s[n]/=-vc;
        obj->w[n]-=s[n];
    }

    vec_move(vc,obj->vertex,s);
}

/*      EOS     */

