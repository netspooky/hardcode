#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
//#define FULLSCREEN
#define CHECKEFFECT
#define USERCONTROL
#define XRES 1680
#define YRES 1050
#define ASPECT (XRES.f/YRES.f)

#include <math.h>
#include "windows.h"
#include "mmsystem.h"
#include <d3d9.h>
#include <d3dx9.h>
#ifndef _DEBUG
	extern "C" int _fltused = 1;
#endif

#ifdef FULLSCREEN
#define IsWindowed 0
#else
#define IsWindowed 1
#endif

#define Frustum D3DXMatrixPerspectiveFovRH
#define LookAt D3DXMatrixLookAtRH

#define SHADOWVAL ".005"

static const char effectSourceCode[] =\
// Params
"float4x4 pm,mvm,lvpm,mvpm,cp;"
"texture tx1,tx2,tx3;"
"float4 a,b;"
// Structures
"struct pso"
"{"
    "float4 cl:COLOR0;"   
    "float dp:DEPTH;"
"};"
"struct vso"
"{"
    "float4 psw:POSITION,cl:COLOR0,ps:TEXCOORD1,pt:TEXCOORD2;"
    "float2 tc:TEXCOORD0;" 
"};"
// Samplers
"sampler tx1s=" 
"sampler_state"
"{"
    "Texture=<tx1>;"    
    //"MinFilter=LINEAR;"
    //"MagFilter=LINEAR;"
    //"MipFilter=NONE;"
    //"AddressU=Clamp;"
    //"AddressV=Clamp;"
"};"
"sampler tx2s=" 
"sampler_state"
"{"
    "Texture=<tx2>;"    
    //"MinFilter=LINEAR;"
    //"MagFilter=LINEAR;"
    //"MipFilter=NONE;"
    //"AddressU=Clamp;"
    //"AddressV=Clamp;"
"};"
"sampler tx3s=" 
"sampler_state"
"{"
    "Texture=<tx3>;"    
    //"MinFilter=LINEAR;"
    //"MagFilter=LINEAR;"
    //"MipFilter=NONE;"
    //"AddressU=Clamp;"
    //"AddressV=Clamp;"
"};"
// vertexshader0 SPHERE_Shader
"vso VST0(float4 ps:POSITION,"
         "float2 tc:TEXCOORD0,"
         "float4 cl:COLOR0)"
"{"
    "vso o;"
    "cl.w*=20;"
    "tc=tc*2-1;"
    "o.pt=ps+a;"
    "o.cl=cl;"
    "o.psw=mul(mul(o.pt,mvm)+float4(tc*cl.w,0,0),pm);"
    "o.ps=o.psw;"
    "o.ps.xy=o.pt.xy+cl.w*13;"
    "o.tc=tc;" 
    "return o;"
"}"
// vertexshader1 Volume_Light_Shader
"vso VST1(float4 ps:POSITION,"
         "float2 tc:TEXCOORD0"
")"
"{"
  "vso o;"
  "tc=tc*8-4;"
  "ps=cp[3]+tc.x*cp[0]+tc.y*cp[1]-cp[2];"
  "o.psw=mul(mul(ps,mvm),pm);"
  "o.ps=ps;"
  "o.pt=0;"
  "o.cl=0;"
  "o.tc=0;"
  "return o;"
"}"
//vertexshader2 WaterMirror
"vso VST2(float4 ps:POSITION)"
"{"
    "vso o;"
    "o.pt=ps*.0025;"
    "o.cl=0;"
    "o.psw=mul(mul(ps,mvm),pm);"
    "o.ps=o.psw;"
    "o.tc=0;" 
    "return o;"
"}"
"float gs(float2 c)"//does the texture for the trees
"{"
"return max(.2,1.5-pow(sin(c.x*3+c.y*7+sin(c.x*12+c.y*3))+sin(c.x*10+c.y*15+sin(c.x*3+c.y*5)),1)+(sin(dot(c,1000))*.5));"
"}"
// pixelshader0 SPHERE_Shader
"pso PST0(vso i)"
"{"
  "pso o;"
  "float4 rn,n;n=float4(i.tc.xy,cos(length(i.tc.xy)*3.1416),0);" // calculate not rotated normal
  "clip(float2(i.pt.y,n.z));"
  "o.dp=(i.ps.z-n.z*i.cl.w)/(i.ps.w-n.z*i.cl.w);"
  "rn=normalize(n);" // rotate normal
  "float4 pz=mul((i.pt+rn*i.cl.w),lvpm);pz/=pz.w;"
  "rn=mul(mvm,rn);"
  //"float4 c=tex2D(tx1s,float2(rn.x+i.ps.x,(rn.y+i.ps.y+i.ps.x)*.5)).x*i.cl*lerp(float4(.4,.3,.1,0),float4(1,.8,.9,1),max(0,dot(rn,b)));"  
  "float4 c=gs(float2(rn.x+i.ps.x,(rn.y+i.ps.y+i.ps.x)*.5))*i.cl*lerp(float4(.2,.15,.05,0),float4(.4,.3,.3,1),max(0,dot(rn,b)));"
  "if (tex2D(tx2s,pz.xy).x-pz.z<-"SHADOWVAL") c*=.5;"
  "o.cl=c;"
  "return o;"
