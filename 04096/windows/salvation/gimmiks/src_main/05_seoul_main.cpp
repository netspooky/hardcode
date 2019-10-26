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

#include "stdio.h"

#ifdef FULLSCREEN
#define IsWindowed 0
#else
#define IsWindowed 1
#endif

#define Frustum D3DXMatrixPerspectiveFovRH
#define LookAt D3DXMatrixLookAtRH
#define MULTISAMPLE D3DMULTISAMPLE_NONE

#define SHADOWVAL ".005"

static const char effectSourceCode[] =\
// Params
"float4x4 pm,mvm,lvpm,mvpm,cp;"
"texture tx1,tx2,tx3,txn;"
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
"};"
"sampler tx2s=" 
"sampler_state"
"{"
    "Texture=<tx2>;"    
"};"
"sampler tx3s=" 
"sampler_state"
"{"
    "Texture=<tx3>;"    
"};"
"sampler txns=" 
"sampler_state"
"{"
    "Texture=<txn>;"    
"};"
// thats for the ridged multi fractal
"void f(float i,out float b0,out float b1,out float r0,out float r1)"
"{"
  "float f=1./256;"
  "r0=frac(i);"
  "r1=r0-1;"
  "b0=(i-r0)*f;"
  "b1=b0+f;"
"}"
"float4 tf(float i)"
"{"
  "float4 ret=tex1D(txns,i);"
  "ret.xyz=normalize(ret.xyz*2-1);"
  "return ret;"
"}"
"float sc(float t)"
"{"
	"return t*t*(3-2*t);"
"}"
"float n3(float4 p)"
"{"
	"float b00,b10,b01,b11,bx0,bx1,by0,by1,bz0,bz1,rx0,rx1,ry0,ry1,rz0,rz1,a,b,c,d,t,u,v;"
  "f(p.x,bx0,bx1,rx0,rx1);"
  "f(p.y,by0,by1,ry0,ry1);"
  "f(p.z,bz0,bz1,rz0,rz1);"
	"u=tf(bx0).w;"
	"v=tf(bx1).w;"
	"b00=tf(u+by0).w;"
	"b10=tf(v+by0).w;"
	"b01=tf(u+by1).w;"
	"b11=tf(v+by1).w;"
	"t=sc(rx0);"
  "float4 e;"
  "e=tf(b00+bz0);u=rx0*e.x+ry0*e.y+rz0*e.z;"
  "e=tf(b10+bz0);v=rx1*e.x+ry0*e.y+rz0*e.z;"
	"a=lerp(u,v,t);"
  "e=tf(b01+bz0);u=rx0*e.x+ry1*e.y+rz0*e.z;"
  "e=tf(b11+bz0);v=rx1*e.x+ry1*e.y+rz0*e.z;"
	"b=lerp(u,v,t);"
  "c=lerp(a,b,sc(ry0));"
  "e=tf(b00+bz1);u=rx0*e.x+ry0*e.y+rz1*e.z;"
  "e=tf(b10+bz1);v=rx1*e.x+ry0*e.y+rz1*e.z;"
	"a=lerp(u,v,t);"
  "e=tf(b10+bz1);u=rx0*e.x+ry1*e.y+rz1*e.z;"
  "e=tf(b11+bz1);v=rx1*e.x+ry1*e.y+rz1*e.z;"
	"b=lerp(u,v,t);"
  "d=lerp(a,b,sc(ry0));"
  "return lerp(c,d,sc(rz0));"
"}"
"float snoise(float4 x){return 2.5*(n3(x)-.5);};"
"float rmf(float4 PP,float o=24,float H=.8,float l=1.85,float of=.75,float sh=1.1,float th=5,float Kt=.9)"
"{"
  "PP.xz*=4;PP.x+=4;PP.z+=6;"
	"float r,s,i;"
	"for(i=0;i<o;i+=1)"
  "{"
    "if(i==0)" 
    "{"
      "s=pow(of-abs(snoise(PP)),sh);"
      "r=s;"
    "}"
    "else"
    "{"
      "PP*=l;"
   		"s=pow(of-abs(snoise(PP)),sh)*clamp(s*th,0,1);"
   		"r+=s*pow(l,(-i*H));"
    "}"
	"}"
  "return 1-r*Kt;"
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
//vertexshaderc cubeshader
"vso VSTC(float4 ps:POSITION,float4 cl:COLOR0)"
"{"
    "vso o;"
    "o.pt=ps+a;"
    "o.cl=cl;"
    "o.psw=mul(mul(o.pt,mvm),pm);"
    "o.ps=o.psw;"
    "o.tc=0;"
    "return o;"
