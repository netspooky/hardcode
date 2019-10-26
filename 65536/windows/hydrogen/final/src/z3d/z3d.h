#ifndef __Z3D_H_
#define __Z3D_H_

#include <math.h>
#include <windows.h>
#include <ddraw.h>

#include "..\base.h"
#include "..\color.h"
#include "..\globals.h"
#include "..\video.h"
//#include "..\zenith\zn_types.h"
#include "search.h"
#include "..\fontdata.h"

class TEXTURE_Z;

#include "..\txgen.h"

#pragma pack(push, enter_z3dh)

#define fogx_water_hi 0x60
#define fogx_water_lo 0x38
#define fogx 0x61 //value for fog table
#define fogx2 0x90
#define fogx_fog_lo   0x60
#define fogx_fog_hi   0xa0

#define PI  3.1415926

#define LOFT_COVER            1
#define LOFT_ENCLOSE          2

#define EXTRUDE_DOUBLESIDED   1

#define FOG_FOG               1
#define FOG_WATER             2

#define FONT_INTERLACED       1
#define FONT_FADEINOUT        2

#define LIGHT_AMBIENT         0
#define LIGHT_SPECULAR        1

#define SCENE_MAX_OBJECTS     256
#define SCENE_MAX_LIGHTS      16
#define SCENE_MAX_CAMERAS     8
#define SCENE_MAX_PLANES      100000

#define Z3D_MAX_SCENES        10
#define Z3D_MAX_TEXTURES      50
#define Z3D_MAX_TEMP_OBJECTS  32

//user processor type definitions
#define Z3D_UPR_PRECALC       0

#define SHADE_SOLID        0 
#define SHADE_FLAT         1 
#define SHADE_GOURAUD      2 
#define SHADE_PHONG        3

#define TEXTURIZE_PLANAR   0
#define TEXTURIZE_CYLINDER 1
#define TEXTURIZE_SPHERE   2


struct ANGLESYSTEM;
struct CSYSTEM;
class VERTEX;
class VECTOR;
struct PLANE;
class OBJECT;
class SCENE;
class CAMERA;
class MATRIX;

//----------------------------------
#pragma pack(1)
struct OBJECT_SELECTOR{
  ushort  scene_id;
  ushort  object_id;
};
//----------------------------------
struct PLANE_SELECTOR{
  SCENE   *scene;
  OBJECT  *object;
  PLANE   *plane;
  uint    plane_id;
};
//----------------------------------
class MATRIX{
public:
    long    a[4][4];
    void MakeEquality();
    int  Unpack(void *);
};
//----------------------------------
class TEXTURE_Z{
    COLOR *data;
  public:
    long  h,w;
    COLOR *GetDataPtr();
    void  Create(long w,long h);
    long  SetPixel(long x,long y,COLOR c);
    COLOR GetPixel(long x,long y);
};
//------------------------------
struct ANGLESYSTEM{
  ushort   ax,ay,az;
           ANGLESYSTEM(){ax=0;ay=0;az=0;};
};
//------------------------------
class VECTOR2D{
public:
  long    x2d;
  long    y2d;
};
//------------------------------
class VECTOR{
public:
          VECTOR (){x=0;y=0;z=0;};
          VECTOR (long x,long y,long z){this->x=x;this->y=y;this->z=z;};
  long    x,y,z;
  long    w;
  long    xworld,yworld,zworld;
  void    normalize();
  void    get_large_normalized(double x,double y,double z);
  void    to_camera(CSYSTEM*,CAMERA*,int translate,int to_wcs);
  void    operator*=(MATRIX&);
  VECTOR  operator*(long m);
  VECTOR  operator+(VECTOR &vx);
  VECTOR& operator+=(VECTOR &vx);
};
//------------------------------
class LIGHT:public VECTOR,public COLOR{
public:
  int      type;
                LIGHT(){type=LIGHT_AMBIENT; r=0;g=0;b=0;};
      void      Set(int type,long x,long y,long z,uint color);
};
//------------------------------
struct CSYSTEM:public VECTOR,public ANGLESYSTEM{
};
//------------------------------
class CAMERA:public CSYSTEM{
  public:
  RECT    rect; //Clipping rectangle
  LPDIRECTDRAWSURFACE7  surface;
  void    *data;
  long    pitch;
  long    width,height;
  long    *zbuffer;
  long    dist;
  int     fog;
  uchar   fog_intensity;
  long    dusk;
          CAMERA(){fog_intensity=255;dusk=0;fog=0;zbuffer=NULL;dist=(long)DEMO_BB_WIDTH<<16;z=-800L<<16;};
  void    Create(LPDIRECTDRAWSURFACE7 surface,RECT *cliprect);
  void    InitAndLock();
  void    Unlock();
  void Clear(COLOR color=0L);
};
//----------------------------
class VERTEX:public VECTOR,public VECTOR2D{
public:
  long     xw,yw,zw;
  VECTOR   Nw;
  long     w; //w==1/z
  long     u,v; //texture coords 
  void     project(CSYSTEM*,CAMERA*);
           VERTEX(){
             Nw.x=0;
             Nw.y=0;
             Nw.z=0;
           };
};

