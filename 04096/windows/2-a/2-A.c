#include "windows.h"
#include "xmmintrin.h"

#define W 1920
#define H 1080

#define TILESIZE 8
#define MAXSTEPS 256
#define MINDIST (2e-5)

#define NOBJECTS 42
#define NCOLORS 16
#define NCHAIR 14

#define NOTHING 0
#define SPHERE 1
#define BOX 2
#define PLANE 3
#define CYLINDER 4
#define HBOX 5

__m128 color_table[NCOLORS]=
{
{0.6f,0.3f,0.0f,1.f},
{0.8f,0.8f,0.8f,1.f},
{0.0f,0.15f,0.0f,1.f},
{0.25f,0.1f,0.05f,1.f},
{1.0f,1.0f,1.0f,1.f},
{0.95f,0.90f,0.80f,1.f},
};
#define CBROWN 0
#define CGREY 1
#define CDGREEN 2
#define CBLACK 3
#define CWHITE 4
#define CBUFF 5

typedef struct
{
int type;
int color;
int direction;
float reflect;
int texture;
float tweight;
float pos[4];
float size[4];
} Object;

Object objects[NOBJECTS]=
{
{BOX,
0,0,0.0f,0,0.0f,
{0.0f,1.5f,2.5f,0.0f},
{4.0f,1.5f,4.0f,0.0f}},
{CYLINDER,
CWHITE,1,0.0f,0,0.5f,
{0.25f,0.0f,0.03f,0.015f},
{0.0f,0.0f,0.0f,0.42f}},
{CYLINDER,
CWHITE,1,0.0f,0,0.5f,
{-0.25f,0.0f,0.03f,0.015f},
{0.0f,0.0f,0.0f,0.42f}},
{CYLINDER,
CWHITE,1,0.0f,0,0.5f,
{0.25f,0.0f,-0.45f,0.015f},
{0.0f,0.0f,0.0f,0.80f}},
{CYLINDER,
CWHITE,1,0.0f,0,0.5f,
{-0.25f,0.0f,-0.45f,0.015f},
{0.0f,0.0f,0.0f,0.80f}},
{BOX,
CBROWN,0,0.05f,3,0.5f,
{0.0f,-0.42f,-0.18f,0.0f},
{0.28f,0.01f,0.26f,0.0f}},
{BOX,
CBROWN,0,0.0f,3,0.5f,
{0.0f,-0.72f,-0.45f,0.0f},
{0.29f,0.10f,0.01f,0.0f}},
{CYLINDER,
CWHITE,1,0.0f,0,0.5f,
{0.38f,0.0f,0.05f,0.015f},
{0.0f,0.0f,0.0f,0.65f}},
{CYLINDER,
CWHITE,1,0.0f,0,0.5f,
{-0.38f,0.0f,0.05f,0.015f},
{0.0f,0.0f,0.0f,0.65f}},
{CYLINDER,
CWHITE,1,0.0f,0,0.5f,
{0.38f,0.0f,0.5f,0.015f},
{0.0f,0.0f,0.0f,0.65f}},
{CYLINDER,
CWHITE,1,0.0f,0,0.5f,
{-0.38f,0.0f,0.5f,0.015f},
{0.0f,0.0f,0.0f,0.65f}},
{BOX,
CGREY,2,0.0f,0,0.0f,
{0.0f,-0.60f,0.28f,0.0f},
{0.36f,0.04f,0.25f,0.01f}},
{BOX,
CBROWN,0,0.05f,3,0.5f,
{0.0f,-0.66f,0.28f,0.0f},
{0.40f,0.01f,0.27f,0.0f}},
{CYLINDER,
CWHITE,2,0.0f,0,0.0f,
{-0.38f,-0.2f,0.275f,0.015f},
{0.0f,0.0f,0.0f,0.225f}},
{CYLINDER,
CWHITE,2,0.0f,0,0.0f,
{0.38f,-0.2f,0.275f,0.015f},
{0.0f,0.0f,0.0f,0.225f}},
{PLANE,
CBROWN,1,0.050f,1,0.4f,
{0.0f,0.0f,0.0f,1.5f},
{0.0f,0.0f,0.0f,0.0f}},
{PLANE,
CBUFF,2,0.0f,2,0.15f,
{0.0f,0.0f,0.0f,8.0f},
{0.0f,0.0f,0.0f,0.0f}},
{PLANE,
CBUFF,1,0.0f,0,0.0f,
{0.0f,0.0f,0.0f,-1.5f},
{0.0f,0.0f,0.0f,0.0f}},
{PLANE,
CBUFF,0,0.0f,2,0.25f,
{0.0f,0.0f,0.0f,4.0f},
{0.0f,0.0f,0.0f,0.0f}},
{BOX,
CBLACK,0,0.0f,2,0.25f,
{4.0f,1.5f,6.5f,0.0f},
{0.05f,2.0f,0.4f,0.05f}},
{BOX,
CBROWN,0,0.0f,4,0.25f,
{4.0f,1.5f,6.5f,0.0f},
{0.02f,1.95f,0.38f,0.0f}},
{BOX,
CBROWN,0,0.0f,3,0.6f,
{0.0f,1.5f,8.0f,0.0f},
{2.6f,0.15f,0.5f,0.0f}},
{BOX,
CBROWN,0,0.0f,4,0.25f,
{0.0f,1.5f,7.4f,0.0f},
{0.48f,0.80f,0.2f,0.0f}},
{BOX,
CBROWN,0,0.0f,3,0.5f,
{0.0f,0.7f,7.4f,0.0f},
{0.52f,0.015f,0.24f,0.0f}},
{BOX,
CWHITE,2,0.0f,0,0.0f,
{0.0f,0.0f,8.0f,0.0f},
{2.4f,0.6f,0.05f,0.03f}},
{BOX,
CWHITE,0,0.0f,0,0.0f,
{0.0f,0.5f,8.0f,0.0f},
{2.4f,0.015f,0.15f,0.0f}},
{BOX,
CDGREEN,0,0.0f,2,0.5f,
{0.0f,0.0f,8.0f,0.0f},
{2.4f,0.6f,0.02f,0.0f}},
{BOX,
CWHITE,2,0.0f,0,0.0f,
{3.1f,0.0f,8.0f,0.0f},
{0.32f,0.4f,0.05f,0.04f}},
{BOX,
CGREY,2,0.0f,0,0.0f,
{3.1f,0.0f,8.0f,0.0f},
{0.32f,0.4f,0.02f,0.0f}},
{BOX,
CGREY,2,0.0f,0,0.0f,
{-3.2f,0.5f,8.0f,0.0f},
{0.3f,1.0f,0.3f,0.05f}},
{BOX,
CGREY,2,0.0f,0,0.0f,
{-3.2f,0.35f,8.0f,0.0f},
{0.3f,0.25f,0.3f,0.04f}},
{BOX,
CBUFF,0,0.0f,2,0.25f,
{-4.0f,0.0f,8.0f,0.0f},
{0.2f,2.0f,0.2f,0.0f}},
{BOX,
CBUFF,0,0.0f,2,0.25f,
{4.0f,0.0f,8.0f,0.0f},
{0.2f,2.0f,0.2f,0.0f}},
{BOX,
CBUFF,0,0.0f,2,0.25f,
{0.0f,-1.5f,8.0f,0.0f},
{5.0f,0.25f,0.1f,0.0f}},
{BOX,
CBUFF,0,0.0f,0,0.25f,
{-4.1f,1.3f,4.0f,0.0f},
{0.1f,0.5f,4.0f,0.0f}},
{BOX,
CBUFF,0,0.0f,0,0.25f,
{-4.1f,-1.5f,4.0f,0.0f},
{0.1f,0.5f,4.0f,0.0f}},
{BOX,
CBUFF,0,0.0f,0,0.0f,
{-4.1f,-0.1f,4.0f,0.0f},
{0.02f,0.04f,4.0f,0.0f}},
{BOX,
CBUFF,0,0.0f,0,0.0f,
{-4.1f,0.0f,6.9f,0.0f},
{0.02f,2.0f,0.04f,0.0f}},
{BOX,
CBUFF,0,0.0f,0,0.0f,
{-4.1f,0.0f,6.0f,0.0f},
{0.02f,2.0f,0.04f,0.0f}},
{CYLINDER,
CWHITE,2,0.0f,0,0.0f,
{0.0f,-0.9f,8.0f,0.2f},
{0.0f,0.0f,0.0f,0.03f}},
{BOX,
CGREY,0,0.0f,0,0.0f,
{0.0f,-1.0f,8.0f,0.2f},
{0.01f,0.1f,0.05f,0.0f}},
{BOX,
CGREY,0,0.0f,0,0.0f,
{-0.1f,-0.9f,8.0f,0.2f},
{0.1f,0.01f,0.05f,0.0f}},
};

