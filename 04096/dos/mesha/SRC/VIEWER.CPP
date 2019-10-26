#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>
#include <string.h>
#include <malloc.h>
#include <time.h>
#include <conio.h>
#include <ctype.h>

#include "std.h"
#include "_i86.h"
#include "mesha.hpp"

//#define FILEDUMP

int matherr(struct exception *a)
{
  printf("Matherr\n");
  exit(1);
  return 0;
}

extern "C" {

#define MAX_OBJECT 97
#define OWNOBJ     96

struct tPMode {
  unsigned short GDT[4];
  unsigned char  GDT_Null[8];
  unsigned char  Code32[8];
  unsigned char  Data32[8];
  byte*          Screen;
};

byte*          BaseMem;
struct tObject {
  long           Size;
  long           Dir[3];
  long           Pos[3];
  long           Ofs[3];
  long           dDir[3];
  long           dPos[3];
  long           dOfs[3];
  byte           Temp1[128-76];
};

struct tVertex {
  long          x,y,z,nx,ny,nz,tx,ty,yy,xx,dist,col,gentx,genty,yy2,xx2;
};

struct tFace {
  tVertex*      v[4];
};

struct tProcess {
  tObject*      Object;
  long          Delay;
  long          No;
  ulong         Code;
};

struct tModel {
  tVertex*      VStart;
  tFace*        FStart;
  tVertex*      VEnd;
  tFace*        FEnd;
};

struct tMatrix {
  struct {
    float         r[3];
    long          p;
  }    l[3];
  long s[4];
};

extern byte DFL_Ambient;
extern ulong DFL_ColMap;
extern byte* DFL_Texture;
extern ulong VCount;
extern ulong FCount;
extern byte CharMap[];
extern byte VGAPal[];
extern struct tProcess Process[256];
extern struct tPMode  PMode_Data;
extern struct tObject Objects[256];
extern struct tModel  Models[256];
extern ulong AniProcess;
extern ulong AniClock;
extern tMatrix Matrix;

extern void Pal_Generate();
extern void Int_Timer();
extern void ProtMain();
extern void DebugInit();
extern int DebugLoop();
extern void DebugDraw();
extern void Draw_Faces( tModel* s );
extern void Draw_Faces2( tModel* s );
extern void Calc_Matrix( long* );
extern schar Const_Model[1024];
extern byte Const_Object[1024];
schar Const_Object2[1024];
extern schar Const_Code[1024];

#ifdef __WATCOMC__
#pragma aux (Pal_Generate,AuxASM)
#pragma aux (Int_Timer,AuxASM)
#pragma aux (ProtMain,AuxASM)
#pragma aux (DebugInit,AuxASM)
#pragma aux (DebugLoop,AuxASM)
#pragma aux (DebugDraw,AuxASM)
#pragma aux Draw_Faces "_*" parm [ ESI ] modify exact []
#pragma aux Draw_Faces2 "_*" parm [ ESI ] modify exact []
#pragma aux Calc_Matrix "_*" parm [ ESI ] modify exact []
#endif

byte*           VirtScreen;
ulong*          ZBuffer;
struct tVertex* Vertex;
struct tFace*   Face;
byte*           ColorMap;
byte*           Textures;
};

void Draw_Point( tVertex* v ) {
  if (v->xx >= 0 && v->xx < 320 && v->yy >= 0 && v->yy < 200)
    VirtScreen[v->xx+v->yy*320] = 31+16;

}

long d_Xl;
long d_Xr;

long s_S;
long d_Sl;
long d_Sx;
long s_T0;
long d_T0l;
long d_T0x;
long s_T1;
long d_T1l;
long d_T1x;
long s_Z;
long d_Zl;
long d_Zx;

long s_Y;
long s_Y2;
long s_Xl;
long s_Xr;

long plus;
long longest;
tVertex* a;
tVertex* b;
tVertex* c;

long    sx = 320;
long    sy = 200;
byte*   p;
ulong*  z;

