/*
    One day miracle... main function and some additional thangs
*/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include <sys/time.h>
#include <unistd.h>

#include "cool_gfx/cool_gfx.h"
#include "cool_gfx/gfx_x.h"
#include "cool_mzx/cool_mzx.h"
#include "feidi.h"
#include "SDL_main.h"

#define LEV 320
#define KOR 240

#define PLEV 982
#define PKOR 240

/* #define DEBUG */

/* External datas */
extern unsigned char moddi[],kafka[],tekstit[],picasso[];

/* Lazy lazy lazy: instead of writing headers here are the declarations */
extern void init_maf();
extern void horiz_maf(int *,int *,int,int, int,int,int,int, int,int,int);
extern void vert_maf(int *,int *,int,int, int,int,int,int, int,int,int);
extern void venkula_init(int param1,int param2);
extern void venkula(int clock,int *buffer,int *bg);
extern int pano_init(unsigned *,unsigned *);
extern void pano_effect(unsigned *,int);
extern int suumi_init(int,int);
extern void suumi_effect(unsigned *,int,double,unsigned *,unsigned *,unsigned *);
void halftone_init(int xs,int ys);
void halftone(unsigned *dest,unsigned *src,int inten);
void init_flare();
void flarez(unsigned *buf,int phase);
void ranta_init(unsigned char *smurffi);
void ranta_effect(int p_time1);

void tee_tausta(unsigned *taus,unsigned *edus);
void lodju(int x,int y,unsigned *buf,int new);
void tex(int px,int py,int num,int brite,unsigned *buf);

void pallotko_init(unsigned *dest);
void pallotko(unsigned *buf,int n);
void alku(unsigned *pbuf,int n);
void tonko(unsigned *buf,int n);
void unzoomeri_init();
void unzoomeri_taas(unsigned *buf,int n);
void blandis(unsigned *buf,int n);
void flar(unsigned *buf,int n);
int mzx_ticks(void);

static unsigned pt[PLEV*PKOR],pe[PLEV*PKOR],
                unz[256*256];