__m128 c_light_pos={-6.0f,-0.95f,4.5f,0.0f};
__m128 c_mlight_pos={-3.5f,-0.5f,6.0f,0.0f};
__m128 c_light_color={1.0f,1.0f,1.0f,0.0f};
__m128 c_neg0={-0.0f,-0.0f,-0.0f,-0.0f};
__m128 c_f02={0.2f,0.2f,0.2f,0.2f};
__m128 c_f05={0.5f,0.5f,0.5f,0.5f};
__m128 c_f100={10.0f,10.0f,10.0f,10.0f};
__m128 c_zero={0.0f,0.0f,0.0f,0.0f};
__m128 c_one={1.0f,1.0f,1.0f,1.0f};
__m128 c_f200={20.0f,20.0f,20.0f,20.0f};
__m128 c_1k={1024.0f,1024.0f,1024.0f,1024.0f};
__m128 c_eps={0.0f,0.0f,1e-5f,0.0f};
__m128 c_v001={0.0f,0.0f,1.0f,0.0f};
__m128 c_v010={0.0f,1.0f,0.0f,0.0f};
__m128 c_v011={0.0f,1.0f,1.0f,0.0f};
__m128 c_v100={1.0f,0.0f,0.0f,0.0f};
__m128 c_v101={1.0f,0.0f,1.0f,0.0f};
__m128 c_v110={1.0f,1.0f,0.0f,0.0f};
__m128 c_v111={1.0f,1.0f,1.0f,0.0f};
__m128 c_vlls={4.0f,4.0f,0.25f,0.0f};
__m128 c_vsll={1.0f,4.0f,4.0f,0.0f};
__m128 c_vlsl={4.0f,1.0f,4.0f,0.0f};
__m128 c_nscale={4.0f,4.0f,4.0f,0.0f};
__m128 c_noise={123.f,123.f,123.f,120.f};
__m128 c_const1={1.2f,1.2f,1.2f,1.2f};
__m128 c_const2={0.6f,0.6f,0.6f,0.6f};
__m128 c_ao_step={0.02f,0.02f,0.02f,0.02f};
__m128 c_chairscale={1.6f,3.0f,1.6f,1.0f};

