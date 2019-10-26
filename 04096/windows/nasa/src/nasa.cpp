// windows standard configurations
#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN

// resolution and screen modes
#define FULLSCREEN
#define XRES 1280
#define YRES 720
#define ASPECT (XRES.f/YRES.f)
#ifdef FULLSCREEN
#define isWindowed 0
#else
#define isWindowed 1
#endif

// some d3dx/processorstates
#define MULTISAMPLE D3DMULTISAMPLE_NONE
#define SAVESTATE D3DXSHADER_PREFER_FLOW_CONTROL
#define MULTICORE

// windows standard includes
#include <math.h>
#include "windows.h"
#include "mmsystem.h"
#include <d3d9.h>
#include <d3dx9.h>
#include "phenom.h"
// we use fpu even in debug mode
#ifndef _DEBUG
	extern "C" int _fltused = 1;
#endif


// d3dx and other functions used
#define LookAt D3DXMatrixLookAtLH
#define Frustum D3DXMatrixPerspectiveFovLH
#define sin(x) sinf(x)
#define cos(x) cosf(x)
#define CAMFOV 140.0f

// structures
static D3DPRESENT_PARAMETERS devParams = {
  XRES, YRES, D3DFMT_A8R8G8B8, 0, MULTISAMPLE,
    0, D3DSWAPEFFECT_DISCARD, 0, isWindowed, true,
    D3DFMT_D24S8, 0, 0, 0 };
static IDirect3DDevice9 *d3dDevice;
static IDirect3D9 *d3d;
static LPD3DXEFFECT effect;
static D3DXMATRIX cameraMatrix;
static D3DXMATRIX cameraProjectionMatrix;
static D3DXMATRIX modelMatrix;
static D3DXMATRIX animParams;

// HANDLES
#define numUniform 4
static char *Uniform[numUniform]={"cm","pm","mm","an"};
static D3DXHANDLE myHandles[numUniform] = {{0}};
#define HANDLE_CAMERAMATRIX  myHandles[0]
#define HANDLE_PROJECTIONMATRIX myHandles[1]
#define HANDLE_MODELMATRIX myHandles[2]
#define HANDLE_ANIMATION myHandles[3]

// the shader source code  
static const char effectSourceCode[] =\
// ------parameter for handles
"float4x4 cm,pm,mm,an;"
// ------structures
"struct v"
"{"
  "float4 p:position,"
         "c:texcoord0,"
         "t:texcoord1,"
         "w:texcoord2;"
"};"
// ------vertexshader
"v _v(float4 p:position,float4 t:texcoord0,float4 c:color0)"
"{"
  "v o;"
  "float4 q=mul(mul(p,mm),cm);"
  "q.z += length(q.xy)*an[0].x;"
  "o.p=mul(q+t,pm);"
  //"o.p.y *= length(o.p.xy/o.p.w)*-an[0].y+1;"
  "o.w=o.p;"
  "o.c=c*(sin(q.z*0.005)*0.4+0.5);"
  "o.c*=lerp(1,sin(length(o.p.xyz-float3(0,0,1000))*0.001+an[0].y),an[0].z);"
  "o.t=sign(t);"
  "return o;"
"}"
"float4 _p(v o):color0"
"{"
  "float a=saturate(1-length(o.t.xy));"
  "float f=length(o.w.xy/o.w.w);"
  "return a*a*o.c*lerp(float4(1,1.4,1.2,1)*0.5,1,f)*an[1];"
"}"
// ------technique
"technique"
"{"
  "pass"
  "{"
    "vertexshader=compile vs_2_0 _v();"
    "pixelshader=compile ps_2_0 _p();"
    "alphablendenable=1;"
    "srcblend=one;"
    "destblend=one;"
    "zenable=0;"
    "zwriteenable=0;"
  "}"
"}";

#define MAX_VERTEX (10000000/16)
#define VERTEX_FORMAT (D3DFVF_XYZ|D3DFVF_DIFFUSE|D3DFVF_TEX1)
#define VERTEX_SIZE_IN_FLOATS (3 + 1 + 2)
static float vertexBuffer[MAX_VERTEX*VERTEX_SIZE_IN_FLOATS] = {{0}};
static char buff[256] = {{0}};
static float *currentFloat = NULL;
static float t[4] = {-1,-1,1,1};