void DrawTri() {
  byte* px;
  ulong*  zx;
  int c;
  long x;
  long xx;
  long Z,S,T0,T1;
  while (s_Y < s_Y2) {
    xx = s_Xl >> 16;
    x = (s_Xr >> 16) - xx;
    if (x > 0 && xx < sx) {
      Z = s_Z;
      S = s_S;
      T0 = s_T0;
      T1 = s_T1;
      if ( xx < 0 ) {
        x += xx;
        Z -= d_Zx * xx;
        S -= d_Sx * xx;
        T0 -= d_T0x * xx;
        T1 -= d_T1x * xx;
        xx = 0;
      }
      if ( xx + x > sx )
        x = sx - xx;
      if ( x > 0) {
        px = p + xx;
        zx = z + xx;
        while (x--) {
          if ( Z < *zx) {
            if (S < 0)
              printf("Baj");
            *zx = Z;
            *px = ColorMap[((ulong)S & 0xFF00) + DFL_ColMap - 0x600000 + (byte)DFL_Texture[ ((T0 >> 16) & 0xFF) + ((T1 >> 8) & 0xFF00)]];
          }
          Z += d_Zx;
          S += d_Sx;
          T0 += d_T0x;
          T1 += d_T1x;
          px++;
          zx++;
        }
      }
    }
    s_Xr += d_Xr;
    s_Xl += d_Xl;
    s_Z += d_Zl;
    s_S += d_Sl;
    s_T0 += d_T0l;
    s_T1 += d_T1l;
    p += sx;
    z += sx;
    s_Y++;
  }
}

long divfix32(ulong a,ulong b);
long mulfix32(ulong a,ulong b);

#ifdef __WATCOMC__
#pragma aux divfix32 parm [ EAX ][ ECX ] = \
   "push edx"    \
   "mov edx,eax" \
   "shl eax,16"  \
   "sar edx,16"  \
   "idiv ecx"    \
   "pop edx"

#pragma aux mulfix32 parm [ EAX ][ EDX ] = \
   "push edx" \
   "imul edx" \
   "shrd eax,edx,16" \
   "pop edx"
#endif

void CalcDeltal( tVertex* up,tVertex* downl) {
  long h;
  s_Xl = up->xx;
  s_Z = up->dist;
  s_S = up->col;
  s_T0 = up->gentx;
  s_T1 = up->genty;
  h = downl->yy - up->yy;
//  if ( downl->yy2 - up->yy2 > 1)
  if (h > 0x8000)
  {
    d_Xl = divfix32(downl->xx - s_Xl,h);
    d_Zl = divfix32(downl->dist - s_Z,h);
    d_Sl = divfix32(downl->col - s_S,h);
    d_T0l = divfix32(downl->gentx - s_T0,h);
    d_T1l = divfix32(downl->genty - s_T1,h);
    s_Xl += mulfix32( d_Xl, plus );
    s_Z += mulfix32( d_Zl, plus );
    s_S += mulfix32( d_Sl, plus );
    s_T0 += mulfix32( d_T0l, plus );
    s_T1 += mulfix32( d_T1l, plus );
  }
}

void CalcDeltar( tVertex* up, tVertex* downr) {
  long h;
  s_Xr = up->xx;
//  if ( downr->yy2 - up->yy2 > 1)
  h = downr->yy - up->yy;
  if (h > 0x8000)
  {
    d_Xr = divfix32(downr->xx - s_Xr,h);
    s_Xr += mulfix32( d_Xr, plus );
  }
}

void CalcTo( tVertex* up, tVertex* down ) {
  plus = s_Y - up->yy2;
  if (plus < 0) {
    s_Y = up->yy2;
    plus = 0;
  }
  plus = ((plus+1) << 16) - (up->yy & 0xFFFF);
  s_Y2 = down->yy2;
  if (s_Y2 >= sy)
    s_Y2 = sy;
}

void Draw_Face() {
  tVertex* t;
  long sign = 0xFFFF;

  if (a->yy > b->yy) { t = a; a = b; b = t; sign ^= -1L; }   // sort up to down
  if (a->yy > c->yy) { t = a; a = c; c = t; sign ^= -1L; }
  if (b->yy > c->yy) { t = b; b = c; c = t; sign ^= -1L; }

  a->yy2 = a->yy >> 16;
  b->yy2 = b->yy >> 16;
  c->yy2 = c->yy >> 16;

  if (c->yy2 < 0 || a->yy2 >= sy || c->yy2 <= a->yy2)
    return;

  long temp = divfix32( b->yy - a->yy, c->yy - a->yy);
  longest = mulfix32( temp, c->xx - a->xx ) + a->xx - b->xx;
  if ((longest ^ sign) >= 0)            // check back face
    return;
  if ((longest ^ sign) >= -0x10000)
    longest = ~sign;

  d_Sx = divfix32((mulfix32(temp,c->col - a->col) + a->col - b->col),longest);
  d_Zx = divfix32((mulfix32(temp,c->dist - a->dist) + a->dist - b->dist),longest);
  d_T0x = divfix32((mulfix32(temp,c->gentx - a->gentx) + a->gentx - b->gentx),longest);
  d_T1x = divfix32((mulfix32(temp,c->genty - a->genty) + a->genty - b->genty),longest);

  s_Y = 0;
  CalcTo( a, b );
  p = VirtScreen + s_Y * sx;
  z = ZBuffer + s_Y * sx;
  if (longest < 0) {
    CalcDeltal(a, c);
    CalcDeltar(a, b);
    DrawTri();
    if (s_Y < sy) {
      CalcTo( b, c );
      CalcDeltar(b, c);
      DrawTri();
    }
  }
  else {
    CalcDeltal(a, b);
    CalcDeltar(a, c);
    DrawTri();
    if (s_Y < sy) {
      CalcTo( b, c );
      CalcDeltal(b, c);
      DrawTri();
    }
  }
}

