#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "intro.h"
#include "ficken3d.h"
#include "math3d.h"
#include "matrix.h"
#include "util.h"
#include "line.h"

#define SCREEN_X 320
#define SCREEN_Y 240

extern void __stdcall dd_setpal(long *);


#define TREFOIL_RINGS 120
#define TREFOIL_CYLS  14
//#define TREFOIL_RINGS 160
//#define TREFOIL_CYLS  22

// 1026


static char      *buffer;
static long      IntroFlags=0;
static float     IntroTime;
static float     matrix[16];
static tvector   rot = {0,0,0};
static tvector   *spherevecs;
static object    *trefoil;
static object    *sphere;


int Init (void)
//////////////
{
  rawobject * blah;
  IntroFlags|=1;
  HeapInit ();
  Engine_Init();

  // Init trefoil knot
  trefoil = Engine_AllocObject (TREFOIL_RINGS*TREFOIL_CYLS, TREFOIL_RINGS*TREFOIL_CYLS*2);
  spcGetToroidFaceList(trefoil->faces, TREFOIL_RINGS,TREFOIL_CYLS);
  spcGetToroidVerts   (trefoil->vertices, 0,TREFOIL_RINGS,TREFOIL_CYLS,trefoilpath,3.8,0);
  Engine_CalcEdges    (trefoil);

  // init sphere
  blah = gensphere (4);
  sphere = Engine_InitObjectRaw ((tvector *)blah->poly, blah->npoly);
  myfree (blah);
  Engine_CalcEdges(sphere);
  spherevecs = (tvector *) mymalloc (sphere->nvertices * 12);
  mymemcpy (spherevecs, sphere->vertices, sphere->nvertices*12);
  buffer = mymalloc (SCREEN_X*SCREEN_Y+1024);
  return 1;
}

void Quit (void)
////////////////
{
  if (IntroFlags&1)
  {
    Engine_Done();
    HeapDone ();
  }
}


static float interpol1 (float t, float t1, float t2, float val1, float val2)
/////////////////////////////////////////////////////////////////////
{
  if ( t<t1 ) return val1;
  if ( t>t2 ) return val2;
  return val1+(val2-val1)*sin(0.5f*M_PI*(t-t1)/(t2-t1));
}

static float interpol2 (float t, float t1, float t2, float val1, float val2)
/////////////////////////////////////////////////////////////////////
{
  float tt;
  if ( t<t1 ) return val1;
  if ( t>t2 ) return val2;
  t=(t-t1)/(t2-t1);
  tt=(t*t);
  return val1+(val2-val1)*(-2.0f*t*tt+3.0f*tt);
}

static void BufCopy (char * data, int pitch)
/////////////////////////////////////
{
  int y;
  char * s = buffer;
  char * d = data;
  for ( y=0; y<SCREEN_Y; y++ )
  {
    mymemcpy (d,s, SCREEN_X);
    d+=pitch;
    s+=SCREEN_X;
  }
}

static int  CurrentObject = 0;
static int  Variation = 0;


static void DoEffect1 (float IntroTime, float fx)
//////////////////////////////////////////
{
  engine_scale = interpol1 (IntroTime, 0,5,0,interpol2 (IntroTime, 6,20,250,400+100.0*sin(IntroTime*0.2)));
  trefoil_amp  = interpol1 (IntroTime, 0,6,0,0.25);
  trefoil_anim = -IntroTime*0.3;

  rot.x = interpol2 (IntroTime, 5,9,0, M_PI/2*sin(IntroTime*0.3));
  rot.y = 0.1;
  rot.z = interpol2 (IntroTime, 0,10,10.0, IntroTime*0.4);
  MakeRotationMatrix  (matrix, &rot);
  matrix[11] = 6.0;
  engine_scale *= fx;
  spcGetToroidVerts (trefoil->vertices, 0, TREFOIL_RINGS,TREFOIL_CYLS,trefoilpath,3.8,-IntroTime);
  Engine_DrawObject (trefoil,matrix, EDGEMODE_FRONT);
}