struct PLANE{
  uint   vindex[3];
  uint   vindex2d[3];
  VECTOR N;
  VECTOR Nw;
};
//------------------------------
#pragma pack(1)
struct SHAPE_PLANE{
  ushort    vindex[3];
};
//------------------------------
#pragma pack(1)
struct SHAPE_VERTEX{
  short    x;
  short    y;
};
//------------------------------
#pragma pack(1)
struct SHAPE_EDGE{
  ushort    vindex[2];
};
//------------------------------
struct SHAPE{
            SHAPE(){vertex=NULL;edge=NULL;plane=NULL;};
            ~SHAPE(){delete vertex;
                     delete edge;
                     delete plane;
                     };
  void      reset(uint vertexcount,uint edgecount,uint loftvertexcount,uint planecount);
  uint      loftvertexcount;
  uint      vertexcount;
  uint      edgecount;
  uint      planecount;
  SHAPE_VERTEX  *vertex;
  SHAPE_EDGE    *edge;
  SHAPE_PLANE   *plane;
  void      Transform(MATRIX*,int step=1);
  void      gnCircle(int cx,int cy,uint R,uint maxsteps,uint steps,double start_angle=0.0);
};
//------------------------------
class OBJECT:public COLOR,public CSYSTEM{
public:
  void      Cleanup();
  char      name[256];

  VERTEX    *vertex;
  PLANE     *plane;
  uint      vertexcount,
            planecount;

  int       standard_render;

//shading parameters
  int       shade;
  int       visible;
  int       shine;
  double    shininess;

  
  int     translucent;
  int     translucent_doublesided;
  int     translucent_stainglass;
  
  TEXTURE_Z  *texture;
  int       recycle_u,recycle_v;

        OBJECT();
        ~OBJECT();

  void  reset(uint vcount,uint pcount);
  void  calc_plane_normals();
  void  calc_vertex_normals();
  void  plane_sort_by_y_2d(uint);
  void  plane_normals_to_camera(CAMERA*);
  void  flip_plane_normals();
  
  virtual void render(SCENE *,uint);
  virtual void render_plane(SCENE *,uint,uint);

  void calc_light(SCENE *,long nx,long ny,long nz,uchar *c_r,uchar *c_g,uchar *c_b);

