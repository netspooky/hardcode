/*
 *
 *      VecSys Poly
 *
 *      - polygon fill
 *
 */

#include "vecsys.h"
#include "vec_poly.h"
#include "vec_mem.h"
#include "vec_math.h"

#include <stdlib.h>
#include <string.h>

#if (VEC_YRES < VEC_XRES)
#define MRES    VEC_XRES
#else
#define MRES    VEC_YRES
#endif

typedef union {
    int32   i;
    vec_fp  f;
} vtx_u[VEC_MAXV];

typedef struct {
    int32   i;
    vec_fp  f;
} vtx_s[VEC_MAXV];

#define Zin     (VEC_MAXV-1)
#define B32(b)  ((uint32 *)b)

#ifdef  VEC_X86
extern void vec_texfill_lin8(int32 x,int32 y,int32 dx,int32 dy,int32 end,
                int32 len,uint8 *dbuffer,uint8 *tex1);
extern void vec_texfill_lin32(int32 x,int32 y,int32 dx,int32 dy,int32 end,
                int32 len,uint8 *dbuffer,uint8 *tex1);
#endif  /* VEC_X86 */

static uint8    *vec_dbuffer=NULL,      //      t„nne piirret„„n
                *tex1=NULL,
                *tex2=NULL,             //      tekstuurit
                *tex3=NULL;
static vec_fp   *vec_zbuffer=NULL;      //      et„isyydet..

static uint8    bytemul[0x10000];

static uint32   talvi;                  //      v„liaikaiss„il”

static long     vec_xres=320,           //      piirtoresoluutio
                vec_yres=200,
                vec_cdepth=8,           //      bitti„/pikseli

                curfilltype=0,          //      nykyinen fillaustyyppi

                miny,maxy,minx,maxx,    //      polygonin piirtoalue
                midpoint;

static int      nova,var_num[VEC_MAXV]; //      montako ja mitk„ muuttujat

static vtx_u    beg[MRES],              //      polygonin alku- ja
                end[MRES];              //      loppureunojen puskurit

static vtx_s    dlt,                    //      deltat
                var/*,v2r*/;            //      muuttujat

static int      type_vars[] =           //      ei varsia
                {
                    0x01,0x41,0x0d,0x31,0x3d,0x01,0x80,0x80,0x00,0x00,
                    0x01,0x42,0x0e,0x32,0x3e,0x02,0x80,0x80,0x00,0x00
                };

#if defined(__WATCOMC__) && !defined(VEC_NO_TWEAK)
static int      vec_tweak=0;            //      piirto tweak-sivulle
static long     vec_page=0;
#else
static const int vec_tweak=0;            //      ei tweaked VGA:ta
#endif

#ifndef VEC_NO_FLOAT
#ifdef  __WATCOMC__
static double   tmpd,fist_magic=4503601774854144.0;
static float    tmpf;
extern long     qfist(float f);         //      nopea float->long
#else
#define         qfist(f) ((long)(f))    //      ei kovin q fist
#endif
#endif  /* VEC_NO_FLOAT */

static void (*vec_fill)(void);
static void (*vec_cline)(vec_vtx *,vec_vtx *);

/*      Linear:     */
//  erin„isten arvojen interpolointi pisteiden v„lille
static void c_line_lin(vec_vtx *vx1,vec_vtx *vx2);
//  sama kuin edellinen, perspektiivikorjattuna
static void cp_line_lin(vec_vtx *vx1,vec_vtx *vx2);
/*
static void f_poly_lin8(void);       //  flat fill
static void g_poly_lin8(void);       //  gouraud fill
static void t_poly_lin8(void);       //  texture mapping
static void gt_poly_lin8(void);      //  gouraud, texture
static void t2_poly_lin8(void);      //  2 * texture mapping
static void at2_poly_lin8(void);     //  transparent, 2 * texture
static void b_poly_lin8(void);       //  bump mapping (env+texture)
static void fz_poly_lin8(void);      //  z-buf, flatfill
static void gz_poly_lin8(void);      //  z-buf, gouraud
static void tz_poly_lin8(void);      //  z-buf, texture mapping
static void t2z_poly_lin8(void);     //  z-buf, 2 * texture mapping
static void bz_poly_lin8(void);      //  z-buf, bump mapping
static void tzp_poly_lin8(void);     //  z-buf, p-corr, texture
static void gtzp_poly_lin8(void);    //  z-buf, p-corr, gouraud texture
static void t2zp_poly_lin8(void);    //  z-buf, p-corr, 2 * texture
static void bzp_poly_lin8(void);     //  z-buf, p-corr, bump mapping
*/
static void f_poly_lin32(void);     //  flat fill
/*
static void g_poly_lin32(void);     //  gouraud fill
static void t_poly_lin32(void);     //  texture mapping
static void gt_poly_lin32(void);    //  gouraud, texture
static void at_poly_lin32(void);    //  transparent, texture
static void t2_poly_lin32(void);    //  2 * texture mapping
static void b_poly_lin32(void);     //  bump mapping (env+texture)
static void fz_poly_lin32(void);    //  z-buf, flat fill
static void afz_poly_lin32(void);   //  z-buf, transparent, flat fill
static void gz_poly_lin32(void);    //  z-buf, gouraud
static void tz_poly_lin32(void);    //  z-buf, texture mapping
static void t2z_poly_lin32(void);   //  z-buf, 2 * texture mapping
static void bz_poly_lin32(void);    //  z-buf, bump mapping
static void iz_poly_lin32(void);    //  z-buf, image fill
static void tzp_poly_lin32(void);   //  z-buf, p-corr, texture
static void gtzp_poly_lin32(void);  //  z-buf, p-corr, gouraud, texture
static void atzp_poly_lin32(void);  //  z-buf, p-corr, transp, texture
static void t2zp_poly_lin32(void);  //  z-buf, p-corr, 2 * texture
static void bzp_poly_lin32(void);   //  z-buf, p-corr, bump mapping
*/
/*      Tweak:      */
//  erin„isten arvojen interpolointi pisteiden v„lille
/*
static void c_line_tweak(vec_vtx *vx1,vec_vtx *vx2);

static void f_poly_tweak(void);     //  flat fill
static void t_poly_tweak(void);     //  texture mapping
*/
void vec_init_fill(void)
{
    long    i,j;

    for(i=0; i<0x100; i++)
        for(j=0; j<0x100; j++)
            bytemul[i*0x100+j]=i*j >> 8;
}

void vec_close_fill(void)
{
}

void vec_poly(int num,vec_vtx *vrtcs,uint32 col)
{
    int     m;
    uint8   *cc;

    maxx=minx=vrtcs->x;
    maxy=miny=vrtcs->y;
    for(m=1; m<num; m++)
    {
        if(vrtcs[m].x > maxx)
            maxx=vrtcs[m].x;
        else if(vrtcs[m].x < minx)
            minx=vrtcs[m].x;
        if(vrtcs[m].y > maxy)
            maxy=vrtcs[m].y;
        else if(vrtcs[m].y < miny)
            miny=vrtcs[m].y;
    }

    minx >>= 8;
    maxx >>= 8;
    miny >>= 8;
    maxy >>= 8;

    if(miny < 0)
    {
        if(maxy < 1)
            return;
        miny=0;
    }
    if(maxy > vec_yres)
    {
        if(miny > vec_yres-1)
            return;
        maxy=vec_yres;
    }
    if(minx < 0)
    {
        if(maxx < 1)
            return;
        minx=0;
    }
    if(maxx > vec_xres)
    {
        if(minx > vec_xres-1)
            return;
        maxx=vec_xres;
    }

    midpoint=(miny+maxy) >> 1;

    if(curfilltype & (VEC_FLAT+VEC_GOURAUD))
    {
        talvi=col;

        if((curfilltype&VEC_FLAT) && !(curfilltype&VEC_TRANSPARENT))
        {
            if(vec_cdepth == 8)
                talvi+=(uint32)vrtcs[0].i/0x100;
            else
                for(m=0,cc=(uint8 *)&talvi; m<3; m++)
                    cc[m]=bytemul[cc[m]+((uint32)vrtcs[0].i & 0xff00)];
        }
    }

    for(m=0,num--; m<num; m++)
        vec_cline(&vrtcs[m],&vrtcs[m+1]);
    vec_cline(&vrtcs[num],&vrtcs[0]);

    vec_fill();
}

