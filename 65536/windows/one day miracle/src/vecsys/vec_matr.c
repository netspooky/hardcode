/*
 *
 *      VecSys Matrix
 *
 *      - rutiinit vektorien ja rotaatiomatriisien k„sittelyyn
 *
 *      ++ Yzi teki pari funktiota ++
 *
 */

#include "vecsys.h"
#include "vec_math.h"
#include "vec_matr.h"

#include <string.h>

void vec_init_qmatr(vec_fp q[4][4])
{
    int     n;

    memset(q,0,16*sizeof(vec_fp));
    for(n=0; n<4; n++)
        q[n][n]=1;
}

void vec_calc_qrot(vec_fp q[4][4],vec_fp ax,vec_fp ay,vec_fp az)
{
#ifdef  VEC_NO_FLOAT
    long    apu0=-vec_sin[az]*vec_sin[ax] >> 15,
            apu1=-vec_cos[az]*vec_sin[ax] >> 15;

    q[0][0] = vec_cos[ay]*vec_cos[az] + apu0*vec_sin[ay] >> 15;
    q[0][1] = vec_sin[az]*vec_cos[ax] >> 15;
    q[0][2] =-vec_cos[az]*vec_sin[ay] + apu0*vec_cos[ay] >> 15;

    q[1][0] =-vec_sin[az]*vec_cos[ay] + apu1*vec_sin[ay] >> 15;
    q[1][1] = vec_cos[ax]*vec_cos[az] >> 15;
    q[1][2] = vec_sin[az]*vec_sin[ay] + apu1*vec_cos[ay] >> 15;

    q[2][0] = vec_sin[ay]*vec_cos[ax] >> 15;
    q[2][1] = vec_sin[ax];
    q[2][2] = vec_cos[ay]*vec_cos[ax] >> 15;
#else
    vec_fp  anx=ax*M_PI/512, any=ay*M_PI/512, anz=az*M_PI/512,
            apu0=-sin(anz)*sin(anx),
            apu1=-cos(anz)*sin(anx);

    q[0][0] = cos(any)*cos(anz) + apu0*sin(any);
    q[0][1] = sin(anz)*cos(anx);
    q[0][2] =-cos(anz)*sin(any) + apu0*cos(any);

    q[1][0] =-sin(anz)*cos(any) + apu1*sin(any);
    q[1][1] = cos(anx)*cos(anz);
    q[1][2] = sin(anz)*sin(any) + apu1*cos(any);

    q[2][0] = sin(any)*cos(anx);
    q[2][1] = sin(anx);
    q[2][2] = cos(any)*cos(anx);
#endif
}

void vec_matrixmul_4x4(vec_fp s1[4][4],vec_fp s2[4][4],vec_fp de[4][4])
{
    static vec_fp   ma[4][4];
    int             i,j,n;

    for(i=0; i<4; i++)
        for(j=0; j<4; j++)
        {
            for(n=0,ma[i][j]=0; n<4; n++)
                ma[i][j]+=s1[i][n]*s2[n][j];
#ifdef  VEC_NO_FLOAT
            ma[i][j]>>=15;
#endif
        }

    memcpy(de,ma,16*sizeof(vec_fp));
}

void vec_transf_vects(long num,vec_fp q[4][4],vec_fp *so,vec_fp *de)
{
    long    m;
    vec_fp  dest_X,dest_Y,dest_Z;

    for(m=(num-1)*3; m>=0; m-=3)
    {
        dest_X = so[m+Xi]*q[0][0]+so[m+Yi]*q[0][1]+so[m+Zi]*q[0][2];
        dest_Y = so[m+Xi]*q[1][0]+so[m+Yi]*q[1][1]+so[m+Zi]*q[1][2];
        dest_Z = so[m+Xi]*q[2][0]+so[m+Yi]*q[2][1]+so[m+Zi]*q[2][2];
#ifndef VEC_NO_FLOAT
        de[m+Xi] = dest_X+q[Xi][3];     //      Nyt voi kohde olla
        de[m+Yi] = dest_Y+q[Yi][3];     //      sama kuin l„hde
        de[m+Zi] = dest_Z+q[Zi][3];
#else
        de[m+Xi] = (dest_X >> 15)+q[Xi][3];
        de[m+Yi] = (dest_Y >> 15)+q[Yi][3];
        de[m+Zi] = (dest_Z >> 15)+q[Zi][3];
#endif
    }
}