float SHUFFLE_LUT[4][4]={
{1.0f,1e-4f,1e-4f,1e-4f},
{1e-4f,1.0f,1e-4f,1e-4f},
{1e-4f,1e-4f,1.0f,1e-4f},
{1e-4f,1e-4f,1e-4f,1e-4f}};

float tmp[4]={0.0f,0.0f,0.0f,0.0f};

int buf[H*W];

__m128 _dot(__m128 a,__m128 b)
{
a=_mm_mul_ps(a,b);
b=a;
b=_mm_shuffle_ps(b,b,_MM_SHUFFLE(0,0,2,1));
a=_mm_add_ps(a,b);
b=_mm_shuffle_ps(b,b,_MM_SHUFFLE(0,0,0,1));
a=_mm_add_ps(a,b);
a=_mm_shuffle_ps(a,a,0);
return a;
}

__m128 _len(__m128 a)
{
a=_dot(a,a);
a=_mm_sqrt_ps(a);
return a;
}

__m128 _floor(__m128 a)
{
int i,t;
for(i=0;i<4;++i)
 {
 t=_mm_cvt_ss2si(_mm_sub_ps(a,c_f05));
 a=_mm_cvt_si2ss(a,t);
 a=_mm_shuffle_ps(a,a,_MM_SHUFFLE(0,3,2,1));
 }
return a;
}

