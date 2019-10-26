/*
 *
 *      VecSys Light source
 *
 *      - Licht sorsa
 *
 */

#include "vec_lsrc.h"
#include "vecsys.h"
#include "vec_matr.h"

#ifndef VEC_NO_FLOAT
#include <math.h>
#endif

static vec_fp   vec_ls[3]={900,1000,-400},
                ls_first=0,ls_last=255*256,ls_num=256*256;

void vec_set_lsrc(vec_fp ls[])
{
    int     n;

    for(n=Xi;n<=Zi;n++)
        vec_ls[n]=ls[n];
}

void vec_set_range(long first,long num)
{
    if(min(first,num)<0)
        return;
    ls_first=first*256;
    ls_last=(first+num-1)*256;
    ls_num=num*256;
}

void vec_init_shading(vec_obj *obz)
{
    vec_fp  /*Tp,*/ *L=obz->light;

    L[Xi]=-vec_ls[Xi]+obz->w[Xi];
    L[Yi]=-vec_ls[Yi]+obz->w[Yi];
    L[Zi]=-vec_ls[Zi]+obz->w[Zi];

#ifdef  VEC_NO_FLOAT
    if((Tp=max(abs(L[Zi]),max(abs(L[Xi]),abs(L[Yi])))))
    {
        L[Xi]=(L[Xi] << 8)/Tp;      //      "normalisoidaan"
        L[Yi]=(L[Yi] << 8)/Tp;      //          L(x,y,z)
        L[Zi]=(L[Xi] << 8)/Tp;
    }
#endif
    vec_inverse_transf(obz->omatr,L,L);
}

vec_fp vec_shade(vec_obj *obz,long fan)
{
    long    i, f1,f2,f3;
    vec_fp  Tp, A[3],B[3],N[3], *L=obz->light, col=0;

    if(obz->type & VEC_GOURAUD)
    {
        for(i=Xi; i<=Zi; i++)
            N[i]=obz->normal[3*obz->face[fan]+i];
    }
    else
    {
        f1=3*obz->face[fan];
        f2=3*obz->face[fan+1];
        f3=3*obz->face[fan+2];

        for(i=Xi; i<=Zi; i++)
#ifdef  VEC_NO_FLOAT
            N[i] =  obz->normal[f1+i] +
                obz->normal[f2+i] +
                obz->normal[f3+i];
#else
        {
            A[i]=obz->vertex[f2+i] - obz->vertex[f1+i];
            B[i]=obz->vertex[f3+i] - obz->vertex[f1+i];
        }

        vec_crossproduct(A,B,N);
        vec_normalizevector(N);
#endif
    }

#ifdef  VEC_NO_FLOAT
    Tp = (N[Xi]*N[Xi] + N[Yi]*N[Yi] + N[Zi]*N[Zi] >> 4) *
        (L[Xi]*L[Xi] + L[Yi]*L[Yi] + L[Zi]*L[Zi] >> 4);
    if((Tp = vec_sqrt(Tp,&col)))
        col=16 * (N[Xi]*L[Xi] + N[Yi]*L[Yi] + N[Zi]*L[Zi]) *
            ls_num / Tp >> col;
#else
    if((Tp = sqrt((N[Xi]*N[Xi] + N[Yi]*N[Yi] + N[Zi]*N[Zi]) *
        (L[Xi]*L[Xi] + L[Yi]*L[Yi] + L[Zi]*L[Zi]))))
        col=ls_num * (N[Xi]*L[Xi] + N[Yi]*L[Yi] + N[Zi]*L[Zi]) / Tp;
#endif
    return max(ls_first,min(ls_last,ls_first+col));
}