int vec_set_filltype(long type)
{
    int     ftype, whichvars,
            num=vec_tweak ? sizeof(type_vars)/sizeof(int)/2 : 0;
    vec_ret retval=VEC_OK;

    if(curfilltype == type)
        return VEC_OK;
    curfilltype=type;

    if(vec_cdepth > 8)
    {
        switch(type)
        {
            case VEC_FLAT:
                vec_fill=f_poly_lin32;
                break;
#ifdef NUI
            case VEC_GOURAUD:
                vec_fill=g_poly_lin32;
                break;
            case VEC_ENV:
            case VEC_TEXTURE:
                vec_fill=t_poly_lin32;
                break;
            case VEC_GOURAUD+VEC_TEXTURE:
                vec_fill=gt_poly_lin32;
                break;
            case VEC_TRANSPARENT+VEC_ENV:
            case VEC_TRANSPARENT+VEC_TEXTURE:
                vec_fill=at_poly_lin32;
                break;
            case VEC_ENV+VEC_TEXTURE:
                vec_fill=t2_poly_lin32;
                break;
#ifndef VEC_NO_BUMP
            case VEC_BUMP:
                vec_fill=b_poly_lin32;
                break;
#endif  /* !VEC_NO_BUMP */
#ifndef VEC_NO_FLOAT
            case VEC_FLAT+VEC_ZBUFFER:
            case VEC_FLAT+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=fz_poly_lin32;
                break;
            case VEC_TRANSPARENT+VEC_FLAT+VEC_ZBUFFER:
            case VEC_TRANSPARENT+VEC_FLAT+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=afz_poly_lin32;
                break;
            case VEC_GOURAUD+VEC_ZBUFFER:
                vec_fill=gz_poly_lin32;
                break;
            case VEC_ENV+VEC_ZBUFFER:
            case VEC_TEXTURE+VEC_ZBUFFER:
                vec_fill=tz_poly_lin32;
                break;
#ifndef VEC_NO_BUMP
            case VEC_BUMP+VEC_ZBUFFER:
                vec_fill=bz_poly_lin32;
                break;
            case VEC_BUMP+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=bzp_poly_lin32;
                break;
#endif  /* !VEC_NO_BUMP */
            case VEC_ENV+VEC_TEXTURE+VEC_ZBUFFER:
                vec_fill=t2z_poly_lin32;
                break;
            case VEC_IMAGE+VEC_ZBUFFER:
            case VEC_IMAGE+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=iz_poly_lin32;
                break;
            case VEC_ENV+VEC_ZBUFFER+VEC_PCORRECT:
            case VEC_TEXTURE+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=tzp_poly_lin32;
                break;
            case VEC_GOURAUD+VEC_TEXTURE+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=gtzp_poly_lin32;
                break;
            case VEC_TRANSPARENT+VEC_ENV+VEC_ZBUFFER+VEC_PCORRECT:
            case VEC_TRANSPARENT+VEC_TEXTURE+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=atzp_poly_lin32;
                break;
            case VEC_ENV+VEC_TEXTURE+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=t2zp_poly_lin32;
                break;
#endif  /* !VEC_NO_FLOAT */
#endif
            default:
                vec_fill=f_poly_lin32;
                type=VEC_FLAT;
                retval=VEC_ERR;
        }
    }
#ifdef NUI
    else if(!vec_tweak)
        switch(type)
        {
            case VEC_FLAT:
                vec_fill=f_poly_lin8;
                break;
            case VEC_GOURAUD:
                vec_fill=g_poly_lin8;
                break;
            case VEC_ENV:
            case VEC_TEXTURE:
                vec_fill=t_poly_lin8;
                break;
            case VEC_GOURAUD+VEC_TEXTURE:
                vec_fill=gt_poly_lin8;
                break;
            case VEC_ENV+VEC_TEXTURE:
                vec_fill=t2_poly_lin8;
                break;
            case VEC_TRANSPARENT+VEC_TEXTURE+VEC_ENV:
                vec_fill=at2_poly_lin8;
                break;
#ifndef VEC_NO_BUMP
            case VEC_BUMP:
                vec_fill=b_poly_lin8;
                break;
#endif  /* !VEC_NO_BUMP */
#ifndef VEC_NO_FLOAT
            case VEC_FLAT+VEC_ZBUFFER:
            case VEC_FLAT+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=fz_poly_lin8;
                break;
            case VEC_GOURAUD+VEC_ZBUFFER:
                vec_fill=gz_poly_lin8;
                break;
            case VEC_ENV+VEC_ZBUFFER:
            case VEC_TEXTURE+VEC_ZBUFFER:
                vec_fill=tz_poly_lin8;
                break;
            case VEC_ENV+VEC_TEXTURE+VEC_ZBUFFER:
                vec_fill=t2z_poly_lin8;
                break;
#ifndef VEC_NO_BUMP
            case VEC_BUMP+VEC_ZBUFFER:
                vec_fill=bz_poly_lin8;
                break;
            case VEC_BUMP+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=bzp_poly_lin8;
                break;
#endif  /* !VEC_NO_BUMP */
            case VEC_ENV+VEC_ZBUFFER+VEC_PCORRECT:
            case VEC_TEXTURE+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=tzp_poly_lin8;
                break;
            case VEC_GOURAUD+VEC_TEXTURE+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=gtzp_poly_lin8;
                break;
            case VEC_ENV+VEC_TEXTURE+VEC_ZBUFFER+VEC_PCORRECT:
                vec_fill=t2zp_poly_lin8;
                break;
#endif  /* !VEC_NO_FLOAT */
            default:
                vec_fill=f_poly_lin8;
                type=VEC_FLAT;
                retval=VEC_ERR;
        }
#if defined(__WATCOMC__) && !defined(VEC_NO_TWEAK)
    else
        switch(type)
        {
            case VEC_FLAT:
                vec_fill=f_poly_tweak;
                break;
            case VEC_ENV:
            case VEC_TEXTURE:
                vec_fill=t_poly_tweak;
                break;
            default:
                vec_fill=f_poly_tweak;
                type=VEC_FLAT;
                retval=VEC_ERR;
        }
#endif  /* __WATCOMC__ && !VEC_NO_TWEAK */
#endif

    for(ftype=type&~VEC_TRANSPARENT,whichvars=0; ftype; ftype>>=1,num++)
        if(ftype & 1)
            whichvars |= type_vars[num];
    for(num=nova=0; whichvars && nova<VEC_MAXV; whichvars>>=1,num++)
        if(whichvars & 1)
            var_num[nova++]=num;

#if defined(__WATCOMC__) && !defined(VEC_NO_TWEAK)
    if(var_num[0] & 1)
        vec_cline=c_line_tweak;
    else
#endif  /* __WATCOMC__ && !VEC_NO_TWEAK */
#ifndef VEC_NO_FLOAT
    if(type & VEC_PCORRECT)
        vec_cline=cp_line_lin;
    else
#endif  /* !VEC_NO_FLOAT */
    vec_cline=c_line_lin;

    return retval;
}

int vec_set_fillres(long x,long y,int cdepth)
{
    if(cdepth<8 || min(x,y)<=0 || x>VEC_XRES || y>VEC_YRES)
        return VEC_ERR;
    vec_xres=x;
    vec_yres=y;
    vec_cdepth=cdepth;

    return VEC_OK;
}

int vec_set_bufs(uint8 *dbuf,vec_fp *zbuf)
{
    if(dbuf == NULL)
        return VEC_ERR;
    vec_dbuffer=dbuf;
    vec_zbuffer=zbuf;

    return VEC_OK;
}

void vec_set_texture(uint8 *tex,int num)
{
    switch(num)
    {
        case 1: tex1=tex;
                break;
        case 2: tex2=tex;
                break;
        case 3: tex3=tex;
                break;
    }
}

vec_fp *vec_tell_zbuffer(void)
{
    return vec_zbuffer;
}

void vec_clear_zbuffer(void)
{
    memset(vec_zbuffer,0,vec_xres*vec_yres*sizeof(vec_fp));
}

/*      Linear:     */

void c_line_lin(vec_vtx *vx1,vec_vtx *vx2)
{
    long    m,n, ymin,ymax, subpixel;
    int     zv=curfilltype&VEC_ZBUFFER ? nova-1 : nova;
    vec_ff  *vtx1,*vtx2, disp;
    vtx_u   *edgebuf;

    if(vx1->y > vx2->y)
    {
        vtx1=(vec_ff *)vx2;
        vtx2=(vec_ff *)vx1;
        edgebuf=beg;
    }
    else
    {
        vtx1=(vec_ff *)vx1;
        vtx2=(vec_ff *)vx2;
        edgebuf=end;
    }

    ymin=(long)vtx1[Yi] >> 8;
    ymax=(long)vtx2[Yi] >> 8;
    if(!(ymax-ymin))
        return;

    disp=vtx2[Yi]-vtx1[Yi];
    subpixel=(vtx1[Yi]-((long)vtx1[Yi]&~0xff))-0x100;
    dlt[0].f=(vtx2[0]-vtx1[0])*0x100/disp;
    var[0].f=vtx1[0]-subpixel*dlt[0].f/0x100;
    for(n=1; n<zv; n++)
    {
        m=var_num[n];
        dlt[n].i=(vtx2[m]-vtx1[m])*0x10000/disp;
        var[n].i=vtx1[m]*0x100-(subpixel*dlt[n].i >> 8);
    }
    if(zv != nova)
    {
        if(min(vtx1[Zin],vtx2[Zin]) <= 0)
            return;
        var[zv].f=(vec_fp)0x100/vtx1[Zin];
        dlt[zv].f=((vec_fp)0x10000/vtx2[Zin]-var[zv].f*0x100)/disp;
        var[zv].f-=subpixel*dlt[zv].f/0x100;
    }

    if(ymax > vec_yres)
    {
        if(ymin > vec_yres-1)
            return;
        ymax=vec_yres;
    }
    if(ymin < 0)
    {
        if(ymax < 1)
            return;
        var[0].f-=ymin*dlt[0].f;
        for(n=1; n<zv; n++)
            var[n].i-=ymin*dlt[n].i;
        if(zv != nova)
            var[zv].f-=ymin*dlt[zv].f;
        ymin=0;
    }

    if(zv == nova)
        for(m=ymin; m<ymax; m++)
        {
            edgebuf[m][0].i=var[0].f;
            var[0].f+=dlt[0].f;
            for(n=1; n<zv; n++)
            {
                edgebuf[m][n].i=var[n].i;
                var[n].i+=dlt[n].i;
            }
        }
    else
        for(m=ymin; m<ymax; m++)
        {
            edgebuf[m][0].i=qfist(var[0].f);
            var[0].f+=dlt[0].f;
            for(n=1; n<zv; n++)
            {
                edgebuf[m][n].i=var[n].i;
                var[n].i+=dlt[n].i;
            }
            edgebuf[m][zv].f=var[zv].f;
            var[zv].f+=dlt[zv].f;
        }
}