"}"
// pixelshader2 volume light Shader
"pso PST2(vso i)"
"{"
  "pso o;"
  "float4 d=float4(normalize(i.ps.xyz-cp[3].xyz),0);"
  "float4 b=cp[3];"
  "o.cl=0;"
  "int l=1;"
  "for(int j=0;j<200;++j)"
  "{"
    "if(l)"
    "{"
      "b+=d;"
      "float4 pz=mul(b,lvpm);pz/=pz.w;"
      "float4 pv=mul(b,mvpm);pv/=pv.w;"
      "if (tex2D(tx2s,pz.xy).x-pz.z>-"SHADOWVAL")o.cl+=float4(.6,.4,.2,0)*.01;"
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
  "float4 b=cp[3]+d*800;"
  "b.xz/=(b.y+120)*4;"
  "b.xz+=8;"
  "float c=rmf(float4(b.x,0,b.z,0),4);"
  //"o.cl=lerp(float4(.2,.15,0,0),float4(.3,.4,.3,0),c)+b.y*.001;"
  //"o.cl=lerp(float4(.15,.15,0.15,0),float4(.3,.3,.25,0)*2,c)+b.y*.001;"
  "o.cl=lerp(float4(.23,.23,.23,0),float4(.3,.3,.25,0)*2,c)+b.y*.001;"
  "o.dp=.9999;"
  "return o;"
"}"
//landscapeshader
"float4 PSTL(vso i):COLOR0"
"{"
  "float4 ps=float4(i.pt.x+1000,0,i.pt.z+1000,0)*.0002;"
  "float s1=rmf(ps);"
  "float s2=rmf(ps+float4(-2*.0002,0,0,0));"
  "float s3=rmf(ps+float4(0,0,-2*.0002,0));"
  "float t1=rmf(ps,9);"
  "float t2=rmf(ps+float4(-2*.0002,0,0,0),9);"
  "float t3=rmf(ps+float4(0,0,-2*.0002,0),9);"
  "float4 sn=normalize(float4(s2-s1,.01,s3-s1,0));"
  "float4 tn=normalize(float4(t2-t1,.01,t3-t1,0));"
  "float4 c=lerp(float4(.1,.1,.025,0),float4(.05,.04,.0,0),dot(sn,normalize(float4(0,1,0,0))));"
  "c*=max(.55,dot(tn,normalize(b.xyz-i.ps.xyz))*2);"
  "float4 pz=mul(i.pt,lvpm);pz/=pz.w;"
  "if (tex2D(tx2s,pz.xy).x-pz.z<-"SHADOWVAL") c*=.5;"
  "return c;"
"}"
//cubeshader
"float4 PSTC(vso i):COLOR0"
"{"
  "float4 n=float4((i.cl.xyz-.5)*2,0);"
  "float4 p=float4(i.pt.xyz,0);"
  "float4 l=float4((b-p).xyz,0);"
  "float4 v=float4((cp[3]-p).xyz,0);"
  "float4 pz=mul(i.pt,lvpm);pz/=pz.w;"
  "float4 c=(pow(min(0,dot(normalize(normalize(l-p)+normalize(v-p)),n)),60)*float4(9,8,6,0)+max(0,dot(normalize(l-p),n))*.45)*0.2;"
  "if (tex2D(tx2s,pz.xy).x-pz.z<-"SHADOWVAL") c*=.75;"
  "return c;"
"}"
//cube zonly
"pso PSTD(vso i)"
"{"
  "pso o;"
  "o.dp=i.ps.z/i.ps.w;"
  "o.cl=o.dp;"
  "return o;"
"}"
//ridged into render target
"float4 PSTR(float2 u:texcoord):COLOR0"
"{"
"return rmf(float4(u.x,0,u.y,0));"
"}"

