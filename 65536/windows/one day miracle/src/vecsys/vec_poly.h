/*
 *
 *      VecSys Poly
 *
 *      - polygon fill
 *
 */

#ifndef VEC_POLY_H
#define VEC_POLY_H

//#define VEC_X86                     //      k„ytet„„n vec_fill.asm:ia

#define VEC_XRES    640             //      max_X_resulaatio
#define VEC_YRES    480             //      max_Y_resulaatio

typedef float       vec_ff;

typedef struct
{
    vec_ff  x,  y,                  //      pisteen koordinaatit
            u1, v1,                 //      tekstuurikoordinaatit
            u2, v2,                 //      toisen tekst. koord.
            i,                      //      valoisuus
            z;                      //      et„isyys
} vec_vtx;

#define VEC_MAXV    (sizeof(vec_vtx)/sizeof(vec_ff))

//  fillausrutiinien initialisointi
extern void     vec_init_fill(void);
//  fillausrutiinien sulkeminen
extern void     vec_close_fill(void);

//  yleinen polygoninfillausrutiini
extern void     vec_poly(int num,vec_vtx *vrtcs,uint32 col);

//  fillaustyypin asetus
extern int      vec_set_filltype(long type);
//  resoluution asetus
extern int      vec_set_fillres(long x,long y,int cdepth);
//  puskurien asetus
extern int      vec_set_bufs(uint8 *dbuf,vec_fp *zbuf);
//  tekstuurien 1 ja 2 asetus
extern void     vec_set_texture(uint8 *tex,int num);

//  z-bufferin tyhjennys
extern void     vec_clear_zbuffer(void);
//  z-bufferin osoitteen palautus (NULL jos ei k„yt”ss„)
extern vec_fp   *vec_tell_zbuffer(void);

/*      Tweak:      */

//  tweak-sivun asetus (-1 asettaa tweakin pois k„yt”st„)
extern void     vec_set_tweakpage(long offset);

#endif

