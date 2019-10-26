// windows standard configurations
#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
//#define MADHACK

// resolution and screen modes
#define FULLSCREEN
#define XRES 1280
#define YRES 720
#define SCALEX 1
#define SCALEY 1
#ifdef MADHACK
//#define XRES 1680
//#define YRES 1050
//#define SCALEX 1
//#define SCALEY (1280.0/XRES)
#endif
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
#include "space.h"
// we use fpu even in debug mode
#ifndef _DEBUG
	extern "C" int _fltused = 1;
#endif


// d3dx and other functions used
#define LookAt D3DXMatrixLookAtLH
#define Frustum D3DXMatrixPerspectiveFovLH
#define sin(x) sinf(x)
#define cos(x) cosf(x)
#define VOXX 256
#define VOXY 256
#define VOXZ 256
#define VOXXSTRING "256"
#define NORMI "40" // for the normal calculations
#define STEPI "10" // for the step onto the surface
#define VOXI "24" // for the voxeltexture lookup
#define LOWRESX (1280/4) // increase this texture size for lesser blockiness
#define LOWRESY (720/4)
#define MAXSCENE 512

// structures
static D3DPRESENT_PARAMETERS devParams = {
  XRES, YRES, D3DFMT_A8R8G8B8, 0, MULTISAMPLE,
    0, D3DSWAPEFFECT_DISCARD, 0, isWindowed, true,
    D3DFMT_D24S8, 0, 0, 0 };
static IDirect3DDevice9 *d3dDevice;
static IDirect3D9 *d3d;
static LPD3DXEFFECT effect;
static D3DXMATRIX cameraMatrix;

// HANDLES
#define numUniform 3
static char *Uniform[numUniform]={"cm","tx","ty"};
static D3DXHANDLE myHandles[numUniform] = {{0}};
#define HANDLE_CAMERAMATRIX  myHandles[0]
#define HANDLE_VOLUMETEXTURE myHandles[1]
#define HANDLE_TEXTURE myHandles[2]

// the shader source code  
static const char effectSourceCode[] =\
// ------parameter for handles
// cm[0] = pos;
// cm[1] = dir;
// cm[2] = up;
"float4x4 cm;"
"texture tx,ty;" // tx should be texture3d
"sampler3D txs=" 
"sampler_state"
"{"
    "texture=<tx>;"    
    "minfilter=linear;" // can be avoided
    "magfilter=linear;"
    //"MipFilter=NONE;"
    //"AddressU=Clamp;"
    //"AddressV=Clamp;"
"};"
"sampler tys=" 
"sampler_state"
"{"
    "texture=<ty>;"    
    "minfilter=linear;" // can be avoided
    "magfilter=linear;"
    //"MipFilter=NONE;"
    "addressu=clamp;"
    "addressv=clamp;"
"};"
// ------structures
"struct v"
"{"
  "float4 s:position," // screenpos
         "p:texcoord0," // raystart
         "d:texcoord1," // raydir
         "e:texcoord2;" // screenpos
"};"
// ------vertexshader
"v _v(float4 p:position)"
"{"
  "v o;"
  "o.s=o.e=p;"
  "o.p=cm[0];"//w muss dafür 0 sein
//  "o.d=float4(cm[1].xyz+p.y*1.5*cm[2].xyz+p.x*1.5*1280./720.*normalize(cross(cm[1].xyz,cm[2].xyz)),0);"
  "o.d=float4(cm[1].xyz+p.y*1.5*cm[2].xyz+p.x*2.6*normalize(cross(cm[1].xyz,cm[2].xyz)),0);"
  "return o;"
"}"

"float _i(float3 p)"
"{"
  "float3 o=p-(cm[0].xyz+cm[1].xyz*.3475);"
  "o-=o*sin(atan2(o.x,o.y)*5)*sin(atan2(o.y,o.z)*7)*.55;"
  "return length(o)-cm[3].z;"
"}"
"float4 _d(float3 c,float j)"
"{"
  //"float sc=-2.975;" // scale darf nicht kleiner 1
  "float s=2.895;" // scale darf nicht kleiner 1
  "float d=1;"
  "float fR2=.85;" // farrad*farrad
  "float mR2=.625;" //minrad*minrad
  "float3 p=0;"
  "float i;"
  "float o=1000;" 
  "for(i=0;i<j;i++)"
  "{"
    "p=sign(p)*(1-abs(abs(p)-1));"
    "float r2=dot(p,p);"
    "if(r2<mR2)"
    "{"
      "p*=fR2/mR2;"
      "d*=fR2/mR2;"
    "}"
    "else if(r2<fR2)"
    "{"
      "p*=fR2/r2;"
      "d*=fR2/r2;"
    "}"
    "p*=s;"
    "d*=s;"//"d*=abs(s);"
    "p+=c;"
    "d+=1;"
    "o=min(o,length(abs(p)-2.25));"
  "}"
  "return float4((length(p)-s+1)/d-pow(s,1-i),o,0,0);"//  "return float4((length(p)-abs(s-1))/abs(d)-pow(abs(s),1-i),o,0,0);"