void Draw_Faces2( tModel* Model ) {
  tFace* f = Model->FStart;
  while (f != Model->FEnd) {
    a = f->v[0];
    b = f->v[1];
    c = f->v[2];
    if ((a->dist | b->dist | c->dist) >= 0) {
      Draw_Face();
      if (f->v[3]) {
        a = f->v[0];
        b = f->v[2];
        c = f->v[3];
        Draw_Face();
      }
    }
    f++;
  }
}

void DrawTexture(byte* Text,byte Col,byte* Scr) {
  int y,x,n;
  n = 64;
  Col <<= 4;
  for (y=0;y<n;y++)
    for (x=0;x<n;x++)
      Scr[y*320+x] = Text[((y<<8)+x)<<2] + Col;
}

void DrawTexture2(byte* Text,byte Col) {
  int y,x;
  Col <<= 4;
  for (y=0;y<256;y++)
    for (x=0;x<200;x++)
      VirtScreen[x*320+y] = Text[(y << 8)+x] + Col;
}


void DumpModel(int n) {
  struct tVertex* v;
  struct tFace* face;
  char s[128];
  struct tModel* M = &Models[n];
  FILE* f = NULL;
  word i;
  if (M->VStart == NULL)
    return;
#ifdef FILEDUMP
  sprintf(s,"obj\\dump%u.obj",n);
  f = fopen(s,"w+");
#endif
  if (f == NULL)
    return;
  fprintf(f,"Vertex:%u\n",M->VEnd - M->VStart);
  v = M->VStart;
  while (v != M->VEnd) {
    fprintf(f,"%4lu X:%5.2f Y:%5.2f Z:%5.2f nX:%5.2f nY%5.2f nZ:%5.2f mX:%6.3f mY:%6.3f\n",
       v-M->VStart,
       (float)v->x/0x10000,(float)v->y/0x10000,(float)v->z/0x10000,
       (float)v->nx/0x10000,(float)v->ny/0x10000,(float)v->nz/0x10000,
       (float)v->tx/0x10000,(float)v->ty/0x10000);
    v++;
  }
  fprintf(f,"Faces:%u ,",M->FEnd - M->FStart);
  i = 0;
  face = M->FStart;
  while (face != M->FEnd) {
    i++; if (face->v[3]) i++;
    face++;
  }
  fprintf(f,"%u\n",i);
  face = M->FStart;
  while (face != M->FEnd) {
    fprintf(f,"A:%5ld B:%5ld C:%5ld D:%5ld\n",face->v[0]-M->VStart,face->v[1]-M->VStart,face->v[2]-M->VStart,
      face->v[3] ? face->v[3]-M->VStart : -1);
    face++;
  }
  fclose(f);
}

int ObjNo = 0;

void AddObject(int n,int a,int b,int c,int x,int y,int z) {
  struct tObject* o = Objects + ObjNo;
  if (Models[n].VStart == NULL)
    return;
  DumpModel(n);
  Const_Object[ObjNo] = n*2;
  Const_Object[MAX_OBJECT+ObjNo] = 0x33;
  ObjNo++;
  o->Size = 1;
  o->Dir[0] = a;
  o->Dir[1] = b;
  o->Dir[2] = c;
  o->Pos[0] = 0x10000 * x;
  o->Pos[1] = 0x10000 * y;
  o->Pos[2] = 0x200000 + 0x10000 * z;
}

