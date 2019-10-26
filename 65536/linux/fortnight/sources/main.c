//3703
#define _GNU_SOURCE
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "signal.h"
#include <SDL/SDL.h>
#include <mikmod.h>
#include <math.h>


float con, bri;
int rando;
int stopnow=0;
float cube(float a) { return a*a*a; }

static inline float inoise(int x, int y, int z) {
  int a=x*453415497+y*692345763^z*473546769;
  int b=y*213452313+z*685246969^x*743457661;
  int c=z*915876951+x*456766761^y*421345463;
  int d=a*584278733+b*543588311^c*943566311;
  return (d>>10&65535)*(1/65536.);
}
static inline float noise(float x, float y, float z) {
  int xi=lrint(x-.5), yi=lrint(y-.5), zi=lrint(z-.5);
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
static inline float noise2(float x, float y, float z) {
  float v=(noise(x, y, z)+noise(x+100.5, z+100.5, y+100.5))*.5;
  return (3-2*v)*v*v;
}
void line(char *b, int p, int x0, int y0, int x1, int y1, int c) {
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
#include "demoo.c"
#include "sumu.c"



static inline void rotate2(float *u, float *v, float a) {
  float sa=sin(a), ca=cos(a), tmp=*u*ca-*v*sa;
  *v=*u*sa+*v*ca; *u=tmp;
}




typedef struct {
  float x, y, z, s;
} Dot;
Dot dots[32768];
static inline void prekalc_clouds() {
  int i;
  Dot *d;
  for (d=dots; d<dots+32768; d++) {
    do {
      d->x=(rand()-rand())*(5./RAND_MAX);
      d->y=(rand()-rand())*(5./RAND_MAX);
      d->z=(rand()-rand())*(5./RAND_MAX);
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
      for (ron=0; ron<narf-1; ron++) foo[jack*2*eenie+ron*2+1]=dick[jack*narf+ron]+dick[jack*narf+ron+1]>>1;
    }
    for (jack=0; jack<zort-1; jack++) {
      for (ron=0; ron<narf; ron++) foo[(jack*2+1)*eenie+ron*2]=dick[jack*narf+ron]+dick[(jack+1)*narf+ron]>>1;
      for (ron=0; ron<narf-1; ron++) foo[(jack*2+1)*eenie+ron*2+1]=(dick[jack*narf+ron]+dick[jack*narf+ron+1]+dick[(jack+1)*narf+ron]+dick[(jack+1)*narf+ron+1])*mou+foo[(jack*2+1)*eenie+ron*2+1]*4*(256-mou)+512>>10;
    }
    
  }
}

void glaah(unsigned char *foo, int eenie, int bar, int baz, int mou) {
  if (bar>3 && baz>3) {
    int ron, jack, narf=bar>>1, zort=baz/2;
    unsigned char *dick=malloc(narf*zort);
    for (jack=0; jack<zort; jack++) {
      for (ron=0; ron<narf; ron++) dick[jack*narf+ron]=foo[jack*2*eenie+ron*2];
    }
    glaah(dick, narf, narf, zort, mou);
/*    for (jack=0; jack<zort    for (jack=0; jack<zort; jack++) {
      for (ron=0; ron<narf; ron++) foo[jack*2*eenie+ron*2]=dick[jack*narf+ron];
      for (ron=0; ron<narf-1; ron++) foo[jack*2*eenie+ron*2+1]=dick[jack*narf+ron]+dick[jack*narf+ron+1]>>1;
    }
    for (jack=0; jack<zort-1; jack++) {
      for (ron=0; ron<narf; ron++) foo[(jack*2+1)*eenie+ron*2]=dick[jack*narf+ron]+dick[(jack+1)*narf+ron]>>1;
      for (ron=0; ron<narf-1; ron++) foo[(jack*2+1)*eenie+ron*2+1]=(dick[jack*narf+ron]+dick[jack*narf+ron+1]+dick[(jack+1)*narf+ron]+dick[(jack+1)*narf+ron+1])*mou+foo[(jack*2+1)*eenie+ron*2+1]*4*(256-mou)+512>>10;
    }*/
    for (jack=0; jack<baz; jack++) {
      int teheran, baghdad;
      teheran=(jack-zort)*96-(0-narf)*32+zort*128;
      baghdad=(jack-zort)*32+(0-narf)*96+narf*128;
      for (ron=0; ron<bar; ron++) {
        unsigned char *george=dick+(teheran>>8)*narf+(baghdad>>8);
        foo[jack*eenie+ron]=foo[jack*eenie+ron]*mou
           +((george[0]*(256-(teheran&255))+george[1]*(teheran&255))*(256-(baghdad&255))
           +(george[narf]*(256-(teheran&255))+foo[jack*eenie+ron]*(teheran&255))*(baghdad&255)+32768>>16)*(256-mou)+128>>8;
        teheran-=32; baghdad+=96;
      }
    }
    
  }
}


typedef struct Blk {
  int xr, yr, tr;
  char *data;
  struct Blk *next;
} Blk;

typedef struct {
  int xcnt, ycnt, tcnt, tot;
  Blk *root;
  Blk **data;
} Movie;



Movie *readmovie(char *datah) {
  int xr, yr, zr, cnt;
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
//    fread(b->data, 1, 1<<b->xr+b->yr+b->tr, f);
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

static inline void drawblk(char *buf, int pitch, Blk *b, int xs, int ys, int fno) {
  char *kuv=b->data+(fno<<b->tr>>12<<b->xr+b->yr);
  int xsi=(256<<b->xr)/xs, ysi=(256<<b->yr)/ys, x, y;
//  if (b->xr!=4 || b->yr!=4 || b->tr!=4) exit(1);
  for (y=0; y<ys; y++) {
    for (x=0; x<xs; x++) *buf++=kuv[(y*ysi>>8<<b->xr)+(x*xsi>>8)];
    buf+=pitch-xs;
  }
}

static void getframe(char *buf, int pitch, Movie *m, int xs, int ys, int fno) {
  Blk **b0=m->data+(((fno>>12)%m->tcnt+m->tcnt)%m->tcnt)*m->ycnt*m->xcnt;
  int xk=xs/m->xcnt, yk=ys/m->ycnt, x, y;
  for (y=0; y<m->ycnt; y++) for (x=0; x<m->xcnt; x++)
    drawblk(buf+y*yk*pitch+x*xk, pitch, b0[y*m->xcnt+x], xk, yk, fno&4095);
}

static void duunaa_sumu(char *buf, int pitch, int xs, int ys, float t) {
  short buf2[64000], *s;
  int x, y;
  char tab[1024];
  char *d;
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

void duunaa_kirkkovene(char *dbuf, char *sbuf, int pitch, int xs, int ys, float c, float b, float g, float frob, float borf) {
  unsigned static char tab[256];
  unsigned char *dp, *sp;
  int x, y, i, j;
  float f;
  for (i=0; i<256; i++) {
    f=pow((i/256.)*c+b, g);
    f=f+sin(f*frob)*borf;
    j=lrint(f*256);
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

extern char musadata[];
int fakeoff=0, fakesize=56366;
int fakeseek(struct MREADER *m, long offset, int whence) { fakeoff=(whence==SEEK_SET?0:whence==SEEK_CUR?fakeoff:fakesize)+offset; return 0; }
long faketell(struct MREADER *m) { return fakeoff; }
int fakeread(struct MREADER *m, void *dest, size_t length) { memcpy(dest, musadata+fakeoff, length); fakeoff+=length; return length; }
int fakeeof(struct MREADER *m) { return fakeoff>=fakesize; }
int fakeget(struct MREADER *m) { return fakeeof(0)?EOF:musadata[fakeoff++]; }

static Tso tsot[10];
Movie *mov;

#include "desing.c"


int rajo807f(int x) { return x<-128?-128:x>127?127:x; }

int main(int argc, char *argv[]) {
  int i, j;
  float t;
  float numbs[16384];
  static char buffer[200000];
  static char U[320*240], V[320*240];
  FILE *fp;
//  OggVorbis_File oggi;
  int bufsiz;
  unsigned time0, timex;
  SDL_Surface *screen;
  SDL_Overlay *ovl;
  SDL_Color colors[256];
  static int graffa[320*200];
  int effu=argc>1?atoi(argv[1]):0;
 
  MODULE *module;

/*  {
    FILE *fp=fopen("pakked.dat", "r");
    mov=readmovie(fp);
    fclose(fp);
  }*/
  {
    extern char videodata[];
    mov=readmovie(videodata);
  }
  rando=time(0)>>20;

  fprintf(stderr, "d-2\n");

  fprintf(stderr, "d-1\n");
  if (SDL_Init(SDL_INIT_VIDEO)<0) {
    fprintf(stderr, "sdlerror %s\n", SDL_GetError());
    return 1;
  }
  atexit(SDL_Quit);
  fprintf(stderr, "d0\n");
  fprintf(stderr, "d1\n");
  screen=SDL_SetVideoMode(640, 480, 16, SDL_SWSURFACE|SDL_FULLSCREEN);
  fprintf(stderr, "d2\n");
  SDL_ShowCursor(0);
  fprintf(stderr, "d3\n");

  ovl=SDL_CreateYUVOverlay(320, 240, SDL_IYUV_OVERLAY, screen);

  for (i=0; i<16384; i++) numbs[i]=1+(rand()*(1./RAND_MAX));

  t=0;
  fprintf(stderr, "d4\n");

//  initdemo();
//  SDL_PauseAudio(0);
  SDL_EventState(SDL_KEYDOWN, SDL_ENABLE);
  SDL_EventState(SDL_QUIT, SDL_ENABLE);
  fprintf(stderr, "d5\n");


  

  MikMod_RegisterAllDrivers();
  MikMod_RegisterAllLoaders();
  md_mode = DMODE_SOFT_MUSIC|DMODE_INTERP|DMODE_16BITS|DMODE_STEREO;
  if (MikMod_Init("")) {
    fprintf(stderr, "Could not initialize sound, reason: %s\n",  MikMod_strerror(MikMod_errno));
    return;
  }
  {
    MREADER m={ fakeseek, faketell, fakeread, fakeget, fakeeof };
    module = Player_LoadGeneric(&m, 64, 0);
//    module = Player_Load("dxn-sl2.xm", 64, 0);
  }
  if (!module) {
    fprintf(stderr, "fgsfgsrstr, reason: %s\n", MikMod_strerror(MikMod_errno));
    return;
  }
  fprintf(stderr, "d5\n");
  {
    int x, y;
    float a, b, c;
    float f=rando*(2*3.141592653589793238462648336675485856345634564*1048576/3600./24./365.24)-.3;
    float k=cos(f);
    float s=cos(f+2);
    float n=.03*exp(sin(f)*sin(f)*.5);
    for (y=0; y<120; y++) for (x=0; x<160; x++) {
      a=x*.02+sin(y*.03); b=y*.02+sin(x*.03);
      
/*      ovl->pixels[1][y*320+x]=128+sin(a+b)*13+cos(a-b)*16+rand()*(4./RAND_MAX);
      ovl->pixels[2][y*320+x]=128+sin(a-b)*5+cos(a+b)*4+rand()*(4./RAND_MAX);*/
      U[y*160+x]=rajo807f((noise2(x*n, y*n, 0)-.5)*160.5+96*k);
      V[y*160+x]=rajo807f((noise2(x*n, y*n, 3)-.5)*191.5+48*s);
    }
  }
  for (j=0; j<5; j++) {
//    for (i=0; i<256; i++) tsot[j].map[i]=-1+2*cube(.5-.5*cos(((i+128&255)-128)*.2))-.2;
    for (i=0; i<256; i++) tsot[j].map[i]=-1+2*(.5-.5*cos(((i+128&255)-128)*.2))+.5*sin(((i+128&255)-128)*.05);//-.2;
  }

  for (i=0; i<256; i++) tsot[3].map[i]=sin(((i+128&255)-128)*.5)*.05;
  for (i=0; i<256; i++) tsot[4].map[i]=sin(((i+128&255)-128)*.5)*.05;

  presumu();
  desing_precalc();
  fprintf(stderr, "d5\n");
  time0=SDL_GetTicks();
  Player_Start(module);
  md_reverb=12; 
  md_musicvolume=42;
  
  while (!stopnow) {
    float aikaero=.02;
    SDL_Event eve;
    SDL_Rect rectum;
    timex=SDL_GetTicks()-time0;

    while (SDL_PollEvent(&eve)) {
      if (eve.type==SDL_KEYDOWN) {
/*        if (eve.key.keysym.sym==SDLK_PLUS) Player_NextPosition();
        else if (eve.key.keysym.sym==SDLK_MINUS) Player_PrevPosition();
        else if (eve.key.keysym.sym==SDLK_KP_PLUS) Player_NextPosition();
        else if (eve.key.keysym.sym==SDLK_KP_MINUS) Player_PrevPosition(); works not with this module...
        else*/ if (eve.key.keysym.sym==SDLK_ESCAPE) stopnow++;
        else if (eve.key.keysym.sym==SDLK_q) stopnow++;
      }
      if (eve.type==SDL_QUIT) stopnow++;
    }  

    j=rand();
    SDL_LockYUVOverlay(ovl);
/*    for (i=0; i<640*480; i++) {
      ovl->pixels[0][i]=64;//74+((j=j*35345243+1)>>25);
    }*/
    { 
      int x, y;
      unsigned char *p0, *p1;
      signed char *p3;
      static int flipflop=0;
      for (y=0; y<120; y++) {
        for (p0=ovl->pixels[0]+y*640, p1=ovl->pixels[1+flipflop]+y*160, p3=(flipflop?V:U)+y*160, x=0; x<160; x++, p0+=8, p1+=4, p3+=4) {
          p1[0]=((p1[0]-128)*28*128+p3[0]*2*p0[0]+512>>12)+128;
          p1[1]=((p1[1]-128)*28*128+p3[1]*2*p0[1]+512>>12)+128;
          p1[2]=((p1[2]-128)*28*128+p3[2]*2*p0[2]+512>>12)+128;
          p1[3]=((p1[3]-128)*28*128+p3[3]*2*p0[3]+512>>12)+128;
        }
      }
      flipflop^=1;
    }
/*    for (i=0; i<320*240; i++) {
      ovl->pixels[1]U[y*320+x]=noise2(x*.03, y*.03, 0)*255.5;
      V[y*320+x]=noise2(x*.03, y*.03, 3)*255.5;
    }*/
    
    {
      t=timex*0.0001; 
      tsot[0].xk=.3/64.; tsot[0].yk=0; tsot[0].zk=0; tsot[0].d=0;
      tsot[1].xk=0; tsot[1].yk=.3/64.; tsot[1].zk=0; tsot[1].d=0;
      tsot[2].xk=0; tsot[2].yk=0; tsot[2].zk=.3/64.; tsot[2].d=t*8000000;

      //tsot[3].xk=.3; tsot[3].yk=-.3; tsot[3].zk=.3; tsot[3].d=0;
      tsot[3].xk=-1.9/64.; tsot[3].yk=-1.9/64.; tsot[3].zk=0; tsot[3].d=50/64.;
      tsot[4].xk=-1.9/64.; tsot[4].yk= 1.9/64.; tsot[4].zk=0; tsot[4].d=50/64.;
//      tsot[4].xk=.2; tsot[4].yk=-.2; tsot[4].zk=0; tsot[4].d=0;
      for (i=0; i<5; i++) {
        rotate2(&tsot[i].xk, &tsot[i].yk, t*numbs[0]);
        rotate2(&tsot[i].yk, &tsot[i].zk, t*numbs[1]);
        rotate2(&tsot[i].zk, &tsot[i].xk, t*numbs[2]);
        rotate2(&tsot[i].xk, &tsot[i].yk, t*numbs[3]);
        rotate2(&tsot[i].yk, &tsot[i].zk, t*numbs[4]);
      }
/*      for (i=0; i<5; i++) {
        tsot[i].xk=sin(t*numbs[i*8+0]+numbs[i*8+3])*3;
        tsot[i].yk=sin(t*numbs[i*8+1]+numbs[i*8+4])*3;
        tsot[i].zk=sin(t*numbs[i*8+2]+numbs[i*8+5])*3;
        tsot[i].d=0;
      }*/
    }
    gounter=0; 
    if (!effu) desing(ovl->pixels[0], ovl->pitches[0], 320, 240, /*module->sngpos+fmod(*/timex*(1./1000/60*125/16*6/6.5)/*, 1)*/);
    if (effu&1) rend(ovl->pixels[0], ovl->pitches[0], 320, 224, tsot, 5);
//    rend(ovl->pixels[0], ovl->pitches[0], 320, 240, tsot, 3);
    if (effu&2) getframe(ovl->pixels[0], ovl->pitches[0], mov, 320, 240, timex*8);
    if (effu&4) {
      short buf[64000], *s;
      int x, y;
      char tab[1024];
      char *d;
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
//    printf("%i\n", gounter);
    SDL_UnlockYUVOverlay(ovl);

    rectum.x=0; rectum.y=0; rectum.w=640; rectum.h=480;
    SDL_DisplayYUVOverlay(ovl, &rectum);
    MikMod_Update();
//    usleep(100000);
  }

  //SDL_CloseAudio();

  Player_Stop();
  Player_Free(module);
  MikMod_Exit();

  return 0;
}