int main(int argc,char *argv[])
{
    static unsigned    buf[LEV*KOR],buf2[LEV*KOR*2],white[LEV*KOR],buf3[LEV*KOR];
    int         n=0,cont=1,tmp,vuaro,ver=0,tid,ver2,ctr,ctr2,x,y,marker;

    /* Inits */
    if(!mzx_init())
    {
        fprintf(stderr,"MZX failure\n");
        return(EXIT_FAILURE);
    }
    mzx_get(moddi);

    if(gfx_init(GFX_320x240x32,0)!=GFX_OK)
    {
        fprintf(stderr,"GFX failure\n");
        return(EXIT_FAILURE);
    }

    init_maf();
    init_flare();
    tee_tausta(pt,pe);
    pano_init(pt,pe);
    halftone_init(320,240);
    venkula_init(1200,280);
    for(n=0;n<320*240;n++)
        white[n]=0xffddcc;
    ranta_init((unsigned char *)buf);

    /* Let's go! */
    mzx_start(52);
    while(mzx_position()<0 || mzx_position()>100)
        ;
    
    /* The first part */
    ver=mzx_ticks();
    ctr=0;
    while(mzx_position()<100 && cont)
    {
        tid=mzx_ticks()-ver;
        if(!ctr)
        {
            tmp=mzx_position();
            if(tmp==8 || tmp==0x28)
                ctr=tid+20;
        }
        alku(buf,tid);
        if(ctr)
        {
            if(tid>ctr)
                ctr=0;
            else
            {
                tmp=10-(ctr-tid);
                add_fade(buf,white,buf,320*240,255,120-tmp*tmp);
            }
        }
        gfx_blit(buf);
        if(gfx_exitevent())
            cont=0;
    }
#ifdef DEBUG
    cont=1;
#endif

    halftone_init(320,240);
    venkula_init(1200,280);

    /* Halftone part */
    ver2=ver;
    ver=mzx_ticks();
    ctr=20;
    while(mzx_position()<200 && cont)
    {
        tid=mzx_ticks()-ver;
        alku(buf,mzx_ticks()-ver2);
        tonko(buf2,tid);
        cross_fade(buf,buf2,buf2,320*240,(tid<256)?tid:255);
        if(ctr)
        {
            if(tid>ctr)
                ctr=0;
            else
            {
                tmp=10-(ctr-tid);
                add_fade(buf2,white,buf2,320*240,255,120-tmp*tmp);
            }
        }
        gfx_blit(buf2);
        if(gfx_exitevent())
            cont=0;
    }
#ifdef DEBUG
    cont=1;
#endif

    ctr=0;
    vuaro=1;
    ver2=ver;
    while(mzx_position()<400 && cont)
    {
        tid=mzx_ticks()-ver;
        if(!ctr)
        {
            tmp=mzx_position()%100;
            if(tmp==0 || tmp==0x20)
            {
                ctr=tid+30;
                vuaro=-vuaro;
                ver2=mzx_ticks();
                marker=tid;
            }
        }
        tonko(buf,marker+(mzx_ticks()-ver2)*vuaro);
        if(ctr)
        {
            if(tid>ctr)
                ctr=0;
            else
            {
                tmp=15-(ctr-tid);
                tex(125,114,0,255-tmp*tmp,buf);
                tex(65,114+24,1,255-tmp*tmp,buf);
            }
        }
        gfx_blit(buf);
        n++;
        if(gfx_exitevent())
            cont=0;
    }
#ifdef DEBUG
    cont=1;
#endif

    /* Flare part */
    ver2=ver;
    ver=mzx_ticks();
    while(mzx_position()<430 && cont)
    {
        tid=mzx_ticks()-ver;
        tonko(buf,mzx_ticks()-ver2);
        flar(buf2,tid);
        for(y=0;y<3;y++)
            tex(6,84+y*24,y+2,200,buf2);
        tmp=256-tid*3;
        add_fade(buf,buf2,buf2,320*240,(tmp>0)?tmp:0,(tid<85)?tid*3:255);
        gfx_blit(buf2);
        n++;
        if(gfx_exitevent())
            cont=0;
    }
#ifdef DEBUG
    cont=1;
#endif

    ctr=0;
    vuaro=2;
    while(mzx_position()<700 && cont)
    {
        tid=mzx_ticks()-ver;
        if(!ctr)
        {
            tmp=mzx_position()%100;
            if(tmp==0 || tmp==0x20)
            {
                ctr=tid+42;
                vuaro=(vuaro+1)%3;
            }
        }
        flar(buf,tid);
        if(ctr)
        {
            if(tid>ctr)
            {
                for(y=0;y<3;y++)
                    tex(6,84+y*24,y+2,200,buf);
                ctr=0;
            }
            else
                for(y=0;y<3;y++)
                {
                    tmp=42-(ctr-tid);
                    if(y==vuaro)
                    {
                        if(tmp<24)
                        {
                            tmp-=12;
                            tmp=144-tmp*tmp;
                        }
                        else
                        {
                            if(tmp<36)
                            {
                                tmp-=30;
                                tmp=36-tmp*tmp;
                            }
                            else
                            {
                                tmp-=39;
                                tmp=9-tmp*tmp;
                            }
                        }
                        tmp/=3;
                    }
                    else
                        tmp=0;
                    tex(6+tmp,84+y*24,y+2,200+((y==vuaro)?55:0),buf);
                }
        }
        else
            for(y=0;y<3;y++)
                tex(6,84+y*24,y+2,200,buf);

        gfx_blit(buf);
        n++;
        if(gfx_exitevent())
            cont=0;
    }
#ifdef DEBUG
    cont=1;
#endif

    unzoomeri_init();

    /* Unzoomer part */
    ver2=ver;
    ver=mzx_ticks();
    while(mzx_position()<800 && cont)
    {
        tid=mzx_ticks()-ver;
        flar(buf,mzx_ticks()-ver2);
        for(y=0;y<3;y++)
            tex(6,84+y*24,y+2,200,buf);
        unzoomeri_taas(buf2,tid);
        cross_fade(buf,buf2,buf2,320*240,(tid<256)?tid:255);
        gfx_blit(buf2);
        if(gfx_exitevent())
            cont=0;
    }
#ifdef DEBUG
    cont=1;
#endif

    ctr=0;
    marker=-1;
    while(mzx_position()<1100 && cont)
    {
        tid=mzx_ticks()-ver;
        if(marker!=mzx_position())
        {
            marker=mzx_position();
            tmp=mzx_position();
            if(tmp<900)
            {
                tmp%=100;
                if(tmp==8 || tmp==0x28)
                    ctr=tid+20;
            }
            else
            {
                tmp%=100;
                if(tmp==0 || tmp==3 || tmp==0x18 || tmp==0x1b || tmp==0x2a
                   || tmp==0x3b || tmp==0x3e)
                    ctr=tid+20;
            }
        }
        unzoomeri_taas(buf,tid);
        if(ctr)
        {
            if(tid>ctr)
                ctr=0;
            else
            {
                tmp=10-(ctr-tid);
                add_fade(buf,white,buf,320*240,255,120-tmp*tmp);
            }
        }
        gfx_blit(buf);
        if(gfx_exitevent())
            cont=0;
    }
#ifdef DEBUG
    cont=1;
#endif

    venkula_init(500,180);

    /* Ball part */
    pallotko_init(buf2);
    ver2=ver;
    ver=mzx_ticks();
    ctr=ctr2=0;
    vuaro=4;
    marker=0;
    while(mzx_position()<1600 && cont)
    {
        tid=mzx_ticks()-ver;
        if(!ctr && mzx_position()>=1300)
        {
            tmp=mzx_position()%100;
            if(tmp==0 || tmp==0x20)
            {
                ctr=tid+20;
                vuaro=(vuaro+1)%6;
            }
        }
        if(!ctr2)
        {
            if(mzx_position()==1300)
                ctr2=tid+20;
        }
        memset(buf,0,320*240*sizeof(int));
        if(ctr)
            tmp=ctr-tid;
        else
            tmp=0;
        halftone(buf,&buf2[(((int)(48000+tmp*60*sin(tid/13.0)))%240)*320],220+40*sin(tid/10.0));
        if(mzx_position()<1300)
            ranta_effect(tid);
        else
            ranta_effect(tid*4);
        if(ctr)
        {
            if(tid>ctr)
                ctr=0;
            else
            {
                tmp=10-(ctr-tid);
                horiz_maf(buf,buf3, 0,0,0,0, 320,240, 320,240, 21-tmp*tmp/5);
                memcpy(buf,buf3,320*240*sizeof(int));
            }
        }
        if(ctr)
        {
            tmp=10-(ctr-tid);
            tmp=100-tmp*tmp;
        }

        tmp=(tid%78)-77;
        lodju(0,0,buf,1);
        for(x=0;x<5;x++)
            lodju(x*78-tmp-78,-10,buf,0);
        for(x=0;x<5;x++)
            tex(tmp+x*78,210,0,155+((x==vuaro && ctr)?100:0),buf);

        if(ctr2)
        {
            if(tid>ctr2)
                ctr2=0;
            else
            {
                tmp=10-(ctr2-tid);
                add_fade(buf,white,buf,320*240,255,120-tmp*tmp);
            }
        }

        if(mzx_position()<1200)
        {
            unzoomeri_taas(buf3,(mzx_ticks()-ver2)*4);
            tmp=300-tid;
            if(tmp<0) tmp=0;
            cross_fade(buf3,buf,buf,320*240,(rand()%300<tmp)?16:240);
        }
        if(mzx_position()>1500)
        {
            if(!marker)
                marker=mzx_ticks();
            blandis(buf3,tid);
            for(y=0;y<5;y++)
                lodju(245,y*48,buf3,0);
            tmp=mzx_ticks()-marker;
            cross_fade(buf,buf3,buf,320*240,(tmp<256)?tmp:255);
        }

        gfx_blit(buf);

        if(gfx_exitevent())
            cont=0;
    }
#ifdef DEBUG
    cont=1;
#endif
  
    /* The last part */
    ctr=0;
    vuaro=1;
    while(mzx_position()<1800 && cont)
    {
        if(!ctr)
        {
            tmp=mzx_position();
            if(tmp>1700)
            {
                tmp%=100;
                if(tmp==8 || tmp==0x28)
                {
                    ctr=tid+42;
                    vuaro=(vuaro+2)%5;
                }
            }
            else
            {
                tmp%=100;
                if(tmp==0 || tmp==3 || tmp==0x18 || tmp==0x1b || tmp==0x2a
                   || tmp==0x3b || tmp==0x3e)
                {
                    ctr=tid+42;
                    vuaro=(vuaro+2)%5;
                }
            }
        }
        tid=mzx_ticks()-ver;
        blandis(buf,tid);
        if(ctr)
        {
            if(tid>ctr)
            {
                for(y=0;y<5;y++)
                    lodju(245,y*48,buf,0);
                ctr=0;
            }
            else
                for(y=0;y<5;y++)
                {
                    tmp=42-(ctr-tid);
                    if(y==vuaro)
                    {
                        if(tmp<24)
                        {
                            tmp-=12;
                            tmp=144-tmp*tmp;
                        }
                        else
                        {
                            if(tmp<36)
                            {
                                tmp-=30;
                                tmp=36-tmp*tmp;
                            }
                            else
                            {
                                tmp-=39;
                                tmp=9-tmp*tmp;
                            }
                        }
                        tmp/=3;
                    }
                    else
                        tmp=0;
                    lodju(245-tmp,y*48,buf,0);
                }
        }
        else
            for(y=0;y<5;y++)
                lodju(245,y*48,buf,0);

        gfx_blit(buf);
        if(gfx_exitevent())
            cont=0;
    }
#ifdef DEBUG
    cont=1;
#endif

    memset(buf2,0,320*240*sizeof(int));
    ver2=mzx_ticks();
    while(mzx_position()<1900 && cont)
    {
        if(!ctr)
        {
            tmp=mzx_position();
            tmp%=100;
            if(tmp==8 || tmp==0x28)
            {
                ctr=tid+42;
                vuaro=(vuaro+2)%5;
            }
        }
        tid=mzx_ticks()-ver2;
        blandis(buf,tid);
        if(ctr)
        {
            if(tid>ctr)
            {
                for(y=0;y<5;y++)
                    lodju(245,y*48,buf,0);
                ctr=0;
            }
            else
                for(y=0;y<5;y++)
                {
                    tmp=42-(ctr-tid);
                    if(y==vuaro)
                    {
                        if(tmp<24)
                        {
                            tmp-=12;
                            tmp=144-tmp*tmp;
                        }
                        else
                        {
                            if(tmp<36)
                            {
                                tmp-=30;
                                tmp=36-tmp*tmp;
                            }
                            else
                            {
                                tmp-=39;
                                tmp=9-tmp*tmp;
                            }
                        }
                        tmp/=3;
                    }
                    else
                        tmp=0;
                    lodju(245-tmp,y*48,buf,0);
                }
        }
        else
            for(y=0;y<5;y++)
                lodju(245,y*48,buf,0);
        cross_fade(buf,buf2,buf,320*240,(tid<256)?tid:255);
        gfx_blit(buf);
        if(gfx_exitevent())
            cont=0;
    }
#ifdef DEBUG
    cont=1;
#endif

    /* Fade out */
    ver=mzx_ticks();
    while(mzx_position()<2000 && cont)
    {
        tid=mzx_ticks()-ver;
        memset(buf,0,320*240*sizeof(int));
        tex(120,110,5,255,buf);
        tmp=tid-100; if(tmp<1) tmp=1;
        if(tmp>110)
            memset(buf2,0,320*240*sizeof(int));
        else
            vert_maf(buf,buf2, 0,0,0,0, 320,240, 320,240, tmp);
        gfx_blit(buf2);
        if(gfx_exitevent())
            cont=0;
    }

    mzx_close();
    gfx_close();
    return(EXIT_SUCCESS);
}