#ifndef VEC_NO_FLOAT
void cp_line_lin(vec_vtx *vx1,vec_vtx *vx2)
{
    long    m,n, ymin,ymax;
    int     zv=nova-1;
    vec_ff  *vtx1,*vtx2;
    vec_fp  fpdiv, subpixel;
    vtx_u   *edgebuf;

    if(vx1->y > vx2->y)
    {
        vtx1=(vec_ff *)vx2;
        vtx2=(vec_ff *)vx1;
        edgebuf=beg;
    }
    else
    {
        vtx1=(vec_ff *)vx1;
        vtx2=(vec_ff *)vx2;
        edgebuf=end;
    }

    if(min(vtx1[Zin],vtx2[Zin]) <= 0)
        return;

    ymin=(long)vtx1[Yi] >> 8;
    ymax=(long)vtx2[Yi] >> 8;
    if(!(ymax-ymin))
        return;

    fpdiv=(vec_fp)0x100/(vtx2[Yi]-vtx1[Yi]);
    subpixel=(vtx1[Yi]-((long)vtx1[Yi]&~0xff))/0x100-1;
    dlt[0].f=(vtx2[Xi]-vtx1[Xi])*fpdiv;
    var[0].f=vtx1[Xi]-subpixel*dlt[0].f;
    for(n=1; n<zv; n++)
    {
        m=var_num[n];
        var[n].f=(vec_fp)0x100*vtx1[m]/vtx1[Zin];
        dlt[n].f=((vec_fp)0x100*vtx2[m]/vtx2[Zin]-var[n].f)*fpdiv;
        var[n].f-=subpixel*dlt[n].f;
    }
    var[zv].f=(vec_fp)0x100/vtx1[Zin];
    dlt[zv].f=((vec_fp)0x100/vtx2[Zin]-var[zv].f)*fpdiv;
    var[zv].f-=subpixel*dlt[zv].f;

    if(ymax > vec_yres)
    {
        if(ymin > vec_yres-1)
            return;
        ymax=vec_yres;
    }
    if(ymin < 0)
    {
        if(ymax < 1)
            return;
        for(n=0; n<nova; n++)
            var[n].f-=ymin*dlt[n].f;
        ymin=0;
    }

    for(m=ymin; m<ymax; m++)
    {
        edgebuf[m][0].i=qfist(var[0].f);
        var[0].f+=dlt[0].f;
        for(n=1; n<nova; n++)
        {
            edgebuf[m][n].f=var[n].f;
            var[n].f+=dlt[n].f;
        }
    }
}
#endif  /* !VEC_NO_FLOAT */

#ifdef NUI
void f_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp, col=talvi;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 0)
            continue;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            disp=vec_xres-fbeg;
        }

        memset(&vec_dbuffer[fbeg+inx+1],col,disp);
    }
}

#pragma aux gouraudfill =\
    "rol    eax,16"\
    "rol    ecx,16"\
    "add    edi,vec_dbuffer"\
    "joo:"\
    "add    eax,ecx"\
    "adc    eax,0"\
    "mov    byte ptr [edi+ebx],al"\
    "dec    ebx"\
    "jnz    joo"\
    parm [eax] [ecx] [edi] [ebx]

void g_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp, subpixel;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        var[1].i=end[m][1].i+(talvi << 16);

        if(fbeg < 0)
        {
            if(fend<1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg>vec_xres-2)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            disp=vec_xres-fbeg;
        }

#if defined(__WATCOMC__)
        gouraudfill(var[1].i,dlt[1].i,inx+fbeg,disp);
#else
        for(i=disp,fbeg+=inx; i>0; i--)
        {
            vec_dbuffer[fbeg+i]=var[1].i >> 16;
            var[1].i+=dlt[1].i;
        }
#endif
    }
}

/*#pragma aux texfill =\
    "add    edi,vec_dbuffer"\
    "mov    talvi,ebp"\
    "add    esi,tex1"\
    "mov    ebp,ebx"\
    "joo:"\
    "mov    ebx,esi"\
    "mov    bl,ah"\
    "mov    bl,byte ptr [ebx]"\
    "mov    byte ptr [edi+ebp],bl"\
    "add    eax,ecx"\
    "add    esi,edx"\
    "dec    ebp"\
    "jnz    joo"\
    "mov    ebp,talvi"\
    parm [eax] [esi] [ecx] [edx] [edi] [ebx]*/

#pragma aux texfill =\
    "add    edi,vec_dbuffer"\
    "mov    talvi,ebp"\
    "shl    edx,16"\
    "add    ecx,edx"\
    "shl    esi,16"\
    "add    eax,esi"\
    "mov    esi,tex1"\
    "mov    ebp,ebx"\
    "joo:"\
    "shld   ebx,eax,16"\
    "mov    bl,ah"\
    "and    ebx,0ffffh"\
    "mov    bl,byte ptr [esi+ebx]"\
    "mov    byte ptr [edi+ebp],bl"\
    "add    eax,ecx"\
    "dec    ebp"\
    "jnz    joo"\
    "mov    ebp,talvi"\
    parm [eax] [esi] [ecx] [edx] [edi] [ebx]

void t_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp, subpixel;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            disp=vec_xres-fbeg;
        }

#if defined(__WATCOMC__)
        texfill(var[1].i,var[2].i,dlt[1].i,dlt[2].i,
            inx+fbeg,disp);
#elif defined(VEC_X86)
        vec_texfill_lin8(var[1].i,var[2].i,dlt[1].i,dlt[2].i,
            inx+fbeg,disp,vec_dbuffer,tex1);
#else
        for(i=disp,fbeg+=inx; i>0; i--)
        {
            vec_dbuffer[fbeg+i]=
                tex1[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
        }
#endif
    }
}

void gt_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp, subpixel;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i>>8))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        dlt[3].i=(-end[m][3].i+beg[m][3].i)/disp;
        var[1].i=end[m][1].i;
        var[2].i=end[m][2].i;
        var[3].i=end[m][3].i;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            var[3].i-=(vec_xres-fend)*dlt[3].i;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            vec_dbuffer[fbeg+i]=(var[3].i >> 16) +
                tex1[(var[1].i>>16 & 0xff) + (var[2].i>>8 & 0xff00)];

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].i+=dlt[3].i;
        }
    }
}

#pragma aux tex2fill =\
    "add    edi,vec_dbuffer"\
    "mov    talvi,ebp"\
    "mov    ebp,ebx"\
    "add    edi,ecx"\
    "xor    ebx,ebx"\
    "joo:"\
    "mov    bx,si"\
    "add    ebx,tex1"\
    "mov    bl,ah"\
    "mov    bl,byte ptr [ebx]"\
    "mov    byte ptr [edi],bl"\
    "mov    ebx,eax"\
    "shr    ebx,8"\
    "and    ebx,0ff0000h"\
    "shld   ebx,esi,8"\
    "rol    ebx,8"\
    "add    eax,ebp"\
    "add    ebx,tex2"\
    "mov    bl,byte ptr [ebx]"\
    "add    byte ptr [edi],bl"\
    "add    esi,edx"\
    "dec    edi"\
    "xor    ebx,ebx"\
    "dec    ecx"\
    "jnz    joo"\
    "mov    ebp,talvi"\
    parm [eax] [esi] [ebx] [edx] [edi] [ecx]

void t2_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp, subpixel;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
        dlt[1].i+=(-end[m][3].i+beg[m][3].i)/disp << 16;
        dlt[2].i+=(-end[m][4].i+beg[m][4].i)/disp << 16;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 0)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;
        var[1].i+=end[m][3].i << 8 &~0xffff;
        var[2].i+=end[m][4].i << 8 &~0xffff;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            disp=vec_xres-fbeg;
        }

#if defined(__WATCOMC__)
        tex2fill(var[1].i,var[2].i,dlt[1].i,dlt[2].i,inx+fbeg,disp);
#else
        for(i=disp,fbeg+=inx; i>0; i--)
        {
            vec_dbuffer[fbeg+i]=
                tex1[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)] +
                tex2[((uint32)var[1].i>>24)+(var[2].i>>16 & 0xff00)];

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
        }
#endif
    }
}

#pragma aux atex2fill =\
    "add    edi,vec_dbuffer"\
    "mov    talvi,ebp"\
    "mov    ebp,ebx"\
    "add    edi,ecx"\
    "xor    ebx,ebx"\
    "joo:"\
    "mov    bx,si"\
    "add    ebx,tex1"\
    "mov    bl,ah"\
    "mov    bl,byte ptr [ebx]"\
    "test   bl,255"\
    "jz     jee"\
    "mov    byte ptr [edi],bl"\
    "mov    ebx,eax"\
    "shr    ebx,8"\
    "and    ebx,0ff0000h"\
    "shld   ebx,esi,8"\
    "rol    ebx,8"\
    "add    ebx,tex2"\
    "mov    bl,byte ptr [ebx]"\
    "add    byte ptr [edi],bl"\
    "jee:"\
    "add    eax,ebp"\
    "add    esi,edx"\
    "dec    edi"\
    "xor    ebx,ebx"\
    "dec    ecx"\
    "jnz    joo"\
    "mov    ebp,talvi"\
    parm [eax] [esi] [ebx] [edx] [edi] [ecx]

void at2_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp, subpixel;
    uint8   lugu;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
        dlt[1].i+=(-end[m][3].i+beg[m][3].i)/disp << 16;
        dlt[2].i+=(-end[m][4].i+beg[m][4].i)/disp << 16;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;
        var[1].i+=end[m][3].i << 8 &~0xffff;
        var[2].i+=end[m][4].i << 8 &~0xffff;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            disp=vec_xres-fbeg;
        }

#if defined(__WATCOMC__)
        atex2fill(var[1].i,var[2].i,dlt[1].i,dlt[2].i,
            inx+fbeg,disp);
#else
        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(lugu=tex1[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)])
                vec_dbuffer[fbeg+i]=lugu +
                    tex2[((uint32)var[1].i>>24)+(var[2].i>>16 & 0xff00)];

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
        }
#endif
    }
}

#ifndef VEC_NO_BUMP
void b_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp, subpixel, dlen,d1=0,d2=0;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
        if((dlen=vec_sqrt(dlt[1].i*dlt[1].i+dlt[2].i*dlt[2].i>>8,&i)))
        {
            d1=(dlt[1].i << i+13)/dlen;
            d2=(dlt[2].i << i+13)/dlen;
        }
        dlt[1].i+=(-end[m][3].i+beg[m][3].i)/disp << 16;
        dlt[2].i+=(-end[m][4].i+beg[m][4].i)/disp << 16;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 0)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;
        var[1].i+=end[m][3].i << 8 &~0xffff;
        var[2].i+=end[m][4].i << 8 &~0xffff;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            vec_dbuffer[fbeg+i]=
              tex1[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)]+tex2[
                (0xff & ((uint32)var[1].i>>24)+
                  (tex3[(var[1].i-d1>>8 & 0xff)+(var[2].i-d2 & 0xff00)]-
                  tex3[(var[1].i+d1>>8 & 0xff)+(var[2].i+d2 & 0xff00)]))+
                (0xff00 & (var[2].i>>16)+
                  (tex3[(var[1].i-d2>>8 & 0xff)+(var[2].i+d1 & 0xff00)]-
                  tex3[(var[1].i+d2>>8 & 0xff)+(var[2].i-d1 & 0xff00)]
                  << 8 ))];

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
        }
    }
}
#endif  /* !VEC_NO_BUMP */

