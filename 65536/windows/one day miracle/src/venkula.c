/*
    Venkulaosan toteutus. Luultavasti ja toivottavasti toimii ulkoisesta
    ympäristöstä välittämättä.
*/

#include <math.h>

#define XS 320
#define YS 240

//#define HULLUNRASKAS

extern unsigned char kafka[];

static int  reika[256*257],reagan[256*257],
            px[XS*YS],py[XS*YS],zeda[XS*YS];

void venkula_init(int param1,int param2)
{
    int tx,ty,z,x,y,rx,ry;

    for(y=0;y<256;y++)
        for(x=0;x<256;x++)
        {
            tx=x-128;
            ty=y-128;
    
            if(ty*ty+tx*tx>10000)
                reika[x+y*256]=0;
            else
                if(ty*ty+tx*tx>9700)
                    reika[x+y*256]=0xc0c0c0c0;
                else
                    reika[x+y*256]=0xffffffff;
    
            if(ty*ty+tx*tx<9000)
                reagan[x+y*256]=0;
            else
                if(ty*ty+tx*tx<9200)
                    reagan[x+y*256]=0;
                else
                    reagan[x+y*256]=1;
        }

    for(y=0;y<YS;y++)
        for(x=0;x<XS;x++)
        {
            tx=x-XS/2;
            ty=y-YS/2;

            zeda[x+y*XS]=z=param1-sqrt(100*(tx*tx+ty*ty));
            rx=tx*z/param2;
            ry=ty*z/param2;

            px[x+y*XS]=rx+512*10;
            py[x+y*XS]=ry+512*10;
        }
}

void venkula(int clock,int *buffer,int *bg)
{
    int plus,paikka,i,x,y,z,tmp;

#ifdef HULLUNRASKAS
    int rx,ry,tx,ty;
#endif

    plus=5000*sin(clock/600.0)+clock;
    paikka=100*cos(clock/22.1);

#ifdef HULLUNRASKAS
    for(y=0;y<YS;y++)
        for(x=0;x<XS;x++)
        {
            tx=x-XS/2;
            ty=y-YS/2;

            z=zeda[x+y*XS];
            rx=tx*z/(160+paikka);
            ry=ty*z/(160+paikka);

            px[x+y*XS]=rx+512*10;
            py[x+y*XS]=ry+512*10;
        }
#endif

    memcpy(buffer,bg,XS*YS*sizeof(int));

    for(y=i=0;y<YS;y++)
    {
        tmp=paikka*3;
        for(x=0;x<XS;x++,i++)
        {
            z=((plus+px[i])&0xff)+(((py[i]+tmp)&0xff)<<8);
            buffer[i]&=reika[z];
            if(buffer[XS*YS-i-1])
            {
                buffer[XS*YS-i-1]>>=reagan[z];
                if(reagan[z]==1)
                    buffer[XS*YS-i-1]&=0x7f7f7f;
                else
                    if(reagan[z]==2)
                        buffer[XS*YS-i-1]&=0x3f3f3f;
            }
        }
    }
}

void venkula_close()
{
}

/* EOF */

