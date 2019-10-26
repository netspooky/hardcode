/*
 *
 *      VecSys Palette
 *
 *      - paletin k„(si)ttelyyn rutiineja
 *      - palettia k„ytt„vien tekstuurien k„sittelyrutiineja
 *
 */

#include "vecsys.h"
#include "vec_pal.h"
#include "vec_poly.h"
#include "vec_mem.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void vec_cshift(int *nc,int *n);

void vec_calc_etpal(uint8 *so1,uint8 *so2,uint8 *de,int nc)
{
    int     i,n;

    vec_cshift(&nc,&n);
    for(n=0; n<(256/nc)*3; n+=3)
        for(i=0; i<nc*3; i+=3)
        {
            de[i*nc+n]=(so2[i]+255)*so1[n] >> 9;
            de[i*nc+n+1]=(so2[i+1]+255)*so1[n+1] >> 9;
            de[i*nc+n+2]=(so2[i+2]+255)*so1[n+2] >> 9;
        }
}

void vec_calc_gtpal(uint8 *so1,uint8 *so2,uint8 *de,int nc,int per)
{
    int     i,n,pro=100-per;

    if(pro<1 || per<1)
        return;

    vec_cshift(&nc,&n);
    for(n=0; n<(256/nc)*3; n+=3)
        for(i=0; i<nc*3; i+=3)
        {
            de[i*nc+n+0]=(so2[i+0]*per+so1[n+0]*pro)/100;
            de[i*nc+n+1]=(so2[i+1]*per+so1[n+1]*pro)/100;
            de[i*nc+n+2]=(so2[i+2]*per+so1[n+2]*pro)/100;
        }
}

void vec_init_tex(uint8 *tex,int nc)
{
    int     n;
    long    i;

    vec_cshift(&nc,&n);
    for(i=0; i<0x10000; i++)
        tex[i]=tex[i] << n;
}

void vec_cshift(int *nc,int *n)
{
    int     i;

    for(i=2,*n=1; i<128; i<<=1,(*n)++)
        if(i >= *nc)
            break;
    *nc=i;
}

