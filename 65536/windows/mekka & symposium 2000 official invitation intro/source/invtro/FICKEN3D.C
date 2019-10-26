#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "ficken3d.h"
#include "matrix.h"
#include "math3d.h"
#include "util.h"
#include "line.h"

#define SCREEN_X 320
#define SCREEN_Y 240

void * SurfacePtr;
long SurfacePitch;

const float M_PI  = 3.1415926535897932384626433832795f;

#define MAXEDGE  16384
#define MAXVERT  10240       // max faces per object

static tvector    * tempvert;
static sU8        * edgevis;
static long         pal[256];

long   engine_xmin=1<<16;
long   engine_ymin=1<<16;
long   engine_xmax=((SCREEN_X-1)<<16);
long   engine_ymax=((SCREEN_Y-1)<<16);

float  engine_scale = 4.0;

void Engine_Init (void)
///////////////////////
{
  int i;
  tempvert = (tvector    *) zmymalloc ( MAXVERT * sizeof (tvector));
  edgevis  = (sU8        *) zmymalloc ( MAXEDGE * sizeof (sU8));
  Engine_SetSubPal (14);
}

void Engine_SetSubPal (int fak)
///////////////////////////////
{
  int i;
  for ( i=0; i<256; i++ )
  {
    int c = i*fak/256;
    pal[i]=(c<<16)|(c<<8)|c;
  }
}


void Engine_Done (void)
///////////////////////
{
  myfree (edgevis);
  myfree (tempvert);
}

static void RegisterEdge (object *o, int i, float scale)
////////////////////////////////////////////////////////
{
  sU32 a,b;
  float x0,y0,x1,y1;
  float lx, ly;
  float xmid, ymid;
  float len;
  a=(o->edges[i]&0xffff);
  b=(o->edges[i]>>16);
  x0 = tempvert[a].x;
  y0 = tempvert[a].y;
  x1 = tempvert[b].x;
  y1 = tempvert[b].y;
  xmid = (x0+x1)/2.0f;
  ymid = (y0+y1)/2.0f;
  x0=(x0-xmid)*scale+xmid;
  y0=(y0-ymid)*scale+ymid;
  x1=(x1-xmid)*scale+xmid;
  y1=(y1-ymid)*scale+ymid;
  len=fsqrt((x1-x0)*(x1-x0)+(y1-y0)*(y1-y0));
  if (len>65536*100)
    return;
  lineclip8 (x0,y0,x1,y1, SurfacePtr, pal);
}


void Engine_DrawObject (object *o, float * matrix, int EdgeMode)
///////////////////////////////////////////////////////////////////////////////
{
  int       i;
  float     w;
  face      *f;
  int       of;

  // transform faces
  for ( i=0; i<o->nvertices; i++ )
  {
    VTransform (&tempvert[i], matrix, &o->vertices[i]);
    w=65536.0f/(tempvert[i].z);
    tempvert[i].x = (engine_scale*tempvert[i].x * w)+(SCREEN_X*32768);
    tempvert[i].y = (SCREEN_Y*32768)-(engine_scale*tempvert[i].y * w);
  }

  // build polygons
  f=o->faces;

  for ( i=0; i<o->nfaces; i++, f++ )
  {
    float     ux, uy, vx, vy;
    tvector   *a,*b,*c;

    a= &tempvert[f->a];
    b= &tempvert[f->b];
    c= &tempvert[f->c];

    // backface culling
    ux = c->x - a->x;  uy = c->y - a->y;
    vx = b->x - a->x;  vy = b->y - a->y;
    if(ux*vy-uy*vx>=0) continue;

    // edge visibility
    edgevis[f->ea]++;
    edgevis[f->eb]++;
    edgevis[f->ec]++;
  }

  switch ( EdgeMode )
  {
    case EDGEMODE_EDGES:
    {
      for (i=0; i<o->nedges; i++)
      {
        if (edgevis[i]==1) RegisterEdge (o,i,1.0);
        edgevis[i]=0;
      }
    } break;

    case EDGEMODE_FRONT:
    {
      for (i=0; i<o->nedges; i++)
      {
        if (edgevis[i]!=0)
        {
          if ( edgevis[i]==1 ) RegisterEdge (o,i,1.0);
          else RegisterEdge (o,i,0.6);
        }
        edgevis[i]=0;
      }
    } break;

    case EDGEMODE_ALL:
    {
      for (i=0; i<o->nedges; i++)
      {
        RegisterEdge (o,i,0.5);
        edgevis[i]=0;
      }
    }
  }
}