#define MAX_OBJECTS 3
#define OBJECT1 0
#define OBJECT2 1
#define OBJECT3 2
static LPDIRECT3DVERTEXBUFFER9 Object[MAX_OBJECTS]={{NULL}};
static int ObjectVertexCount[MAX_OBJECTS] = {{0}};

void __fastcall Draw(int object)
{
  UINT passCount;
  effect->SetMatrix(HANDLE_CAMERAMATRIX, &cameraMatrix);
  effect->SetMatrix(HANDLE_PROJECTIONMATRIX, &cameraProjectionMatrix);
  effect->SetMatrix(HANDLE_MODELMATRIX, &modelMatrix);
  effect->SetMatrix(HANDLE_ANIMATION, &animParams);
  effect->Begin(&passCount,0);
  effect->BeginPass(0);
  d3dDevice->SetFVF( VERTEX_FORMAT );
  d3dDevice->SetStreamSource(0,Object[object],0,sizeof(float)*VERTEX_SIZE_IN_FLOATS);
  d3dDevice->DrawPrimitive(D3DPT_TRIANGLELIST,0,ObjectVertexCount[object]/3);
  effect->EndPass();
  effect->End();
}

void __fastcall Glow(const float *pos, float color, const float size) {
  int col = (int)(color * 255.f);
  col |= col << 8;
  col |= col << 16;
  for (int i = 0; i < 3; ++i) {
    currentFloat[0]=pos[0];
    currentFloat[1]=pos[1];
    currentFloat[2]=pos[2];
    currentFloat[3]=*((float*)&col);
    currentFloat[4]=size * (float)t[i];
    currentFloat[5]=size * (float)t[(i+1) & 3];
    currentFloat += VERTEX_SIZE_IN_FLOATS;
  }
  for (int i = 2; i < 5; ++i) {
    currentFloat[0]=pos[0];
    currentFloat[1]=pos[1];
    currentFloat[2]=pos[2];
    currentFloat[3]=*((float*)&col);
    currentFloat[4]=size * (float)t[i & 3];
    currentFloat[5]=size * (float)t[(i+1) & 3];
    currentFloat += VERTEX_SIZE_IN_FLOATS;
  }
}

void __fastcall Line(const float *pos1, const float *pos2, const float size) {
  float pos[3];
  const int pointCount = 16;
  for (int x = 0; x < pointCount; ++x) {
    float a = (float)x/(float)pointCount;
    pos[0] = pos1[0] + (pos2[0]-pos1[0])*a;
    pos[1] = pos1[1] + (pos2[1]-pos1[1])*a;
    pos[2] = pos1[2] + (pos2[2]-pos1[2])*a;
    Glow(pos,1.0,size);
  }
}

#define AFFINE_COUNT 4
D3DXMATRIX affine[AFFINE_COUNT];
void _fastcall IFS(D3DXMATRIX &mat, float siz, int depth) {
  if (depth<0)
    return;
  D3DXMATRIX useful;
  for (int i = 0; i < AFFINE_COUNT; ++i) {
    D3DXMatrixMultiply(&useful,&affine[i], &mat);
    Line(&useful.m[3][0],&mat.m[3][0], siz);
    IFS(useful,siz*0.5f,depth-1);
  }
}

// also does a recompile
void __fastcall CompileObject(int nr)
{
  int siz = (int)(currentFloat-vertexBuffer);
  ObjectVertexCount[nr]=siz/VERTEX_SIZE_IN_FLOATS;
  LPDIRECT3DVERTEXBUFFER9 &o=Object[nr];
  if (o != NULL)
    o->Release();
  d3dDevice->CreateVertexBuffer(
    siz*sizeof(float),
    0,
    VERTEX_FORMAT,
    D3DPOOL_MANAGED,
    &o,
    0);
  float *adr;
  o->Lock(
    0,
    siz*sizeof(float),
    (void**)&adr,
    0
    );
  for (int x = 0; x < siz; ++x) 
    adr[x]=vertexBuffer[x];
  //if (siz > MAX_VERTEX*VERTEX_SIZE_IN_FLOATS)
  //  ExitProcess(0);
  o->Unlock();
  currentFloat = vertexBuffer;
}


/////////////////////////////////////////////////////////////////////////////////
// initialized data
/////////////////////////////////////////////////////////////////////////////////
// MAX_SAMPLES gives you the number of samples for the whole song. we always produce stereo samples, so times 2 for the buffer
static SAMPLE_TYPE	lpSoundBuffer[MAX_SAMPLES*2];  
static HWAVEOUT	hWaveOut;

