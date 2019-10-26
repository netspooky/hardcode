/*
 *
 *      VecSys Math
 *
 *      - sini- ja neli”juuritaulukoiden lasku
 *
 */

#include "vec_math.h"

static unsigned long    sqrtt[4096];

#ifdef  VEC_NO_FLOAT

long                    vec_sin[1281],*vec_cos=vec_sin+256;

static long             teho(long lku,long ep);

void vec_calc_sin(void)
{
    long    lkr;
    long    pannu,kannu;

    for(lkr=0,pannu=-256*25; lkr<512; lkr++,pannu+=25)
    {
        kannu=1024 * ( 32767 -
                teho(pannu,2) +
                teho(pannu,4)/12 -
                teho(pannu,6)/360 +
                teho(pannu,8)/20160 ) >> 10;

        vec_sin[lkr]=kannu;
        vec_sin[512+lkr]=-kannu;

        if(lkr < 257)
            vec_sin[lkr+1024]=kannu;
    }
}

long teho(long lku,long ep)
{
    long    televisio=16384;

    for(; ep; ep--)
        televisio=televisio*lku >> 12;

    return televisio;
}
#endif

void vec_calc_sqrt(void)
{
        long    m,i=0,len=1,vlue=0,delta,intrp;

        while(i<4096)
        {
                delta=65536/len;
                for(m=0,intrp=0; m<len; m++,intrp+=delta)
                {
                        if(i==4096)
                                break;
                        sqrtt[i++]=vlue+(intrp>>8);
                }
                len += 2;
                vlue += 256;
        }
}

long vec_sqrt(long arg,long *shift)
{
    *shift=0;
    while(arg > 4095)
    {
        arg >>= 6;
        *shift += 3;
    }

    return sqrtt[arg];
}