#ifndef VEC_NO_FLOAT

void fz_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp, col=talvi;
    vec_fp  fpdiv, subpixel;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=(-end[m][1].f+beg[m][1].f)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[1].f)
            {
                vec_zbuffer[fbeg+i]=var[1].f;
                vec_dbuffer[fbeg+i]=col;
            }

            var[1].f+=dlt[1].f;
        }
    }
}

void gz_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp;
    vec_fp  subpixel;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].f=(-end[m][2].f+beg[m][2].f)/disp;
        var[1].i=end[m][1].i+(talvi << 16);
        var[2].f=end[m][1].f+subpixel*dlt[2].f;

        if(fbeg < 0)
        {
            if(fend<1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg>vec_xres-2)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].f-=(vec_xres-fend)*dlt[2].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[2].f)
            {
                vec_zbuffer[fbeg+i]=var[2].f;
                vec_dbuffer[fbeg+i]=var[1].i >> 16;
            }

            var[1].i+=dlt[1].i;
            var[2].f+=dlt[2].f;
        }
    }
}

void tz_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp;
    vec_fp  subpixel;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i>>8))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        dlt[3].f=(-end[m][3].f+beg[m][3].f)/disp;
        var[1].i=end[m][1].i;
        var[2].i=end[m][2].i;
        var[3].f=end[m][3].f+subpixel*dlt[3].f;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[3].f)
            {
                vec_zbuffer[fbeg+i]=var[3].f;
                vec_dbuffer[fbeg+i]=
                    tex1[(var[1].i>>16 & 0xff)+(var[2].i>>8 & 0xff00)];
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].f+=dlt[3].f;
        }
    }
}

void t2z_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp;
    vec_fp  subpixel;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
        dlt[1].i+=(-end[m][3].i+beg[m][3].i)/disp << 16;
        dlt[2].i+=(-end[m][4].i+beg[m][4].i)/disp << 16;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        dlt[3].f=(-end[m][5].f+beg[m][5].f)/disp;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;
        var[1].i+=end[m][3].i << 8 &~0xffff;
        var[2].i+=end[m][4].i << 8 &~0xffff;
        var[3].f=end[m][5].f+subpixel*dlt[3].f;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[3].f)
            {
                vec_zbuffer[fbeg+i]=var[3].f;
                vec_dbuffer[fbeg+i]=
                    tex1[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)] +
                    tex2[((uint32)var[1].i>>24)+(var[2].i>>16 & 0xff00)];
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].f+=dlt[3].f;
        }
    }
}

#ifndef VEC_NO_BUMP
void bz_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp, dlen,d1=0,d2=0;
    vec_fp  subpixel;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
        if((dlen=vec_sqrt(dlt[1].i*dlt[1].i+dlt[2].i*dlt[2].i>>8,&i)))
        {
            d1=(dlt[1].i << i+13)/dlen;
            d2=(dlt[2].i << i+13)/dlen;
        }
        dlt[1].i+=(-end[m][3].i+beg[m][3].i)/disp << 16;
        dlt[2].i+=(-end[m][4].i+beg[m][4].i)/disp << 16;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        dlt[3].f=(-end[m][5].f+beg[m][5].f)/disp;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;
        var[1].i+=end[m][3].i << 8 &~0xffff;
        var[2].i+=end[m][4].i << 8 &~0xffff;
        var[3].f=end[m][5].f+subpixel*dlt[3].f;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[3].f)
            {
                vec_zbuffer[fbeg+i]=var[3].f;
                vec_dbuffer[fbeg+i]=
                  tex1[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)]+tex2[
                    (0xff & ((uint32)var[1].i>>24)+
                      (tex3[(var[1].i-d1>>8 & 0xff)+(var[2].i-d2 & 0xff00)]-
                      tex3[(var[1].i+d1>>8 & 0xff)+(var[2].i+d2 & 0xff00)]))+
                    (0xff00 & (var[2].i>>16)+
                      (tex3[(var[1].i-d2>>8 & 0xff)+(var[2].i+d1 & 0xff00)]-
                      tex3[(var[1].i+d2>>8 & 0xff)+(var[2].i-d1 & 0xff00)]
                      << 8 ))];
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].f+=dlt[3].f;
        }
    }
}
#endif  /* !VEC_NO_BUMP */

void tzp_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp;
    vec_fp  nextz,zbeg,zend, fpdiv, subpixel;
					
    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        zbeg=beg[m][3].f;
        zend=end[m][3].f;

        if((disp=fend-fbeg)<1 || min(zbeg,zend)<=0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=-(end[m][1].f-beg[m][1].f)*fpdiv;
        dlt[2].f=-(end[m][2].f-beg[m][2].f)*fpdiv;
        dlt[3].f=-(zend-zbeg)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;
        var[2].f=end[m][2].f+subpixel*dlt[2].f;
        var[3].f=zend+subpixel*dlt[3].f;
        fpdiv=1/zend;
        v2r[1].i=qfist(var[1].f*fpdiv);
        v2r[2].i=qfist(var[2].f*fpdiv);

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            var[2].f-=(vec_xres-fend)*dlt[2].f;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            fpdiv=1/var[3].f;
            v2r[1].i=qfist(var[1].f*fpdiv);
            v2r[2].i=qfist(var[2].f*fpdiv);
            disp=vec_xres-fbeg;
        }

        dlt[1].f *= 16;
        dlt[2].f *= 16;

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if((i-disp&15) == 0)
            {
                var[1].i=v2r[1].i;
                var[2].i=v2r[2].i;

                var[1].f+=dlt[1].f;
                var[2].f+=dlt[2].f;
                nextz=1/(var[3].f+dlt[3].f*16);

                v2r[1].i=qfist(var[1].f*nextz);
                v2r[2].i=qfist(var[2].f*nextz);
                dlt[1].i=v2r[1].i-var[1].i >> 4;
                dlt[2].i=v2r[2].i-var[2].i >> 4;
            }

            if(vec_zbuffer[fbeg+i] < var[3].f)
            {
                vec_zbuffer[fbeg+i]=var[3].f;
                vec_dbuffer[fbeg+i]=
                    tex1[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].f+=dlt[3].f;
        }
    }
}

void gtzp_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp;
    vec_fp  nextz,zbeg,zend, fpdiv, subpixel;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        zbeg=beg[m][4].f;
        zend=end[m][4].f;

        if((disp=fend-fbeg)<1 || min(zbeg,zend)<=0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=-(end[m][1].f-beg[m][1].f)*fpdiv;
        dlt[2].f=-(end[m][2].f-beg[m][2].f)*fpdiv;
        dlt[3].f=-(end[m][3].f-beg[m][3].f)*fpdiv;
        dlt[4].f=-(zend-zbeg)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;
        var[2].f=end[m][2].f+subpixel*dlt[2].f;
        var[3].f=end[m][3].f+subpixel*dlt[3].f;
        var[4].f=zend+subpixel*dlt[4].f;
        fpdiv=1/zend;
        v2r[1].i=qfist(var[1].f*fpdiv);
        v2r[2].i=qfist(var[2].f*fpdiv);
        v2r[3].i=qfist(var[3].f*fpdiv);

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            var[2].f-=(vec_xres-fend)*dlt[2].f;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            var[4].f-=(vec_xres-fend)*dlt[4].f;
            fpdiv=1/var[4].f;
            v2r[1].i=qfist(var[1].f*fpdiv);
            v2r[2].i=qfist(var[2].f*fpdiv);
            v2r[3].i=qfist(var[3].f*fpdiv);
            disp=vec_xres-fbeg;
        }

        dlt[1].f *= 16;
        dlt[2].f *= 16;
        dlt[3].f *= 16;

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if((i-disp&15) == 0)
            {
                var[1].i=v2r[1].i;
                var[2].i=v2r[2].i;
                var[3].i=v2r[3].i;

                var[1].f+=dlt[1].f;
                var[2].f+=dlt[2].f;
                var[3].f+=dlt[3].f;
                nextz=1/(var[4].f+dlt[4].f*16);

                v2r[1].i=qfist(var[1].f*nextz);
                v2r[2].i=qfist(var[2].f*nextz);
                v2r[3].i=qfist(var[3].f*nextz);
                dlt[1].i=v2r[1].i-var[1].i >> 4;
                dlt[2].i=v2r[2].i-var[2].i >> 4;
                dlt[3].i=v2r[3].i-var[3].i >> 4;
            }

            if(vec_zbuffer[fbeg+i] < var[4].f)
            {
                vec_zbuffer[fbeg+i]=var[4].f;
                vec_dbuffer[fbeg+i]=(var[3].i>>8) +
                    tex1[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].i+=dlt[3].i;
            var[4].f+=dlt[4].f;
        }
    }
}