void TestObject() {
  tModel* m = Models;
  tVertex* v = Vertex + VCount;
  tFace* f = Face + FCount;
  v[0].tx = 0x000000;
  v[0].ty = 0x000000;
  v[0].nx = 0x10000;
  v[0].ny = 0;
  v[0].nz = 0;
  v[0].x = 0x100000;
  v[0].y = 0x100000;
  v[0].z = 0;
  v[1].tx = 0x800000;
  v[1].ty = 0x000000;
  v[1].nx = 0x10000;
  v[1].ny = 0;
  v[1].nz = 0;
  v[1].x = 00000;
  v[1].y = 0x100000;
  v[1].z = 0;
  v[2].tx = 0x400000;
  v[2].ty = 0x600000;
  v[2].nx = 0x10000;
  v[2].ny = 0;
  v[2].nz = 0;
  v[2].x = 0;
  v[2].y = -0x100000;
  v[2].z = 0;
  v[3].tx = 0x200000;
  v[3].ty = 0x300000;
  v[3].nx = 0x10000;
  v[3].ny = 0;
  v[3].nz = 0;
  v[3].x = -0x100000;
  v[3].y = -0x100000;
  v[3].z = 0;
  f[0].v[0] = v+0;
  f[0].v[1] = v+1;
  f[0].v[2] = v+2;
  f[0].v[3] = NULL;
  f[1].v[0] = v+2;
  f[1].v[1] = v+1;
  f[1].v[2] = v+3;
  f[1].v[3] = NULL;

  m->VStart = v;
  m->FStart = f;
  v += 4;
  f += 2;
  m->VEnd = v;
  m->FEnd = f;
}

void ClearAll() {
  int i,j,k;
  ObjNo = 0;
  memcpy(&Const_Object,&Const_Object2,sizeof(Const_Object));
  memset(Objects,0,sizeof(Objects));
  memset(&Process,0,sizeof(Process));
  Process[0].Object = Objects;
  Process[0].Code = (ulong) &Const_Code * 2;
  AniProcess = (ulong) &Process[1];
}

void Print(char* s,int i) {
  struct tObject* Obj = Objects + ObjNo;
  int diff = (int)0x080000L;
  int diff2 = (int)0x100000L;
  char* p;
  int x,y,x2;
  x = 0;
  y = 1;
  p = s;
  x2 = 0;
  while (*p) {
    if (*p == 10) {
      if (x < x2) x = x2;
      x2 = 0;
      y++;
    }
    else x2++;
    p++;
  }
  x = -diff*(x >> 1);
  y = -diff2*(y >> 1);
  x2 = x;
  while (*s) {
    if (*s == 10) {
      y += diff2;
      x = x2;
    }
    else {
      if (*s != ' ') {
        Const_Object[ObjNo] = (*s - 32)*2;
        DumpModel((int)*s-32);
        Obj->Size = 1;
        Const_Object[ObjNo+MAX_OBJECT] = 0x33;
        Obj->Dir[2] = 0x10000;
        Obj->Pos[2] = 0x400000 + 0x100000 * i;
        Obj->Pos[1] = y;
        Obj->Pos[0] = x;
        Obj++;
        ObjNo++;
      }
      x += diff;
    }
    s++;
  }
}

void DumpMatrix() {
  for (int i=0;i<3;i++)
    printf("[%6.3f %6.3f %6.3f %6ld]\n",
      Matrix.l[i].r[0],Matrix.l[i].r[1],Matrix.l[i].r[2],Matrix.l[i].p);
  printf("\n");
}

/*
void CheckMatrix() {
  long v[6];
  v[3] = 1000;
  v[4] = 2000;
  v[5] = 3000;
  v[0] = 0;v[1] = 0;v[2] = 0; Calc_Matrix(v); DumpMatrix();
  v[0] = 0x10000;v[1] = 0;v[2] = 0; Calc_Matrix(v); DumpMatrix();
  v[1] = 0x10000;v[0] = 0;v[2] = 0; Calc_Matrix(v); DumpMatrix();
  v[2] = 0x10000;v[1] = 0;v[0] = 0; Calc_Matrix(v); DumpMatrix();
  v[0] = 0x8000;v[1] = 0;v[2] = 0; Calc_Matrix(v); DumpMatrix();
  v[1] = 0x8000;v[0] = 0;v[2] = 0; Calc_Matrix(v); DumpMatrix();
  v[2] = 0x8000;v[1] = 0;v[0] = 0; Calc_Matrix(v); DumpMatrix();
}
*/

void DebugDone() {
  ZeroReg386();
  Reg386.w.ax = 0x0003;
  Int386( 0x10, NULL );
}

extern int MainAnim;
extern int Anim[][256];
extern int Object[][256];
extern schar Model[];

int Pos,k,ModelErr;
schar* Data;
FILE* Inc;
void IncDump(const char* s) {
  int i,j,k;
  if (s)
    fprintf(Inc,"\n\nlabel %s byte\n",s);
  else
    fprintf(Inc,"\n");
  i = 0;
  j = (Pos+1)>>1;
  for (k=0;k<j;k++) {
    if ((k % 10) == 0) {
      fprintf(Inc,"\n  db ");
    }
    fprintf(Inc,"0%02xh",(byte)Data[k]);
    if ((k % 10) != 9 && k != j-1)
      fprintf(Inc,",");
  }
}

