/*
    The multizuumeri.
    Initille annetaan suumin koko ja efektille bufferi ja vaihe
    (voi olla mik‰ vaan posetiivinen luku).

    - Marq
*/

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define SUUMTXT 256*256

#ifndef M_PI
#define M_PI 3.141592
#endif

static int  width,
            height;

int suumi_init(int pwidth,int pheight)
{
    height=pheight;
    width=pwidth;

    return(0);
}

void suumi_effect(unsigned *buf,int phase,double potenz,
                  unsigned *zuum1,unsigned *zuum2,unsigned *zuum3)
{
    int n,
        kx,ky,
        kerroin,
        ax,ay,
        adx,ady,
        roundx,roundy;

    unsigned    *eka=0,
                *toka=0,
                of,
                final,
                mul1[256],
                mul2[256];

    unsigned char   *pixel1,
                    *pixel2;

    double  angle,
            ker,
            luku,
            x,y,
            kesx,kesy,
            vax,vay,
            vyx,vyy,
            oyx,oyy,
            realphase;

    realphase=phase;
    kerroin=phase&255;
    phase%=768; /* Yhden kuvan zuumaus kest‰‰ aina 256 */

    /* Zuumattavat kuvat vaiheen mukaan */
    if(phase<256)
    {
        eka=zuum1;
        toka=zuum2;
    }
    if(phase<512 && phase >=256)
    {
        eka=zuum2;
        toka=zuum3;
    }
    if(phase>=512)
    {
        eka=zuum3;
        toka=zuum1;
    }

    /* Kertoimet v‰rikomponenteille */
    for(n=0;n<256;n++)
    {
        mul1[n]=(255-kerroin)*n/255;
        mul2[n]=kerroin*n/255;
    }

    /* Koordinaatit kulmille jne. */
    luku=kerroin;
    angle=M_PI*1.20+cos(realphase/25.6/2);

    ker=256.0/(pow(luku,potenz)/(pow(256.0,potenz)/256.0)+1.0);

    kesx=128.5;
    kesy=128.5;

    vyx=kesx+cos(angle)*ker;
    vyy=kesy+sin(angle)*ker;

    vax=cos(angle-M_PI/2.6)*ker;
    vay=sin(angle-M_PI/2.6)*ker;

    oyx=-vax;
    oyy=-vay;

    vax+=kesx;
    vay+=kesy;
    oyx+=kesx;
    oyy+=kesy;

    adx=(oyx-vyx)*65536.0/(double)width;
    ady=(oyy-vyy)*65536.0/(double)width;

    /* Piirtoluuppi */
    for(ky=of=0;ky<height;ky++)
    {
        x=vyx+(vax-vyx)*ky/(double)height;
        y=vyy+(vay-vyy)*ky/(double)height;
        ax=x*65536.0;
        ay=y*65536.0;

        /* Ja "tiukka" innerluuppi */
        for(kx=0;kx<width;kx++,of++)
        {
            roundx=ax>>16;
            roundx&=255;
            roundy=ay>>16;
            roundy&=255;
            pixel1=(unsigned char *)&eka[roundy*256+roundx];

            roundx=(ax&0xffff)>>8;
            roundy=(ay&0xffff)>>8;
            pixel2=(unsigned char *)&toka[roundy*256+roundx];

#ifdef BIG
            final=(mul1[pixel1[1]]<<16)+(mul1[pixel1[2]]<<8)+mul1[pixel1[3]];
            final+=(mul2[pixel2[1]]<<16)+(mul2[pixel2[2]]<<8)+mul2[pixel2[3]];
#else
            final=(mul1[pixel1[2]]<<16)+(mul1[pixel1[1]]<<8)+mul1[pixel1[0]];
            final+=(mul2[pixel2[2]]<<16)+(mul2[pixel2[1]]<<8)+mul2[pixel2[0]];
#endif

            buf[of]=final;

            ax+=adx;
            ay+=ady;
        }
    }
}

/* EOS */
