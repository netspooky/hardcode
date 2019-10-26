#pragma pack(1)

#include <conio.h>
#include <stdio.h>
#include <stdlib.h>


void vgamode(char m);
#pragma aux vgamode parm [ax] modify [ax] = "xor ah,ah" "int 10h"

static void setpal (char n, char r, char g, char b)
{
    outp(0x3c8,n);
    outp(0x3c9,r);
    outp(0x3c9,g);
    outp(0x3c9,b);
}

static char *vgamem = (char *)0xa0000;


static void putp (int x, int y, char c)
{
    if (x>=0 && x<320 && y>=0 && y<200)
      vgamem[320*y+x]=c;
}


static void vline (int x, int y1, int y2, char c)
{
    if (y2<y1) { int h=y1; y2=y2; y2=h; };
    for (int yy=y1; yy<=y2; yy++)
      putp(x,yy,c);
}


#include "osc.hpp"

typedef struct {
  char p0,v0,v1,l;
} splseg;



static float spline(float p0, float p1, float p2, float p3, float x)
{
  register float x2=x*x;
  register float x3=x2*x;
  return p0*(-4.5*x3+9*x2-5.5*x+1)+
         p1*(13.5*x3-22.5*x2+9*x)+
         p2*(-13.5*x3+18*x2-4.5*x)+
         p3*(4.5*x3-4.5*x2+x);
}


void main()
{
    FILE *inf;
    int i;

		setbuf(stdout,0);

    vgamode(0x13);

    inf=fopen("ms2000.raw","rb");

    fseek(inf,0,SEEK_END);
    int l=ftell(inf)/2;
    fseek(inf,0,SEEK_SET);

    short *smpl = new short [l];
    fread(smpl,2,l,inf);
    fclose(inf);

    float *fs = new float[l];
    for (i=0; i<l; i++) fs[i]=smpl[i]/32768.0;

    // display sample
    int miny=0;
    int maxy=0;
    for (i=0; i<320; i++)
    {
        int hh=miny; miny=maxy; maxy=hh;
        for (int pp=i*l/320; pp<(i+1)*l/320; pp++)
        {
            if (smpl[pp]<miny) miny=smpl[pp];
            if (smpl[pp]>maxy) maxy=smpl[pp];
        }
        vline(i,miny*32/32768+56,maxy*32/32768+56,10);
        putp(i,56,15);
    }


//<ryg>         dw      90, 130, 190, 280, 410, 610, 900
//<ryg>         dw      1340, 1950, 2800, 4100, 6070, 15000


    // init oscillators
    Osc *band[8];
    band[0]=new Osc(90,0);
    band[1]=new Osc(190,0);
    band[2]=new Osc(410,0);
    band[3]=new Osc(900,0);
    band[4]=new Osc(1950,0);
    band[5]=new Osc(4100,0);
    band[6]=new Osc(6070,0);
    band[7]=new Osc(10000,1);


    float *vals[8];

    #define FRLEN 100
    int frames=(l/FRLEN)+!!(l%FRLEN);

    printf("frames: %d\n",frames);

    for (i=0; i<8; i++)
      vals[i]=new float[frames];

    float amp[8]={1,1,1,1,1,1,1,0.5};

    // analyze
    for (i=0; i<frames; i++)
        for (int bb=0; bb<8; bb++)
        {
            float bv=0,mbv=0;
            for (int ss=i*FRLEN; ss<(i+1)*FRLEN; ss++)
            {
                bv+=band[bb]->tick((ss>=l)?0:fs[ss]);
                if (bv>mbv) mbv=bv;
            }
            bv/=FRLEN;
            mbv=bv;
            mbv*=2.5;
            vals[bb][i]=mbv;
//            if (mbv>amp[bb]) amp[bb]=mbv;
        }

		for (i=0; i<frames; i++)
        for (int bb=0; bb<8; bb++)
        {
						//vals[bb][i]/=amp[bb];
            putp(i*320/frames,199-100*vals[bb][i],bb+1);
						putp(i*320/frames,100,8);
				}

		FILE *of;
    of = fopen("ms2000.pv2","wb");

		int	rfrlen=FRLEN; // oversampling?
		fwrite (&rfrlen,4,1,of);

    // pack the muthafuckin' splines

    splseg *sp=new splseg[(frames+2)/3];
    int    act0, act1;
    float  p0,p1,p2,p3;
    float  c1,c2,ge;
    int    gf, segc, gseg=0;
    int    bb;
    for (bb=0; bb<8; bb++)
    {
      act0=0;
      gf=0;
      segc=0;
      while (act0<frames)
      {
        p0=vals[bb][act0];
        act1=act0+1;
        do {
          act1+=2;
          // determine spline points
          if (act1>frames) act1=frames;
          p3=act1<frames?vals[bb][act1]:0;
          int tp=(act1-act0-1)/2;
          c1=c2=0;
          for (i=act0+1;i<=act0+tp;i++)
            c1+=vals[bb][i];
          c1/=tp;
          for (i=act0+tp+1;i<act1;i++)
            c2+=vals[bb][i];
          c2/=tp;
          // calculate error
          float e=0;
          for (i=1; i<(act1-act0); i++)
            e+=fabs((spline(p0,c1,c2,p3,(float)i/(float)(act1-act0))/vals[bb][act0+i])-1);
//            e+=fabs((spline(p0,c1,c2,p3,(float)i/(float)(act1-act0))-vals[bb][act0+i]));

          //printf("from %d to %d: error %f\n",act0,act1,e);


          e/=(act1-act0);
          gf=(e<0.2 && act1<frames && (act1-act0)<256 );
          if (gf) {p1=c1; p2=c2; ge=e;}
        } while (gf);
        act1-=2;
        p3=act1<frames?vals[bb][act1]:0;

				splseg &ss=sp[segc];
				if (p0<0) p0=0; else if (p0>255) p0=255;
				if (p1<0) p1=0; else if (p1>255) p1=255;
				if (p2<0) p2=0; else if (p2>255) p2=255;
				ss.p0=255*p0;
				ss.v0=255*p1;
				ss.v1=255*p2;
				ss.l=act1-act0;

				segc++;
        if (act0==act1) break;

        for (i=0; i<(act1-act0); i++)
          putp((i+act0)*320/frames,199-100*spline(p0,p1,p2,p3,(float)i/(act1-act0)),bb+9);


        //putp(act0,199-150*spline(p0,p1,p2,p3,0),bb+9);
        //putp(act0+(act1-act0)/3,199-150*spline(p0,p1,p2,p3,0.333),13);
        //putp(act0+2*(act1-act0)/3,199-150*spline(p0,p1,p2,p3,0.666),13);
        act0=act1;
      }
      printf("%d ",segc);

      int bscale=65500*amp[bb];
			fwrite(&segc,2,1,of);
			fwrite(&bscale,2,1,of);
			fwrite(sp,sizeof(splseg),segc,of);

      gseg+=segc;
    }
    printf(", total %d\n",gseg);

    // save it

		fclose(of);

    getch();

    delete smpl;
    delete fs;

    vgamode(3);

}
