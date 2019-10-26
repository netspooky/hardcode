//3703

#define _GNU_SOURCE

#pragma warning (disable: 4244)

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "tinyptc.h"
#include "minifmod.h"

#define WIN32_LEAN_AND_MEAN
#include "windows.h"
#include "mmsystem.h"

float con, bri;
int rando;
int stopnow=0;
float cube(float a) { return a*a*a; }

unsigned long realframebuffer[320*240]={0};
unsigned long rfbbla=0;


__inline static float inoise(int x, int y, int z) {
  int a=x*453415497+y*692345763^z*473546769;
  int b=y*213452313+z*685246969^x*743457661;
  int c=z*915876951+x*456766761^y*421345463;
  int d=a*584278733+b*543588311^c*943566311;
  return (d>>10&65535)*(1/65536.0f);
}

static __inline float noise(float x, float y, float z) {
  int xi=(int)floor(x), yi=(int)floor(y), zi=(int)floor(z);
  float n000=inoise(xi, yi, zi);
  float n001=inoise(xi, yi, zi+1);
  float n010=inoise(xi, yi+1, zi);
  float n011=inoise(xi, yi+1, zi+1);
  float n100=inoise(xi+1, yi, zi);
  float n101=inoise(xi+1, yi, zi+1);
  float n110=inoise(xi+1, yi+1, zi);
  float n111=inoise(xi+1, yi+1, zi+1);
  float xf=x-xi, yf=y-yi, zf=z-zi, xg, yg, zg;
  xf=(3-2*xf)*xf*xf; yf=(3-2*yf)*yf*yf; zf=(3-2*zf)*zf*zf;
  xg=1-xf; yg=1-yf; zg=1-zf;
  return ((n000*zg+n001*zf)*yg+(n010*zg+n011*zf)*yf)*xg+
    ((n100*zg+n101*zf)*yg+(n110*zg+n111*zf)*yf)*xf;
}

__inline static float noise2(float x, float y, float z) {
  float v=(noise(x, y, z)+noise(x+100.5f, z+100.5f, y+100.5f))*.5f;
  return (3-2*v)*v*v;
}

void line(unsigned char *b, int p, int x0, int y0, int x1, int y1, int c) {
  int x, y, xd=x1-x0, yd=y1-y0;
  int xmin=x0<x1?x0:x1, ymin=y0<y1?y0:y1, xmax=x0>x1?x0:x1, ymax=y0>y1?y0:y1;
  if (xmax-xmin>ymax-ymin) {
    for (x=xmin; x<xmax; x++) {
      y=(x-x0)*yd/xd+y0;
      b[y*p+x]=c;
    }  
  } else {
    for (y=ymin; y<ymax; y++) {
      x=(y-y0)*xd/yd+x0;
      b[y*p+x]=c;
    }  
  }  
}



#include "vox.c"
#include "sumu.c"



__inline static void rotate2(float *u, float *v, float a) {
  float sa=sin(a), ca=cos(a), tmp=*u*ca-*v*sa;
  *v=*u*sa+*v*ca; *u=tmp;
}




typedef struct {
  float x, y, z, s;
} Dot;
Dot dots[32768];
static void prekalc_clouds() {
  Dot *d;
  for (d=dots; d<dots+32768; d++) {
    do {
      d->x=(myrand()-myrand())*(5./MYRAND_MAX);
      d->y=(myrand()-myrand())*(5./MYRAND_MAX);
      d->z=(myrand()-myrand())*(5./MYRAND_MAX);
    } while (noise(d->x, d->y, d->z)>.2);
  }
}
void draw_dots() {
}



