/*
    Panoraamaeffektsi. Py‰ritell‰‰n kuvaa ja siin‰ p‰‰ll‰ toistaki.
    Rantapallo kruunaa kaiken, mutta se tulee muualta.
    - Marq
 */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define PANOLEV 982
#define PANOKOR 240

unsigned *tausta,
         *paalline;

static unsigned ymul[320*240],xmul[320];

/* Efektin alustus */
int pano_init(unsigned *taus,unsigned *paa)
{
    int n,
        x,y;

    tausta=taus;
    paalline=paa;

    /* Tehd‰‰n tablet joista saadaan panoraaman venkautus */
    for(n=0;n<320;n++)
        xmul[n]=PANOLEV+atan2(n-160.0,200.0)*200.0;

    for(y=0;y<240;y++)
        for(x=0;x<320;x++)
        {
            ymul[y*320+x]=PANOLEV*(int)(PANOKOR/2.0+
                          atan2(y-120.0,200.0)*220.0*cos((x-160)/250.0));
        }
    return(1);
}

/* Ite efekti */
void pano_effect(unsigned *buf,int phase)
{
    int x,y,
        n,
        of,
        tmp;

    unsigned    mulnphase1[320],
                mulnphase2[320],
                hole;

    /* Pi‰ni precalcci */
    for(n=0;n<320;n++)
    {
        mulnphase1[n]=(xmul[n]+phase)%PANOLEV;
        mulnphase2[n]=(xmul[n]+phase*2)%PANOLEV;
    }

    hole=paalline[0];   /* Kuvan eka pikseli on taustaf‰ri */
    for(y=of=0;y<240;y++)
    {
        for(x=0;x<320;x++,of++)
        {
            tmp=paalline[ymul[of]+mulnphase2[x]];
            if(tmp!=hole)
                buf[of]=tmp;
            else
                buf[of]=tausta[ymul[of]+mulnphase1[x]];
        }
    }
}

/* EOS */