__m128 _mix(__m128 a,__m128 b,__m128 x)
{
x=_mm_shuffle_ps(x,x,0);
return _mm_add_ps(a,_mm_mul_ps(_mm_sub_ps(b,a),x));
}

__m128 _noise(__m128 p)
{
unsigned int i,t;

p=_mm_add_ps(p,c_noise);
p=_mm_add_ps(p,_len(p));
p=_mm_mul_ps(p,c_noise);

for(i=0;i<4;++i)
 {
 t=_mm_cvt_ss2si(p);
 t=(t<<13)^t;
 t=t*(t*t*18701+1000003);
 t&=1023;
 p=_mm_cvt_si2ss(p,t);
 p=_mm_shuffle_ps(p,p,_MM_SHUFFLE(0,3,2,1));
 }
p=_mm_div_ps(p,c_1k);
return p;
}

__m128 _snoise(__m128 p)
{
__m128 floor,frac,tx1,tx2,tx3,tx4;
floor=_floor(p);
frac=_mm_sub_ps(p,floor);
tx1=_mix(_noise(floor),_noise(_mm_add_ps(floor,c_v100)),frac);
tx2=_mix(_noise(_mm_add_ps(floor,c_v001)),_noise(_mm_add_ps(floor,c_v101)),frac);
tx3=_mix(_noise(_mm_add_ps(floor,c_v010)),_noise(_mm_add_ps(floor,c_v110)),frac);
tx4=_mix(_noise(_mm_add_ps(floor,c_v011)),_noise(_mm_add_ps(floor,c_v111)),frac);
tx1=_mix(tx1,tx2,_mm_shuffle_ps(frac,frac,2));
tx3=_mix(tx3,tx4,_mm_shuffle_ps(frac,frac,2));
tx1=_mix(tx1,tx3,_mm_shuffle_ps(frac,frac,1));
return tx1;
}

__m128 _perlin(__m128 p)
{
__m128 t=c_zero,divider=c_one;
int i;
p=_mm_mul_ps(p,c_nscale);
for(i=0;i<4;++i)
 {
 divider=_mm_div_ps(divider,c_f05);
 t=_mm_add_ps(t,_mm_div_ps(_snoise(p),divider));
 p=_mm_div_ps(p,c_f05);
 }
return t;
}
__m128 _texture(__m128 p,int material)
{
__m128 t,q,m,tw;
tw=_mm_set_ps1(objects[material].tweight);
switch(objects[material].texture)
 {
 case 1: t=_perlin(_mm_mul_ps(p,c_vlls));
         q=_mm_mul_ps(p,c_f100);
         m=_floor(q);
         if(_mm_cvtss_f32(_mm_sub_ps(q,m))<0.1f){t=c_zero;break;}
         q=_mm_shuffle_ps(p,p,2);
         q=_mm_add_ps(q,_mm_mul_ps(m,c_f02));
         if(_mm_cvtss_f32(_mm_sub_ps(q,_floor(q)))<0.02f)t=c_zero;
         break;
 case 2: t=_perlin(p);break;
 case 3: t=_perlin(_mm_mul_ps(p,c_vsll));break;
 case 4: t=_perlin(_mm_mul_ps(p,c_vlsl));break;
 default: return c_one;
 }
t=_mm_mul_ps(t,tw); t=_mm_add_ps(t,_mm_sub_ps(c_one,tw));
return _mm_shuffle_ps(t,t,0);
}
__m128 _normalize(__m128 p)
{
__m128 a=_len(p);
p=_mm_div_ps(p,a);
return p;
}

__m128 _bump(__m128 p,__m128 dir,int material)
{
if(objects[material].texture==1)
 {
 dir=_mm_add_ps(dir,_mm_div_ps(_perlin(_mm_mul_ps(p,c_f05)),c_f200)),
 dir=_normalize(dir);
 }
return dir;
}

__m128 _plane(int i,__m128 p)
{
__m128 t,q;
float x;
t=c_one;
x=objects[i].pos[3];
q=_mm_loadu_ps(SHUFFLE_LUT[objects[i].direction]);
if(x>0.0f)
 t=_mm_xor_ps(q,c_neg0);
else
 t=q,x=-x;
p=_dot(p,t);
p=_mm_add_ps(p,_mm_set_ps1(x));
p=_mm_shuffle_ps(p,p,0);
return p;
}

