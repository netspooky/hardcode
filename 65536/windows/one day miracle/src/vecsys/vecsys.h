/*------------------------------------------------------------------------

        Projekti        :       Vector System
        Versio          :       1.3 - ehk„ joskus
        Aika            :       26.6.1996 -
        Tekij„t         :       Pete/Fit ja muut

-------------------------------------------------------------------------*/

#ifndef VEC_MAIN_H
#define VEC_MAIN_H

#include "vec_type.h"
#include "vec_def.h"            //      Ei pit„isi olla t„„ll„!

#define VEC_NO_TWEAK

typedef enum                    //      Er„iden funktioden paluuarvot
{
    VEC_OK,                     
    VEC_ERR
} vec_ret;

#define VEC_FLAT        0x001   //      Eri fillaustavat,
#define VEC_GOURAUD     0x002   //      joita voi yhdistell„
#define VEC_TEXTURE     0x004
#define VEC_ENV         0x008
#define VEC_BUMP        0x010
#define VEC_IMAGE       0x020
#define VEC_ZBUFFER     0x040
#define VEC_PCORRECT    0x080
#define VEC_ANATAUS     0x100   //      My”s takapinta fillataan
#define VEC_TRANSPARENT 0x200

#define VEC_MAX_FACES   65536   //      Maailmassa monta on facea
#define VEC_MAX_VPF     4       //      Vertexej„ facessa, „l„ muuta

typedef enum                    //      Sort-tyypit
{
    VEC_RADIX,                  
    VEC_COUNTING
} vec_st;

#define VEC_SORTBYTES   3       //      Tavujen m„„r„ radixissa

#define VEC_FRONTCLIP   -105    //      Taso johon leikataan edess„

#define VEC_CALC_NORMALS        //      Lasketaan normaalit initiss„

enum                            //      Indeksit objektin sharedat-kentt„„n
{
    VEC_SHARE_DATA,             
    VEC_SHARE_NORM,
    VEC_SHARE_OBJ
};

typedef struct VEC_OBJ
{
    long    vertices,           //      Vertexien m„„r„
            faces,              //      Facejen m„„r„
            type,               //      Piirtotyyppi
            *face;              //      Polygonien pisteiden numerot
    vec_fp  *vertex,            //      Vertexien koordinaatit
            *tcoord,            //      Tekstuurikoordinaatit
            *normal,            //      Pisteiden normaalit
            w[3],               //      Paikka maailmassa
            d[3],               //      Paikkadeltat
            ax,ay,az,           //      Kulmadeltat objektin koord.
            omatr[4][4],        //      Objektin matriisi
            ematr[4][4],        //      Objektin silm„avaruusmatriisi
            mmatr[4][4];        //      3ds:n "Mesh Matrix"

    char    name[11],           //      Objektin nimi
            material[17];       //      Materiaalin nimi
    uint8   *texture,           //      Tekstuurin osoitin
            *anataus,           //      "Anataus"-tekstuurin osoitin
            *env,               //      "Env"-tekstuurin osoitin
            *bump;              //      "Bump"-tekstuurin osoitin
    uint32  colour;             //      Objektin v„ri

    int     *sharedat;          //      Ovatko eri datat yhteisi„
    vec_fp  maxvtxlen,          //      Max vertexin et„isyys kp:st„
            objdist,            //      Objektin et„isyys katsojasta
            *vcoord,            //      Rotatoidut koordinaatit
            *scoord,            //      Pisteiden ruutukoordinaatit
            *ncoord,            //      Rotataoidut normaalit
            pivot[3],           //      Nyt py”rit„„n (t„m„n ymp„ri)
            light[3];           //      Backtransformoitu valon suunta
} vec_obj;

/*
 * jos n„it„ ei ole k„„nnett„ess„ mukana, j„„ n„it„ k„ytt„v„ osa
 *      systeemist„ k„„nt„m„tt„ (ja valot lasketaan muuten)
 */
#include "vec_poly.h"           //      L„j„ fillausrutiineja
#include "vec_lsrc.h"           //      Valon tuoja

extern int      vec_init_sys(void);
extern void     vec_close_sys(void);

extern void     vec_rotate(long num,vec_fp *so,vec_fp *de,
                    vec_fp ax,vec_fp ay,vec_fp az);
extern void     vec_move(long num,vec_fp *so,vec_fp dlt[]);
extern void     vec_project(long num,vec_fp *so,vec_fp *de,
                    long xsize,long ysize,vec_fp asp);
extern void     vec_rotate_object(vec_obj *obj);
extern void     vec_translate_object(vec_obj *obj);
extern void     vec_project_object(vec_obj *obz,
                    long xsize,long ysize,vec_fp asp);

extern void     vec_set_mirror(vec_fp mirror[4][4]);
extern void     vec_mirror_object(vec_obj *obz);

extern int      vec_set_res(long x,long y,int cdepth);
extern int      vec_set_aspect(int aspect);

extern long     vec_visicalc(vec_obj *obj);
extern void     vec_init_sort(void);
extern int      vec_tell_sorttype(void);
extern void     vec_draw_objects(void);
extern void     vec_draw_object(vec_obj *obj);

extern vec_obj  *vec_alloc_object(long vertices,long faces,int texture);
extern void     vec_init_object(vec_obj *obj);
extern void     vec_free_object(vec_obj *obj);
extern int      vec_calc_normals(vec_obj *obj);
extern void     vec_center_object(vec_obj *obj);

#endif