  void  operator+=(OBJECT &);
  void  Clone(OBJECT *);
  void  Array(uint count,MATRIX*);
  void  Transform(MATRIX*);
  void  Loft(uint count,MATRIX*,SHAPE*,uint flags);
  void  Extrude(SHAPE *shape,uint flags);
};
//---------------------------------
#define DECAL_LOOP          0x8000
#define DECAL_FORWARD       0
#define DECAL_BACKWARD      1
#define DECAL_PINGPONG      3
//---------------------------------
class DECAL:public VECTOR2D{
public:
  uint    w,h;
  uint    cx,cy;
  COLOR   **frame;
  uint    framecount;
  int     animation_type;
  uint    framedelay;
  uint    current_frame;

          DECAL(){
            frame=NULL;
            framecount=0;
            framedelay=1;
            current_frame=0;
            cx=0;
            cy=0;
            w=0;
            h=0;
            animation_type=DECAL_LOOP|DECAL_PINGPONG;
          }

          ~DECAL(){
            for (uint i=0;i<framecount;i++){
              delete frame[i];
            }
            delete frame;
          }

  void Create(uint w,uint h,uint framecount);
  COLOR *GetFrame(uint frame_index);
  int isEnd(uint frame_index);
  void Clear();
  void BltToSurface(LPDIRECTDRAWSURFACE7 surface,RECT *rect=NULL);
  void Play(){current_frame++;};
};
//---------------------------------
class DECAL_SPAWNER:public OBJECT{
  public:
  DECAL   *decal;
  CSYSTEM *bind_csystem;

  VERTEX  *spawnpoint;
  uint    *current_frame;
  int     *present;

  uint    spawncount;
  uint    killonend;

  virtual void render(SCENE *scene,uint camera_id);

  int Spawn(int x,int y,int z);
  int Spawn(CSYSTEM *source,VECTOR point);
  void Play();
  void Modulo();
  DECAL_SPAWNER();
  void Create(uint spawncount);
  ~DECAL_SPAWNER();
};
//---------------------------------
class BUBBLE_SPAWNER:public DECAL_SPAWNER{
public:
  VECTOR   *vel;
  VECTOR   *acc;
  
  long     end_y;
  
  BUBBLE_SPAWNER(){
    vel=NULL;
    acc=NULL;
    end_y=800L<<16;
  }

  ~BUBBLE_SPAWNER(){
    delete vel;
    delete acc;
  }

  void Create(uint spawncount);
  int Spawn();
  void Play();
};
//---------------------------------
class SCENE{
  void    zero_pointers(){
      ZeroMemory(object,SCENE_MAX_OBJECTS*sizeof(OBJECT*));
      ZeroMemory(light,SCENE_MAX_LIGHTS*sizeof(LIGHT*));
      ZeroMemory(camera,SCENE_MAX_CAMERAS*sizeof(CAMERA*));
  };
  public:
  OBJECT  *object[SCENE_MAX_OBJECTS];
  LIGHT   *light[SCENE_MAX_LIGHTS];
  CAMERA  *camera[SCENE_MAX_CAMERAS];
          SCENE(){
      zero_pointers();
    }

  void    render(int camera_id);
  void    Remove();
        ~SCENE(){Remove();};
};
//----------------------------------
class Z3D{
public:
  void    Init();
  CSYSTEM wcs;
  SCENE   scene[Z3D_MAX_SCENES];
  TEXTURE_Z *texture[Z3D_MAX_TEXTURES];
  void    TexturizeObject(uint type,uint scene_id,uint object_id,uint texture_id);
//  uint    keyframecount;
//  uint    constructorcount;
          ~Z3D();
};
//----------------------------------
class FONT{
  int     getpx(int x,int y,char *dat);
public:
  DECAL   *symbol[256];
          FONT();
          ~FONT();
  
  void    Unpack(char *abc,uchar *data,uint size,COLOR color,int frames,int flags);
  void    GetTextParam(char *string,int *w,int *h);
  void    Puts(DECAL *buf,char *string,int frame);
  void    PutsToSurface(int x,int y,char *string,LPDIRECTDRAWSURFACE7 surface,RECT *rect,int frame);
};
//----------------------------------

#pragma pack(pop, enter_z3dh)
#endif