void Push8( int j, const char* s) {
  if (j < 0 || j > 255) {
    printf("Push8 out of range %d! %s (%d)\n",j,s,k-1);
    ModelErr = 1;
  }
  schar i = j & 15;
  if (Pos & 1) i <<= 4;
  Data[Pos++ >> 1] |= i;
  i = (j >> 4) & 15;
  if (Pos & 1) i <<= 4;
  Data[Pos++ >> 1] |= i;
}

void PushS8( int j,const char* s) {
  if (j < -128 || j > 127) {
    printf("PushS8 out of range %d! %s (%d)\n",j,s,k-1);
    ModelErr = 1;
  }
  schar i = j & 15;
  if (Pos & 1) i <<= 4;
  Data[Pos++ >> 1] |= i;
  i = (j >> 4) & 15;
  if (Pos & 1) i <<= 4;
  Data[Pos++ >> 1] |= i;
}

void Push4(int i,const char* s) {
  if (i < 0 || i > 15) {
    printf("Push4 out of range %d! %s (%d)\n",i,s,k-1);
    ModelErr = 1;
  }
  if (Pos & 1) i <<= 4; else i &= 15;
  Data[Pos++ >> 1] |= (schar)i;
}
void PushSL4(int i,const char* s) {
  if (i < -7 || i > 8) {
    printf("PushSL4 out of range %d! %s (%d)\n",i,s,k-1);
    ModelErr = 1;
  }
  if (i<=0)
    i = (-i << 1) | 1;
  else
    i = (i-1) << 1;
  i &= 0xF;
  if (Pos & 1) i <<= 4;
  Data[Pos++ >> 1] |= (schar)i;
}

void PushS4(int i,const char* s) {
  if (i < -8 || i > 7) {
    printf("PushS4 out of range %d! %s (%d)\n",i,s,k-1);
    ModelErr = 1;
  }
  i &= 0xF;
  if (Pos & 1) i <<= 4;
  Data[Pos++ >> 1] |= (schar)i;
}

int ModelInit() {
  int i,j,rel,p,p2;
  char* co = "Count";
  char* v = "Vertex";
  char* f = "Face";
  char* f2 = "Face2";
  ModelErr = 0;
  Pos = 0;
  k = 0;
  i = MNEW;
  memset(&Const_Model,0,sizeof(Const_Model));
  Data = Const_Model;
  while (i != MQUIT && i != MQUITS) {
    switch (i) {
      case MMOVEX:
      case MMOVEY:
      case MMOVEZ:
//        printf("Move\n");
        Push4(Model[k++],"Movement");
        PushS4(Model[k++],"Movement");
        break;
      case MMIRRORX:
      case MMIRRORY:
      case MMIRRORZ:
//        printf("Mirror\n");
        rel <<= 1;
        break;
      case MNEWS:
      case MNEW:
//        printf("New\n");
        rel = 0;
        Pos = (Pos +1) & ~1;
      case MVERTEX:
        Push4(i = Model[k++],co);
//        printf("Vertex %i\n",i);
        if (i) {
          Push4(Model[k++],co);
          Push4(Model[k++],co);
          while (i--) {
            PushS4(Model[k++],v);
            PushS4(Model[k++],v);
            PushS4(Model[k++],v);
            PushS4(Model[k++],v);
            PushS4(Model[k++],v);
            PushS4(Model[k++],v);
            rel++;
          }
        }
        p = rel;
        Push4(i = Model[k++],co);
//        printf("Face %i\n",i);
        while (i--) {
          switch (Model[k++]) {
            case P4:
              PushS4((p2 = Model[k++]) - p,f);p = p2;
              PushS4((p2 = Model[k++]) - p,f);p = p2;
              PushS4((p2 = Model[k++]) - p,f);p = p2;
              PushS4((((p2 = Model[k++]) - p) << 1),f2);p = p2;
              break;
            case P33:
              PushS4((p2 = Model[k++]) - p,f);p = p2;
              PushS4((p2 = Model[k++]) - p,f);p = p2;
              PushS4((p2 = Model[k++]) - p,f);p = p2;
              PushS4((((p2 = Model[k++]) - p) << 1)|1,f2);p = p2;
              break;
            case P3:
              PushS4((p2 = Model[k++]) - p,f);p = p2;
              PushS4((p2 = Model[k++]) - p,f);p = p2;
              PushS4((p2 = Model[k++]) - p,f);p = p2;
              PushS4(0,NULL);
              break;
          }
        }
        break;
    }
    Push4(i = Model[k++],NULL);
    if (i == MQUIT || i == MQUITS || i == MNEW || i == MNEWS)
      Push4(Model[k++],co);
  }
  IncDump("Const_Model");
#ifdef FILEDUMP
  int h = open("model.dat",O_RDWR | O_CREAT | O_TRUNC ,S_IWRITE | S_IREAD);
  write(h,Data,(Pos+1)>>1);
  close(h);
#endif
  return ModelErr;
}