static void DoEffect2 (float IntroTime, float fx)
//////////////////////////////////////////
{
  static float amp[3][3] =
  {
    {1.0f, 1.0f, 1.0f},
    {1.0f, 0.5f, 1.0f},
    {1.1f, 1.4f, 0.5f},
  };

  engine_scale = 600*fx;
  rot.x = IntroTime*1.0;
  rot.y = IntroTime*-0.5;
  rot.z = IntroTime*1.14;
  MakeRotationMatrix  (matrix, &rot);
  matrix[11] = 6.0;
  matrix[3]  = 0.2*sin(IntroTime*0.3);
  matrix[7]  = 0.2*sin(IntroTime*0.4);
  mymemcpy   (sphere->vertices, spherevecs, sphere->nvertices*12);
  if ( Variation&1 )
    testdeform2 (sphere->vertices, sphere->nvertices, IntroTime*3, amp[Variation%3]);
  else
    testdeform (sphere->vertices, sphere->nvertices, IntroTime*3, amp[Variation%3]);
  Engine_DrawObject (sphere, matrix, (Variation&1)?EDGEMODE_ALL:EDGEMODE_FRONT);
}

static void MakePalette (int n, int divisor)
////////////////////////////////////////////
{
  PALETTEENTRY pal[256];
  int i;
  MakePalBCW ((long*)pal, 64,128, 0x00808080);
  if ( n<0 ) n=0;
  if ( n>400 ) n=400;

  for ( i=0; i<256; i++)
  {
    pal[i].peRed    = pal[i].peRed  +((128-pal[i].peRed)*n/divisor);
    pal[i].peGreen  = pal[i].peGreen+((128-pal[i].peGreen)*n/divisor);
    pal[i].peBlue   = pal[i].peBlue +((128-pal[i].peBlue)*n/divisor);
  }
  dd_setpal ((long *) pal);
}


void DoFrame(char * data, int pitch)
////////////////////////////////////
{
  static long FirstFrameTick;
  static long PalTick;
  long CurrentTick;
  float zoomout;
  int n;

  CurrentTick = GetTickCount();

  if ( !(IntroFlags&2) )
  {
    IntroFlags|=2;
    FirstFrameTick = CurrentTick;
    PalTick        = FirstFrameTick;
  }

  IntroTime    = (float)(CurrentTick-FirstFrameTick)/1000.0f;
  SurfacePtr   = buffer;
  SurfacePitch = SCREEN_X;
  RectRopFill (0,0,SCREEN_X,SCREEN_Y,30+64);

#define FADETIME   200
#define SWITCHTIME 1000

  n = (CurrentTick-PalTick)/3;

  if ( n<FADETIME)
  {
    MakePalette (FADETIME-n, FADETIME);
//    if(n) zoomout = (float) FADETIME / (float)(FADETIME-n);
//    else  zoomout = 10000;
    zoomout = 1.0;
  } else
  if ( n<FADETIME+SWITCHTIME)
  {
    zoomout = 1.0;
  } else
  if ( n<2*FADETIME+SWITCHTIME)
  {
    float f;
    long x = n-(1*FADETIME+SWITCHTIME);
    MakePalette (x,FADETIME);

    f=(float)(x-FADETIME)/(float)FADETIME;
    f*=f;
    if(f) zoomout = 1.0/f;
  } else
  {
    // switch Objects
    MakePalette (FADETIME, FADETIME);
    PalTick = CurrentTick;
    CurrentObject ^=1;
    if (!CurrentObject) Variation++;
    zoomout = 0;
  }

  if (CurrentObject) DoEffect1(IntroTime, zoomout);
  else               DoEffect2(IntroTime, zoomout);


  RectRopFill (0,0,320,1,96);
  RectRopFill (0,239,320,240,96);
  RectRopFill (0,0,1,240,96);
  RectRopFill (319,0,320,240,96);
  BufCopy (data, pitch);
}