"technique T0"
"{"
  // VolumeLightShader
  "pass P0"
  "{"
    "AlphaBlendEnable=1;"
    "SrcBlend=ONE;"
    "DestBlend=ONE;"
    "VertexShader=compile vs_3_0 VST1();"
    "PixelShader=compile ps_3_0 PST2();"
  "}"
  // SkyAndMountainShader
  "pass P1"
  "{"
    "VertexShader=compile vs_3_0 VST1();"
    "PixelShader=compile ps_3_0 PST3();"
  "}"
  // Landscape Shader
  "pass P2"
  "{"
    "VertexShader=compile vs_3_0 VSTC();"
    "PixelShader=compile ps_3_0 PSTL();"
  "}"
  // Cube Shader
  "pass P3"
  "{"
    //"AlphaBlendEnable=1;"
    //"SrcBlend=ONE;"
    //"DestBlend=ONE;"
    "VertexShader=compile vs_3_0 VSTC();"
    "PixelShader=compile ps_3_0 PSTC();"
  "}"
  // Cube Zonly 
  "pass P4"
  "{"
    "VertexShader=compile vs_3_0 VSTC();"
    "PixelShader=compile ps_3_0 PSTD();"
  "}"
  // render ridged onto rendertarget
  "pass P4"
  "{"
    "PixelShader=compile ps_3_0 PSTR();"
  "}"
"}";

#define PASS_MAIN 0
#define PASS_ZRENDER 1

#define PASS_VOLUMELIGHT 0
#define PASS_SKY 1
#define PASS_LANDSCAPE 2
#define PASS_CUBE 3 
#define PASS_ZONLY 4
#define PASS_RIDGED 5
unsigned int clearColor[]={0x00000000,0xffffffff};//fuer die ersten beiden passes eine clearfarbe

#define MAX_OBJECTS 20
#define OBJECT_LSCAPE 0
#define OBJECT_CUBES 1

#define VERTEX_FORMAT (D3DFVF_XYZ|D3DFVF_DIFFUSE|D3DFVF_TEX1)
#define VERTEX_SIZE_IN_FLOATS (3 + 1 + 2)
#define MAX_VERTEX 2250000

#define SHADOWMAP_WIDTH 2048
#define SHADOWMAP_HEIGHT 2048

// tweakable
// picture control start
#define FUTURA_COUNT 5
#define FUTURA_SEED 300
#define FUTURA_RAD 50.f
#define FUTURA_HEIGHT 10.f
D3DXVECTOR3 lightpos(-150,120,-50);
D3DXVECTOR3 lightfocuspoint(0,70,30);
D3DXVECTOR3 campos(0,30,20);
D3DXVECTOR3 camfocuspoint(-100,50,-20);
#define CAMFOV 100.f
#define LIGHTFOV 100.f
#define TOWER_SEED1 10
#define TOWER_COUNT1 200
#define TOWER_SEED2 100
#define TOWER_COUNT2 200
// picture control end

#define SPHERE_TYPE_SHROOM 0
#define SPHERE_TYPE_STAMP 1
#define SPHERE_TYPE_FEATHER 2
#define SPHERE_TYPE_CAR 3
#define SPHERE_TYPE_ROOT 4
#define SPHERE_TYPE_TRI 5

#define setv(v,x,y,z) {v[0] = (x); v[1] = (y); v[2] = (z);}
#define sin(x) sinf(x)
#define cos(x) cosf(x)
#define COL(r,g,b,a) b,g,r,a

#define RIDGED_TEXX 1024
#define RIDGED_TEXY 1024

static float sinusio;
static float sphere_p[4];
static float sphere_s;
static float cube_s[4];
static D3DXVECTOR4 Translation(0,0,0,0);
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
static const float quadVerts[4*5] =
{
  1,-1,0,1,1,
  -1,-1,0,0,1,
  1,1,0,1,0,
  -1,1,0,0,0
};
static float sinv[8]={-1,0,1,1,1,0,-1,-1};
static float cosv[8]={1,1,1,0,-1,-1,-1,0};