int ObjIndex[64];

int ObjectInit() {
  int i,j,l,p,p2;
  Pos = 0;
  i = 0;
  k = 0;
  memset(&Const_Object,0,sizeof(Const_Object));
  ModelErr = 0;
  Data = (schar*) Const_Object;
  l = 0;
  j = 0;
  p = 0;
  while (!ModelErr) {
    if (Object[p][0] < 0)
      break;
    ObjIndex[p] = j;
    k =0;
    while (!ModelErr) {
      i = Object[p][k++];
      if (i < 0) break;
      if (j == MAX_OBJECT) {
        ModelErr = 1;
        printf("MAX_OBJECT limited (%i,%i)\n",p,k-1);
      }
      if (i < 32)
        i += OWNOBJ;
      else
        i -= 32;
      Data[j] = i*2;
      i = Object[p][k++];
      if (i < 0) i = l;
      else {
        i = (Object[p][k++] << 1) | (!i);
        i = (i << 4) | Object[p][k++];
      }
      l = i;
      Data[j+MAX_OBJECT] = i;
      j++;
    }
    p++;
  }
  Pos = MAX_OBJECT*2*2;

  fprintf(Inc,"\n\nNO_OBJECT = %i\n",j);
  IncDump("Const_Object");
#ifdef FILEDUMP
  int h = open("object.dat",O_RDWR | O_CREAT | O_TRUNC ,S_IWRITE | S_IREAD);
  write(h,Data,(Pos+1)>>1);
  close(h);
#endif
  memcpy(&Const_Object2,&Const_Object,sizeof(Const_Object));
  return ModelErr;
}

int reloc[256][3];

int AnimInit() {
  int i,j,l,p,p2,save[64];
  int r;
  Pos = 0;
  i = 0;
  k = 0;
  r = 0;
  memset(&Const_Code,0,sizeof(Const_Code));
  ModelErr = 0;
  Data = Const_Code;
  l = 0;
  p = 0;
  while (!ModelErr) {
    if (Anim[p][0] > 15) break;
//    Pos = (Pos +1) & ~1;
    save[p] = Pos;
    while (!ModelErr) {
      i = Anim[p][k++];
      if (i > 15)
        break;
      Push4(i,"");
      switch (i) {
        case AEND:
          break;
        case AWAIT:
          Push4(Anim[p][k++],"Wait");
          break;
        case AJMP:
          reloc[r][0] = Pos;
          reloc[r][1] = p+Anim[p][k++];
          reloc[r][2] = 0; //Anim[p][k++];
          r++;
          PushS8(0,NULL);
          break;
        case AFADE:
          break;
        case ASIZE:
          i = Anim[p][k++];
          if (i>0)
            Push4(((i-1) << 1)|1,"Size");
          else
            if (i==0) Push4(0,NULL);
            else Push4(15,NULL);
          break;
        case APROC:
          reloc[r][0] = Pos;
          reloc[r][1] = p+Anim[p][k++];
          reloc[r][2] = 0; //Anim[p][k++];
          r++;
          PushS8(0,NULL);
          PushS8(ObjIndex[Anim[p][k]]+Anim[p][k+1]-128,"Proc ObjNo");
          k += 2;
          Push4(Anim[p][k+1],"Proc dDelay");
          i = Anim[p][k];
          if (i > 8) i = (i+8) >> 1;
          Push4(i,"Proc Count");
          k += 2;
          break;
        case AADJUST:
          Push4(Anim[p][k++],"Adjust");
          break;
        case ANODPOS:
        case ANODDIR:
        case ANODOFS:
          break;
        case APOS:
        case ADIR:
        case AOFS:
        case ADPOS:
        case ADDIR:
        case ADOFS:
          PushSL4(Anim[p][k++],"Vector X");
          PushSL4(Anim[p][k++],"Vector Y");
          PushSL4(Anim[p][k++],"Vector Z");
          break;
      }
    }
    p++;
    k = 0;
  }
  i = Pos;
  for (k=0;k<r;k++) {
    Pos = reloc[k][0];
    PushS8(save[reloc[k][1]]+reloc[k][2]-(Pos+2),"Realloc");
  }
  Pos = i;
  if (MainAnim > 0) {
    Pos = save[MainAnim];
    IncDump(NULL);
    Data += i >> 1;
    Pos = i - Pos;
  }
  IncDump("Const_Code");
#ifdef FILEDUMP
  int h = open("anim.dat",O_RDWR | O_CREAT | O_TRUNC ,S_IWRITE | S_IREAD);
  write(h,Data,(Pos+1)>>1);
  close(h);
#endif
  return ModelErr;
}