"}"
"float _e(float3 c)"
"{"
  "return tex3Dlod(txs,float4(c/4+.5,0)).x;"
"}"
"float3 _n(float3 p)"
"{"
  "float dt=.001;"
  "float3 n=float3(_d(p+float3(dt,0,0),"NORMI").x,_d(p+float3(0,dt,0),"NORMI").x,_d(p+float3(0,0,dt),"NORMI").x)-_d(p,"NORMI").x;"
  "return normalize(n);"
"}"
"float3 _n2(float3 p)"
"{"
  "float dt=.025;"
  "float3 n=float3(_i(p+float3(dt,0,0)),_i(p+float3(0,dt,0)),_i(p+float3(0,0,dt)))-_i(p);"
  "return normalize(n);"
"}"
"float4 _p(v o):color0"
"{"
  "float3 d=normalize(o.d);"
  "float3 p=o.p.xyz+d*.05;"
  "float k=1;"
  "for(int i=0;i<250&&abs(k)>1./"VOXXSTRING";i++){"
    "k=_e(p);"
    "p+=d*k;"
  "}"
  "for(int i=0;i<32;i++){"
    "k=_d(p,"STEPI").x;"
    "p+=d*k;"
  "}"
  "return float4(p,0);"
"}"
"v _q(float4 p:position)"
"{"
  "v o;"
  "o.s=p;"
  "o.p=o.d=o.e=float4(p.xy,cm[3].w,0);"
  "return o;"
"}"
"float4 _r(v o):color0"
"{"
  "float3 p=o.p.xyz*2;"
  "return _d(p,"VOXI").x;"
"}"
//"float _a(float3 p,float3 d)"
//"{"
//  "float k=1;"
//  "float a=0.1;"
//  "float v=0;"
//  "float r=1;"
//  "for(int i=0;i<5;i++)"
//  "{" 
//    "v+=r*(i*d*a-_d(p-i*d*a,8));"
//    "r*=.5;"
//  "}"
//  "return max(0,k*v);"
//"}"
"float4 _s(v o):color0"
"{"
  "float3 d=normalize(o.d);"
  "float3 sp=o.p.xyz;"
  "float3 p2=sp;"
  "float k=1;"
  "for(int i=0;i<5&&cm[3].z>0;i++){"
    "k=_i(p2);"
    "p2+=d*k;"
  "}"
  "float2 f=o.e.xy*.5+.5;"
  "float3 p=clamp(tex2Dlod(tys, float4(f,0,0)),-4,4);"
  "float z=min(2,length(p-p2));"
  "if(length(p2-sp)<length(p-sp)&&cm[3].z>0)"
  "{"
    "f+=_n2(p2).xy*z*.1;"
    "p=clamp(tex2Dlod(tys, float4(f,0,0)),-4,4);"
  "}"
  "float3 n=_n(p);"
  "float3 l=normalize(float3(.2,1,.3));"
  "float h=dot(n,l)*.5+.5;"
  "float s=pow(saturate(dot(n,normalize(normalize(sp-p)+l))),20);"
  "h*=1.5-length(p-sp);"
  "float4 r=(lerp(float4(.1,.4,.3,0),lerp(float4(.6,.9,1,0),float4(1,.9,.6,0)*.45,cm[3].y),clamp(_d(p,"NORMI").y*.5,0,1))*h+float4(.9,.6,.3,0)*(1-max(0,h))*.2)*cm[3].x+s;"
  "if(length(p2-sp)<length(p-sp)&&cm[3].z>0)"
  "{"
    "p=p2;"
    "float3 n=_n2(p);"
    "float h=dot(n,l)*.425+.5;"
    "float s=pow(saturate(dot(n,normalize(normalize(sp-p)+l))),20);"
    "r=lerp(r,s+h*float4(.1,.4,.3,0)*cm[3].x,max(0,max(0,1-length(p-sp)*.5)-.5+z*.5));"
  "}"
  "return r;"
"}"

// ------technique
"technique"
"{"
  "pass"
  "{"
    "vertexshader=compile vs_3_0 _v();"
    "pixelshader=compile ps_3_0 _p();"
  "}"
  "pass"
  "{"
    "vertexshader=compile vs_3_0 _q();"
    "pixelshader=compile ps_3_0 _r();"
  "}"
  "pass"
  "{"
    "vertexshader=compile vs_3_0 _v();"
    "pixelshader=compile ps_3_0 _s();"
  "}"
"}";