static D3DPRESENT_PARAMETERS devParams = {
  XRES, YRES, D3DFMT_A8R8G8B8, 0, MULTISAMPLE,
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
static LPDIRECT3DTEXTURE9 voxelTex,noiseTex;
static LPDIRECT3DSURFACE9 ridgedLockableRenderTarget;
static D3DLOCKED_RECT lockRect;

// HANDLES
#define numUniform 12
static const char *Uniform[numUniform]={"mvm","pm","lvpm","mvpm","tx1","tx2","tx3","txn","a","cp","b"};
static D3DXHANDLE myHandles[numUniform];
#define HANDLE_MODELVIEW  myHandles[0]
#define HANDLE_PROJECTION myHandles[1]
#define HANDLE_LIGHTVIEWPROJECTION myHandles[2]
#define HANDLE_CAMERAVIEWPROJECTION myHandles[3]
#define HANDLE_TEXTURE1   myHandles[4]
#define HANDLE_TEXTURE2   myHandles[5]
#define HANDLE_TEXTURE3   myHandles[6]
#define HANDLE_TEXTURENOISE  myHandles[7]
#define HANDLE_A myHandles[8]
#define HANDLE_CUSTOM_PROJECTION myHandles[9]
#define HANDLE_B myHandles[10]
D3DXMATRIX cameraProjectionMatrix;
D3DXMATRIX cameraViewMatrix;
D3DXMATRIX lightProjectionMatrix;
D3DXMATRIX lightViewMatrix;

D3DXVECTOR3 up(0,1,0);
D3DXVECTOR4 lightdir;
#define B 256
int p[B];

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
  sphere_p[3] = sphere_s;
  Vertex(sphere_p,sphere_p,1,1); 
  Vertex(sphere_p,sphere_p,1,0); 
  Vertex(sphere_p,sphere_p,0,0); 
  Vertex(sphere_p,sphere_p,0,0); 
  Vertex(sphere_p,sphere_p,0,1); 
  Vertex(sphere_p,sphere_p,1,1);
}

float nx,ny,nz;
void VertexCube(float xa,float ya,float za)
{
  float p[4];
  float c[4];
  p[0]=sphere_p[0]+xa;
  p[1]=sphere_p[1]+ya;
  p[2]=sphere_p[2]+za;
  c[0]=0.5f+nx*0.5f;
  c[1]=0.5f+ny*0.5f;
  c[2]=0.5f+nz*0.5f;
  Vertex(p,c,0,0);
}

void __fastcall PlaceCube()
{
  for (int s=0;s<4;s++)
  {
    int t=s<<1;
    float ya0=-cube_s[1];
    float xa0=sinv[t]*cube_s[0];
    float za0=cosv[t]*cube_s[2];
    t=(t+1)&7;
    ny=0;
    nx=cosv[t];
    nz=sinv[t];
    t=(t+1)&7;
    float ya1=+cube_s[1];
    float xa1=sinv[t]*cube_s[0];
    float za1=cosv[t]*cube_s[2];
    VertexCube(xa1,ya1,za1); 
    VertexCube(xa1,ya0,za1); 
    VertexCube(xa0,ya0,za0); 
    VertexCube(xa0,ya0,za0); 
    VertexCube(xa0,ya1,za0); 
    VertexCube(xa1,ya1,za1);
    if (!(s&1))
    {
      xa0=+cube_s[0];
      ya0=sinv[t]*cube_s[1];
      za0=cosv[t]*cube_s[2];
      t=(t+1)&7;
      nx=0;
      ny=sinv[t];
      nz=cosv[t];
      t=(t+1)&7;
      xa1=-cube_s[0];
      ya1=sinv[t]*cube_s[1];
      za1=cosv[t]*cube_s[2];
      VertexCube(xa1,ya1,za1);
      VertexCube(xa0,ya1,za1); 
      VertexCube(xa0,ya0,za0); 
      VertexCube(xa0,ya0,za0); 
      VertexCube(xa1,ya0,za0); 
      VertexCube(xa1,ya1,za1);
    }
  }
}