void pallotko_init(unsigned *dest)
{
    int x,y;

    memset(dest,0,320*240*sizeof(int));
    for(y=0;y<240;y++)
        for(x=0;x<256;x++)
            dest[32+x+y*320]=dest[32+x+(y+240)*320]=
                             (kafka[x+y*256]<<16)+(kafka[x+y*256]/2<<8);
}

void blandis(unsigned *buf,int n)
{
    static unsigned    dest[320*240];
    int         y;

    pano_effect(buf,n);///48*20);
    horiz_maf(buf,dest, 0,0,0,0, 320,240, 320,240, fabs(sin(n/12.0))*20.0+1.0);
    venkula(n,buf,dest);
    lodju(0,0,buf,1);
}

void unzoomeri_init()
{
    int n;
    unsigned    tmp;

    suumi_init(320,240);
    venkula_init(500,180);
    for(n=0;n<256*256;n++)
    {
        if(picasso[n]==picasso[0])
            unz[n]=0xee8800;
        else
            unz[n]=picasso[n]*3/4<<16;
    }
}
void unzoomeri_taas(unsigned *buf,int n)
{
    static unsigned    tmp[320*240];
    
    suumi_effect(tmp,100000-n+80+60.0*sin(n/15.0),5.0,unz,unz,unz);
    venkula(n,buf,tmp);
    lodju(0,0,buf,1);
    lodju(245,24+16*sin(n/16.0),buf,0);
    lodju(245,96+16*sin(n/16.0+1.0),buf,0);
    lodju(245,168+16*sin(n/16.0+2.0),buf,0);
}