void t2zp_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp;
    vec_fp  nextz,zbeg,zend, fpdiv, subpixel;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        zbeg=beg[m][5].f;
        zend=end[m][5].f;

        if((disp=fend-fbeg)<1 || min(zbeg,zend)<=0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=-(end[m][1].f-beg[m][1].f)*fpdiv;
        dlt[2].f=-(end[m][2].f-beg[m][2].f)*fpdiv;
        dlt[3].f=-(end[m][3].f-beg[m][3].f)*fpdiv;
        dlt[4].f=-(end[m][4].f-beg[m][4].f)*fpdiv;
        dlt[5].f=-(zend-zbeg)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;
        var[2].f=end[m][2].f+subpixel*dlt[2].f;
        var[3].f=end[m][3].f+subpixel*dlt[3].f;
        var[4].f=end[m][4].f+subpixel*dlt[4].f;
        var[5].f=zend+subpixel*dlt[5].f;
        fpdiv=1/zend;
        v2r[1].i=qfist(var[1].f*fpdiv);
        v2r[2].i=qfist(var[2].f*fpdiv);
        v2r[3].i=qfist(var[3].f*fpdiv);
        v2r[4].i=qfist(var[4].f*fpdiv);

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            var[2].f-=(vec_xres-fend)*dlt[2].f;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            var[4].f-=(vec_xres-fend)*dlt[4].f;
            var[5].f-=(vec_xres-fend)*dlt[5].f;
            fpdiv=1/var[5].f;
            v2r[1].i=qfist(var[1].f*fpdiv);
            v2r[2].i=qfist(var[2].f*fpdiv);
            v2r[3].i=qfist(var[3].f*fpdiv);
            v2r[4].i=qfist(var[4].f*fpdiv);
            disp=vec_xres-fbeg;
        }

        dlt[1].f *= 16;
        dlt[2].f *= 16;
        dlt[3].f *= 16;

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if((i-disp&15) == 0)
            {
                var[1].i=v2r[1].i;
                var[2].i=v2r[2].i;
                var[3].i=v2r[3].i;
                var[4].i=v2r[4].i;

                var[1].f+=dlt[1].f;
                var[2].f+=dlt[2].f;
                var[3].f+=dlt[3].f;
                var[4].f+=dlt[4].f;
                nextz=1/(var[5].f+dlt[5].f*16);

                v2r[1].i=qfist(var[1].f*nextz);
                v2r[2].i=qfist(var[2].f*nextz);
                v2r[3].i=qfist(var[3].f*nextz);
                v2r[4].i=qfist(var[4].f*nextz);
                dlt[1].i=v2r[1].i-var[1].i >> 4;
                dlt[2].i=v2r[2].i-var[2].i >> 4;
                dlt[3].i=v2r[3].i-var[3].i >> 4;
                dlt[4].i=v2r[4].i-var[4].i >> 4;
            }

            if(vec_zbuffer[fbeg+i] < var[5].f)
            {
                vec_zbuffer[fbeg+i]=var[5].f;
                vec_dbuffer[fbeg+i]=
                    tex1[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)] +
                    tex2[(var[3].i>>8 & 0xff)+(var[4].i & 0xff00)];
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].i+=dlt[3].i;
            var[4].i+=dlt[4].i;
            var[5].f+=dlt[5].f;
        }
    }
}

#ifndef VEC_NO_BUMP
void bzp_poly_lin8(void)
{
    long    i,m, inx,fbeg,fend,disp, dlen,d1=0,d2=0;
    vec_fp  nextz,zbeg,zend, fpdiv, subpixel;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
        if((dlen=vec_sqrt(dlt[1].i*dlt[1].i+dlt[2].i*dlt[2].i>>8,&i)))
        {
            d1=(dlt[1].i << i+13)/dlen;
            d2=(dlt[2].i << i+13)/dlen;
        }
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        zbeg=beg[m][5].f;
        zend=end[m][5].f;

        if((disp=fend-fbeg)<1 || min(zbeg,zend)<=0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=-(end[m][1].f-beg[m][1].f)*fpdiv;
        dlt[2].f=-(end[m][2].f-beg[m][2].f)*fpdiv;
        dlt[3].f=-(end[m][3].f-beg[m][3].f)*fpdiv;
        dlt[4].f=-(end[m][4].f-beg[m][4].f)*fpdiv;
        dlt[5].f=-(zend-zbeg)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;
        var[2].f=end[m][2].f+subpixel*dlt[2].f;
        var[3].f=end[m][3].f+subpixel*dlt[3].f;
        var[4].f=end[m][4].f+subpixel*dlt[4].f;
        var[5].f=zend+subpixel*dlt[5].f;
        fpdiv=1/zend;
        v2r[1].i=qfist(var[1].f*fpdiv);
        v2r[2].i=qfist(var[2].f*fpdiv);
        v2r[3].i=qfist(var[3].f*fpdiv);
        v2r[4].i=qfist(var[4].f*fpdiv);
        
        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            var[2].f-=(vec_xres-fend)*dlt[2].f;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            var[4].f-=(vec_xres-fend)*dlt[4].f;
            var[5].f-=(vec_xres-fend)*dlt[5].f;
            fpdiv=1/var[5].f;
            v2r[1].i=qfist(var[1].f*fpdiv);
            v2r[2].i=qfist(var[2].f*fpdiv);
            v2r[3].i=qfist(var[3].f*fpdiv);
            v2r[4].i=qfist(var[4].f*fpdiv);
            disp=vec_xres-fbeg;
        }

        dlt[1].f *= 16;
        dlt[2].f *= 16;
        dlt[3].f *= 16;

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if((i-disp&15) == 0)
            {
                var[1].i=v2r[1].i;
                var[2].i=v2r[2].i;
                var[3].i=v2r[3].i;
                var[4].i=v2r[4].i;

                var[1].f+=dlt[1].f;
                var[2].f+=dlt[2].f;
                var[3].f+=dlt[3].f;
                var[4].f+=dlt[4].f;
                nextz=1/(var[5].f+dlt[5].f*16);

                v2r[1].i=qfist(var[1].f*nextz);
                v2r[2].i=qfist(var[2].f*nextz);
                v2r[3].i=qfist(var[3].f*nextz);
                v2r[4].i=qfist(var[4].f*nextz);
                dlt[1].i=v2r[1].i-var[1].i >> 4;
                dlt[2].i=v2r[2].i-var[2].i >> 4;
                dlt[3].i=v2r[3].i-var[3].i >> 4;
                dlt[4].i=v2r[4].i-var[4].i >> 4;
            }

            if(vec_zbuffer[fbeg+i] < var[5].f)
            {
                vec_zbuffer[fbeg+i]=var[5].f;
                vec_dbuffer[fbeg+i]=
                  tex1[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)]+tex2[
                    (0xff & (var[3].i>>8)+
                      (tex3[(var[1].i-d1>>8 & 0xff)+(var[2].i-d2 & 0xff00)]-
                      tex3[(var[1].i+d1>>8 & 0xff)+(var[2].i+d2 & 0xff00)]))+
                    (0xff00 & var[4].i+
                      (tex3[(var[1].i-d2>>8 & 0xff)+(var[2].i+d1 & 0xff00)]-
                      tex3[(var[1].i+d2>>8 & 0xff)+(var[2].i-d1 & 0xff00)]
                      << 8 ))];
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].i+=dlt[3].i;
            var[4].i+=dlt[4].i;
            var[5].f+=dlt[5].f;
        }
    }
}
#endif  /* !VEC_NO_BUMP */

#endif  /* !VEC_NO_FLOAT */

#endif

void f_poly_lin32(void)
{
    long    i,m, inx,fbeg,fend,disp, col=talvi;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 0)
            continue;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            disp=vec_xres-fbeg;
        }

        for(i=disp; i>0; i--)
            B32(vec_dbuffer)[fbeg+inx+i]=col;
    }
}

#ifdef NUI

void g_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp, subpixel;
    uint32  pix;
    uint8   *pixp=(uint8 *)&pix;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        var[1].i=end[m][1].i >> 8;
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp >> 8;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            for(n=0,pix=talvi; n<3; n++)
                pixp[n]=bytemul[pixp[n]+(var[1].i & 0xff00)];
            B32(vec_dbuffer)[fbeg+i]=pix;

            var[1].i+=dlt[1].i;
        }
    }
}

#pragma aux texfill32 =\
    "shl    edi,2"\
    "add    edi,vec_dbuffer"\
    "mov    talvi,ebp"\
    "shl    edx,16"\
    "add    ecx,edx"\
    "shl    esi,16"\
    "add    eax,esi"\
    "mov    esi,tex1"\
    "shl    ebx,2"\
    "mov    ebp,ebx"\
    "joo:"\
    "shld   ebx,eax,16"\
    "mov    bl,ah"\
    "and    ebx,0ffffh"\
    "mov    ebx,dword ptr [esi+ebx*4]"\
    "mov    dword ptr [edi+ebp],ebx"\
    "add    eax,ecx"\
    "sub    ebp,4"\
    "jnz    joo"\
    "mov    ebp,talvi"\
    parm [eax] [esi] [ecx] [edx] [edi] [ebx]

void t_poly_lin32(void)
{
    long    i,m, inx,fbeg,fend,disp, subpixel;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            disp=vec_xres-fbeg;
        }

#if defined(__WATCOMC__)
        texfill32(var[1].i,var[2].i,dlt[1].i,dlt[2].i,
            inx+fbeg,disp);
#elif defined(VEC_X86)
        vec_texfill_lin32(var[1].i,var[2].i,dlt[1].i,dlt[2].i,
            inx+fbeg,disp,vec_dbuffer,tex1);
#else
        for(i=disp,fbeg+=inx; i>0; i--)
        {
            B32(vec_dbuffer)[fbeg+i]=
                B32(tex1)[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
        }
#endif
    }
}

void gt_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp, subpixel;
    uint32  pix;
    uint8   *pixp=(uint8 *)&pix;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        dlt[3].i=(-end[m][3].i+beg[m][3].i)/disp >> 8;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;
        var[3].i=end[m][3].i >> 8;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            var[3].i-=(vec_xres-fend)*dlt[3].i;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            pix=B32(tex1)[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];
            for(n=0; n<3; n++)
                pixp[n]=bytemul[pixp[n]+(var[3].i & 0xff00)];
            B32(vec_dbuffer)[fbeg+i]=pix;

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].i+=dlt[3].i;
        }
    }
}

void at_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp, subpixel;
    uint32  pix;
    uint8   *pix1p=(uint8 *)&pix,*pix2p;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            pix=B32(tex1)[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];
            pix2p=(uint8 *)&B32(vec_dbuffer)[fbeg+i];
            for(n=0; n<3; n++)
                pix2p[n]=bytemul[pix1p[n]+(pix2p[n]<<8)];

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
        }
    }
}

void t2_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp, subpixel;
    uint32  pix1,pix2;
    uint8   *pix1p=(uint8 *)&pix1,*pix2p=(uint8 *)&pix2;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
        dlt[1].i+=(-end[m][3].i+beg[m][3].i)/disp << 16;
        dlt[2].i+=(-end[m][4].i+beg[m][4].i)/disp << 16;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 0)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;
        var[1].i+=end[m][3].i << 8 &~0xffff;
        var[2].i+=end[m][4].i << 8 &~0xffff;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            pix1=B32(tex1)[(var[1].i>>8 & 0xff) +
                (var[2].i & 0xff00)];
            pix2=B32(tex2)[((uint32)var[1].i>>24) +
                (var[2].i>>16 & 0xff00)];
            for(n=0; n<3; n++)
                pix1p[n]=bytemul[pix1p[n]+(pix2p[n]<<8)];
            B32(vec_dbuffer)[fbeg+i]=pix1;

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
        }
    }
}

