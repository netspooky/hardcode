#ifndef __ficken3d_h
#define __ficken3d_h

#pragma pack(0);

typedef unsigned char           sU8;    // Basic integer types
typedef signed char             sS8;
typedef unsigned short          sU16;
typedef signed short            sS16;
typedef unsigned long           sU32;
typedef signed long             sS32;
typedef unsigned __int64        sU64;
typedef signed __int64          sS64;
typedef signed long             sInt;   // minimal 16 bit signed
typedef signed long             sLong;  // minimal 32 bit signed, possibly 64

sS32 sMulDiv64(sS32 a,sS32 b,sS32 c);           // return a*b/c;
sS32 sMul64(sS32 a,sS32 b);                  // return (a*b)>>16
sS32 sMul64_U(sS32 a,sS32 b);                  // return a*b/sUNITONE (sUNITONE = 0x4000)
sU32 sMul64_H(sU32,sU32);                       // return (a*b)>>32
sS32 sMul2Cmp64(sS32 a,sS32 b,sS32 c,sS32 d);   // return (a*b)-(c*d)>>32
sS32 sDiv64(sS32 a,sS32 b);                  // return (a>>32)/b
void sAdd64(sU32 *d,sU32 *s);
void sSub64(sU32 *d,sU32 *s);
sS32 sDiv64Save(sS32 a,sS32 b);

void fist32 (int * dst, float src);
#pragma aux fist32 = \
"   fistp  dword [eax]  "\
parm [eax] [8087] modify exact [8087]


void fist16 (short * dst, double src);
#pragma aux fist16 = \
"   fistp  word [eax]  "\
parm [eax] [8087] modify exact [8087]


#pragma aux sMulDiv64 = \
" imul ebx "            \
" idiv ecx "            \
  parm [eax][ebx][ecx]  \
  value [eax]           \
  modify [ebx ecx edx]  ;

#pragma aux sMul64 =    \
" imul ebx    "         \
" mov  ax,dx  "         \
" ror  eax,16 "         \
  parm [eax][ebx]       \
  value [eax]           \
  modify [ebx edx]      ;

#pragma aux sMul64_U =  \
" imul ebx    "         \
" shrd eax,edx,14  "    \
  parm [eax][ebx]       \
  value [eax]           \
  modify [ebx edx]      ;

#pragma aux sMul64_H  = \
" mul  ebx    "         \
" mov  ax,dx  "         \
  parm [eax][ebx]       \
  value [edx]           \
  modify [ebx edx]      ;

#pragma aux sMul2Cmp64= \
" imul edx    "         \
" push edx    "         \
" push eax    "         \
" mov  eax,ecx"         \
" imul ebx    "         \
" pop  ebx    "         \
" pop  ecx    "         \
" sub  ebx,eax"         \
" sbb  ecx,edx"         \
  parm [eax][edx][ecx][ebx] \
  value [ecx]           ;

#pragma aux sDiv64 =    \
" mov  edx,eax "        \
" shl  eax,16  "        \
" sar  edx,16  "        \
" idiv ebx     "        \
  parm [eax][ebx]       \
  value [eax]           \
  modify [ebx edx]      ;

#pragma aux sAdd64 =    \
" mov  eax,[esi] "      \
" add  [edi],eax "      \
" mov  eax,4[esi] "     \
" adc  4[edi],eax "     \
  parm [edi][esi]       \
  modify [eax]          ;

#pragma aux sSub64 =    \
" mov  eax,[esi] "      \
" sub  [edi],eax "      \
" mov  eax,4[esi] "     \
" sbb  4[edi],eax "     \
  parm [edi][esi]       \
  modify [eax]          ;

#pragma aux sDiv64Save = \
" cmp  ebx, 10000h      "\
" jle  special          "\
" mov  edx,eax          "\
" shl  eax,16           "\
" sar  edx,16           "\
" idiv ebx              "\
" jmp  weiter           "\
"special:               "\
" push ecx              "\
" xor  edx, edx         "\
" mov  ecx, eax         "\
" mov  eax, 40000000h   "\
" idiv ebx              "\
" imul ecx              "\
" pop  ecx              "\
" shrd eax, edx, 14     "\
" weiter:               "\
  parm [eax][ebx]        \
  value [eax]            \
  modify exact [ebx edx];


extern const float M_PI;
extern const float M_PI2;

extern void * SurfacePtr;
extern long SurfacePitch;
extern long PolyColor;

#define CLIPFLAG_LEFT   1
#define CLIPFLAG_RIGHT  2
#define CLIPFLAG_TOP    4
#define CLIPFLAG_BOTTOM 8

#define EDGEMODE_NONE     0
#define EDGEMODE_EDGES    1
#define EDGEMODE_FRONT    2
#define EDGEMODE_ALL      3

extern long  engine_xmin;
extern long  engine_ymin;
extern long  engine_xmax;
extern long  engine_ymax;
extern float EdgeFrontScale;

typedef struct
{
  float x,y,z;
} tvector;

typedef struct
{
  sU16 a ,b ,c;
  sU16 ea,eb,ec;
  sU32 pad;
} face;

typedef struct
{
  sU32       nfaces;
  sU32       nvertices;
  sU32       nedges;
  sU8      * edgevis;
  tvector  * vertices;
  face     * faces;
  sU32     * edges;
} object;


typedef struct
{
  int    npoly;   /* # of triangles in object */
  float *poly;    /* Triangles */
} rawobject;

void      Engine_Init          (void);
void      Engine_Done          (void);
void      Engine_DrawObject    (object *o, float * matrix, int EdgeMode);
void      Engine_FreeObject    (object *o);
void      Engine_CalcEdges     (object *o);
void      Engine_SetSubPal     (int fak);

object *  Engine_InitObjectRaw (tvector *list, int npolys);
object *  Engine_AllocObject   (int vertices, int faces);

extern float  engine_scale;

#endif