static const float quadVerts[4*5] =
{
  1.0f*SCALEX, -1.0f*SCALEY,0.0f,
 -1.0f*SCALEX, -1.0f*SCALEY,0.0f,
  1.0f*SCALEX, 1.0f*SCALEY,0.0f,
 -1.0f*SCALEX, 1.0f*SCALEY,0.0f
};

LPDIRECT3DSURFACE9 surs;
LPDIRECT3DSURFACE9 sur1;
LPDIRECT3DSURFACE9 sur2;
LPDIRECT3DTEXTURE9 tex1;
LPDIRECT3DVOLUMETEXTURE9 vox1;

double scene[MAXSCENE];
int taktStart[MAXSCENE];

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

void Draw(int pass) {
    UINT passCount;
#ifdef MADHACK
    d3dDevice->Clear(0,0,D3DCLEAR_TARGET|D3DCLEAR_ZBUFFER,0,1,0);
#endif
    effect->SetMatrix(HANDLE_CAMERAMATRIX, &cameraMatrix);
    effect->SetTexture(HANDLE_TEXTURE, tex1);
    effect->SetTexture(HANDLE_VOLUMETEXTURE, vox1);
    effect->Begin(&passCount,0);
    effect->BeginPass(pass);
    d3dDevice->SetFVF( D3DFVF_XYZ);
    d3dDevice->DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,2,quadVerts,3*sizeof(float));
    effect->EndPass();
    effect->End();
}

#ifdef _DEBUG
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
#else
extern "C" __declspec(noreturn) void WinMainCRTStartup()
#endif
{
  CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0); 

  int q = 2+15*4;

  seed = 31337;
  for (int i = 0; i < MAXSCENE; ++i) {
    scene[i] = (double)rand_4k()/32.0;
    if (i & 1) 
      scene[i] = scene[i-1]+0.25;
  }
  scene[2*40+1]=443;
  //for (int i = 2*40+1+1; i < 2*40+1+2*10; ++i) { // you could include this
  //  scene[i]=scene[i-1]+0.1; // without 4072 bytes with 4085
  //}
  scene[85] = scene[12];
  scene[87] = scene[39];
  scene[89] = scene[24];
  scene[94] = scene[45];

  scene[102] = scene[51];
  scene[103] = scene[55];
  scene[105] = scene[11];
  scene[109] = scene[13];
  scene[112] = scene[17];

  // that one is wrong but 1.5 as delta looked worse
  // i think this does also work, treat it as design
  // decision
  taktStart[0] = 0;
  for (int i = 0; i < MAXSCENE-1; ++i)  {
    if (i==2*40)
      q+=64;
    q += i & 1 ? 1 : 3;
    taktStart[i+1] = q;
  }
  // ---------------------------------------------
  // INIT DIRECT3D
  // ---------------------------------------------
  d3d=Direct3DCreate9( D3D_SDK_VERSION ); 
  devParams.hDeviceWindow = CreateWindow("static",0,WS_POPUP|WS_VISIBLE,0,0,XRES,YRES,0,0,0,0); 
  if(D3D_OK!=d3d->CreateDevice(D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,devParams.hDeviceWindow,D3DCREATE_HARDWARE_VERTEXPROCESSING,&devParams,&d3dDevice))
    ExitProcess(0);
  ShowCursor( 0 );

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

  d3dDevice->CreateVolumeTexture(VOXX,VOXY,VOXZ,1,0,D3DFMT_R32F,D3DPOOL_MANAGED,&vox1,0);
  d3dDevice->CreateTexture(LOWRESX,LOWRESY,1,D3DUSAGE_RENDERTARGET,D3DFMT_A32B32G32R32F,D3DPOOL_DEFAULT, &tex1,0);
  d3dDevice->CreateRenderTarget(VOXX,VOXY,D3DFMT_R32F,D3DMULTISAMPLE_NONE, 0, true, &sur1, 0);
  d3dDevice->GetRenderTarget(0,&surs);
  tex1->GetSurfaceLevel(0,&sur2);

  D3DLOCKED_BOX lb;
  vox1->LockBox(0,&lb,0,0);
  float *lbp = (float*)lb.pBits;
  int lbp1 = lb.RowPitch >> 2;
  int lbp2 = lb.SlicePitch >> 2;

  d3dDevice->BeginScene();
  for (int i = 0; i < VOXZ; ++i) {
  
    cameraMatrix.m[3][3] = (float)i/(float)(VOXZ/2)-1;
    d3dDevice->SetRenderTarget(0, sur1);
    Draw(1);
    D3DLOCKED_RECT lr;
    sur1->LockRect(&lr,0,D3DLOCK_DISCARD);
    float *lrp = (float*)lr.pBits;
    int lrp1 = lr.Pitch >> 2;
    for (int y = 0; y < VOXY; ++y) {
      float *x1 = lbp+lbp1*y+lbp2*i;
      float *x2 = lrp+lrp1*y;
      for (int x = 0; x < VOXX; ++x) {
        *x1++ = *x2++;
      }
    }
    sur1->UnlockRect();

  }
  vox1->UnlockBox(0);