"}"

// pixelshader1 Z only Shader
"pso PST1(vso i)"
"{"
  "pso o;"
  "float4 n;n=float4(i.tc.xy,cos(length(i.tc.xy)*3.1416),0);" // calculate not rotated normal
  "clip(n.z);"
  "o.dp=(i.ps.z-n.z*i.cl.w)/(i.ps.w-n.z*i.cl.w);"
  "o.cl=o.dp;"
  "return o;"
"}"
// pixelshader2 volume light Shader
"pso PST2(vso i)"
"{"
  "pso o;"
  "float4 d=float4(normalize(i.ps.xyz-cp[3].xyz),0)*.35;"
  "float4 b=cp[3];"
  "o.cl=0;"
  "int l=1;"
  "for(int j=0;j<128;++j)"
  "{"
    "if(l)"
    "{"
      "b+=d;"
      "float4 pz=mul(b,lvpm);pz/=pz.w;"
      "float4 pv=mul(b,mvpm);pv/=pv.w;"
      "if (tex2D(tx2s,pz.xy).x-pz.z>-"SHADOWVAL")o.cl+=float4(1,1,.5,0)*.01;"
      "if (tex2D(tx3s,pv.xy).x-pv.z<-"SHADOWVAL")l=0;"
    "}"
  "}"
  "o.dp=.0001;"
  "return o;"
"}"
// pixelshader3 sky and mountain Shader
"pso PST3(vso i)"
"{"
  "pso o;"
  "float4 d=float4(normalize(i.ps.xyz-cp[3].xyz),0);"
  "float4 b=cp[3]+d*150;"
  "float p=atan2(b.x,b.z);"
  "b.xz/=b.y*.1;"
  "b.x+=b.w;"
  "float c=sin(b.x*.1+b.z*.2+sin(b.x*1.2+b.z*1.3))+sin(b.x*.3+b.z*.1)+sin(b.x*1.2+b.z*1.3)*.1;"
  "c=pow(.7,c*2);"
  "float p2=((sin(p*5+sin(p*22))+sin(p*7+sin(p*15)))*5+15);p+=.2f;"
  "float p3=((sin(p*5+sin(p*22))+sin(p*7+sin(p*15)))*5+15);"
  "p=b.y-p2;"
  "o.cl=p<10?"
  "lerp(float4(.2,.2,.2,0),float4(.1,.1,.1,0),(pow(-p*.2+(p3-p2)*.25,2)+c*.0005)):"
  //sun color             horizon color         sky color              cloud color
  "lerp(float4(0,0,0,0),lerp(float4(.6,.7,.8,0),lerp(float4(.3,.6,.8,0),float4(1,1,1,1),c),b.y*.05),.75);"
  "o.dp=.9999;"
  "return o;"
"}"
//stoneshader
"pso PST4(vso i)"
"{"
  "pso o;"
  "float4 rn,n;n=float4(i.tc.xy,cos(length(i.tc.xy)*3.1416),0);" // calculate not rotated normal
  "clip(float2(i.pt.y,n.z));"
  "o.dp=(i.ps.z-n.z*i.cl.w)/(i.ps.w-n.z*i.cl.w);"
  "rn=normalize(n);" // rotate normal
  "float4 pz=mul((i.pt+rn*i.cl.w),lvpm);pz/=pz.w;"
  "rn=mul(mvm,rn);"
  "float4 c=(sin(dot(rn,100))*.5+.5)*i.cl*lerp(float4(0.5,0.4,0,0),float4(1,1,1,0),max(0,dot(rn,b)));"  
  "if (tex2D(tx2s,pz.xy).x-pz.z<-"SHADOWVAL") c*=.5;"
  "o.cl=c;"
  "return o;"
"}"
//watershader
"float4 PST5(vso i):COLOR0"
"{"
"return (tex2D(tx1s,i.ps.xy/i.ps.w*float2(.5,-.5)+.5)*.45+float4(.05,.15,.15,0))*(1-length(i.pt));"
"}"

