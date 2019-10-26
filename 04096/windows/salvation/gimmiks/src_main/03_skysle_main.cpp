#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#define FULLSCREEN
//#define CHECKEFFECT
//#define USERCONTROL
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
    //"AddressU=Border;"
    //"AddressV=Border;"
"};"
"sampler tx2s=" 
"sampler_state"
"{"
    "Texture=<tx2>;"    
    //"MinFilter=LINEAR;"
    //"MagFilter=LINEAR;"
    //"MipFilter=NONE;"
    //"AddressU=Border;"
    //"AddressV=Border;"
"};"
"sampler tx3s=" 
"sampler_state"
"{"
    "Texture=<tx3>;"    
    //"MinFilter=LINEAR;"
    //"MagFilter=LINEAR;"
    //"MipFilter=NONE;"
    //"AddressU=Border;"
    //"AddressV=Border;"
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
    "o.pt=ps;"
    "o.cl=0;"
    "o.psw=mul(mul(ps,mvm),pm);"
    "o.ps=o.psw;"
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
  "float4 c=gs(float2(rn.x+i.ps.x,(rn.y+i.ps.y+i.ps.x)*.5))*i.cl*lerp(float4(.2,.15,.05,0),float4(.4,.3,.3,1),max(0,dot(rn,normalize(b.xyz-i.ps.xyz))));"
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
  "float4 d=float4(normalize(i.ps.xyz-cp[3].xyz),0)*1.5;"
  "float4 b=cp[3];"
  "o.cl=0;"
  "int l=1;"
  "for(int j=0;j<160;++j)"
  "{"
    "if(l)"
    "{"
      "b+=d;"
      "float4 pz=mul(b,lvpm);pz/=pz.w;"
      "float4 pv=mul(b,mvpm);pv/=pv.w;"
      "if (tex2D(tx2s,pz.xy).x-pz.z>-"SHADOWVAL")o.cl+=float4(.9,.8,.6,0)*.0025;"
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
  "float4 b=cp[3]+d*550;"
  "b.xz/=b.y*.5;"
  "float c=sin(b.x*.1+b.z*.1+sin(b.x*1.2+b.z*.3))+sin(b.x*.3+b.z*.1)+sin(b.x*1.2+b.z*1.3)*.1;"
  "c=pow(.7,c*2);"
             //sun color             horizon color         sky color              cloud color
  "o.cl=lerp(float4(0,0,0,0),lerp(float4(.6,.7,.8,0),lerp(float4(.3,.6,.8,0),float4(1,1,1,1),c),b.y*.05),.15)*.25;"
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
  "float4 c=dot(rn,normalize(b.xyz-i.ps.xyz))*i.cl+i.cl;"  
  "if (tex2D(tx2s,pz.xy).x-pz.z<-"SHADOWVAL") c*=.5;"
  "o.cl=c;"
  "return o;"
"}"
//watershader
"float4 PST5(vso i):COLOR0"
"{"
"float4 c=(tex2D(tx1s,i.ps.xy/i.ps.w*float2(.5,-.5)+.5+sin(i.ps.x)*.001+i.pt.y*0.001)*.5+float4(0.25,0.25,0.25,0)+i.pt.y*.01)*float4(0.25,0.35,0.3,0);"
"c=lerp(c,float4(.05,.025,.0125,0),min(1,length(i.pt*.0015)));"
"float4 pz=mul(i.pt,lvpm);pz/=pz.w;"
//"if (tex2D(tx2s,pz.xy).x-pz.z<-"SHADOWVAL") c*=.5;"
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
  "float4 c=(pow(dot(normalize(normalize(l-p)+normalize(v-p)),n),30)*float4(.09,.08,.06,0)+max(.0,dot(normalize(l-p),n))*.25)*0.2;"
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
  // Cube Shader
  "pass P6"
  "{"
    "VertexShader=compile vs_3_0 VSTC();"
    "PixelShader=compile ps_3_0 PSTC();"
  "}"
  // Cube Zonly 
  "pass P7"
  "{"
    "VertexShader=compile vs_3_0 VSTC();"
    "PixelShader=compile ps_3_0 PSTD();"
  "}"
"}";

#define WATER_HEIGHT 0  // hier geht bloß 0
#define WATER_DEPTH 2000 // change this value in the shader too 

#define PASS_MAIN 0
#define PASS_ZRENDER 1
#define PASS_VOLUMELIGHT 2
#define PASS_SKY 3
#define PASS_STONY 4
#define PASS_WATER 5
#define PASS_CUBE 6
#define PASS_CUBE_ZRENDER 7
unsigned int clearColor[]={0x00000000,0xffffffff};//fuer die ersten beiden passes eine clearfarbe

