/*
    Halftonee nin birusti
*/

#include <math.h>

#define SIZEE 7
#define HDIST 6
#define VDIST 5
#define SAMPL 2

static unsigned int dist[SIZEE][SIZEE];
static int yk,xk;

void halftone_init(int xs,int ys)
{
    int x,y,dx,dy,tmp=SIZEE/2;
    double d;

    yk=ys;
    xk=xs;
    for(y=0;y<SIZEE;y++)
        for(x=0;x<SIZEE;x++)
        {
            dx=x-SIZEE/2;
            dy=y-SIZEE/2;
            d=sqrt(dx*dx+dy*dy);
            if(d>SIZEE/2+0.5)
                dist[y][x]=-1;
            else
            {
                dist[y][x]=(int)((d+0.25)/tmp*256.0);
                //if(dist[y][x]==0)
                //    dist[y][x]=(256/SIZEE)/2;
            }
        }
}

void halftone(unsigned *dest,unsigned *src,int inten)
{
    int x,y,px,py,rx,ry,d,n,c,samples,
        vuaro=0,ver=256/(SIZEE/2),tau[256];
    unsigned char cp[3],*dp,varm[256];
    unsigned tmp[3];

    for(n=0;n<256;n++)
        tau[n]=(ver-n)*256/ver;
    for(n=0;n<256;n++)
    {
        if(n*inten/255>255)
            varm[n]=255;
        else
            varm[n]=n*inten/255;
    }

    for(y=0;y<yk;y+=VDIST)
    {
        for(x=vuaro*HDIST/2;x<xk;x+=HDIST)
        {
            samples=0;
            tmp[0]=tmp[1]=tmp[2]=0;
            for(py=0;py<SAMPL;py++)
            {
                ry=y+(SIZEE/SAMPL)*py-SIZEE/2;
                if(ry<0) continue;
                if(ry>=yk) break;
                for(px=0;px<SAMPL;px++)
                {
                    rx=x+(SIZEE/SAMPL)*px-SIZEE/2;
                    if(rx<0) continue;
                    if(rx>=xk) break;
                    dp=(unsigned char *)&src[ry*xk+rx];
                    tmp[0]+=dp[0];
                    tmp[1]+=dp[1];
                    tmp[2]+=dp[2];
                    samples++;
                }
            }

            cp[0]=tmp[0]/samples;
            cp[1]=tmp[1]/samples;
            cp[2]=tmp[2]/samples;

            for(py=0;py<SIZEE;py++)
            {
                ry=py+y-SIZEE/2;
                if(ry<0) continue;
                if(ry>=yk) break;

                for(px=0;px<SIZEE;px++)
                {
                    rx=px+x-SIZEE/2;
                    if(rx<0) continue;
                    if(rx>=xk) break;

                    if((d=dist[py][px])!=-1)
                    {
                        dp=(unsigned char *)&dest[ry*xk+rx];
                        for(n=0;n<3;n++)
                        {
                            c=varm[cp[n]];
                            if(d<c && c>SIZEE/2)
                                dp[n]=255;
                            else
                            {
                                if(d<c+ver && c>SIZEE/2)
                                {
                                    c=tau[d-c];
                                    if(dp[n]+c<256)
                                        dp[n]+=c;
                                    else
                                        dp[n]=255;
                                }
                            }
                        }
                    }
                }
            }
        }
        vuaro=1-vuaro;
    }
}