"technique T0"
"{"
  // Normal Sphere Shader
  "pass P0"
  "{"
    "VertexShader=compile vs_3_0 VST0();"
    "PixelShader=compile ps_3_0 PST0();"
  "}"
  // Depth Output Sphere Shader
  "pass P1"
  "{"
    "VertexShader=compile vs_3_0 VST0();"
    "PixelShader=compile ps_3_0 PST1();"
  "}"
  // VolumeLightShader
  "pass P2"
  "{"
    "AlphaBlendEnable=1;"
    "SrcBlend=ONE;"
    "DestBlend=ONE;"
    "VertexShader=compile vs_3_0 VST1();"
    "PixelShader=compile ps_3_0 PST2();"
  "}"
  // SkyAndMountainShader
  "pass P3"
  "{"
    "VertexShader=compile vs_3_0 VST1();"
    "PixelShader=compile ps_3_0 PST3();"
  "}"
  // Stony Sphere Shader
  "pass P4"
  "{"
    "VertexShader=compile vs_3_0 VST0();"
    "PixelShader=compile ps_3_0 PST4();"
  "}"
  // Water Shader
  "pass P5"
  "{"
    "VertexShader=compile vs_3_0 VST2();"
    "PixelShader=compile ps_3_0 PST5();"
  "}"
"}";

#define WATER_HEIGHT 0  // hier geht bloß 0
#define WATER_DEPTH 150 // change this value in the shader too 

#define PASS_MAIN 0
#define PASS_ZRENDER 1
#define PASS_VOLUMELIGHT 2
#define PASS_SKY 3
#define PASS_STONY 4
#define PASS_WATER 5
unsigned int clearColor[]={0x00000000,0xffffffff};//fuer die ersten beiden passes eine clearfarbe

#define MAX_OBJECTS 10
#define OBJECT_GROUND 0
#define OBJECT_TREE1 1
#define OBJECT_TREE2 2
#define OBJECT_FUTURA 3
#define OBJECT_WATER 4
#define OBJECT_BOAT 5

#define VERTEX_FORMAT (D3DFVF_XYZ|D3DFVF_DIFFUSE|D3DFVF_TEX1)
#define VERTEX_SIZE_IN_FLOATS (3 + 1 + 2)
#define MAX_VERTEX 10000000

#define SHADOWMAP_WIDTH 2048
#define SHADOWMAP_HEIGHT 2048

#define VOXELX_SHIFT 9
#define VOXELZ_SHIFT 9
#define VOXELX (1<<VOXELX_SHIFT)
#define VOXELZ (1<<VOXELZ_SHIFT)

// picture control start
#define VOXEL_HEIGHT_FACTOR .1f
#define VOXEL_INITIAL_HEIGHT 3.f
#define VOXEL_SEED 60
#define TREE1_COUNT 10
#define TREE1_SEED 60
#define TREE1_RAD 30.f
#define TREE2_COUNT 160
#define TREE2_SEED 80
#define TREE2_RAD 100.f
#define FUTURA_COUNT 15
#define FUTURA_SEED 300
#define FUTURA_RAD 50.f
#define FUTURA_HEIGHT 10.f
D3DXVECTOR3 lightpos(5.f,40.f,-100.f);
D3DXVECTOR3 focuspoint(0,10,0);
D3DXVECTOR3 campos(0,7.31f,40);
#define CAMFOV 90.f
#define LIGHTFOV 100.f
// picture control end

#define SPHERE_TYPE_WHITE 0
#define SPHERE_TYPE_GREEN 1
#define SPHERE_TYPE_FUTURA 2
#define SPHERE_TYPE_GROUND 3
#define SPHERE_TYPE_RED 4

#define GETADR(x,y) (((x & (VOXELX-1)) + ((y & (VOXELZ-1)) << VOXELX_SHIFT)))
#define setv(v,x,y,z) {v[0] = (x); v[1] = (y); v[2] = (z);}
#define sin(x) sinf(x)
#define cos(x) cosf(x)
#define COL(r,g,b,a) b,g,r,a

static float sinusio;
static float sphere_p[4];
static float sphere_s;
static D3DXVECTOR4 Translation;
// This is matrix transform every coordinate x,y,z
// x = x* 0.5 + 0.5 
// y = y* -0.5 + 0.5 
// z = z* 0.5 + 0.5 
// Moving from unit cube [-1,1] to [0,1]  
static const float bias[16] = {	
	0.5f, 0.0, 0.0, 0.0, 
	0.0, -0.5f, 0.0, 0.0,
	0.0, 0.0, 0.5f, 0.0,
	0.5f, 0.5f, 0.5f, 1.0f};

static unsigned char maxIter[] = {70,60,50,40,30,20,10};
static float Sphere_Colors[] = {COL(1.f,1.f,1.f,0.f), COL(0.5f,0.8f,0.2f,0.f), COL(0.3f,0.2f,0.1f,0.f), COL(0.6f,0.5f,0.4f,0.f), COL(1.f,0.5f,0.2f,0.f)};

static float Voxel[VOXELX*VOXELZ]={0};
static D3DPRESENT_PARAMETERS devParams = {
    XRES, YRES, D3DFMT_A8R8G8B8, 0, D3DMULTISAMPLE_NONE,
    0, D3DSWAPEFFECT_DISCARD, 0, IsWindowed, true,
    D3DFMT_D24S8, 0, 0, D3DPRESENT_INTERVAL_IMMEDIATE };