#define MAX_OBJECTS 20
#define OBJECT_GROUND 0
#define OBJECT_TREE1 1
#define OBJECT_TREE2 2
#define OBJECT_FUTURA 3
#define OBJECT_WATER 4
#define OBJECT_BOAT 5
#define OBJECT_STREET 6
#define OBJECT_BLACK 7
#define OBJECT_SHROOM 11

#define VERTEX_FORMAT (D3DFVF_XYZ|D3DFVF_DIFFUSE|D3DFVF_TEX1)
#define VERTEX_SIZE_IN_FLOATS (3 + 1 + 2)
#define MAX_VERTEX 10000000

#define SHADOWMAP_WIDTH 2048
#define SHADOWMAP_HEIGHT 2048

// tweakable
// picture control start
#define FUTURA_COUNT 5
#define FUTURA_SEED 300
#define FUTURA_RAD 50.f
#define FUTURA_HEIGHT 10.f
D3DXVECTOR3 lightpos(-80,200,-200);
D3DXVECTOR3 lightfocuspoint(0,0,0);
D3DXVECTOR3 campos(0,100,100);
D3DXVECTOR3 camfocuspoint(0,100,0);
#define CAMFOV 100.f
#define LIGHTFOV 100.f
#define TOWER_SEED1 10
#define TOWER_COUNT1 200
#define TOWER_SEED2 100
#define TOWER_COUNT2 200
// picture control end

#define SPHERE_TYPE_SHROOM 0
#define SPHERE_TYPE_BLOSSOM 1
#define SPHERE_TYPE_FRUIT 2
#define SPHERE_TYPE_NET 3

#define setv(v,x,y,z) {v[0] = (x); v[1] = (y); v[2] = (z);}
#define sin(x) sinf(x)
#define cos(x) cosf(x)
#define COL(r,g,b,a) b,g,r,a

static float sinusio;
static float sphere_p[4];
static float sphere_s;
static float cube_s[4];
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
static float sinv[8]={-1,0,1,1,1,0,-1,-1};
static float cosv[8]={1,1,1,0,-1,-1,-1,0};

static float Sphere_Colors[] = {COL(0.4f,0.2f,0.0f,0.f), COL(0.3f,0.2f,0.0f,0.f), COL(0.4f,0.2f,0.15f,0.f), COL(0.15f,0.2f,0.25f,0.f)};

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
  *(c+3) = sphere_s;
  Vertex(sphere_p,c,1,1); 
  Vertex(sphere_p,c,1,0); 
  Vertex(sphere_p,c,0,0); 
  Vertex(sphere_p,c,0,0); 
  Vertex(sphere_p,c,0,1); 
  Vertex(sphere_p,c,1,1);
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

void __fastcall PlaceCube3()
{
  if (rand_4k() & 7)
    return;
  float zs=sphere_p[2]-cube_s[2];
  float ze=sphere_p[2]+cube_s[2];
  float zy=cube_s[2]*0.2f;
  cube_s[2]=zy*0.5f*0.2f;
  cube_s[0]+=1.f;
  cube_s[1]+=1.f;
  for (float z=zs;z<ze;z+=zy)
  {
    sphere_p[2]=z;
    PlaceCube();
  }
}