#ifndef VEC_NO_BUMP
void b_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp, subpixel, dlen,d1=0,d2=0;
    uint32  pix1,pix2;
    uint8   *pix1p=(uint8 *)&pix1,*pix2p=(uint8 *)&pix2;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
        if((dlen=vec_sqrt(dlt[1].i*dlt[1].i+dlt[2].i*dlt[2].i>>8,&i)))
        {
            d1=(dlt[1].i << i+13)/dlen;
            d2=(dlt[2].i << i+13)/dlen;
        }
        dlt[1].i+=(-end[m][3].i+beg[m][3].i)/disp << 16;
        dlt[2].i+=(-end[m][4].i+beg[m][4].i)/disp << 16;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 0)
            continue;

        // subpixel=(end[m][0].i & 0xffff) >> 8;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;
        var[1].i+=end[m][3].i << 8 &~0xffff;
        var[2].i+=end[m][4].i << 8 &~0xffff;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            pix1=B32(tex2)[
              (0xff & ((uint32)var[1].i>>24)+
                (tex3[(var[1].i-d1>>8 & 0xff)+(var[2].i-d2 & 0xff00)]-
                tex3[(var[1].i+d1>>8 & 0xff)+(var[2].i+d2 & 0xff00)]))+
              (0xff00 & (var[2].i>>16)+
                (tex3[(var[1].i-d2>>8 & 0xff)+(var[2].i+d1 & 0xff00)]-
                tex3[(var[1].i+d2>>8 & 0xff)+(var[2].i-d1 & 0xff00)]
                << 8))];
            pix2=B32(tex1)[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];
            for(n=0; n<3; n++)
                pix1p[n]=bytemul[pix1p[n]+(pix2p[n]<<8)];
            B32(vec_dbuffer)[fbeg+i]=pix1;

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
        }
    }
}
#endif  /* !VEC_NO_BUMP */

#ifndef VEC_NO_FLOAT

void fz_poly_lin32(void)
{
    long    i,m, inx,fbeg,fend,disp, col=talvi;
    vec_fp  fpdiv, subpixel;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=(-end[m][1].f+beg[m][1].f)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;
        
        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[1].f)
            {
                vec_zbuffer[fbeg+i]=var[1].f;
                B32(vec_dbuffer)[fbeg+i]=col;
            }

            var[1].f+=dlt[1].f;
        }
    }
}

void afz_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp;
    uint32  pix1=talvi;
    uint8   *pix1p=(uint8 *)&pix1,*pix2p;
    vec_fp  fpdiv, subpixel;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=(-end[m][1].f+beg[m][1].f)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[1].f)
            {
                vec_zbuffer[fbeg+i]=var[1].f;
                pix2p=(uint8 *)&B32(vec_dbuffer)[fbeg+i];
                for(n=0; n<3; n++)
                    pix2p[n]=bytemul[pix1p[n]+(pix2p[n]<<8)];
            }

            var[1].f+=dlt[1].f;
        }
    }
}

void gz_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp;
    uint32  pix;
    uint8   *pixp=(uint8 *)&pix;
    vec_fp  subpixel;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp >> 8;
        dlt[2].f=(-end[m][2].f+beg[m][2].f)/disp;
        var[1].i=end[m][1].i >> 8;
        var[2].f=end[m][2].f+subpixel*dlt[2].f;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].f-=(vec_xres-fend)*dlt[2].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[2].f)
            {
                vec_zbuffer[fbeg+i]=var[2].f;
                for(n=0,pix=talvi; n<3; n++)
                    pixp[n]=bytemul[pixp[n]+(var[1].i & 0xff00)];
                B32(vec_dbuffer)[fbeg+i]=pix;
            }

            var[1].i+=dlt[1].i;
            var[2].f+=dlt[2].f;
        }
    }
}

void tz_poly_lin32(void)
{
    long    i,m, inx,fbeg,fend,disp;
    vec_fp  subpixel;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i>>8))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        dlt[3].f=(-end[m][3].f+beg[m][3].f)/disp;
        var[1].i=end[m][1].i+subpixel*dlt[1].i;
        var[2].i=end[m][2].i+subpixel*dlt[2].i;
        var[3].f=end[m][3].f+subpixel*dlt[3].f;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[3].f)
            {
                vec_zbuffer[fbeg+i]=var[3].f;
                B32(vec_dbuffer)[fbeg+i]=B32(tex1)[(var[1].i>>16 & 0xff)+
                    (var[2].i>>8 & 0xff00)];
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].f+=dlt[3].f;
        }
    }
}

void t2z_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp;
    uint32  pix1,pix2;
    uint8   *pix1p=(uint8 *)&pix1,*pix2p=(uint8 *)&pix2;
    vec_fp  subpixel;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
        dlt[1].i+=(-end[m][3].i+beg[m][3].i)/disp << 16;
        dlt[2].i+=(-end[m][4].i+beg[m][4].i)/disp << 16;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        dlt[3].f=(-end[m][5].f+beg[m][5].f)/disp;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;
        var[1].i+=end[m][3].i << 8 &~0xffff;
        var[2].i+=end[m][4].i << 8 &~0xffff;
        var[3].f=end[m][5].f+subpixel*dlt[3].f;
        
        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[3].f)
            {
                vec_zbuffer[fbeg+i]=var[3].f;
                pix1=B32(tex1)[(var[1].i>>8 & 0xff)+
                    (var[2].i & 0xff00)];
                pix2=B32(tex2)[((uint32)var[1].i>>24)+
                    (var[2].i>>16 & 0xff00)];
                for(n=0; n<3; n++)
                    pix1p[n]=bytemul[pix1p[n]+(pix2p[n]<<8)];
                B32(vec_dbuffer)[fbeg+i]=pix1;
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].f+=dlt[3].f;
        }
    }
}

#ifndef VEC_NO_BUMP
void bz_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp, dlen,d1=0,d2=0;
    uint32  pix1,pix2;
    uint8   *pix1p=(uint8 *)&pix1,*pix2p=(uint8 *)&pix2;
    vec_fp  subpixel;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
        if((dlen=vec_sqrt(dlt[1].i*dlt[1].i+dlt[2].i*dlt[2].i>>8,&i)))
        {
            d1=(dlt[1].i << i+13)/dlen;
            d2=(dlt[2].i << i+13)/dlen;
        }
        dlt[1].i+=(-end[m][3].i+beg[m][3].i)/disp << 16;
        dlt[2].i+=(-end[m][4].i+beg[m][4].i)/disp << 16;
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        dlt[3].f=(-end[m][5].f+beg[m][5].f)/disp;
        var[1].i=end[m][1].i >> 8;
        var[2].i=end[m][2].i >> 8;
        var[1].i+=end[m][3].i << 8 &~0xffff;
        var[2].i+=end[m][4].i << 8 &~0xffff;
        var[3].f=end[m][5].f+subpixel*dlt[3].f;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].i-=(vec_xres-fend)*dlt[1].i;
            var[2].i-=(vec_xres-fend)*dlt[2].i;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[3].f)
            {
                vec_zbuffer[fbeg+i]=var[3].f;
                pix1=B32(tex2)[
                  (0xff & ((uint32)var[1].i>>24)+
                    (tex3[(var[1].i-d1>>8 & 0xff)+(var[2].i-d2 & 0xff00)]-
                    tex3[(var[1].i+d1>>8 & 0xff)+(var[2].i+d2 & 0xff00)]))+
                  (0xff00 & (var[2].i>>16)+
                    (tex3[(var[1].i-d2>>8 & 0xff)+(var[2].i+d1 & 0xff00)]-
                    tex3[(var[1].i+d2>>8 & 0xff)+(var[2].i-d1 & 0xff00)]
                    << 8))];
                pix2=B32(tex1)[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];
                for(n=0; n<3; n++)
                    pix1p[n]=bytemul[pix1p[n]+(pix2p[n]<<8)];
                B32(vec_dbuffer)[fbeg+i]=pix1;
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].f+=dlt[3].f;
        }
    }
}
#endif  /* !VEC_NO_BUMP */

void iz_poly_lin32(void)
{
    long    i,m, inx,fbeg,fend,disp;
    vec_fp  fpdiv, subpixel;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=(-end[m][1].f+beg[m][1].f)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            disp=vec_xres-fbeg;
        }

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if(vec_zbuffer[fbeg+i] < var[1].f)
            {
                vec_zbuffer[fbeg+i]=var[1].f;
                B32(vec_dbuffer)[fbeg+i]=B32(tex1)[fbeg+i];
            }

            var[1].f+=dlt[1].f;
        }
    }
}

void tzp_poly_lin32(void)
{
    long    i,m, inx,fbeg,fend,disp;
    vec_fp  nextz, fpdiv, subpixel;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        if((disp=fend-fbeg) < 1)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=-(end[m][1].f-beg[m][1].f)*fpdiv;
        dlt[2].f=-(end[m][2].f-beg[m][2].f)*fpdiv;
        dlt[3].f=-(end[m][3].f-beg[m][3].f)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;
        var[2].f=end[m][2].f+subpixel*dlt[2].f;
        var[3].f=end[m][3].f+subpixel*dlt[3].f;
        fpdiv=1/var[3].f;
        v2r[1].i=qfist(var[1].f*fpdiv);
        v2r[2].i=qfist(var[2].f*fpdiv);

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            var[2].f-=(vec_xres-fend)*dlt[2].f;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            fpdiv=1/var[3].f;
            v2r[1].i=qfist(var[1].f*fpdiv);
            v2r[2].i=qfist(var[2].f*fpdiv);
            disp=vec_xres-fbeg;
        }

        dlt[1].f *= 16;
        dlt[2].f *= 16;

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if((i-disp&15) == 0)
            {
                var[1].i=v2r[1].i;
                var[2].i=v2r[2].i;

                var[1].f+=dlt[1].f;
                var[2].f+=dlt[2].f;
                nextz=1/(var[3].f+dlt[3].f*16);

                v2r[1].i=qfist(var[1].f*nextz);
                v2r[2].i=qfist(var[2].f*nextz);
                dlt[1].i=v2r[1].i-var[1].i >> 4;
                dlt[2].i=v2r[2].i-var[2].i >> 4;
            }

            if(vec_zbuffer[fbeg+i] < var[3].f)
            {
                vec_zbuffer[fbeg+i]=var[3].f;
                B32(vec_dbuffer)[fbeg+i]=
                    B32(tex1)[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].f+=dlt[3].f;
        }
    }
}