static WAVEFORMATEX WaveFMT =
{
#ifdef FLOAT_32BIT	
	WAVE_FORMAT_IEEE_FLOAT,
#else
	WAVE_FORMAT_PCM,
#endif		
    2, // channels
    SAMPLE_RATE, // samples per sec
    SAMPLE_RATE*sizeof(SAMPLE_TYPE)*2, // bytes per sec
    sizeof(SAMPLE_TYPE)*2, // block alignment;
    sizeof(SAMPLE_TYPE)*8, // bits per sample
    0 // extension not needed
};

static WAVEHDR WaveHDR = 
{
	(LPSTR)lpSoundBuffer, 
	MAX_SAMPLES*sizeof(SAMPLE_TYPE)*2,			// MAX_SAMPLES*sizeof(float)*2(stereo)
	0, 
	0, 
	0, 
	0, 
	0, 
	0
};

static MMTIME MMTime = 
{ 
	TIME_SAMPLES,
	0
};

#define KOMPI 64
#define KOMPISHIFT 6
char kugels[] = {
  // kugels
  128/KOMPI,
  384/KOMPI,
  640/KOMPI,
  //1152/KOMPI,
  6080/KOMPI,
  1664/KOMPI,
  1920/KOMPI,
  2176/KOMPI,
  2432/KOMPI,
  2688/KOMPI,
  2944/KOMPI,
  3200/KOMPI,
  3712/KOMPI,
  3968/KOMPI,
  4208/KOMPI,
  4800/KOMPI,
  5056/KOMPI,
  5312/KOMPI,
  5568/KOMPI,
  5824/KOMPI,
  //6080,
  //6336,
  //6348,
  //6592,
  
  // plane flight
  0/KOMPI,
  320/KOMPI,
  448/KOMPI,
  768/KOMPI,
  960/KOMPI,
  1280/KOMPI,
  1408/KOMPI,
  //1728,
  //2048,
  2496/KOMPI,
  2816/KOMPI,
  3008/KOMPI,
  3264/KOMPI,
  //3456,
  //3776,
  3904/KOMPI,
  4096/KOMPI,
  4224/KOMPI,
  4544/KOMPI,
  4736/KOMPI,
  4864/KOMPI,
  5184/KOMPI,
    //5504/KOMPI,
    -(5184/KOMPI),
  5952/KOMPI,
  6144/KOMPI,
  //6464,

  // sideways
  64/KOMPI,
  5120/KOMPI,
  256/KOMPI,
  512/KOMPI,
  704/KOMPI,
  832/KOMPI,
  1024/KOMPI,
  1216/KOMPI,
  1472/KOMPI,
  1536/KOMPI,
  2112/KOMPI,
  2560/KOMPI,
  2624/KOMPI,
  2752/KOMPI,
  2880/KOMPI,
  //3392/KOMPI,
  192/KOMPI,
  3520/KOMPI,
  4648/KOMPI,
  3840/KOMPI,
  4160/KOMPI,
  4228/KOMPI,
  4672/KOMPI,
    // 4928/KOMPI,
  4480/KOMPI,
  -(4480/KOMPI),
  //5120,

  // blast
  6144/KOMPI,
  704/KOMPI,
  960/KOMPI,
  1088/KOMPI,
  1408/KOMPI,
  2240/KOMPI,
  2368/KOMPI,
  2432/KOMPI,
  2688/KOMPI,
  2752/KOMPI,
  2880/KOMPI,
  3200/KOMPI,
  3712/KOMPI,
  3804/KOMPI,
    //3968/KOMPI,
    //4160/KOMPI,
    //-(4160/KOMPI),
    3968/KOMPI,
    -(3968/KOMPI),
  4416/KOMPI,
  4480/KOMPI,
  4928/KOMPI,
  5696/KOMPI,
  5760/KOMPI,
  5824/KOMPI,
  6144/KOMPI,
  6208/KOMPI,
  6272/KOMPI,

  // builddown
  //6592,
  //6348,
  //6336,
  //6080,
  5824/KOMPI,
  5568/KOMPI,
  5312/KOMPI,
  5056/KOMPI,
  4800/KOMPI,
  4208/KOMPI,
  3968/KOMPI,
  3712/KOMPI,
  3200/KOMPI,
  2944/KOMPI,
  2688/KOMPI,
  2432/KOMPI,
  2176/KOMPI,
  1920/KOMPI,
  128/KOMPI,
  //1152/KOMPI,
  640/KOMPI,
  384/KOMPI,
  6080/KOMPI,
  1664/KOMPI,
  1664/KOMPI,
};