static float factor;
static IDirect3DDevice9 *d3dDevice;
static IDirect3D9 *d3d;
static LPD3DXEFFECT effect;

static int currentVertex = 0;
static float vertexBuffer[MAX_VERTEX*VERTEX_SIZE_IN_FLOATS];

// the z render targets
#define RENDER_TARGET_COUNT 3
static LPDIRECT3DTEXTURE9 depthTex[RENDER_TARGET_COUNT];
static LPDIRECT3DSURFACE9 depthSur[RENDER_TARGET_COUNT];
#define lightSourceDepthTex depthTex[0]
#define cameraDepthTex depthTex[1]
#define mirrorTex depthTex[2]
#define lightSourceDepthSur depthSur[0]
#define cameraDepthSur depthSur[1]
#define mirrorSur depthSur[2]
static D3DFORMAT RenderTargetFormat[RENDER_TARGET_COUNT]={D3DFMT_R32F,D3DFMT_R32F,D3DFMT_X8R8G8B8};

static LPDIRECT3DSURFACE9 screenDepthSur;
static LPDIRECT3DSURFACE9 newDepthBuffer;
static LPDIRECT3DVERTEXBUFFER9 Object[MAX_OBJECTS]={NULL};
static int ObjectVertexCount[MAX_OBJECTS];

// HANDLES
#define numUniform 10
static char *Uniform[numUniform]={"mvm","pm","lvpm","mvpm","tx1","tx2","tx3","a","cp","b"};
static D3DXHANDLE myHandles[numUniform];
#define HANDLE_MODELVIEW  myHandles[0]
#define HANDLE_PROJECTION myHandles[1]
#define HANDLE_LIGHTVIEWPROJECTION myHandles[2]
#define HANDLE_CAMERAVIEWPROJECTION myHandles[3]
#define HANDLE_TEXTURE1   myHandles[4]
#define HANDLE_TEXTURE2   myHandles[5]
#define HANDLE_TEXTURE3   myHandles[6]
#define HANDLE_A myHandles[7]
#define HANDLE_CUSTOM_PROJECTION myHandles[8]
#define HANDLE_B myHandles[9]
D3DXMATRIX cameraProjectionMatrix;
D3DXMATRIX cameraViewMatrix;
D3DXMATRIX lightProjectionMatrix;
D3DXMATRIX lightViewMatrix;

D3DXVECTOR3 up(0,1,0);
D3DXVECTOR4 lightdir;
D3DXPLANE reflection(0,1,0,-WATER_HEIGHT);

int seed;
int __fastcall rand_4k(void) 
{
	__asm 
	{
		mov		eax, dword ptr [seed]
		imul	eax, 0x000343FD
		add		eax, 0x00269EC3
		mov		dword ptr [seed], eax
		sar		eax, 10
		and		eax, 0x00007FFF
	};
}

float __fastcall frand_4k(void)
{
  return (float)rand_4k()/16384.f-1.f;
}

float __fastcall GetHeight(int x, int y)
{
  return Voxel[GETADR(x,y)];
}

void __fastcall SetRandomPixel(int x, int y, float oh)
{
  // optimized level1
  float *v = &Voxel[GETADR(x,y)]; 
  if (*v == 0)
    *v = oh * .5f + frand_4k()*factor;
}

void __fastcall PaintHeight(int x1, int y1, int x2, int y2)
{
  // optimized level1
  factor = (float)(x2 - x1);
  if (factor < 2)
    return;
  factor*=VOXEL_HEIGHT_FACTOR;
  const int xm = (x1 + x2) >> 1;
  const int ym = (y1 + y2) >> 1;
  const float c1 = GetHeight(x1,y1);
  const float c2 = GetHeight(x2,y1);
  const float c3 = GetHeight(x2,y2);
  const float c4 = GetHeight(x1,y2);
  SetRandomPixel(xm,ym,(c1+c2+c3+c4)*.5f);
  SetRandomPixel(xm,y1,(c1+c2));
  SetRandomPixel(xm,y2,(c3+c4));
  SetRandomPixel(x1,ym,(c1+c4));
  SetRandomPixel(x2,ym,(c2+c3));
  PaintHeight(x1,y1,xm,ym);
  PaintHeight(xm,y1,x2,ym);
  PaintHeight(x1,ym,xm,y2);
  PaintHeight(xm,ym,x2,y2);
}

float __fastcall GetVoxelHeight(float x, float z)
{
    int xp = (int)(x*VOXELX/2/200+VOXELX/2);
    int zp = (int)(z*VOXELZ/2/200+VOXELZ/2);
//  if (((unsigned int)xp<VOXELX)&&((unsigned int)zp<VOXELZ))
      return Voxel[GETADR(xp,zp)];
//  return 0;
}

