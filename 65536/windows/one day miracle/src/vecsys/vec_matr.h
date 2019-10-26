/*
 *
 *      VecSys Matrix
 *
 *      - rutiinit vektorien ja rotaatiomatriisien k„sittelyyn
 *
 *      ++ Yzi teki pari funktiota ++
 *
 */

#ifndef VEC_MATR_H
#define VEC_MATR_H

#include "vec_type.h"

extern void     vec_init_qmatr(vec_fp q[4][4]);
extern void     vec_calc_qrot(vec_fp q[4][4],vec_fp ax,vec_fp ay,vec_fp az);
extern void     vec_matrixmul_4x4(vec_fp s1[4][4],vec_fp s2[4][4],
                    vec_fp de[4][4]);
extern void     vec_transf_vects(long num,vec_fp q[4][4],vec_fp *so,vec_fp *de);
extern void     vec_inverse_transf(vec_fp q[4][4],vec_fp so[3],vec_fp de[3]);
extern vec_fp   vec_dotproduct(vec_fp s1[3],vec_fp s2[3]);
extern void     vec_crossproduct(vec_fp s1[3],vec_fp s2[3],vec_fp t[3]);
extern void     vec_normalizevector(vec_fp v[3]);
extern void     vec_axisangle2matrix(vec_fp axis[3],vec_fp angle,
                    vec_fp matr[4][4]);
extern void     vec_calc_qtodir(vec_fp q[4][4],vec_fp dir[3],vec_fp anz);
extern void     vec_calc_qtoaxis(vec_fp q[4][4],vec_fp z[3],vec_fp y[3]);

#endif

