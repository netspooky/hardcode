/*
    flareosa
*/

#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

#define min(x,y) ((x)<(y))?(x):(y)
#define max(x,y) ((x)>(y))?(x):(y)

void flarez(unsigned *,int);
void draw_flarex(unsigned *buf,int siz,int intx,int inty,unsigned col);

static unsigned char flare[256*256];
static unsigned kuda[320*240],buda[320*240];

extern unsigned	picasso[];
#define flared picasso

void init_flare()
{
	int	x,y,tmp;
	float	dist;
	unsigned col;

	memset(kuda,0,320*240*4);
	memset(buda,0,320*240*4);
	
	for(x=0; x<256; x++)
	    for(y=0; y<256; y++)
	    {
		dist=min(255,2*sqrt((x-128)*(x-128)+(y-128)*(y-128)));
		flare[x+y*256]=215*cos(3.1415/2*dist/256);
		col=(((unsigned)((unsigned char *)
			flared)[x+y*256])/3<<8)+0x5f0006;
		kuda[(x/2+96)+(y/2+56)*320]=col;
		buda[(int)(x/1.5+75)+(int)(y/1.5+35)*320]=col;
	    }	
}

void flarez(unsigned *buf,int phase)
{
    int count,n,siz,pase,base,
        intx,inty,
        x,y,x2,y2,klip;

    unsigned int    col,bol;

    double  vx,vy,vz;

    if(phase<64)
    {
	memcpy(buf,kuda,320*240*4);
	return;
    }

    if(phase<250)
	pase=0;
    else 
    	pase=max(0,min(500,phase-250))*2;

    base=max(0,min(250,phase-200));

    for(count=0;count<32*32;count++)
    {
        vz=300.0+200.0*sin(count/2.6+phase/48.0);
        vx=120.0*150.0*sin(count/2.7+phase/42.0);
        vy=120.0*150.0*cos(count/2.2+phase/43.0);

	// siz=32+31*sin(count/2.2+phase/50.0);
	siz=30*100/vz;
	// col=((550*count)<<8)|0xef0000;
	col=(((unsigned)((unsigned char *)flared)[count%32*8+(count/32*256*8)])
		/3<<8)+0x6f0006;
	
	vx=(pase*vx+(1000-pase)*((count%32-16)*2200+300*10))/1000;
	vy=(pase*vy+(1000-pase)*((count/32-16)*2200))/1000;
	vz=(pase*vz+(1000-pase)*400)/1000
		-(1+cos(2*3.1416*abs(125-base)/250))/2*150;	
	siz=30*100/vz;

        intx=vx/vz+160;
        inty=vy/vz+120;

	// x=(pase*intx+(1000-pase)*(count%32*(240/32)+55))/1000;
	// y=(pase*inty+(1000-pase)*(count/32*(240/32)))/1000;
	siz=((pase)*siz+(1000-pase)*siz*2)/1000;

	draw_flarex(buf,siz,intx,inty,col);
    }
 
    if(phase<128)	
	cross_fade(kuda,buda,buf,320*240,(phase-64)*4);
    else if(phase<256)
	cross_fade(buda,buf,buf,320*240,phase*2-255);
    else if(phase>500 && phase<628)
	cross_fade(buda,buf,buf,320*240,abs(phase-564)*4);
    
}

void draw_flarex(unsigned *buf,int siz,int intx,int inty,unsigned col)
{
    	int n,x,y,x2,y2;

    	unsigned int    xs,klip;

    	unsigned char   *ptr,
                    	*shapester;

	intx-=siz/2;
	inty-=siz/2;

	xs=65536/siz;
        for(y=0;y<siz;y++)
        {	    
            if(inty+y<0)
                continue;
            if(inty+y>239)
                break;

	    y2=y*xs>>8;
	    // y2=y*256/siz;
            for(x=0;x<siz;x++)
            {
		if(intx+x<0)
	            continue;
            	if(intx+x>319)
                    break;		

                x2=x*xs>>8;
		// x2=x*256/siz;
		ptr=&buf[intx+x+(inty+y)*320];
                shapester=&flare[y2*256+x2];

                for(n=0;n<4;n++)
                {
                    klip=((unsigned)ptr[n])+((unsigned)(shapester[0])*
			((unsigned char *)&col)[n]>>8);
                    if(klip>255)
                        klip=255;
                    ptr[n]=klip;
                }
            }
        }
}

/* EOS */