void Vertex(float *pos, float *color, float tx, float ty)
{
  if (currentVertex>=MAX_VERTEX)
    ExitProcess(0);
  float *currentFloat = &vertexBuffer[currentVertex*VERTEX_SIZE_IN_FLOATS];
  int col = 0, u = 0;
  for (int i = 0; i < 4; ++i)
  {
    int d = (int)(*color*255.f);
    if (d<0) d=0;
    if (d>255) d=255;
    col |= d << u;
    u+=8;
    color++;
  }
  currentFloat[0]=pos[0];
  currentFloat[1]=pos[1];
  currentFloat[2]=pos[2];
  currentFloat[3]=*((float*)&col);
  currentFloat[4]=tx;
  currentFloat[5]=ty;
  currentVertex++;
}

void __fastcall PlaceSphere(int type)
{
  float *c = &Sphere_Colors[type<<2];

  if (type == SPHERE_TYPE_GROUND)
  {
    float lerp = sin(sphere_p[0]*0.3f+sphere_p[2]*0.5f)+sin(sphere_p[0]*0.5f+sphere_p[2]*0.3f);
    lerp = lerp * 0.25f + 0.5f;
    *(c+0) = lerp * 0.3f;
    *(c+2) = lerp * 0.4f;
    *(c+1) = lerp * 0.6f;
  }

  *(c+3) = sphere_s;
  Vertex(sphere_p,c,1,1); 
  Vertex(sphere_p,c,1,0); 
  Vertex(sphere_p,c,0,0); 
  Vertex(sphere_p,c,0,0); 
  Vertex(sphere_p,c,0,1); 
  Vertex(sphere_p,c,1,1);
}


void __fastcall DrawAst(float px,float py,float pz, float ax, float ay, float az, float size, int currentIter, int currentLeave)
{
  if (currentIter> maxIter[currentLeave]*3)
    return;
  if (currentLeave > 5)
    return;
  sphere_p[0] = px;
  sphere_p[1] = py;
  sphere_p[2] = pz;
  sphere_s = size;
  PlaceSphere(SPHERE_TYPE_WHITE);

  // paint blätter
  if (currentLeave > 4)
  {
    sphere_p[0] += frand_4k() * 1.1f;
    sphere_p[1] += frand_4k() * 1.1f;
    sphere_p[2] += frand_4k() * 1.1f;
    sphere_s=0.0075f;
    if (!(rand_4k() & 1))
      PlaceSphere(SPHERE_TYPE_GREEN);
  }
  float st = 0.1f;
  px += ax * st;
  py += ay * st;
  pz += az * st;
  px += sin(py+pz)*0.02f;
  pz += sin(py+px)*0.02f;
  DrawAst(px,py,pz,ax,ay,az,size,currentIter+1,currentLeave);
  if (!(rand_4k() % 32))
  {
    ax += frand_4k() * 0.151f;
    az += frand_4k() * 0.151f;
    size *= 0.5f;
    currentIter = 0;
    currentLeave++;
    DrawAst(px,py,pz,ax,ay,az,size,currentIter+1,currentLeave);
  }
}

void __fastcall DrawObject(int nr,int pass)
{
  UINT passCount;
  effect->SetVector(HANDLE_A, &Translation);
  effect->Begin(&passCount,0);
  effect->BeginPass(pass);
  d3dDevice->SetStreamSource(0,Object[nr],0,sizeof(float)*VERTEX_SIZE_IN_FLOATS);
  d3dDevice->DrawPrimitive(D3DPT_TRIANGLELIST,0,ObjectVertexCount[nr]/3);
  effect->EndPass();
  effect->End();
}

void __fastcall Draw_Scene(int pass)
{
  d3dDevice->SetFVF( VERTEX_FORMAT );

  d3dDevice->Clear(0,0,D3DCLEAR_TARGET|D3DCLEAR_ZBUFFER,clearColor[pass],1,0);
  d3dDevice->BeginScene();
  Translation.x=0;
  Translation.y=0;
  Translation.z=0;
  int p2=pass;if (p2==PASS_MAIN) p2=PASS_STONY;
  DrawObject(OBJECT_GROUND,p2);

  seed = TREE1_SEED;
  for (int i = 0; i < TREE1_COUNT; ++i)
  {
    Translation.x=frand_4k()*TREE1_RAD;
    Translation.z=frand_4k()*TREE1_RAD;
    Translation.y = GetVoxelHeight(Translation.x,Translation.z);
    if (Translation.y > WATER_HEIGHT)
      DrawObject(OBJECT_TREE1,pass);
  }

  seed = TREE2_SEED;
  for (int i = 0; i < TREE2_COUNT; ++i)
  {
    Translation.x=frand_4k()*TREE2_RAD;
    Translation.z=frand_4k()*TREE2_RAD;
    Translation.y = GetVoxelHeight(Translation.x,Translation.z);
    if (Translation.y > WATER_HEIGHT)
      DrawObject(OBJECT_TREE2,pass);
  }

  seed = FUTURA_SEED;
  for (int i = 0; i < FUTURA_COUNT; ++i)
  {
    Translation.x=frand_4k()*FUTURA_RAD;
    Translation.z=frand_4k()*FUTURA_RAD;
    Translation.y = GetVoxelHeight(Translation.x,Translation.z)+FUTURA_HEIGHT;
    DrawObject(OBJECT_FUTURA,pass);
  }

  Translation.x=-5;
  Translation.z=-5;
  Translation.y=30;
  DrawObject(OBJECT_FUTURA,pass);

  Translation.x=-2;
  Translation.y=1;
  Translation.z=27;
  DrawObject(OBJECT_BOAT,pass);
  d3dDevice->EndScene();
}