void foofoo(unsigned char *foo, int eenie, int bar, int baz, int mou) {
  if (bar>3 && baz>3) {
    int ron, jack, narf=bar>>1, zort=baz/2;
    unsigned char *dick=malloc(narf*zort);
    for (jack=0; jack<zort; jack++) {
      for (ron=0; ron<narf; ron++) dick[jack*narf+ron]=foo[jack*2*eenie+ron*2];
    }
    foofoo(dick, narf, narf, zort, mou);
    for (jack=0; jack<zort; jack++) {
      for (ron=0; ron<narf; ron++) foo[jack*2*eenie+ron*2]=dick[jack*narf+ron];
      for (ron=0; ron<narf-1; ron++) foo[jack*2*eenie+ron*2+1]=(dick[jack*narf+ron]+dick[jack*narf+ron+1])>>1;
    }
    for (jack=0; jack<zort-1; jack++) {
      for (ron=0; ron<narf; ron++) foo[(jack*2+1)*eenie+ron*2]=(dick[jack*narf+ron]+dick[(jack+1)*narf+ron])>>1;
      for (ron=0; ron<narf-1; ron++) foo[(jack*2+1)*eenie+ron*2+1]=(dick[jack*narf+ron]+dick[jack*narf+ron+1]+dick[(jack+1)*narf+ron]+dick[(jack+1)*narf+ron+1])*mou+foo[(jack*2+1)*eenie+ron*2+1]*4*(256-mou)+512>>10;
    }
    
  }
}

void glaah(unsigned char *buf, int pitch, int w, int h, int mou) {
  if (w>3 && h>3) {
    int x, y, hw=w>>1, hh=h/2;
    unsigned char *buf2=malloc(hw*hh);
    for (y=0; y<hh; y++) {
      for (x=0; x<hw; x++) buf2[y*hw+x]=buf[y*2*pitch+x*2];
    }
    glaah(buf2, hw, hw, hh, mou);
    for (y=0; y<h; y++) {
      int v,u;
			unsigned char *ptr;
      v=(y-hh)*96-(0-hw)*32+hh*128;
      u=(y-hh)*32+(0-hw)*96+hw*128;
      for (x=0; x<w; x++) {
				if (v<0) v+=hh<<8;
				else if (v>=(hh<<8)) v-=hh<<8;
				if (u<0) u+=hw<<8;
				else if (u>=(hw<<8)) u-=hw<<8;
        ptr=buf2+(v>>8)*hw+(u>>8);
        buf[y*pitch+x]=buf[y*pitch+x]*mou
           +((ptr[0]*(256-(v&255))
					 +ptr[1]*(v&255))*(256-(u&255))
           +(ptr[hw]*(256-(v&255))+
					 buf[y*pitch+x]*(v&255))*(u&255)+32768>>16)*(256-mou)+128>>8;
        v-=32; u+=96;
      }
    }
    free(buf2);
  }
}


typedef struct Blk {
  int xr, yr, tr;
  unsigned char *data;
  struct Blk *next;
} Blk;

typedef struct {
  int xcnt, ycnt, tcnt, tot;
  Blk *root;
  Blk **data;
} Movie;



Movie *readmovie(unsigned char *datah) {
  unsigned char pakres;
  Movie *m=malloc(sizeof(Movie));
  Blk **nxt=&m->root;
  m->xcnt=320/16; m->ycnt=240/16; m->tcnt=4; m->tot=0;
  do {
    Blk *b;
    if ((pakres=*datah++)==255) break;
    b=malloc(sizeof(Blk)); b->tr=pakres/36%7; b->yr=pakres/6%6; b->xr=pakres%6;
    b->data=malloc(1<<b->xr+b->yr+b->tr);
    memcpy(b->data, datah, 1<<b->xr+b->yr+b->tr);
    datah+=1<<b->xr+b->yr+b->tr;
    b->next=0; 
    *nxt=b; nxt=&b->next;
    m->tot++;
  } while (1+1!=3);
  { 
    int i; 
    Blk *b=m->root;
    m->data=malloc(sizeof(Blk*)*m->tot);
    for (i=0; i<m->tot; i++) { if (!b) exit(1); m->data[i]=b, b=b->next; }
  }
  return m;
}

static void drawblk(unsigned char *buf, int pitch, Blk *b, int xs, int ys, int fno) {
  unsigned char *kuv=b->data+(fno<<b->tr>>12<<b->xr+b->yr);
  int xsi=(256<<b->xr)/xs, ysi=(256<<b->yr)/ys, x, y;
  for (y=0; y<ys; y++) {
    for (x=0; x<xs; x++) *buf++=kuv[(y*ysi>>8<<b->xr)+(x*xsi>>8)];
    buf+=pitch-xs;
  }
}

