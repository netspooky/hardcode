#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "ficken3d.h"
#include "util.h"
#include "math3d.h"
#include "matrix.h"

static HANDLE Heap;

void MakePalBCW (long *pal, int p1, int p2, unsigned long color)
////////////////////////////////////////////////////////////////
{
  int i,m,r,g,b;
  PALETTEENTRY * palptr = (PALETTEENTRY *) pal+p1;
  r=(color>>16)&0xff;
  g=(color>>8)&0xff;
  b=(color>>0)&0xff;
  m=(p1+p2)/2-p1;
  for ( i=0; i<m; i++)
  {
    palptr->peRed   = r*i/m;
    palptr->peGreen = g*i/m;
    palptr->peBlue  = b*i/m;
    palptr->peFlags = 0;
    palptr++;
  }
  m=(p2-p1)-m;
  for ( i=0; i<m; i++)
  {
    palptr->peRed   = r+(255-r)*i/m;
    palptr->peGreen = g+(255-g)*i/m;
    palptr->peBlue  = b+(255-b)*i/m;
    palptr->peFlags = 0;
    palptr++;
  }
}

void HeapInit (void)
////////////////////
{
  Heap = HeapCreate (HEAP_NO_SERIALIZE, 32*0x10000, 0);
}

void HeapDone (void)
////////////////////
{
  HeapDestroy (Heap);
}

void * mymalloc (const unsigned long size)
////////////////////////////////////////
{
  return HeapAlloc(Heap, HEAP_NO_SERIALIZE, size);
}


void * zmymalloc (const unsigned long size)
/////////////////////////////////////////
{
  return HeapAlloc(Heap, HEAP_NO_SERIALIZE|HEAP_ZERO_MEMORY , size);
}

void myfree (const void * ptr)
////////////////////////////
{
  HeapFree (Heap, HEAP_NO_SERIALIZE, (LPVOID)ptr);
}


void testdeform (tvector *vs, int n, float anim, float *amp)
////////////////////////////////////////////////////////////
{
  int i;
  tvector *l = vs;
  tvector v;
  float f;
  float all = 0;
  anim*=0.3;
  for ( i=0; i<n; i++ )
  {
    v.x = fabs(vs->x);
    v.y = fabs(vs->y);
    v.z = fabs(vs->z);
    vs->x*=(0.6+0.4*sin((v.y+anim*amp[0])*M_PI/2));
    vs->y*=(0.6+0.4*sin((v.z+anim*amp[1])*M_PI/2));
    vs->z*=(0.6+0.4*sin((v.x+anim*amp[2])*M_PI/2));

    all+=fsqrt(vs->x*vs->x+vs->y*vs->y+vs->z*vs->z);
    vs++;
  }
  all=(float)n/all;
  vs=l;
  for ( i=0; i<n; i++ )
  {
    vs->x*=all;
    vs->y*=all;
    vs->z*=all;
    vs++;
  }
}


void testdeform2 (tvector *vs, int n, float anim, float *amp)
////////////////////////////////////////////////////////////
{
  int i;
  tvector *l = vs;
  tvector v;
  float f;
  float all = 0;
  anim*=0.3;
  for ( i=0; i<n; i++ )
  {
    v.x = (vs->x)*(vs->x);
    v.y = (vs->y)*(vs->y);
    v.z = (vs->z)*(vs->z);
    vs->x*=(0.6+0.4*sin((v.y+anim*amp[0])*M_PI));
    vs->y*=(0.6+0.4*sin((v.z+anim*amp[1])*M_PI));
    vs->z*=(0.6+0.4*sin((v.x+anim*amp[2])*M_PI));
    all+=fsqrt(vs->x*vs->x+vs->y*vs->y+vs->z*vs->z);
    vs++;
  }
  all=(float)n/all;
  vs=l;
  for ( i=0; i<n; i++ )
  {
    vs->x*=all;
    vs->y*=all;
    vs->z*=all;
    vs++;
  }
}

float trefoil_anim=0;
float trefoil_amp=0;

float trefoilpath(tvector *v0, tvector *v1, float t)
{
  float s1,c1,s2,c2;
  c2=1.8*cos(2*t);
  s2=1.8*sin(2*t);
  c1=1.0*cos(t);
  s1=1.0*sin(t);
  v0->x=c2-c1;
  v0->y=s2+s1;
  v0->z=1.1*sin(3*t);
  v1->x=-2*s2+s1;
  v1->y=2*c2+c1;
  v1->z=3*1.1*cos(3*t);
  if(v1->z==0) v1->z=0.01;
  return 0.4+trefoil_amp*sin(8*(t+trefoil_anim));
}

void spcGetToroidFaceList(face *f, int ringseg, int cylseg)
///////////////////////////////////////////////////////////
{
  int j,i;
  face *fp0=f;
  face *fp1=f+(ringseg*cylseg);
  for (j=0; j<ringseg; j++)
    for (i=0; i<cylseg; i++)
    {
      fp0->a=fp1->a=j*cylseg+i;
      fp0->b=j*cylseg+(i+1)%cylseg;
      fp1->c=((j+1)%ringseg)*cylseg+(i+cylseg-(j&1))%cylseg;
      fp0->c=fp1->b=((j+1)%ringseg)*cylseg+(i+1-(j&1))%cylseg;
      fp0++;
      fp1++;
    }
}



void spcGetToroidVerts(tvector *verts, tvector *norms,
                        int ringseg, int cylseg,
                        float (*path)(tvector *, tvector *, float),
                        float twist, float wrap)
////////////////////////////////////////////////////////////////////

{
  int i,j;
  tvector lastup={0,0,1};
  tvector lastdir={0,1,0};
  tvector norm;


  for (j=0; j<ringseg; j++)
  {
    tvector pos,dir,up,right;
    tvector y;
    tvector x;
    float v,v2;
    float rad;

    rad=path(&pos, &dir, 2*M_PI*j/ringseg);
    NormVector (&dir);

    VCrossProduct2 (&x, &lastdir, &dir);
    v=DotProduct(&lastdir, &dir);
    v2=1+v;
    if (v2<1e-4) v2=1e-4;
    v2=DotProduct(&x, &lastup)/v2;

    VCrossProduct2(&up, &x, &lastup);
    addscale (&up, &lastup, v);
    addscale (&up, &x, v2);
    VCrossProduct2(&right, &dir, &up);
    VCrossProduct2(&up, &right, &dir);
    NormVector (&up);
    NormVector (&right);

    lastup=up;
    lastdir=dir;

    for (i=0; i<cylseg; i++)
    {
      fvecspin(&norm, &up, &right, wrap+2*M_PI*(i-(j&1)/2.0)/cylseg+j*twist/ringseg);
      verts->x = pos.x + norm.x * rad;
      verts->y = pos.y + norm.y * rad;
      verts->z = pos.z + norm.z * rad;
      verts++;
    }
  }
}