void __fastcall Draw_VolumeLightOrSky(int pass)
{
  UINT passCount;
  d3dDevice->BeginScene();
  effect->Begin(&passCount,0);
  effect->BeginPass(pass);
  currentVertex=0;
  sphere_p[0]=0;
  sphere_p[1]=0;
  sphere_p[2]=0;
  sphere_s=0.1f;
  PlaceSphere(0);
  d3dDevice->DrawPrimitiveUP(D3DPT_TRIANGLELIST,2,vertexBuffer,sizeof(float)*VERTEX_SIZE_IN_FLOATS);
  effect->EndPass();
  effect->End();
  d3dDevice->EndScene();
}


void __fastcall CompileObject(int nr)
{
  LPDIRECT3DVERTEXBUFFER9 &o=Object[nr];
  if(o)o->Release();
  d3dDevice->CreateVertexBuffer(currentVertex*VERTEX_SIZE_IN_FLOATS*sizeof(float),0,VERTEX_FORMAT,D3DPOOL_MANAGED,&o,0);
  float *adr;o->Lock(0,currentVertex*VERTEX_SIZE_IN_FLOATS*sizeof(float),(void**)&adr,0);
  for (int x = 0; x < currentVertex*VERTEX_SIZE_IN_FLOATS; ++x) adr[x]=vertexBuffer[x];
  o->Unlock();
  ObjectVertexCount[nr]=currentVertex;
  currentVertex=0;
}

void __fastcall PrepareMatrices(D3DXMATRIX &camView)
{
    lightdir.x = lightViewMatrix[2+0*4];
    lightdir.y = lightViewMatrix[2+1*4];
    lightdir.z = lightViewMatrix[2+2*4];
    lightdir.w = 0;
    effect->SetVector(HANDLE_B,&lightdir);

    // prepare textures and matrices
    effect->SetTexture(HANDLE_TEXTURE1, mirrorTex);
    effect->SetTexture(HANDLE_TEXTURE2, lightSourceDepthTex);
    effect->SetTexture(HANDLE_TEXTURE3, cameraDepthTex);
    D3DXMATRIX lightCombined = lightViewMatrix*lightProjectionMatrix*(*(D3DXMATRIX*)bias);
    D3DXMATRIX cameraCombined  = camView*cameraProjectionMatrix*(*(D3DXMATRIX*)bias);
    D3DXMATRIX m;D3DXMatrixInverse(&m,0,&camView);
    effect->SetMatrix(HANDLE_LIGHTVIEWPROJECTION, &lightCombined);
    effect->SetMatrix(HANDLE_CAMERAVIEWPROJECTION, &cameraCombined);
    effect->SetMatrix(HANDLE_CUSTOM_PROJECTION,&m);
}