void gtzp_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp;
    vec_fp  nextz,zbeg,zend, fpdiv, subpixel;
    uint32  pix;
    uint8   *pixp=(uint8 *)&pix;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        zbeg=beg[m][4].f;
        zend=end[m][4].f;

        if((disp=fend-fbeg)<1 || min(zbeg,zend)<=0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=-(end[m][1].f-beg[m][1].f)*fpdiv;
        dlt[2].f=-(end[m][2].f-beg[m][2].f)*fpdiv;
        dlt[3].f=-(end[m][3].f-beg[m][3].f)*fpdiv;
        dlt[4].f=-(zend-zbeg)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;
        var[2].f=end[m][2].f+subpixel*dlt[2].f;
        var[3].f=end[m][3].f+subpixel*dlt[3].f;
        var[4].f=zend+subpixel*dlt[4].f;
        fpdiv=1/zend;
        v2r[1].i=qfist(var[1].f*fpdiv);
        v2r[2].i=qfist(var[2].f*fpdiv);
        v2r[3].i=qfist(var[3].f*fpdiv);

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            var[2].f-=(vec_xres-fend)*dlt[2].f;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            var[4].f-=(vec_xres-fend)*dlt[4].f;
            fpdiv=1/var[4].f;
            v2r[1].i=qfist(var[1].f*fpdiv);
            v2r[2].i=qfist(var[2].f*fpdiv);
            v2r[3].i=qfist(var[3].f*fpdiv);
            disp=vec_xres-fbeg;
        }

        dlt[1].f *= 16;
        dlt[2].f *= 16;
        dlt[3].f *= 16;

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if((i-disp&15) == 0)
            {
                var[1].i=v2r[1].i;
                var[2].i=v2r[2].i;
                var[3].i=v2r[3].i;

                var[1].f+=dlt[1].f;
                var[2].f+=dlt[2].f;
                var[3].f+=dlt[3].f;
                nextz=1/(var[4].f+dlt[4].f*16);

                v2r[1].i=qfist(var[1].f*nextz);
                v2r[2].i=qfist(var[2].f*nextz);
                v2r[3].i=qfist(var[3].f*nextz);
                dlt[1].i=v2r[1].i-var[1].i >> 4;
                dlt[2].i=v2r[2].i-var[2].i >> 4;
                dlt[3].i=v2r[3].i-var[3].i >> 4;
            }

            if(vec_zbuffer[fbeg+i] < var[4].f)
            {
                vec_zbuffer[fbeg+i]=var[4].f;
                pix=B32(tex1)[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];
                for(n=0; n<3; n++)
                    pixp[n]=bytemul[pixp[n]+(var[3].i & 0xff00)];
                B32(vec_dbuffer)[fbeg+i]=pix;
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].i+=dlt[3].i;
            var[4].f+=dlt[4].f;
        }
    }
}

void atzp_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp;
    vec_fp  nextz,zbeg,zend, fpdiv, subpixel;
    uint32  pix;
    uint8   *pix1p=(uint8 *)&pix,*pix2p;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        zbeg=beg[m][3].f;
        zend=end[m][3].f;

        if((disp=fend-fbeg)<1 || min(zbeg,zend)<=0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=-(end[m][1].f-beg[m][1].f)*fpdiv;
        dlt[2].f=-(end[m][2].f-beg[m][2].f)*fpdiv;
        dlt[3].f=-(zend-zbeg)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;
        var[2].f=end[m][2].f+subpixel*dlt[2].f;
        var[3].f=zend+subpixel*dlt[3].f;
        fpdiv=1/zend;
        v2r[1].i=qfist(var[1].f*fpdiv);
        v2r[2].i=qfist(var[2].f*fpdiv);

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            var[2].f-=(vec_xres-fend)*dlt[2].f;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            fpdiv=1/var[3].f;
            v2r[1].i=qfist(var[1].f*fpdiv);
            v2r[2].i=qfist(var[2].f*fpdiv);
            disp=vec_xres-fbeg;
        }

        dlt[1].f *= 16;
        dlt[2].f *= 16;

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if((i-disp&15) == 0)
            {
                var[1].i=v2r[1].i;
                var[2].i=v2r[2].i;

                var[1].f+=dlt[1].f;
                var[2].f+=dlt[2].f;
                nextz=1/(var[3].f+dlt[3].f*16);

                v2r[1].i=qfist(var[1].f*nextz);
                v2r[2].i=qfist(var[2].f*nextz);
                dlt[1].i=v2r[1].i-var[1].i >> 4;
                dlt[2].i=v2r[2].i-var[2].i >> 4;
            }

            if(vec_zbuffer[fbeg+i] < var[3].f)
            {
                vec_zbuffer[fbeg+i]=var[3].f;
                pix=B32(tex1)[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];
                pix2p=(uint8 *)&B32(vec_dbuffer)[fbeg+i];
                for(n=0; n<3; n++)
                    pix2p[n]=bytemul[pix1p[n]+(pix2p[n]<<8)];
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].f+=dlt[3].f;
        }
    }
}

void t2zp_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp;
    vec_fp  nextz,zbeg,zend, fpdiv, subpixel;
    uint32  pix1,pix2;
    uint8   *pix1p=(uint8 *)&pix1,*pix2p=(uint8 *)&pix2;

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        zbeg=beg[m][5].f;
        zend=end[m][5].f;

        if((disp=fend-fbeg)<1 || min(zbeg,zend)<=0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=-(end[m][1].f-beg[m][1].f)*fpdiv;
        dlt[2].f=-(end[m][2].f-beg[m][2].f)*fpdiv;
        dlt[3].f=-(end[m][3].f-beg[m][3].f)*fpdiv;
        dlt[4].f=-(end[m][4].f-beg[m][4].f)*fpdiv;
        dlt[5].f=-(zend-zbeg)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;
        var[2].f=end[m][2].f+subpixel*dlt[2].f;
        var[3].f=end[m][3].f+subpixel*dlt[3].f;
        var[4].f=end[m][4].f+subpixel*dlt[4].f;
        var[5].f=zend+subpixel*dlt[5].f;
        fpdiv=1/zend;
        v2r[1].i=qfist(var[1].f*fpdiv);
        v2r[2].i=qfist(var[2].f*fpdiv);
        v2r[3].i=qfist(var[3].f*fpdiv);
        v2r[4].i=qfist(var[4].f*fpdiv);

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            var[2].f-=(vec_xres-fend)*dlt[2].f;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            var[4].f-=(vec_xres-fend)*dlt[4].f;
            var[5].f-=(vec_xres-fend)*dlt[5].f;
            fpdiv=1/var[5].f;
            v2r[1].i=qfist(var[1].f*fpdiv);
            v2r[2].i=qfist(var[2].f*fpdiv);
            v2r[3].i=qfist(var[3].f*fpdiv);
            v2r[4].i=qfist(var[4].f*fpdiv);
            disp=vec_xres-fbeg;
        }

        dlt[1].f *= 16;
        dlt[2].f *= 16;
        dlt[3].f *= 16;

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if((i-disp&15) == 0)
            {
                var[1].i=v2r[1].i;
                var[2].i=v2r[2].i;
                var[3].i=v2r[3].i;
                var[4].i=v2r[4].i;

                var[1].f+=dlt[1].f;
                var[2].f+=dlt[2].f;
                var[3].f+=dlt[3].f;
                var[4].f+=dlt[4].f;
                nextz=1/(var[5].f+dlt[5].f*16);

                v2r[1].i=qfist(var[1].f*nextz);
                v2r[2].i=qfist(var[2].f*nextz);
                v2r[3].i=qfist(var[3].f*nextz);
                v2r[4].i=qfist(var[4].f*nextz);
                dlt[1].i=v2r[1].i-var[1].i >> 4;
                dlt[2].i=v2r[2].i-var[2].i >> 4;
                dlt[3].i=v2r[3].i-var[3].i >> 4;
                dlt[4].i=v2r[4].i-var[4].i >> 4;
            }

            if(vec_zbuffer[fbeg+i] < var[5].f)
            {
                vec_zbuffer[fbeg+i]=var[5].f;
                pix1=B32(tex1)[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];
                pix2=B32(tex2)[(var[3].i>>8 & 0xff)+(var[4].i & 0xff00)];
                for(n=0; n<3; n++)
                    pix1p[n]=bytemul[pix1p[n]+(pix2p[n]<<8)];
                B32(vec_dbuffer)[fbeg+i]=pix1;
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].i+=dlt[3].i;
            var[4].i+=dlt[4].i;
            var[5].f+=dlt[5].f;
        }
    }
}