void vec_inverse_transf(vec_fp q[4][4],vec_fp so[3],vec_fp de[3])
{
    vec_fp  dest_X,dest_Y,dest_Z;

    dest_X = so[Xi]*q[0][0] + so[Yi]*q[1][0] + so[Zi]*q[2][0];
    dest_Y = so[Xi]*q[0][1] + so[Yi]*q[1][1] + so[Zi]*q[2][1];
    dest_Z = so[Xi]*q[0][2] + so[Yi]*q[1][2] + so[Zi]*q[2][2];
#ifndef VEC_NO_FLOAT
    de[Xi] = dest_X;
    de[Yi] = dest_Y;
    de[Zi] = dest_Z;
#else
    de[Xi] = dest_X >> 15;
    de[Yi] = dest_Y >> 15;
    de[Zi] = dest_Z >> 15;
#endif
}

vec_fp vec_dotproduct(vec_fp s1[3],vec_fp s2[3])
{
    return s1[Xi]*s2[Xi] + s1[Yi]*s2[Yi] + s1[Zi]*s2[Zi];
}

void vec_crossproduct(vec_fp s1[3],vec_fp s2[3],vec_fp t[3])
{
    t[0] = s1[1]*s2[2] - s1[2]*s2[1];
    t[1] = s1[2]*s2[0] - s1[0]*s2[2];
    t[2] = s1[0]*s2[1] - s1[1]*s2[0];
}

void vec_normalizevector(vec_fp v[3])
{
    vec_fp   length; // shift;

    length = v[0]*v[0] + v[1]*v[1] + v[2]*v[2];

#ifndef VEC_NO_FLOAT
    if((length=sqrt(length)) > 0)
    {
        length = 1/length;

        v[0] *= length;
        v[1] *= length;
        v[2] *= length;
    }
    else
    {
        v[0] = 1;
        v[1] = 0;
        v[2] = 0;
    }
#else
    if((length=vec_sqrt(length,&shift)) > 0)
    {
        v[0] = (v[0] >> shift) / length;
        v[1] = (v[1] >> shift) / length;
        v[2] = (v[2] >> shift) / length;
    }
    else
    {
        v[0] = 32767;
        v[1] = 0;
        v[2] = 0;
    }
#endif
}

#ifndef VEC_NO_FLOAT

void vec_axisangle2matrix(vec_fp axis[3],vec_fp angle,vec_fp matr[4][4])
/*
    - Laskee rotaatiomatriisin, jolla voi rotatoida
      halutun akselin [axis] ymp„ri [angle] radiaania.
    - Sijoittaa matriisin [matrix]:iin.
    - Normalisoi vektorin [axis].
*/
{
    vec_fp a, sina, cosa, x, y, z;

    memset(matr,0,16*sizeof(vec_fp));

    vec_normalizevector(axis);

    a = angle * 0.5;

    sina = sin(a);
    cosa = cos(a);

    x = axis[0] * sina;
    y = axis[1] * sina;
    z = axis[2] * sina;

    matr[0][0] = 1-2*(y*y+z*z);
    matr[0][1] = 2*(x*y-cosa*z);
    matr[0][2] = 2*(x*z+cosa*y);
    matr[1][0] = 2*(x*y+cosa*z);
    matr[1][1] = 1-2*(x*x+z*z);
    matr[1][2] = 2*(y*z-cosa*x);
    matr[2][0] = 2*(x*z-cosa*y);
    matr[2][1] = 2*(y*z+cosa*x);
    matr[2][2] = 1-2*(x*x+y*y);
    matr[3][3] = 1;
}

void vec_calc_qtodir(vec_fp q[4][4],vec_fp dir[3],vec_fp anz)
{
    static vec_fp   v[3]={0,0,-1}, r[4][4];
    int             i;

    for(i=Xi; i<=Zi; i++)
        q[2][i]=-dir[i];
    vec_normalizevector(q[2]);

    vec_crossproduct(q[2],v,q[0]);
    vec_normalizevector(q[0]);

    vec_crossproduct(q[2],q[0],q[1]);
    vec_normalizevector(q[1]);

    vec_axisangle2matrix(q[2],anz*M_PI/512,r);
    vec_matrixmul_4x4(q,r,q);
}

void vec_calc_qtoaxis(vec_fp q[4][4],vec_fp z[3],vec_fp y[3])
{
    vec_normalizevector(z);
    vec_normalizevector(y);

    vec_crossproduct(y,z,q[0]);
    vec_normalizevector(q[0]);

    memcpy(q[2],z,3*sizeof(vec_fp));
    memcpy(q[1],y,3*sizeof(vec_fp));
}

#endif