__m128 _box(int i,__m128 p)
{
__m128 origin,t,p_in,p_out,border;
origin=_mm_loadu_ps(objects[i].pos);
p=_mm_sub_ps(p,origin);
p=_mm_andnot_ps(c_neg0,p);
border=_mm_set1_ps(objects[i].size[3]);

t=_mm_loadu_ps(objects[i].size);
p_out=_mm_sub_ps(p,t);
t=_mm_sub_ps(t,border);
t=_mm_div_ps(t,_mm_sub_ps(c_one,_mm_loadu_ps(SHUFFLE_LUT[objects[i].direction])));
p_in=_mm_sub_ps(p,t);

t=p_out;
p_out=_mm_shuffle_ps(p_out,p_out,_MM_SHUFFLE(0,0,2,1));
t=_mm_max_ss(t,p_out);
p_out=_mm_shuffle_ps(p_out,p_out,_MM_SHUFFLE(0,0,2,1));
t=_mm_max_ss(t,p_out);
t=_mm_min_ss(t,c_zero);
p_out=_mm_max_ps(p_out,c_zero);
p_out=_len(p_out);
p_out=_mm_add_ps(p_out,t);

if(objects[i].size[3]>0.0f)
{
t=p_in;
p_in=_mm_shuffle_ps(p_in,p_in,_MM_SHUFFLE(0,0,2,1));
t=_mm_max_ss(t,p_in);
p_in=_mm_shuffle_ps(p_in,p_in,_MM_SHUFFLE(0,0,2,1));
t=_mm_max_ss(t,p_in);
t=_mm_min_ss(t,c_zero);
p_in=_mm_max_ps(p_in,c_zero);
p_in=_len(p_in);
p_in=_mm_add_ps(p_in,t);
p_in=_mm_xor_ps(p_in,c_neg0);

p_out=_mm_max_ps(p_out,p_in);
}
p=_mm_shuffle_ps(p_out,p_out,0);
return p;
}

__m128 _cylinder(int i,__m128 p)
{
__m128 origin,t,q,len,pC,pL,pH;
origin=_mm_loadu_ps(objects[i].pos);
q=_mm_loadu_ps(SHUFFLE_LUT[objects[i].direction]);
p=_mm_sub_ps(p,origin);
pC=p;
pC=_mm_mul_ps(pC,_mm_sub_ps(c_one,q));
pC=_len(pC);
t=_mm_shuffle_ps(origin,origin,_MM_SHUFFLE(0,0,0,3));
pC=_mm_sub_ps(pC,t);

len=_mm_set_ps1(objects[i].size[3]);
pL=_dot(p,q);
pH=_mm_xor_ps(pL,c_neg0);
pL=_mm_sub_ps(pL,len);
pH=_mm_sub_ps(pH,len);


p=_mm_max_ps(pL,pH);
p=_mm_max_ps(p,pC);
p=_mm_shuffle_ps(p,p,0);
return p;
}

__m128 df(int *id,__m128 p)
{
int i;
__m128 mindist,t=c_f200;

mindist=c_f100;

for(i=NCHAIR;i<NOBJECTS;++i)
 {
 switch(objects[i].type)
  {
  case 0: t=c_f100; break;
  case 2: t=_box(i,p); break;
  case 3: t=_plane(i,p); break;
  case 4: t=_cylinder(i,p); break;
  }
 if(_mm_comile_ss(t,mindist))
  mindist=t,*id=i;
 }

if(_mm_cvtss_f32(_box(0,p))>0.0f)
 return _mm_shuffle_ps(mindist,mindist,0);

p=_mm_div_ps(p,c_chairscale);
p=_mm_sub_ps(p,_mm_set_ss(0.5f));
p=_mm_sub_ps(p,_floor(p));
p=_mm_sub_ps(p,c_f05);
p=_mm_mul_ps(p,c_chairscale);

for(i=1;i<NCHAIR;++i)
 {
 switch(objects[i].type)
  {
  case 2: t=_box(i,p); break;
  case 4: t=_cylinder(i,p); break;
  default: t=c_f100;
  }
 if(_mm_comile_ss(t,mindist))
  mindist=t,*id=i;
 }

return _mm_shuffle_ps(mindist,mindist,0);
}