static void getframe(unsigned char *buf, int pitch, Movie *m, int xs, int ys, int fno) {
  Blk **b0=m->data+(((fno>>12)%m->tcnt+m->tcnt)%m->tcnt)*m->ycnt*m->xcnt;
  int xk=xs/m->xcnt, yk=ys/m->ycnt, x, y;
  for (y=0; y<m->ycnt; y++) for (x=0; x<m->xcnt; x++)
	  drawblk(buf+y*yk*pitch+x*xk, pitch, b0[y*m->xcnt+x], xk, yk, fno&4095);
}

static void duunaa_sumu(unsigned char *buf, int pitch, int xs, int ys, float t) {
  short buf2[320*240], *s;
  int x, y;
  unsigned char tab[1024];
  unsigned char *d;
  teesumu(buf2, t);
  for (x=0; x<1024; x++) tab[x]=sqrt(x*63.9);
  for (y=0; y<240; y++) {
    d=buf+y*pitch;
    s=buf2+y*160;
    for (x=0; x<160; x++, s++) {
      int c=*s>>4;
      if (c>1023) c=1023;
      c=tab[c]*0x0101;
      *(short*)d=c; d+=2;
    }
  }
}

void duunaa_kirkkovene(unsigned char *dbuf, unsigned char *sbuf, int pitch, int xs, int ys, float c, float b, float g, float frob, float borf) {
  unsigned static char tab[256];
  unsigned char *dp, *sp;
  int x, y, i, j;
  float f;
  for (i=0; i<256; i++) {
    f=pow((i/256.)*c+b, g);
    f=f+sin(f*frob)*borf;
    j=floor(f*256+.5f);
    tab[i]=j<0?0:j>255?255:j;
  }
  for (y=0; y<ys; y++) {
    dp=dbuf+y*pitch;
    sp=sbuf+y*pitch;
    for (x=0; x<xs; x+=4) {
      *dp++=tab[*sp++]; *dp++=tab[*sp++]; *dp++=tab[*sp++]; *dp++=tab[*sp++];
    }
  }
}

extern unsigned char musadata[];
int fakeoff=0, fakesize=56366;

unsigned int fakeopen(char *name) { return 31337; }
void fakeclose (unsigned int hndl) {}
int fakeseek(unsigned int hndl, int offset, signed char whence) { fakeoff=(whence==SEEK_SET?0:whence==SEEK_CUR?fakeoff:fakesize)+offset; return 0; }
long faketell(unsigned int hndl) { return fakeoff; }
int fakeread(void *dest, int length, unsigned int hndl) { memcpy(dest, musadata+fakeoff, length); fakeoff+=length; return length; }



static Tso tsot[10];
Movie *mov;

#include "desing.c"


__inline int rajo807f(int x) { return x<-128?-128:x>127?127:x; }

typedef struct{
  unsigned long pitches[3];
	unsigned char *pixels[3];
} FakeOverlay;

FakeOverlay fovl={{320,160,160},{0}};
FakeOverlay *ovl=&fovl;

unsigned long rgb2pix[3*768];
int colortab[4*256];



void IYUV2RGB()
{

    unsigned long* row1=realframebuffer;
    unsigned long* row2=row1+320;
		unsigned char* lum1=fovl.pixels[0];
    unsigned char* lum2=lum1+320;
		unsigned char* cr=fovl.pixels[2];
		unsigned char* cb=fovl.pixels[1];
    int x, y;
    int cr_r;
    int crb_g;
    int cb_b;

    for( y=0; y<120; y++ )
    {
      for ( x=0; x<160; x++)
      {
         register int L;
         cr_r   = 0*768+256 + colortab[ *cr + 0*256 ];
         crb_g  = 1*768+256 + colortab[ *cr + 1*256 ]
                            + colortab[ *cb + 2*256 ];
         cb_b   = 2*768+256 + colortab[ *cb + 3*256 ];
            ++cr; ++cb;

            L = *lum1++;
            *row1++ = (rgb2pix[ L + cr_r ] |
                       rgb2pix[ L + crb_g ] |
                       rgb2pix[ L + cb_b ]);

            L = *lum1++;
            *row1++ = (rgb2pix[ L + cr_r ] |
                       rgb2pix[ L + crb_g ] |
                       rgb2pix[ L + cb_b ]);



            L = *lum2++;
            *row2++ = (rgb2pix[ L + cr_r ] |
                       rgb2pix[ L + crb_g ] |
                       rgb2pix[ L + cb_b ]);

            L = *lum2++;
            *row2++ = (rgb2pix[ L + cr_r ] |
                       rgb2pix[ L + crb_g ] |
                       rgb2pix[ L + cb_b ]);
        }

        lum1 += 320;
        lum2 += 320;
        row1 += 320;
        row2 += 320;
    }
}