#ifdef _DEBUG
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
#else
extern "C" __declspec(noreturn) void WinMainCRTStartup()
#endif
{
  // ---------------------------------------------
  // INIT DIRECT3D
  // ---------------------------------------------
  d3d=Direct3DCreate9( D3D_SDK_VERSION ); 
  devParams.hDeviceWindow = CreateWindow("static",0,WS_POPUP|WS_VISIBLE,0,0,XRES,YRES,0,0,0,0); 
  d3d->CreateDevice(D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,devParams.hDeviceWindow,D3DCREATE_HARDWARE_VERTEXPROCESSING,&devParams,&d3dDevice);
  ShowCursor( 0 );
  //d3dDevice->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
  // ---------------------------------------------

  // ---------------------------------------------
  // COMPILE SHADERS
  // ---------------------------------------------
#define SAVESTATE (0*(D3DXFX_NOT_CLONEABLE|D3DXFX_DONOTSAVESTATE|D3DXFX_DONOTSAVESHADERSTATE|D3DXFX_DONOTSAVESAMPLERSTATE))|D3DXSHADER_PREFER_FLOW_CONTROL
#ifndef CHECKEFFECT
  D3DXCreateEffect(d3dDevice, effectSourceCode, sizeof(effectSourceCode)-1, NULL, NULL, SAVESTATE, NULL, &effect, NULL ); 
#else
  ID3DXBuffer *errors;
  int h = D3DXCreateEffect(d3dDevice, effectSourceCode, sizeof(effectSourceCode)-1, NULL, NULL, SAVESTATE, NULL, &effect, &errors);
  if (errors||!effect||(h<0))
  {
    OutputDebugString("EffectGenerationFailed\n");
    if (errors)
    {
      OutputDebugString((char*)(errors->GetBufferPointer()));
      errors->Release();
    }
    ExitProcess(0);
  }
#endif
  // get the handles
  for (int i = 0; i < numUniform; ++i)
    myHandles[i]=effect->GetParameterByName( NULL, Uniform[i] );

  for (int i = 0; i < RENDER_TARGET_COUNT; ++i)
  {
    d3dDevice->CreateTexture(SHADOWMAP_WIDTH, SHADOWMAP_HEIGHT, 1, D3DUSAGE_RENDERTARGET, RenderTargetFormat[i], D3DPOOL_DEFAULT, &depthTex[i],0);
    depthTex[i]->GetSurfaceLevel(0,&depthSur[i]);
  }
  d3dDevice->CreateDepthStencilSurface(SHADOWMAP_WIDTH>XRES?SHADOWMAP_WIDTH:XRES,SHADOWMAP_HEIGHT>YRES?SHADOWMAP_HEIGHT:YRES, D3DFMT_D24S8,D3DMULTISAMPLE_NONE,0,0,&newDepthBuffer,0);
  d3dDevice->SetDepthStencilSurface(newDepthBuffer);
  d3dDevice->GetRenderTarget(0,&screenDepthSur);

  // ---------------------------------------------
  
  // ---------------------------------------------
  // GENERATE VOXEL
  // ---------------------------------------------
  *Voxel = VOXEL_INITIAL_HEIGHT;
  seed = VOXEL_SEED;
  PaintHeight(0,0,VOXELX,VOXELZ);
  // ---------------------------------------------

  // ---------------------------------------------
  // CALCULATE LANDSCAPE AND TREES
  // ---------------------------------------------
  seed = VOXEL_SEED;
  for (float x = -100.f; x < 100.f; x += .5f)
  for (float z = -100.f; z < 100.f; z += .5f)
  {
    sphere_p[0] = x;
    sphere_p[1] = GetVoxelHeight(x,z);
    sphere_p[2] = z;
    sphere_s = 0.06f+frand_4k()*0.01f;
    {
      PlaceSphere(SPHERE_TYPE_GROUND);
      sphere_p[0]+=sin(sphere_p[2])*2.f;
      sphere_p[1]+=1.f;
      sphere_p[2]+=cos(sphere_p[0])*2.f;
      sphere_s *= 0.3f;
      PlaceSphere((rand_4k()&15)?SPHERE_TYPE_GREEN:SPHERE_TYPE_RED);
    }
  }
  CompileObject(OBJECT_GROUND);

  seed = 100;
  DrawAst(0,0,0,0,0.5f,0,0.05f,0,0);
  CompileObject(OBJECT_TREE1);

  seed = 500;
  DrawAst(0,0,0,0,0.5f,0,0.025f,-40,1);
  CompileObject(OBJECT_TREE2);

  seed = 100;
  // paint future sound of london object
  for (int y = 0; y < 40; ++y)
  {
    sphere_p[0]=0;
    sphere_p[1]=0;
    sphere_p[2]=0;
    sphere_s = 0.025f;
    float a[3];
    const float yf=(float)y;
    a[0] = sin(yf*0.3f);
    a[1] = sin(yf*0.1f);
    a[2] = sin(yf*0.3f);
    for (int i = 0; i < 1000; ++i)
    {
      a[0] += frand_4k()*0.025f;
      a[1] += frand_4k()*0.025f;
      a[2] += frand_4k()*0.025f;
      float d = sphere_s*8.f/sqrt(a[0]*a[0]+a[1]*a[1]+a[2]*a[2]);
      PlaceSphere(SPHERE_TYPE_FUTURA);
      sphere_p[0]+=a[0]*=d;
      sphere_p[1]+=a[1]*=d;
      sphere_p[2]+=a[2]*=d;
      sphere_s *= 0.995f;
    }
  }
  CompileObject(OBJECT_FUTURA);

  sphere_p[1]=WATER_HEIGHT;
  sphere_p[0]=-WATER_DEPTH; sphere_p[2]=-WATER_DEPTH;  Vertex(sphere_p,sphere_p,0,0);
  sphere_p[0]=WATER_DEPTH;  Vertex(sphere_p,sphere_p,0,0);
  sphere_p[2]=WATER_DEPTH;   Vertex(sphere_p,sphere_p,0,0);
  Vertex(sphere_p,sphere_p,0,0);
  sphere_p[0]=-WATER_DEPTH;  Vertex(sphere_p,sphere_p,0,0);
  sphere_p[2]=-WATER_DEPTH;  Vertex(sphere_p,sphere_p,0,0);
  CompileObject(OBJECT_WATER);


  int ka=0;
  for(float y=0;y<1;y+=0.01f)
  {
    int kb=0;
    for(float x=0;x<2;x+=0.01f)
    {
      sphere_s=0.002f;
      sphere_p[0]=x*7.f;
      sphere_p[1]=y*2.f*-sin(x*3.1416f*0.5f);
      sphere_p[2]=sin(x*3.1416f*0.5f)*-sin(y*3.1416f*0.5f+3.1416f*0.5f);
      PlaceSphere(SPHERE_TYPE_FUTURA);
      sphere_p[2]=-sphere_p[2];
      if (rand_4k()>8000)
        PlaceSphere(SPHERE_TYPE_WHITE);
      else
        PlaceSphere(SPHERE_TYPE_GREEN);

      if (((kb & 31)<8)&&(ka==3))
      {
        sphere_s=0.005f;
        float kc=sphere_p[2];
        for(sphere_p[2]=-kc;sphere_p[2]<kc;sphere_p[2]+=0.1f)
          PlaceSphere(SPHERE_TYPE_WHITE);
      }
      kb++;
    }
    ka++;
  }
  CompileObject(OBJECT_BOAT);


#ifndef FULLSCREEN
  do
  {
#endif
    // ---------------------------------------------
    Frustum(&cameraProjectionMatrix, CAMFOV/360.f*2.f*3.1416f, ASPECT, 0.9f, 1000 );
    Frustum(&lightProjectionMatrix, LIGHTFOV/360.f*2.f*3.1416f, 1, 1.f, 5000 );

    // calculate camera matrix
    LookAt(&cameraViewMatrix, &campos, &focuspoint, &up);

    // calculate light matrix
    LookAt(&lightViewMatrix, &lightpos,&focuspoint,&up);

    PrepareMatrices(cameraViewMatrix);

    // render the both depth passes
    effect->SetMatrix(HANDLE_PROJECTION, &lightProjectionMatrix);
    effect->SetMatrix(HANDLE_MODELVIEW, &lightViewMatrix);
    d3dDevice->SetRenderTarget(0,lightSourceDepthSur);
    Draw_Scene(PASS_ZRENDER);
    effect->SetMatrix(HANDLE_PROJECTION, &cameraProjectionMatrix);
    effect->SetMatrix(HANDLE_MODELVIEW, &cameraViewMatrix);
    d3dDevice->SetRenderTarget(0,cameraDepthSur);
    Draw_Scene(PASS_ZRENDER);

    // render the mirror pass
    D3DXMATRIX m;
    D3DXMatrixReflect(&m,&reflection);
    m=m*cameraViewMatrix;
    PrepareMatrices(m);
    effect->SetMatrix(HANDLE_MODELVIEW, &m);
    d3dDevice->SetRenderTarget(0,mirrorSur);
    Draw_Scene(PASS_MAIN);
    // draw the sky and the mountains
    Draw_VolumeLightOrSky(PASS_SKY);

    PrepareMatrices(cameraViewMatrix);
    // render the main pass
    effect->SetMatrix(HANDLE_MODELVIEW, &cameraViewMatrix);
    d3dDevice->SetRenderTarget(0,screenDepthSur);
    Draw_Scene(PASS_MAIN);
    // render the main pass mirror water
    d3dDevice->BeginScene();DrawObject(OBJECT_WATER,PASS_WATER);d3dDevice->EndScene();
    // draw the sky and the mountains
    Draw_VolumeLightOrSky(PASS_SKY);
    // render the volumelight
    Draw_VolumeLightOrSky(PASS_VOLUMELIGHT);
    d3dDevice->Present( NULL, NULL, NULL, NULL );
#ifdef USERCONTROL
#endif
#ifndef FULLSCREEN
#ifdef USERCONTROL
    MSG		msg;
		if (PeekMessage(&msg, devParams.hDeviceWindow, 0,0, PM_REMOVE))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
#endif
  }  while (!GetAsyncKeyState(VK_ESCAPE));
#else
    do  
    {
#ifdef USERCONTROL
      MSG		msg;
		  if (PeekMessage(&msg, devParams.hDeviceWindow, 0,0, PM_REMOVE))
		  {
			  TranslateMessage(&msg);
			  DispatchMessage(&msg);
		  }
#endif
    } while (!GetAsyncKeyState(VK_ESCAPE));
#endif
  ExitProcess(0);
}
//---------------------END OF PROGRAMM-------------------------------------
//TECHNIQUE_Sphere  = effect->GetTechniqueByName("T0");
//static D3DXHANDLE TECHNIQUE_Sphere;
//effect->SetTechnique(TECHNIQUE_Sphere);