void __fastcall DrawObject(int nr,int pass)
{
  UINT passCount;
  effect->SetVector(HANDLE_A, &Translation);
  effect->Begin(&passCount,0);
  effect->BeginPass(pass);
  d3dDevice->SetStreamSource(0,Object[nr],0,sizeof(float)*VERTEX_SIZE_IN_FLOATS);
  //d3dDevice->SetIndices(indexBuffer);
  //d3dDevice->DrawIndexedPrimitive(D3DPT_TRIANGLELIST,0,0,ObjectVertexCount[nr],0,ObjectPrimitiveCount[nr]);
  d3dDevice->DrawPrimitive(D3DPT_TRIANGLELIST,0,ObjectVertexCount[nr]/3);
  effect->EndPass();
  effect->End();
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
  //sphere_s=0.1f;
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
  lightdir.x = lightpos.x;
  lightdir.y = lightpos.y;
  lightdir.z = lightpos.z;
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


void __fastcall Draw_Scene(int pass)
{
  d3dDevice->SetFVF( VERTEX_FORMAT );

  d3dDevice->Clear(0,0,D3DCLEAR_TARGET|D3DCLEAR_ZBUFFER,clearColor[pass],1,0);
  d3dDevice->BeginScene();
  int p2=PASS_ZONLY;if (pass==PASS_MAIN) p2=PASS_LANDSCAPE; 

  DrawObject(OBJECT_LSCAPE,p2);

  int p3=PASS_ZONLY;if (pass==PASS_MAIN) p3=PASS_CUBE; 
  DrawObject(OBJECT_CUBES,p3);

  d3dDevice->EndScene();
}

void __fastcall GetHeight(float *p)
{
  float x=(p[0]+1000.f)*0.0002f*(float)RIDGED_TEXX;
  float z=(p[2]+1000.f)*0.0002f*(float)RIDGED_TEXY;
  int xp=(int)(x*1024.f)>>10; // avoid rounding
  int zp=(int)(z*1024.f)>>10; // avoid rounding
  x-=(float)(xp);
  z-=(float)(zp);
  float *a=(float*)((unsigned char*)lockRect.pBits+(xp & (RIDGED_TEXX-1))*sizeof(float)+(zp & (RIDGED_TEXY-1))*lockRect.Pitch);
  float s1=(*(a+1)-*a)*x+*a;
  a+=lockRect.Pitch/sizeof(float);
  float s2=(*(a+1)-*a)*x+*a;
  p[1]=((s2-s1)*z+s1)*64.f;
}

void __fastcall PlaceLandscape(float x,float z)
{
  float p[4];
  p[0]=x;
  p[2]=z;
  GetHeight(p);
  Vertex(p,p,0,0);
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
#define SAVESTATE D3DXSHADER_PREFER_FLOW_CONTROL|D3DXSHADER_SKIPOPTIMIZATION
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
  d3dDevice->CreateDepthStencilSurface(SHADOWMAP_WIDTH>XRES?SHADOWMAP_WIDTH:XRES,SHADOWMAP_HEIGHT>YRES?SHADOWMAP_HEIGHT:YRES, D3DFMT_D24S8,MULTISAMPLE,0,0,&newDepthBuffer,0);
  d3dDevice->SetDepthStencilSurface(newDepthBuffer);
  d3dDevice->GetRenderTarget(0,&screenDepthSur);

  // Init Noise Functions
  seed = 9*0+11*0+24*0+33*0+37*0+38*0+43*0+46*0+51*0+59*0+62*0+63*0+64*0+65;
  for (int k = 0;k<B;k++) p[k] = k;
	int r=B;
  while ((--r)>0)
	{
	  int j = rand_4k() & (B-1);
	  int k = p[r];p[r] = p[j];p[j] = k;
	}
  d3dDevice->CreateTexture(B,1,1,0,D3DFMT_A8R8G8B8,D3DPOOL_MANAGED,&noiseTex,0);
  noiseTex->LockRect(0,&lockRect,0,0);
  unsigned char *dest = (unsigned char*)lockRect.pBits;
  for (int i = 0; i < B; ++i)
  {
    for (int e=0;e<3;++e)
      *dest++=(unsigned char)(frand_4k()*128.f+128.f);
    *dest++=(unsigned char)(p[i]/(float)B*256.f);
  }
  noiseTex->UnlockRect(0);
  effect->SetTexture(HANDLE_TEXTURENOISE,noiseTex);

  // Render Ridged Multifractal noise into texture
  // prepare ridged multifractal
  d3dDevice->CreateRenderTarget(RIDGED_TEXX,RIDGED_TEXY,D3DFMT_R32F,D3DMULTISAMPLE_NONE,0,1,&ridgedLockableRenderTarget,0);
  d3dDevice->SetRenderTarget(0,ridgedLockableRenderTarget);
  d3dDevice->Clear(0,0,D3DCLEAR_TARGET|D3DCLEAR_ZBUFFER,0,1,0);
  d3dDevice->BeginScene();
  UINT passCount;effect->Begin(&passCount,0);
  effect->BeginPass(PASS_RIDGED);
  d3dDevice->SetFVF( D3DFVF_XYZ|D3DFVF_TEX1 );
  d3dDevice->DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,2,quadVerts,5*sizeof(float));
  effect->EndPass();
  d3dDevice->EndScene();
  ridgedLockableRenderTarget->LockRect(&lockRect,0,0);
  // ---------------------------------------------
  // CALCULATE LANDSCAPE AND TREES
  // ---------------------------------------------

#define dx 2.f
#define dz 2.f
  for (float z=-200.f;z < 200.f; z+=dz)
  {
    for (float x=-800.f;x < 0.f; x+=dx)
    {
      const float x2= x+dx;
      const float z2= z+dz;
      PlaceLandscape(x,z);
      PlaceLandscape(x2,z);
      PlaceLandscape(x2,z2);
      PlaceLandscape(x2,z2);
      PlaceLandscape(x,z2);
      PlaceLandscape(x,z);
    }
  }
  CompileObject(OBJECT_LSCAPE);
  ridgedLockableRenderTarget->UnlockRect();

  for (float z=0.f;z < 200.f; z+=1.5f)
  {
    float xa=190.f;
    if (fabs(z-100.f)<1.5f) xa = 5.f;
    for (int i = 0; i < 20; ++i)
    for (float x=-400.f;x<100.f;x+=xa)
    {
      float ang=frand_4k()*4.f;
      float rad=frand_4k()*15.f*cos(z*0.045f);
      sphere_p[0]=sin(ang)*rad+x-70;
      sphere_p[2]=cos(ang)*rad+x*0.5f-20.f;
      GetHeight(sphere_p);
      sphere_p[1]*=0.2f;
      sphere_p[1]+=z-50.f;
      cube_s[0]=3.f;
      cube_s[1]=1.f;
      cube_s[2]=3.f;
      PlaceCube();
      sphere_p[2]+=80.f;
      PlaceCube();
    }
  }

  seed=5*0+12*0+15*0+21*0+22*0+35*0+45;
  for (int i=0;i<450;++i)
  {
    cube_s[0]=7.5f;
    cube_s[1]=frand_4k()*200.f;
    cube_s[2]=7.5f;
    sphere_p[0]=frand_4k()*600.f-400.f;
    sphere_p[2]=frand_4k()*600.f;
    GetHeight(sphere_p);
    sphere_p[1]=0;
    if (sphere_p[2]<-100.f||sphere_p[2]>100.f)
    {
      const float xs=sphere_p[0]-cube_s[0];
      const float ys=sphere_p[1]-cube_s[1];
      const float zs=sphere_p[2]-cube_s[2];
      const float xe=sphere_p[0]+cube_s[0];
      const float ye=sphere_p[1]+cube_s[1];
      const float ze=sphere_p[2]+cube_s[2];
      const float sx=5.f;
      const float sy=35.f;
      const float sz=5.f;
      for (float x=xs;x<xe;x+=sx)
      for (float y=ys;y<ye;y+=sy)
      for (float z=zs;z<ze;z+=sz)
      {
        sphere_p[0]=x+frand_4k()*sx*2;
        sphere_p[1]=y+frand_4k()*sy;
        sphere_p[2]=z+frand_4k()*sz*2;
        cube_s[0]=sx;
        cube_s[1]=sy;
        cube_s[2]=sz;
        PlaceCube();
        if (!(rand_4k() & 7))
        {
          float ys=sphere_p[1]-cube_s[1];
          float ye=sphere_p[1]+cube_s[1];
          float sy=cube_s[1]*0.1f;
          cube_s[1]=sy*0.5f*0.35f;
          cube_s[0]+=1.f;
          cube_s[2]+=1.f;
          for (float y=ys;y<ye;y+=sy)
          {
            sphere_p[1]=y;
            PlaceCube();
          }
        }
      }
    }
  }
  //sphere_p[0]=lightpos.x;
  //sphere_p[1]=lightpos.y;
  //sphere_p[2]=lightpos.z;
  //cube_s[0]=9.f;
  //cube_s[1]=9.f;
  //cube_s[2]=9.f;
  //PlaceCube();

  CompileObject(OBJECT_CUBES);

#ifndef FULLSCREEN
  do
  {
#endif

    // ---------------------------------------------
    Frustum(&cameraProjectionMatrix, CAMFOV/360.f*2.f*3.1416f, ASPECT, 0.9f, 800 );
    Frustum(&lightProjectionMatrix, LIGHTFOV/360.f*2.f*3.1416f, 1, 1.f, 5000 );
  
    // calculate camera matrix
    LookAt(&cameraViewMatrix, &campos, &camfocuspoint, &up);

    // calculate light matrix
    LookAt(&lightViewMatrix, &lightpos,&lightfocuspoint,&up);

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
 
    // render the main pass
    effect->SetMatrix(HANDLE_MODELVIEW, &cameraViewMatrix);
    d3dDevice->SetRenderTarget(0,screenDepthSur);
    Draw_Scene(PASS_MAIN);

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