int __cdecl main() {
  int i, j;
  float t;
  float numbs[16384];
  static unsigned char buffer[200000];
  static unsigned char U[160*120], V[160*120];
  unsigned time0, timex;
	int *Cr_r_tab = &colortab[0*256];
	int *Cr_g_tab = &colortab[1*256];
	int *Cb_g_tab = &colortab[2*256];
	int *Cb_b_tab = &colortab[3*256];

	static int flipflop=0;

//  int effu=argc>1?atoi(argv[1]):0;
	const int effu=0;
 
	FMUSIC_MODULE *mod;

  if (!ptc_open("Fortnight (Win32)",320,240))
    return 1;

  for (i=0; i<8; i++)
		realframebuffer[320*i+116*320+30]=realframebuffer[320*i+117*320-30]=0xffffff;

	ptc_update(realframebuffer);

	ovl->pixels[0]=malloc(320*240);
	ovl->pixels[1]=malloc(160*120);
	ovl->pixels[2]=malloc(160*120);

	// precalc YUV tables
	for (i=0; i<256; i++)
	{
		int CR,CB;
		rgb2pix[i+0*768+256]=i<<16;
		rgb2pix[i+1*768+256]=i<<8;
		rgb2pix[i+2*768+256]=i;
		CB = CR = (i-128);
	  colortab[i+0*256] = (int) ( (0.419/0.299) * CR);
		colortab[i+1*256] = (int) (-(0.299/0.419) * CR);
		colortab[i+2*256] = (int) (-(0.114/0.331) * CB);
		colortab[i+3*256] = (int) ( (0.587/0.331) * CB);
	}
	for (i=0; i<256; i++)
	{
		rgb2pix[i+0*768]=rgb2pix[0*768+256];
		rgb2pix[i+1*768]=rgb2pix[1*768+256];
		rgb2pix[i+2*768]=rgb2pix[2*768+256];
		rgb2pix[i+0*768+512]=rgb2pix[0*768+256+255];
		rgb2pix[i+1*768+512]=rgb2pix[1*768+256+255];
		rgb2pix[i+2*768+512]=rgb2pix[2*768+256+255];
	}




  {
    extern unsigned char videodata[];
    mov=readmovie(videodata);
  }
  
	// FAKE: i don't like demos that get more colorful if the PC had run longer :)


	rando=126582;


  for (i=0; i<16384; i++) numbs[i]=1+(myrand()*(1./MYRAND_MAX));

  t=0;

  fprintf(stderr, "d5\n");

  
	FSOUND_File_SetCallbacks(fakeopen, fakeclose, fakeread, fakeseek, faketell);

	if (!FSOUND_Init(44100, 0))
	{
		fprintf(stderr,"fmod init error\n");
		return 1;
	}

	// ==========================================================================================
	// LOAD SONG
	// ==========================================================================================
	mod = FMUSIC_LoadSong(0, 0);
	if (!mod)
	{
		printf("fmod load err\n");
		return 1;
	}


  fprintf(stderr, "d5\n");
  {
    int x, y;
    float a, b;
    float f=rando*(2*3.141592653589793238462648336675485856345634564*1048576/3600./24./365.24)-.3;
    float k=cos(f);
    float s=cos(f+2);
    float n=.03*exp(sin(f)*sin(f)*.5);
    for (y=0; y<120; y++) for (x=0; x<160; x++) {
      a=x*.02+sin(y*.03); b=y*.02+sin(x*.03);
      
      U[y*160+x]=rajo807f((noise2(x*n, y*n, 0)-.5)*160.5+96*k);
      V[y*160+x]=rajo807f((noise2(x*n, y*n, 3)-.5)*191.5+48*s);
    }
  }
  for (j=0; j<5; j++) {
    for (i=0; i<256; i++) tsot[j].map[i]=-1+2*(.5-.5*cos(((i+128&255)-128)*.2))+.5*sin(((i+128&255)-128)*.05);//-.2;
  }

  for (i=0; i<256; i++) tsot[3].map[i]=sin(((i+128&255)-128)*.5)*.05;
  for (i=0; i<256; i++) tsot[4].map[i]=sin(((i+128&255)-128)*.5)*.05;

	rando=(GetTickCount()>>10);


  presumu();
  desing_precalc();
  fprintf(stderr, "d5\n");
  time0=timeGetTime();

	FMUSIC_PlaySong(mod);


  
  while (!stopnow) {
    float aikaero=.02f;
    timex=timeGetTime()-time0;

    j=myrand();

    { 
      int x, y;
      unsigned char *p0, *p1;
      signed char *p3;
      for (y=0; y<120; y++) {
        for (p0=ovl->pixels[0]+y*640, p1=ovl->pixels[1+flipflop]+y*160, p3=(flipflop?V:U)+y*160, x=0; 
				     x<160; 
				     x+=4, p0+=8, p1+=4, p3+=4) {
          p1[0]=((p1[0]-128)*28*128+p3[0]*2*p0[0]+512>>12)+128;
          p1[1]=((p1[1]-128)*28*128+p3[1]*2*p0[1]+512>>12)+128;
          p1[2]=((p1[2]-128)*28*128+p3[2]*2*p0[2]+512>>12)+128;
          p1[3]=((p1[3]-128)*28*128+p3[3]*2*p0[3]+512>>12)+128;
        }
      }
      flipflop^=1;
    }
    
    {
      t=timex*0.0001; 
      tsot[0].xk=.3f/64.; tsot[0].yk=0; tsot[0].zk=0; tsot[0].d=0;
      tsot[1].xk=0; tsot[1].yk=.3f/64.; tsot[1].zk=0; tsot[1].d=0;
      tsot[2].xk=0; tsot[2].yk=0; tsot[2].zk=.3f/64.; tsot[2].d=t*80;

      tsot[3].xk=-1.9f/64.f; tsot[3].yk=-1.9f/64.f; tsot[3].zk=0; tsot[3].d=50/64.;
      tsot[4].xk=-1.9f/64.f; tsot[4].yk= 1.9f/64.f; tsot[4].zk=0; tsot[4].d=50/64.;
      for (i=0; i<5; i++) {
        rotate2(&tsot[i].xk, &tsot[i].yk, t*numbs[0]);
        rotate2(&tsot[i].yk, &tsot[i].zk, t*numbs[1]);
        rotate2(&tsot[i].zk, &tsot[i].xk, t*numbs[2]);
        rotate2(&tsot[i].xk, &tsot[i].yk, t*numbs[3]);
        rotate2(&tsot[i].yk, &tsot[i].zk, t*numbs[4]);
      }
    }
    gounter=0; 
    if (!effu) desing(ovl->pixels[0], ovl->pitches[0], 320, 240, /*module->sngpos+fmod(*/timex*(1./1000/60*125/16*6/6.5)/*, 1)*/);
    if (effu&1) rend(ovl->pixels[0], ovl->pitches[0], 320, 224, tsot, 5);
    if (effu&2) getframe(ovl->pixels[0], ovl->pitches[0], mov, 320, 240, timex*8);
    if (effu&4) {
      short buf[320*240], *s;
      int x, y;
      unsigned char tab[1024];
      unsigned char *d;
      teesumu(buf, timex*.03);
      for (x=0; x<1024; x++) tab[x]=sqrt(x*63.9);
      for (y=0; y<360; y++) {
        d=ovl->pixels[0]+y*ovl->pitches[0];
        s=buf+(y>>1)*160;
        for (x=0; x<160; x++, s++) {
          int c=*s>>4;
          if (c>1023) c=1023;
          c=tab[c]*0x01010101;
          *(int*)d=c; d+=4;
        }
      }
    }
    if (effu&8) foofoo(ovl->pixels[0], ovl->pitches[0], 320, 240, 128);

		IYUV2RGB();
    ptc_update(realframebuffer);


    //SDL_UnlockYUVOverlay(ovl);

/*
    rectum.x=0; rectum.y=0; rectum.w=640; rectum.h=480;
    SDL_DisplayYUVOverlay(ovl, &rectum);
		*/
  }

  //SDL_CloseAudio();

	FMUSIC_FreeSong(mod);
	FSOUND_Close();


	ptc_close();

  return 0;
}