void tonko(unsigned *buf,int n)
{
    static unsigned    tausta[320*240];
    int x;

    pano_effect(buf,10000-n);
    memset(tausta,0,320*240*sizeof(unsigned));
    halftone(tausta,buf,255);
    horiz_maf(tausta,buf, 0,0,0,0, 320,240, 320,240, sin(n/10.0)*8.0+10.0);
    lodju(0,0,buf,1);
    for(x=12;x<250;x+=78)
        lodju(x,-10,buf,0);
}

void alku(unsigned *pbuf,int n)
{
    double  d;
    static unsigned    dest[320*240],
                nullum[320*240]={0};
    int tmp;

    pano_effect(pbuf,10000-n);
    d=sqrt(fabs(sin(n/40.0)));
    horiz_maf(pbuf,dest, 0,0,0,0, 320,240, 320,240, 41-d*40.0);
    cross_fade(dest,nullum,pbuf,320*240,240-150.0*fabs(sin(n/40.0+M_PI/2.0)));

    tex(125,114,0,(n<255)?n:255,pbuf);
    tmp=n-128; if(tmp<0) tmp=0;
    tex(65,114+24,1,(tmp<255)?tmp:255,pbuf);
}

void tee_tausta(unsigned *taus,unsigned *edus)
{
    int     x,y,of;

    for(y=0;y<PKOR;y++)
        for(x=0;x<PLEV;x++)
        {
            of=(x*2)%164+44;
            of+=((y*2+110)%256)*256;
            if(kafka[of]==kafka[0])
                taus[x+y*PLEV]=0xee8800;
            else
                taus[x+y*PLEV]=(kafka[of]*3/5)<<16;
            if(y>200)
                taus[x+y*PLEV]=0;
            if(y<73)
                taus[x+y*PLEV]=0xee8800;

            edus[x+y*PLEV]=kafka[x%256+y*256]<<16;
        }
}