__m128 _normal_(__m128 p)
{
__m128 probe,t,res;
int id;
probe=c_eps;
res=probe;

t=probe;
t=_mm_add_ps(t,p);
t=df(&id,t);
res=_mm_move_ss(res,t);
probe=_mm_shuffle_ps(probe,probe,_MM_SHUFFLE(0,0,2,0));
t=probe;
t=_mm_add_ps(t,p);
t=df(&id,t);
res=_mm_shuffle_ps(res,res,_MM_SHUFFLE(2,1,0,0));
res=_mm_move_ss(res,t);
probe=_mm_shuffle_ps(probe,probe,_MM_SHUFFLE(0,0,0,1));
t=probe;
t=_mm_add_ps(t,p);
t=df(&id,t);
res=_mm_shuffle_ps(res,res,_MM_SHUFFLE(2,1,0,0));
res=_mm_move_ss(res,t);
p=df(&id,p);
res=_mm_sub_ps(res,p);

res=_normalize(res);
return res;
}

__m128 _trace(__m128 start,__m128 dir,__m128 limit,int *pmaterial,__m128 *meta)
{
int i;
__m128 t,occ,occ_min=c_one,p=start;
dir=_normalize(dir);
for(i=0;i<MAXSTEPS;++i)
 {
 t=df(pmaterial,p);

 if(_mm_cvtss_f32(t)<MINDIST)
  break;
 if(_mm_ucomigt_ss(_len(_mm_sub_ps(p,start)),limit))
  {
  occ_min=_mm_shuffle_ps(occ_min,occ_min,0);
  *meta=occ_min;
  if(_mm_cvtss_f32(t)>MINDIST)
   *pmaterial=0;
  return p;
  }
 occ=_mm_mul_ps(t,c_f200);
 occ=_mm_div_ps(occ,_len(_mm_sub_ps(p,start)));
 occ_min=_mm_min_ss(occ_min,occ);
 p=_mm_add_ps(p,_mm_mul_ps(t,dir));
 }
*meta=c_zero;
return p;
}

__m128 _ao(__m128 p)
{
int i,a;
__m128 len,step,divider,sum,t;
sum=c_zero;
len=c_zero;
divider=c_one;
step=_mm_mul_ps(_normal_(p),c_ao_step);

for(i=0;i<6;++i)
 {
 p=_mm_add_ps(p,step);
 len=_mm_add_ps(len,c_ao_step);
 divider=_mm_div_ps(divider,c_f05);

 t=_mm_sub_ps(len,_mm_max_ps(c_zero,df(&a,p)));
 t=_mm_div_ps(t,len);
 sum=_mm_add_ps(sum,t);
 }
return _mm_sub_ps(c_one,_mm_div_ps(sum,c_f100));
}

__m128 _light(__m128 p,__m128 *from,int material)
{
__m128 start,dir,limit,normal;
__m128 color,light,shadow,ao,diff,specular,t,mcolor;
int a;
mcolor=color_table[objects[material].color];
mcolor=_mm_mul_ps(mcolor,_texture(p,material));

dir=_mm_sub_ps(c_light_pos,p);
limit=_len(dir);
dir=_normalize(dir);
normal=_normal_(p);
start=_mm_div_ps(dir,c_f200);
start=_mm_add_ps(start,p);
t=_trace(start,dir,limit,&a,&shadow);
ao=_ao(p);
if(objects[material].texture==1)
 ao=_mm_sub_ps(c_one,_mm_mul_ps(_mm_sub_ps(c_one,ao),c_f05));

light=_dot(dir,normal);
light=_mm_max_ps(light,c_zero);
light=_mm_mul_ps(light,c_light_color);
light=_mm_mul_ps(light,mcolor);
light=_mm_mul_ps(light,ao);

t=_mm_add_ps(shadow,c_const2);
t=_mm_mul_ps(t,c_const1);
diff=_mm_mul_ps(light,t);

specular=_dot(normal,*from);
specular=_mm_mul_ps(specular,normal);
specular=_mm_add_ps(specular,specular);
specular=_mm_sub_ps(*from,specular);
*from=specular;
specular=_dot(specular,_normalize(_mm_sub_ps(c_mlight_pos,p)));
specular=_mm_max_ps(specular,c_zero);
specular=_mm_mul_ps(specular,specular);
specular=_mm_mul_ps(specular,specular);
specular=_mm_mul_ps(specular,specular);
specular=_mm_mul_ps(specular,specular);
specular=_mm_mul_ps(specular,c_light_color);
specular=_mm_mul_ps(specular,shadow);

color=_mm_sub_ps(c_one,specular);
color=_mm_mul_ps(color,diff);
color=_mm_add_ps(color,specular);

color=_mm_min_ps(color,c_one);

return color;
}