#ifndef VEC_NO_BUMP
void bzp_poly_lin32(void)
{
    long    i,m,n, inx,fbeg,fend,disp, dlen,d1=0,d2=0;
    vec_fp  nextz,zbeg,zend, fpdiv, subpixel;
    uint32  pix1,pix2;
    uint8   *pix1p=(uint8 *)&pix1,*pix2p=(uint8 *)&pix2;

    m=midpoint;
    if((disp=end[m][0].i-beg[m][0].i))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
        if((dlen=vec_sqrt(dlt[1].i*dlt[1].i+dlt[2].i*dlt[2].i>>8,&i)))
        {
            d1=(dlt[1].i << i+13)/dlen;
            d2=(dlt[2].i << i+13)/dlen;
        }
    }

    for(m=maxy-1,inx=m*vec_xres-1; m>=miny; m--,inx-=vec_xres)
    {
        fbeg=beg[m][0].i >> 8;
        fend=end[m][0].i >> 8;
        zbeg=beg[m][5].f;
        zend=end[m][5].f;

        if((disp=fend-fbeg)<1 || min(zbeg,zend)<=0)
            continue;

        subpixel=(vec_fp)(end[m][0].i & 0xff)/0x100;
        fpdiv=0x100/(vec_fp)(end[m][0].i-beg[m][0].i);
        dlt[1].f=-(end[m][1].f-beg[m][1].f)*fpdiv;
        dlt[2].f=-(end[m][2].f-beg[m][2].f)*fpdiv;
        dlt[3].f=-(end[m][3].f-beg[m][3].f)*fpdiv;
        dlt[4].f=-(end[m][4].f-beg[m][4].f)*fpdiv;
        dlt[5].f=-(zend-zbeg)*fpdiv;
        var[1].f=end[m][1].f+subpixel*dlt[1].f;
        var[2].f=end[m][2].f+subpixel*dlt[2].f;
        var[3].f=end[m][3].f+subpixel*dlt[3].f;
        var[4].f=end[m][4].f+subpixel*dlt[4].f;
        var[5].f=zend+subpixel*dlt[5].f;
        fpdiv=1/zend;
        v2r[1].i=qfist(var[1].f*fpdiv);
        v2r[2].i=qfist(var[2].f*fpdiv);
        v2r[3].i=qfist(var[3].f*fpdiv);
        v2r[4].i=qfist(var[4].f*fpdiv);

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            var[1].f-=(vec_xres-fend)*dlt[1].f;
            var[2].f-=(vec_xres-fend)*dlt[2].f;
            var[3].f-=(vec_xres-fend)*dlt[3].f;
            var[4].f-=(vec_xres-fend)*dlt[4].f;
            var[5].f-=(vec_xres-fend)*dlt[5].f;
            fpdiv=1/var[5].f;
            v2r[1].i=qfist(var[1].f*fpdiv);
            v2r[2].i=qfist(var[2].f*fpdiv);
            v2r[3].i=qfist(var[3].f*fpdiv);
            v2r[4].i=qfist(var[4].f*fpdiv);
            disp=vec_xres-fbeg;
        }

        dlt[1].f *= 16;
        dlt[2].f *= 16;
        dlt[3].f *= 16;

        for(i=disp,fbeg+=inx; i>0; i--)
        {
            if((i-disp&15) == 0)
            {
                var[1].i=v2r[1].i;
                var[2].i=v2r[2].i;
                var[3].i=v2r[3].i;
                var[4].i=v2r[4].i;

                var[1].f+=dlt[1].f;
                var[2].f+=dlt[2].f;
                var[3].f+=dlt[3].f;
                var[4].f+=dlt[4].f;
                nextz=1/(var[5].f+dlt[5].f*16);

                v2r[1].i=qfist(var[1].f*nextz);
                v2r[2].i=qfist(var[2].f*nextz);
                v2r[3].i=qfist(var[3].f*nextz);
                v2r[4].i=qfist(var[4].f*nextz);
                dlt[1].i=v2r[1].i-var[1].i >> 4;
                dlt[2].i=v2r[2].i-var[2].i >> 4;
                dlt[3].i=v2r[3].i-var[3].i >> 4;
                dlt[4].i=v2r[4].i-var[4].i >> 4;
            }

            if(vec_zbuffer[fbeg+i] < var[5].f)
            {
                vec_zbuffer[fbeg+i]=var[5].f;
                pix1=B32(tex2)[
                  (0xff & (var[3].i>>8)+
                    (tex3[(var[1].i-d1>>8 & 0xff)+(var[2].i-d2 & 0xff00)]-
                    tex3[(var[1].i+d1>>8 & 0xff)+(var[2].i+d2 & 0xff00)]))+
                  (0xff00 & var[4].i+
                    (tex3[(var[1].i-d2>>8 & 0xff)+(var[2].i+d1 & 0xff00)]-
                    tex3[(var[1].i+d2>>8 & 0xff)+(var[2].i-d1 & 0xff00)]
                    << 8 ))];
                pix2=B32(tex1)[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];
                for(n=0; n<3; n++)
                    pix1p[n]=bytemul[pix1p[n]+(pix2p[n]<<8)];
                B32(vec_dbuffer)[fbeg+i]=pix1;
            }

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
            var[3].i+=dlt[3].i;
            var[4].i+=dlt[4].i;
            var[5].f+=dlt[5].f;
        }
    }
}
#endif  /* !VEC_NO_BUMP */

#endif  /* !VEC_NO_FLOAT */

#if defined(__WATCOMC__) && !defined(VEC_NO_TWEAK)

/*      Tweak:      */

void vec_set_tweakpage(long offset)
{
    if(offset < 0)
        vec_tweak=0;
    else
    {
        vec_tweak=1;
        vec_page=offset;
    }
}

void c_line_tweak(vec_vtx *vx1,vec_vtx *vx2)
{
    long    m,n, xmin,xmax;
    vec_ff  *vtx1,*vtx2, disp;
    vtx_u   *edgebuf;

    if(vx1->x > vx2->x)
    {
        vtx1=(vec_ff *)vx2;
        vtx2=(vec_ff *)vx1;
        edgebuf=end;
    }
    else
    {
        vtx1=(vec_ff *)vx1;
        vtx2=(vec_ff *)vx2;
        edgebuf=beg;
    }

    xmin=(long)vtx1[Xi] >> 8;
    xmax=(long)vtx2[Xi] >> 8;
    if(!(disp=xmax-xmin))
        return;

    subpixel=((long)vtx1[Yi] & 0xff)-0x100;
    for(n=0; n<nova; n++)
    {
        m=var_num[n];
        dlt[n].i=(vtx2[m]-vtx1[m])*0x100/disp;
        var[n].i=vtx1[m]*0x100-(subpixel*dlt[n].i >> 8);
    }

    if(xmax > vec_xres)
    {
        if(xmin > vec_xres-1)
            return;
        xmax=vec_xres;
    }
    if(xmin < 0)
    {
        if(xmax < 1)
            return;
        for(n=0; n<nova; n++)
            var[n].i-=xmin*dlt[n].i;
        xmin=0;
    }

    for(m=xmin; m<xmax; m++)
        for(n=0; n<nova; n++)
        {
            edgebuf[m][n].i=var[n].i;
            var[n].i+=dlt[n].i;
        }
}

#pragma aux flatfilltweak =\
    "add    edi,0a0000h"\
    "add    edi,vec_page"\
    "mov    talvi,esi"\
    "mov    edx,ecx"\
    "and    ecx,3"\
    "mov    al,01111b"\
    "shl    al,cl"\
    "mov    ecx,edx"\
    "mov    dx,03c5h"\
    "shr    ecx,2"\
    "add    edi,ecx"\
    "shr    esi,2"\
    "sub    esi,ecx"\
    "mov    ecx,esi"\
    "jz     obi"\
    "out    dx,al"\
    "mov    [edi],bl"\
    "inc    edi"\
    "dec    ecx"\
    "jz     ovi"\
    "mov    al,0fh"\
    "out    dx,al"\
    "mov    al,bl"\
    "rep    stosb"\
    "ovi:"\
    "mov    al,01111b"\
    "obi:"\
    "mov    ah,al"\
    "mov    ecx,3"\
    "sub    ecx,talvi"\
    "and    ecx,3"\
    "shr    ah,cl"\
    "and    al,ah"\
    "jz     borg"\
    "out    dx,al"\
    "mov    [edi],bl"\
    "borg:"\
    parm [edi] [ecx] [esi] [ebx] modify [edx eax]

void f_poly_tweak(void)
{
    long    m, inx,fbeg,fend, col=talvi;

    outp(0x3c4,2);
    for(m=maxy-1,inx=m*(vec_xres>>2); m>=miny; m--,inx-=vec_xres>>2)
    {
        fbeg=beg[m][0].i >> 16;
        fend=end[m][0].i >> 16;
        if(fend < fbeg)
            continue;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
        }
        if(fend > vec_xres)
        {
            if(fbeg > vec_xres-1)
                continue;
            fend=vec_xres;
        }

        flatfilltweak(inx,fbeg,fend,col);
    }
}

void t_poly_tweak(void)
{
    long    i,m, inx,fbeg,fend,disp, subpixel;

    m=minx+maxx >> 1;
    if((disp=end[m][0].i-beg[m][0].i>>8))
    {
        dlt[1].i=(-end[m][1].i+beg[m][1].i)/disp;
        dlt[2].i=(-end[m][2].i+beg[m][2].i)/disp;
    }

    outp(0x3c4,2);
    for(m=maxx-1,inx=m-1+vec_page*4; m>=minx; m--,inx-=vec_yres)
    {
        fbeg=beg[m][0].i >> 16;
        fend=end[m][0].i >> 16;
        if((disp=fend-fbeg) < 1)
            continue;

        outp(0x3c5,1 << (m&3));

        subpixel=(end[m][0].i & 0xffff) >> 8;
        var[1].i=beg[m][1].i >> 8;
        var[2].i=beg[m][2].i >> 8;

        if(fbeg < 0)
        {
            if(fend < 1)
                continue;
            fbeg=0;
            disp=fend;
        }
        if(fend > vec_yres)
        {
            if(fbeg > vec_yres-1)
                continue;
            var[1].i-=(vec_yres-fend)*dlt[1].i;
            var[2].i-=(vec_yres-fend)*dlt[2].i;
            disp=vec_yres-fbeg;
        }

        for(i=disp*vec_xres,fbeg*vec_xres,fbeg+=inx; i>0; i-=vec_xres)
        {
            ((uint8 *)(0xa0000))[fbeg+i >> 2] =
                tex1[(var[1].i>>8 & 0xff)+(var[2].i & 0xff00)];

            var[1].i+=dlt[1].i;
            var[2].i+=dlt[2].i;
        }
    }
}

#endif  /* __WATCOMC__ && !VEC_NO_TWEAK */

#if defined(__WATCOMC__) && !defined(VEC_NO_FLOAT)
#pragma aux qfist =\
    "mov    dword ptr tmpf, eax     "\
    "fld    dword ptr tmpf          "\
    "fadd   qword ptr fist_magic    "\
    "fstp   qword ptr tmpd          "\
    "fwait                          "\
    "mov    eax, dword ptr tmpd     "\
    "add    eax, 0x80000000         "\
    value [eax] parm [eax] modify exact[8087];
#endif  /* __WATCOMC__ && !VEC_NO_FLOAT */

#endif