#ifdef _DEBUG
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
#else
extern "C" __declspec(noreturn) void WinMainCRTStartup()
#endif
{
#ifdef MULTICORE
  CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0);
#else
  if (MessageBox(NULL,"MultiCore","if not please wait approx 3min",MB_YESNO)==IDYES)
    CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0);
  else
    _4klang_render(lpSoundBuffer);
#endif

  // ---------------------------------------------
  // INIT DIRECT3D
  // ---------------------------------------------
  d3d=Direct3DCreate9( D3D_SDK_VERSION ); 
  devParams.hDeviceWindow = CreateWindow("static",0,WS_POPUP|WS_VISIBLE,0,0,XRES,YRES,0,0,0,0); 
  if(D3D_OK!=d3d->CreateDevice(D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,devParams.hDeviceWindow,D3DCREATE_HARDWARE_VERTEXPROCESSING,&devParams,&d3dDevice))
    ExitProcess(0);
  ShowCursor( 0 );

  for (int i = 0; i < 255; ++i) {
    buff[i] = kugels[i & 63] & 1 ? '0' : '1'; 
  }
  buff[200]=0;//packs better :)
  // ---------------------------------------------

  // ---------------------------------------------
  // COMPILE SHADERS
  // ---------------------------------------------
  D3DXCreateEffect(d3dDevice, effectSourceCode, sizeof(effectSourceCode)-1, NULL, NULL, SAVESTATE, NULL, &effect, NULL ); 
  //ID3DXBuffer *errors;
  //int h = D3DXCreateEffect(d3dDevice, effectSourceCode, sizeof(effectSourceCode)-1, NULL, NULL, SAVESTATE, NULL, &effect, &errors);
  //if (errors||!effect||(h<0))
  //{
  //  OutputDebugString("effectgenerationfailed\n");
  //  if (errors)
  //  {
  //    OutputDebugString((char*)(errors->GetBufferPointer()));
  //    errors->Release();
  //  }
  //  ExitProcess(0);
  //}
 
  // ---------------------------------------------
  // GET THE HANDLES
  // ---------------------------------------------
  for (int i = 0; i < numUniform; ++i)
    myHandles[i]=effect->GetParameterByName( NULL, Uniform[i] );

  currentFloat = vertexBuffer;