void main() {
  long l2,l3;
  ulong l,vc,fc,oc,phy;
  int Quit = FALSE;
  int ch,i,j,n,k,Anim;
  int a,b;
  int S[3] = {0,0,0};
  int P[3] = {0,0,0};
  int P2[3] = {0,0,0};
  Inc = fopen("scene.inc","w+");
  if (ModelInit())
    return;
  if (ObjectInit())
    return;
  if (AnimInit())
    return;
  fclose(Inc);
  BaseMem = (byte*)((((ulong)malloc((word)0x700000UL) + 13*4) | 0xFFFF)+1);
  ZBuffer = (ulong*) ( BaseMem + 0x1000 );
  VirtScreen = (byte*) ((char*)ZBuffer + 0x40000 );
  Vertex = (struct tVertex*) ((char*) ZBuffer + 0x60000);
  Face = (struct tFace*) ((char*) ZBuffer + 0x460000);
  Textures = (byte*) ((char*) BaseMem + 0x580000 );
  ColorMap = (byte*) ((char*) BaseMem + 0x600000 );
  PMode_Data.Screen = (byte*) 0xA0000;
  DebugInit();

  ZeroReg386();
  Reg386.w.ax = 0x13;
  Int386( 0x10, NULL );
  ZeroReg386();
  byte* p = (byte*) DosAlloc( 768 );
  memcpy(p,&VGAPal,768);
  phy = PtrToPhy( p );
  Reg386.w.ax = 0x1012;
  Reg386.w.cx = 0x100;
  Reg386.w.dx = (ushort)(phy & 0xF);
  Reg386.w.es = (ushort)(phy >> 4);
  Int386X( 0x10, NULL );
  DosFree(p);
  ZeroReg386();
  Reg386.w.ax = 0x1130;
  Reg386.b.bh = 0x06;
  Int386X( 0x10, NULL );
  memcpy( &CharMap, LowToPtr( Reg386.w.es, Reg386.w.bp ), 0x1000);
  ProtMain();
/*
  i = open("colormap.dat",O_RDONLY);
  if (i == -1) {
//    Pal_Generate();
    i = open("colormap.dat",O_RDWR | O_CREAT | O_TRUNC ,S_IWRITE | S_IREAD);
    write(i,ColorMap,0x10000);
    close(i);
  }
  else {
    read(i,ColorMap,0x10000);
    close(i);
  }
*/
  p = VirtScreen+0x10000;
//  memset(p,31,0x10000);
  for (i=0;i<8;i++) {
    for (j=0;j<32;j++) {
      memset(p,0x20*i + j,4);
      memset(p+320,0x20*i + j,4);
      memset(p+640,0x20*i + j,4);
      memset(p+960,0x20*i + j,4);
      p += 4;
    }
    p += 320*4-32*4;
  }
//  memset( VirtScreen + 0x10000,0,0x10000);

//  DebugDone();
//  CheckMatrix();
//  return;

//  for (i=0;i<255;i++) DumpModel(i);
//  DebugDone();
//  return;

/*
  n = 0;
  j = 4;
    for (i=0;i<8;i++) {
      DrawTexture(Textures+i*0x10000,j,VirtScreen+(n%5)*64+(n/5)*64*320);
      n++;
    }
  DebugDraw();
  ch = getch();
  for (i=0;i<8;i++) {
    if (ch == 27)
      break;
    DrawTexture2(Textures+i*0x10000,4);
    DebugDraw ();
    ch = getch();
  }
*/

  DebugDraw();

  n =i = 0;
  l = clock();
  int tn,cn,ref,All;
  tn = 4;
  cn = 3;
  ref = 1;
  k = 96;
  Anim = TRUE;
  All = FALSE;
  ClearAll();
  if (!Anim) AddObject(k,0,0,0,0,0,0);
//  TestObject();
//  AddObject(0,0,0,0,0,0,0);
  DFL_Ambient = 0;
  printf("\n\n\n\n");
  l3 = clock();
  while (!Quit) {
    if (kbhit()) {
      ch = toupper(getch());
      if (ch == 0)
        ch = getch() << 8;
      switch (ch) {
        case '/':
          if (DFL_Ambient > 0) DFL_Ambient-=8;
          break;
        case '*':
          if (DFL_Ambient < 64) DFL_Ambient+=8;
          break;
        case ' ':
          ClearAll();
//          P2[1] = -3;
          Print("THE END",0);
//          Print("www.scene-hu.com",0);
//          Print("PICARD\nDISCLAIMER",0);
          break;
        case '+':
          if (!Anim) {
            ClearAll();
            AddObject(++k,0,0,0,0,0,0);
          }
          else
            l3 -= CLOCKS_PER_SEC*4;
          break;
        case '-':
          if (!Anim) {
            ClearAll();
            AddObject(--k,0,0,0,0,0,0);
          }
          else
            l3 -= CLOCKS_PER_SEC;
          break;
        case '2':
          if (tn < 7) tn++;
          break;
        case '1':
          if (tn > 0) tn--;
          break;
        case '4':
          if (cn < 15) cn++;
          break;
        case '3':
          if (cn > 0) cn--;
          break;
        case '5':
          ref = (ref+1) & 1;
          break;
        case 'Q':
          S[0]++;
          break;
        case 'A':
          S[0]--;
          break;
        case 'Z':
          S[0] = 0;
          break;
        case 'W':
          S[1]++;
          break;
        case 'S':
          S[1]--;
          break;
        case 'X':
          S[1] = 0;
          break;
        case 'E':
          S[2]++;
          break;
        case 'D':
          S[2]--;
          break;
        case 'C':
          S[2] = 0;
          break;
        case 72*256:
          P[1] = 16;
          break;
        case 80*256:
          P[1] = -16;
          break;
        case 75*256:
          P[0] = 16;
          break;
        case 77*256:
          P[0] = -16;
          break;
        case 73*256:
          P[2] = 16;
          break;
        case 81*256:
          P[2] = -16;
          break;
        case 27:
          Quit = TRUE;
          break;
        case '7':
          All = !All;
          break;
        case '6':
          Anim = !Anim;
          ClearAll();
          if (!Anim)
            AddObject(k,0,0,0,0,0,0);
      }
    }
    if (Quit)
      break;
    VirtScreen[n] = 31+16;
    n = (n+1) % 320;
    i++;
    if (!Anim) {
      for (b=0;b<32;b++) {
        Const_Object[b+MAX_OBJECT] = (((tn << 1) | ref) << 4) + cn;
        for (a=0;a<3;a++) {
          Objects[b].Dir[a] += S[a] * 0x200;
          Objects[b].Pos[a] += P[a] * 0x800;
        }
      }
    }
    else {
      if (!All) {
        l2 = clock();
        if (l3 < l2) {
          l3 = 100*(l2-l3)/CLOCKS_PER_SEC;
          while (l3-- > 0) Int_Timer();
        }
        l3 = l2;
      }
      else Int_Timer();
    }
    for (a=0;a<3;a++)
      P[a] = P2[a];
    if (DebugLoop())
      ClearAll();
    if (!Anim) {
      printf("%i %i     \r",tn,cn);
    }
  }
  l = clock()-l;
  DebugDone();
  Inc = NULL;
  vc = fc = oc = 0;
#ifdef FILEDUMP
  Inc = fopen("debug.inc","w+");
#endif
  for (j=0;j<256;j++) {
    if (Objects[j].Size & 1) {
      oc++;
      vc += Models[Const_Object[j] >> 1].VEnd - Models[Const_Object[j] >> 1].VStart;
      fc += Models[Const_Object[j] >> 1].FEnd - Models[Const_Object[j] >> 1].FStart;
      if (Inc)
       fprintf(Inc,"%i\n  Size:%i V:%i F:%i\n  Pos:%5.2f:%5.2f:%5.2f\n  Dir:%5.2f:%5.2f:%5.2f\n  Ofs:%5.2f:%5.2f:%5.2f\n",
        j,Objects[j].Size >> 1,Models[Const_Object[j] >> 1].VEnd - Models[Const_Object[j] >> 1].VStart,
        Models[Const_Object[j] >> 1].FEnd - Models[Const_Object[j] >> 1].FStart,
        (float)Objects[j].Pos[0]/65536,(float)Objects[j].Pos[1]/65536,(float)Objects[j].Pos[2]/65536,
        (float)Objects[j].Dir[0]/65536,(float)Objects[j].Dir[1]/65536,(float)Objects[j].Dir[2]/65536,
        (float)Objects[j].Ofs[0]/65536,(float)Objects[j].Ofs[1]/65536,(float)Objects[j].Ofs[2]/65536);
    }
  }
  if (Inc) fclose(Inc);
  printf("OCount :%lu\n",oc);
  printf("VCount :%lu\n",vc);
  printf("FCount :%lu\n",fc);
  printf("AllVCount :%lu\n",VCount);
  printf("AllFCount :%lu\n",FCount);
  printf("Frames :%u\n",i);
  printf("Seconds:%7.2f\n",(float)l/CLOCKS_PER_SEC);
  printf("Speed  :%5.2f\n",(float)i/l*CLOCKS_PER_SEC);
}