void __fastcall PlaceCube2()
{
  float xs=sphere_p[0]-cube_s[0];
  float ys=sphere_p[1]-cube_s[1];
  float zs=sphere_p[2]-cube_s[2];
  float xe=sphere_p[0]+cube_s[0];
  float ye=sphere_p[1]+cube_s[1];
  float ze=sphere_p[2]+cube_s[2];
  float sx=2.5f;
  float sy=2.5f;
  float sz=15.f;
  for (float x=xs;x<xe;x+=sx)
  for (float y=ys;y<ye;y+=sy)
  for (float z=zs;z<ze;z+=sz)
  {
    sphere_p[0]=x+frand_4k()*sx*2;
    sphere_p[1]=y+frand_4k()*sy*2;
    sphere_p[2]=z+frand_4k()*sz;
    cube_s[0]=sx;
    cube_s[1]=sy;
    cube_s[2]=sz;
    PlaceCube();
    PlaceCube3();
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

void CUBE(float x,float y,float z,float xs,float ys,float zs)
{
  sphere_p[0]=x;
  sphere_p[1]=y;
  sphere_p[2]=z;
  cube_s[0]=xs;
  cube_s[1]=ys;
  cube_s[2]=zs;
  PlaceCube2();
}

void __fastcall Draw_Scene(int pass)
{
  d3dDevice->SetFVF( VERTEX_FORMAT );

  d3dDevice->Clear(0,0,D3DCLEAR_TARGET|D3DCLEAR_ZBUFFER,clearColor[pass],1,0);
  d3dDevice->BeginScene();

  int p3=pass;if (p3==PASS_MAIN) p3=PASS_STONY; 

  seed =200;
  for (int i=0;i<150;++i)
  {
    Translation.x=frand_4k()*1000.f;
    Translation.z=frand_4k()*400.f-400.f;
    Translation.y=(frand_4k()*150.f+150.f);
    if ((Translation.x>150)||(Translation.x<-50))
    {
      DrawObject(OBJECT_SHROOM,p3);
    }
  }
  Translation.x=0;
  Translation.y=0;
  Translation.z=-460;
  int p2=PASS_CUBE_ZRENDER;if (pass==PASS_MAIN) p2=PASS_CUBE; 
  DrawObject(OBJECT_BLACK,p2);
  d3dDevice->EndScene();
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
  d3dDevice->CreateDepthStencilSurface(SHADOWMAP_WIDTH>XRES?SHADOWMAP_WIDTH:XRES,SHADOWMAP_HEIGHT>YRES?SHADOWMAP_HEIGHT:YRES, D3DFMT_D24S8,MULTISAMPLE,0,0,&newDepthBuffer,0);
  d3dDevice->SetDepthStencilSurface(newDepthBuffer);
  d3dDevice->GetRenderTarget(0,&screenDepthSur);

  // ---------------------------------------------
  
  // ---------------------------------------------
  // CALCULATE LANDSCAPE AND TREES
  // ---------------------------------------------
  float radius=50.f;
  for (float y=0;y>-500.f;y-=0.4f)
  {
    sphere_p[0]=-10000.f;
    sphere_p[1]=y+110.f;
    float k=y*0.1f;
    float dix=sin(k-cos(k))*4.f;
    float diz=cos(k-sin(k))*4.f;
    for (float x=0;x<2.f*3.1416f;x+=0.01f)
    {
      float dispersion=sin(x*5.f+y)*radius*0.1f;
      float nx=sin(x)*(radius+dispersion)+dix;
      float nz=cos(x)*(radius+dispersion)+diz;
      float nx2=nx-sphere_p[0];
      float nz2=nz-sphere_p[2];
      float d=nx2*nx2+nz2*nz2;
      if (d>0.1f)
      {
        sphere_p[0]=nx;
        sphere_p[2]=nz;
        sphere_s=0.1f;
        PlaceSphere(SPHERE_TYPE_SHROOM);
      }
    }
    radius*=0.975f;
  }

  for (int y = 0; y < 10; ++y)
  {
    sphere_p[0]=0;
    sphere_p[1]=110.f;
    sphere_p[2]=0;
    sphere_s = 0.1f;
    float a[3];
    a[0] = frand_4k();
    a[1] = frand_4k()+2;
    a[2] = frand_4k();
    for (int i = 0; i < 75; ++i)
    {
      a[0] += frand_4k()*0.075f;
      a[1] += frand_4k()*0.075f;
      a[2] += frand_4k()*0.075f;
      float d = sphere_s*12.f/sqrt(a[0]*a[0]+a[1]*a[1]+a[2]*a[2]);
      PlaceSphere(SPHERE_TYPE_BLOSSOM);
      sphere_p[0]+=a[0]*=d;
      sphere_p[1]+=a[1]*=d;
      sphere_p[2]+=a[2]*=d;
      sphere_s *= 0.995f;
    }
    sphere_s=0.5f+frand_4k()*0.25f;
    PlaceSphere(SPHERE_TYPE_FRUIT);
  }
  CompileObject(OBJECT_SHROOM);

  seed = 0;
  CUBE(50,200,-50,50,5,500);
  CompileObject(OBJECT_BLACK);

#define WXSTEP 100.f
#define WYSTEP 20.f
#define WZSTEP 100.f
  for (float z=-WATER_DEPTH;z<WATER_DEPTH;z+=WZSTEP)
  for (float x=-WATER_DEPTH;x<WATER_DEPTH;x+=WXSTEP)
  {
    sphere_p[0]=x;
    sphere_p[1]=WATER_HEIGHT-WYSTEP*0.5f+frand_4k()*WYSTEP*0.5f;
    sphere_p[2]=z;
    cube_s[0]=WXSTEP*0.5f;
    cube_s[1]=WYSTEP*0.5f;
    cube_s[2]=WZSTEP*0.5f;
    PlaceCube();
  }
  CompileObject(OBJECT_WATER);

#ifndef FULLSCREEN
  do
  {
#endif

    // ---------------------------------------------
    Frustum(&cameraProjectionMatrix, CAMFOV/360.f*2.f*3.1416f, ASPECT, 0.9f, 1000 );
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