#define tesX 100
#define tesY 100
  for (int y = 0; y < tesY; ++y)
    for (int x = 0; x < tesX; ++x) {
      float pos[3];
      pos[0] = ((float)x/tesX*2.0f-1.0f)*10000.0f;
      pos[2] = ((float)y/tesY*2.0f-1.0f)*2500.0f;
      pos[1] = pow(cos(pos[0])*4+cos(pos[2])*4,3);
      Glow(pos,0.5,40.0);
      pos[1] = -pos[1]+2000;
      Glow(pos,0.5,40.0);
      float t = pos[0];
      pos[0] = pos[1];
      pos[1] = t;
      Glow(pos,0.5,40.0);
      pos[0] = -pos[0]+2000;
      Glow(pos,0.5,40.0);
    }
    CompileObject(OBJECT2);


  waveOutOpen	( &hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
	waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
	waveOutWrite( hWaveOut, &WaveHDR, sizeof(WaveHDR) );	

  ID3DXFont *g_pFont;
  D3DXCreateFont( d3dDevice,            // D3D device
                  24*YRES/720,      // Height
                  0,//fkk[i]*YRES/768/3,      // Width
                  FW_MEDIUM,            // Weight
                  0,                    // MipLevels, 0 = autogen mipmaps
                  0,                    // Italic
                  DEFAULT_CHARSET,      // CharSet
                  OUT_DEFAULT_PRECIS,   // OutputPrecision
                  DEFAULT_QUALITY,      // Quality
                  DEFAULT_PITCH | FF_DONTCARE, // PitchAndFamily
                  "Palatino Linotype",             // pFaceName
                  &g_pFont);            // ppFont

  // ---------------------------------------------
  // START THE LOOP
  // ---------------------------------------------
  const float segmentSize = (float)(4.0 * 60.0 / (double)(BPM));
  do
  {
    waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
    float curTime = (float)((double)MMTime.u.sample / 44100.0);
    float curFime = curTime-(segmentSize * 16);
    int segment2 = (int)(curTime / segmentSize * 16384.f)>>14; // error!!
//    segment *= KOMPI;
    int segment = (int)kugels[segment2] << KOMPISHIFT;
    if (segment < 0)
      segment = -segment + 1;
    curTime = (float)segment * segmentSize + curTime - segment2*segmentSize; 

    D3DXMATRIX mat;
    for (int x = 0; x < AFFINE_COUNT; ++x) {
      D3DXMatrixIdentity(&mat);
      mat.m[0][0] = 0.725f*sin(curTime*0.025f);
      mat.m[1][1] = 0.725f*sin(curTime*0.1f);
      mat.m[2][2] = 0.725f*sin(curTime*0.0325f);
      mat.m[3][2] = (x-AFFINE_COUNT/2)*2000.f;
      float xf = (float)x;
      D3DXMatrixRotationYawPitchRoll(&affine[x],xf*5.f,xf*7.f,xf*12.f);
      D3DXMatrixMultiply(&affine[x],&affine[x],&mat);
    }
    D3DXMatrixRotationZ(&mat,curTime*0.1f);
    IFS(mat,500.0f,5);
    CompileObject(OBJECT1);

    // animatables
    float u = sin(curTime*0.01953f);
    u *= u; 
    u *= u; 
    u *= u; 
    u *= u; 
    u *= u; 
    animParams.m[0][0] = u*5.f;
    animParams.m[0][1] = curFime / segmentSize * 3.1415927f;
    float f = curFime/segmentSize+8;
    u = 32;
    if (f > 0)
      u = 32-f * 4;
    f-=40;
    if (f > 0)
      u = 8-f * 1;
    f-=32;
    if (f > 0)
      u = 32-f * 2;
    animParams.m[0][2] = u > 0 ? u : 0;
      
    float k = cos(curTime*0.010579f);
    k *= k;
    k *= k;
    k *= k;
    k *= k;
    k *= -2500.f;
    k -= 10.f;
    if (curFime < 0) curFime = 0;
    animParams.m[1][0] = 1.f+curFime/250.f;
    animParams.m[1][1] = 1.f-curFime/2000.f;
    animParams.m[1][2] = 1.f-curFime/1000.f;

    float t = curTime * 250;
    D3DXVECTOR3 up(sin(curTime*0.1f),cos(curTime*0.1f),0);
    D3DXVECTOR3 camfocuspoint(0,500,t);
    D3DXVECTOR3 campos(sin(curTime*0.010579f*2.f)*500,750,k+t);
    Frustum(&cameraProjectionMatrix, CAMFOV/360.f*2.f*3.1416f, ASPECT, 1.0f, 10000 ); 
    LookAt(&cameraMatrix,&campos,&camfocuspoint,&up);
    // begin the scene
    d3dDevice->Clear(0,0,D3DCLEAR_TARGET|D3DCLEAR_ZBUFFER,0,1,0);
    d3dDevice->BeginScene();
    for (int x = 0; x < 5; ++x) {
      float a = (float)( ((int)(campos.z/5000.f)+x) * 5000-2000 ); 
      D3DXMatrixTranslation(&modelMatrix,0,0,a);  
      Draw(OBJECT2);
      Draw(OBJECT1);
      D3DXMatrixTranslation(&modelMatrix,-10000,0,a);  
      Draw(OBJECT1);
      D3DXMatrixTranslation(&modelMatrix,+10000,0,a);  
      Draw(OBJECT1);
    }

    g_pFont->DrawText( NULL, "STILL-NASA", -1, NULL, DT_NOCLIP, 0x40ffffff );
    for (int x = 0; x < 3; ++x)
    {
      RECT rc;SetRect( &rc, 0, (720-7*12+x*24)*YRES/720, 0, 0 );
      g_pFont->DrawText( NULL, buff+(((int)(f*3)*26+x*26) & 63), -1, &rc, DT_NOCLIP, 0x40000000 );
    }

    // display the scene
    d3dDevice->EndScene();
    d3dDevice->Present( NULL, NULL, NULL, NULL );
  } while (!GetAsyncKeyState(VK_ESCAPE) && waveOutUnprepareHeader(hWaveOut,&WaveHDR,sizeof(WAVEHDR)) == WAVERR_STILLPLAYING);
  ExitProcess(0);
}