//  d3dDevice->EndScene();
//  d3dDevice->Present( NULL, NULL, NULL, NULL );

  ID3DXFont *g_pFont;
  D3DXCreateFont( d3dDevice,            // D3D device
                  32*YRES/720,      // Height
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

  // display the scene
  waveOutOpen	( &hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
	waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
	waveOutWrite( hWaveOut, &WaveHDR, sizeof(WaveHDR) );	

  // ---------------------------------------------
  // START THE LOOP
  // ---------------------------------------------
  int currentScene = 0;
  do
  {
    waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
    double curTakt = ((double)MMTime.u.sample / 44100.0 * BPM / 60.0);
//curTakt+=64*4;
    if (curTakt > taktStart[currentScene])
      currentScene++;
    double curTime = (scene[currentScene] +  (double)(curTakt - taktStart[currentScene])*0.005);

    double t1 = sin(curTime*1.225);
    t1 *= t1 * t1;
    double t2 = cos(curTime*1.425);
    t2 *= t2 * t2;
    double t3 = cos(curTime*0.7);
    t3 *= t3 * t3;

    cameraMatrix.m[0][0] = t1*1.75;
    cameraMatrix.m[0][1] = t3*1.75;
    cameraMatrix.m[0][2] = t2*1.75;

    float ang1 = curTime * 5;
    cameraMatrix.m[1][0] = sin(ang1);
    cameraMatrix.m[1][2] = cos(ang1);

    cameraMatrix.m[2][0] = -cos(ang1);
    cameraMatrix.m[2][1] = sin(ang1);

    double d = (double)(curTakt-8*4)/(double)(8*4);
    double e = d+(8*4-64*4)/(double)(8*4);
    if (d > 1) d = 1;
    if (e > 1) e = 1;
    if (e < 0) e = 0;
    double f = (double)(curTakt-88*4)/(double)(2*4);
    if (f < 0) f = 0;
    d-=f;
    if (d < 0) d = 0;
    cameraMatrix.m[3][0] = d;
    cameraMatrix.m[3][1] = e;

    // 1.5 war cool
    cameraMatrix.m[3][2]=-0.1625f;
    if (curTakt > 72*4) 
      cameraMatrix.m[3][2]=0.1625f;

    // begin the scene
    d3dDevice->BeginScene();
    d3dDevice->SetRenderTarget(0,sur2);
    Draw(0);
    d3dDevice->SetRenderTarget(0,surs);
    Draw(2);

    // Display the text..
#ifdef MADHACK
    RECT rc;SetRect( &rc, 0, YRES/2-YRES*1280.0/XRES/2, 0, 0 );if (currentScene<2)g_pFont->DrawText( NULL, "Hochenergiephysik\nstill-2010", -1, &rc, DT_NOCLIP, 0x40ffffff );
    char buffer[3];
    buffer[2] = 0;
    buffer[1] = (currentScene % 10)+'0';
    buffer[0] = ((currentScene/10) % 10)+'0';
    g_pFont->DrawText(NULL,buffer,-1,&rc,DT_NOCLIP,0xffffffff);
    if (currentScene==2*40+1)g_pFont->DrawText( NULL, "greetings to:\nFarbrausch\nHaujobb\nTraction\nSpeckdrumm\nLoonies\nRGBA\nPlastic\nConspiracy\nSunflower\nPortalProcess\nFairlight\nAndromeda\nEphidrena\nAlcatraz\nPlush\nScarab\nOxyron\nTEK\nQuite\nEinklang\nTBC", -1, &rc, DT_NOCLIP, 0x60ffffff );
#else
    if (currentScene<2)
      g_pFont->DrawText( NULL, "Hochenergiephysik\nstill-2010", -1, NULL, DT_NOCLIP, 0x60ffffff );
    if (currentScene==2*40+1)
      g_pFont->DrawText( NULL, "greetings to:\nFarbrausch\nHaujobb\nTraction\nSpeckdrumm\nLoonies\nRGBA\nPlastic\nConspiracy\nSunflower\nPortalProcess\nFairlight\nAndromeda\nEphidrena\nAlcatraz\nPlush\nScarab\nOxyron\nTEK\nQuite\nEinklang\nTBC", -1, NULL, DT_NOCLIP, 0x60ffffff );
#endif

    //display the scene
    d3dDevice->EndScene();

    d3dDevice->Present( NULL, NULL, NULL, NULL );
  } while (!GetAsyncKeyState(VK_ESCAPE) && waveOutUnprepareHeader(hWaveOut,&WaveHDR,sizeof(WAVEHDR)) == WAVERR_STILLPLAYING);
  ExitProcess(0);
}