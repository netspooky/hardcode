#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <math.h>

//<ryg>         dw      90, 130, 190, 280, 410, 610, 900
//<ryg>         dw      1340, 1950, 2800, 4100, 6070, 15000

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

typedef struct {
   float l1,b1,h1,l2,b2,h2,r,f;  
} filter;

void main()
{
    FILE *inf;
    int i;
    vgamode(0x13);

    inf=fopen("real.pvd","rb");
    long pvdtag,frames,frlen;
    fread(&pvdtag,4,1,inf);
    fread(&frames,4,1,inf);
    fread(&frlen,4,1,inf);

    char *vdat = new char[8*frames];
    fread(vdat,8,frames,inf);
    fclose(inf);

    short *smpl= new short [(frames-1)*frlen];

    int bb,s;

//<ryg>         dw      90, 130, 190, 280, 410, 610, 900
//<ryg>         dw      1340, 1950, 2800, 4100, 6070, 15000

    filter flt[8]={{0,0,0,0,0,0,0,0}};
    flt[0].f=90.0/11025.0;
    flt[1].f=190.0/11025.0;
    flt[2].f=410.0/11025.0;
    flt[3].f=900.0/11025.0;
    flt[4].f=1950.0/11025.0;
    flt[5].f=4100.0/11025.0;
    flt[6].f=6070.0/11025.0;
    flt[7].f=10000.0/11025.0;

    float spos1=0,sfrq1=101.0/44100.0;
    float spos2=0,sfrq2=99.0/44100.0;
    float spos3=0,sfrq3=50.00/44100.0;


    for (int fr=0; fr<frames-1; fr++)
    {
      float vals[8];
      float ramp[8];
      for (bb=0; bb<8; bb++)
      {
        vals[bb]=vdat[frames*bb+fr];
        ramp[bb]=(vdat[frames*bb+fr+1]-vals[bb])/frlen;
        //printf("%f\n",vals[0]);
      }
      // ok, start the show
      for (s=0; s<frlen; s++)
      {
        float sv=0;

        float nseout=(spos1+spos2+spos3)-1;
        spos1+=sfrq1; while (spos1>=1) spos1-=1;
        spos2+=sfrq2; while (spos2>=1) spos2-=1;
        spos3+=sfrq3; while (spos3>=1) spos3-=1;

        //float nseout=((rand()&0xff)-128)/128.0;
        for (bb=0; bb<8; bb++)
        {
          filter &f=flt[bb];
          f.h1=nseout-f.b1-f.l1;
          f.b1+=f.f*f.h1;
          f.l1+=f.f*f.b1;
          f.h2=f.h1-f.b2-f.l2;
          f.b2+=f.f*f.h2;
          f.l2+=f.f*f.b2;
          sv+=vals[bb]*(bb==7?f.h2/16:f.l2);
          vals[bb]+=ramp[bb];
        }
        sv*=200;
        if (sv<-32768) sv=-32768;
        if (sv>32767) sv=32767;
        smpl[frlen*fr+s]=sv;
      }
    }

    FILE *outf = fopen("ficken.raw","wb");
    fwrite(smpl,frlen*(frames-1),2,outf);
    fclose(outf);

    getch();
    delete smpl;
    delete vdat;
    vgamode(3);
    
}