void _pixel(int n,int x,int y)
{
int material;
__m128 color,meta,dir,p;
float reflected;
float ratio=(float)H/W;

tmp[0]=(((float)(x)/W)-0.85f)/ratio;
tmp[1]=(((float)(y)/H)-0.15f);
tmp[2]=1.25f;
tmp[3]=0.0f;


dir=_mm_loadu_ps(tmp);
dir=_normalize(dir);
p=_trace(_mm_set_ps(0.0f,0.0f,-1.0f,3.0f),dir,c_f200,&material,&meta);
color=_light(p,&dir,material);
reflected=objects[material].reflect;
if(reflected>0.0f)
 {
 color=_mm_mul_ps(color,_mm_set_ps1(1.0f-reflected));
 dir=_bump(p,dir,material);
 p=_mm_add_ps(p,_mm_div_ps(dir,c_f200));
 p=_trace(p,dir,c_f200,&material,&meta);
 color=_mm_add_ps(color,_mm_mul_ps(_light(p,&dir,material),_mm_set_ps1(reflected)));
 }

_mm_storeu_ps(tmp,color);
buf[n]=((int)(tmp[0]*255.f)<<16)+((int)(tmp[1]*255.f)<<8)+((int)(tmp[2]*255.f));
}

typedef struct
{
void *mutex;
long *tileID;
} ThreadData;


static unsigned long __stdcall doWord(void *vdata)
{
ThreadData *data=(ThreadData*)vdata;
WaitForSingleObject((HANDLE*)data->mutex,0);
int numtiles=W/TILESIZE;
for(;;)
{
int i,j,ia,ib;
int tile=InterlockedIncrement(data->tileID)-1;
if(tile>=numtiles)break;
ia=tile*TILESIZE;
ib=ia+TILESIZE;
for(i=ia;i<ib;i++)
for(j=0;j<H;j++)
 _pixel(W*j+i,i,j);
}
ReleaseSemaphore((HANDLE*)data->mutex,1,NULL);
return 1;
}

void render(int numCpus)
{
int i;
ThreadData idata[128];
HANDLE th[128];
HANDLE barrier;
__declspec(align(32)) long tileID=0;
if(numCpus>128)numCpus=128;
barrier=CreateSemaphore(0,numCpus,numCpus,0);
for(i=0;i<numCpus;++i)
 {
 unsigned long thid;
 idata[i].mutex=barrier;
 idata[i].tileID=&tileID;
 th[i]=CreateThread(0,0,doWord,idata+i,0,&thid);
 }
WaitForMultipleObjects(numCpus,th,1,INFINITE);
for(i=0;i<numCpus;++i)CloseHandle(th[i]);
CloseHandle(barrier);
}

BITMAPINFO bmi={{sizeof(BITMAPINFOHEADER),W,-H,1,32,0,0,0,0,0,0},{{0,0,0,0}}};

void entrypoint(void)
{
SYSTEM_INFO si;
GetSystemInfo(&si);

HWND w;
RECT r;
HDC dc;

w=CreateWindowEx(0,"edit",0,0x91000000,0,0,0,0,0,0,0,0);
dc=GetDC(w);
GetWindowRect(w,&r);
SetStretchBltMode(dc,HALFTONE);

render(si.dwNumberOfProcessors);

ShowCursor(0);
StretchDIBits(dc,0,0,r.right,r.bottom,0,0,W,H,buf,&bmi,0,0x00CC0020);
while(!GetAsyncKeyState(0x1B))
 Sleep(100);
ExitProcess(0);
}