void tex(int px,int py,int num,int brite,unsigned *buf)
{
    int x,y,of,p,n;
    unsigned char   *c;

    of=num*256*24;

    for(y=py;y<py+24;y++)
        for(x=px;x<px+256;x++,of++)
        {
            p=tekstit[of];
            if(p && x>=0 && x<320)
            {   
#ifdef BIG
                c=1+(unsigned char *)&buf[y*320+x];
#else
                c=(unsigned char *)&buf[y*320+x];
#endif
                p=p*brite/255;
                for(n=0;n<3;n++)
                {
                    c[n]=((255-p)*c[n])/255;
#ifdef BIG
                    c[n]+=(n==2)?p*2/3:p;
#else
                    c[n]+=(n==0)?p*2/3:p;
#endif
                }
            }
        }
}

void flar(unsigned *buf,int n)
{
    int y;

    memset(buf,0,320*240*sizeof(int));
    flarez(buf,n);

}

void lodju(int x,int y,unsigned *buf,int new)
{
    int m,n,of,cpy;
    static unsigned tmp[64*48];

    if(new)
    {
        for(m=0;m<48;m++)
            for(n=0;n<64;n++)
            {
                if(n==0 || n==63 || m==0 || m==47)
                    tmp[m*64+n]=0x885500;
                else
                    tmp[m*64+n]=(buf[m*320*5+n*5]>>1)&0x7f7f7f7f;
            }
    }
    else
    {
        if(x>320-64)
        {
            cpy=320-x;
            if(cpy<=0)
                return;
        }
        else
            cpy=64;

        if(x<0)
        {
            cpy=64+x;
            if(cpy<=0)
                return;
            of=64-cpy;
            x=0;
        }
        else
            of=0;

        for(m=0;m<48;m++)
            if(m+y>=0 && m+y<240)
                memcpy(&buf[320*(m+y)+x],&tmp[of+m*64],cpy*sizeof(int));
    }
}

int mzx_ticks(void)
{
    double  a;
    static long alaku=-1;
    struct timezone sone;
    struct timeval  aika;

    gettimeofday(&aika,&sone);

    if(alaku==-1)
    {
        alaku=aika.tv_sec;
        return(0);
    }
    
    a=(aika.tv_sec-alaku)*1000000.0;
    a+=aika.tv_usec;
    return((int)(0.5+a/(1000000.0/50.0)));
}
/* EOF */