static void InsertEdge(object * o, int a, int b)
////////////////////////////////////////////////
{
  sU32 i;
  sU32 code;
  if (a>b) {int temp = a; a=b; b= temp;}
  code = (a<<16)|(b);
  for ( i=0; i<o->nedges; i++ ) if ( o->edges[i]==code ) return;
  o->edges[o->nedges++]=code;
}


static int FindEdge(object * o, int a, int b)
/////////////////////////////////////////////
{
  sU32 l,r,x;
  sU32 code;
  if (a>b) {register int temp = a; a=b; b= temp;}
  return bsearch32 (o->edges, o->nedges, (a<<16)|(b));
}

object * Engine_AllocObject (int vertices, int faces)
/////////////////////////////////////////////////////
{
  object *o;
  o=(object *) zmymalloc (sizeof (object));
  o->nvertices = vertices;
  o->nfaces    = faces;
  o->vertices  = (tvector *) zmymalloc (vertices*sizeof (tvector));
  o->faces     = (face    *) zmymalloc (faces   *sizeof (face   ));
  return o;
}

object * Engine_InitObjectRaw (tvector *list, int npolys)
/////////////////////////////////////////////////////////
{
  int       nvertices;
  int       i,j;
  int     * ftab;
  int     * fi;
  object  * o;
  tvector * vtab;
  tvector * li = list;

  ftab      = (int *)     mymalloc(npolys*3*sizeof (int));
  vtab      = (tvector *) mymalloc(npolys*3*sizeof (tvector));
  nvertices = 0;
  for (i=0, fi=ftab; i<npolys*3; i++, li++)
  {
    for(j=0; j<nvertices; j++) if (equalvec(&vtab[j], li)) { *(fi++)=j; goto skip; }
    vtab[nvertices] = *li;
    *(fi++)=nvertices++;
skip:;
  }

  o = Engine_AllocObject (nvertices, npolys);
  mymemcpy (o->vertices, vtab, nvertices*sizeof (tvector));
  myfree (vtab);

  for ( i=0, fi=ftab; i<npolys; i++ )
  {
    o->faces[i].a=*fi++;
    o->faces[i].c=*fi++;
    o->faces[i].b=*fi++;
  }
  myfree (ftab);
  Engine_CalcEdges(o);
  return o;
}


void  Engine_FreeObject (object *o)
///////////////////////////////////
{
  if (o->vertices) myfree (o->vertices);
  if (o->faces)    myfree (o->faces);
  if (o->edges)    myfree (o->edges);
  myfree (o);
}

void Engine_CalcEdges (object *o)
/////////////////////////////////
{
  int  i,a,b,c;
  sU32 * tempbuf;
  o->edges     = (sU32    *) mymalloc (MAXEDGE     *sizeof (sU32));
  o->nedges    = 0;
  for(i=0; i<o->nfaces; i++)
  {
    a=o->faces[i].a;
    b=o->faces[i].b;
    c=o->faces[i].c;
    InsertEdge(o,a,b);
    InsertEdge(o,b,c);
    InsertEdge(o,c,a);
  }
  sort32 (o->edges, o->nedges);
  tempbuf = (sU32*) mymalloc (o->nedges*4);
  mymemcpy (tempbuf, o->edges, o->nedges*4);
  myfree (o->edges);
  o->edges=tempbuf;

  for(i=0; i<o->nfaces; i++)
  {
    o->faces[i].ea = FindEdge(o,o->faces[i].a,o->faces[i].b);
    o->faces[i].eb = FindEdge(o,o->faces[i].b,o->faces[i].c);
    o->faces[i].ec = FindEdge(o,o->faces[i].a,o->faces[i].c);
  }
}

