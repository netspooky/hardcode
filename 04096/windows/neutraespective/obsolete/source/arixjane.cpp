// windows standard configurations
#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN

// resolution and screen modes
#define FULLSCREEN
#define XRES 1280
#define YRES 720
#define ASPECT (XRES.f/YRES.f)
#define MULTISAMPLE D3DMULTISAMPLE_NONE
#define SAVESTATE D3DXSHADER_PREFER_FLOW_CONTROL
#ifdef FULLSCREEN
#define isWindowed 0
#else
#define isWindowed 1
#endif

// windows standard includes
#include <math.h>
#include "windows.h"
#include "mmsystem.h"
#include <d3d9.h>
#include <d3dx9.h>
#include "kunst.h"

// we use fpu even in debug mode
#ifndef _DEBUG
	extern "C" int _fltused = 1;
#endif

// d3dx and other functions used
#define LookAt D3DXMatrixLookAtLH
#define sin(x) sinf(x)
#define cos(x) cosf(x)

// structures
static D3DPRESENT_PARAMETERS devParams = {
  XRES, YRES, D3DFMT_A8R8G8B8, 0, MULTISAMPLE,
    0, D3DSWAPEFFECT_DISCARD, 0, isWindowed, true,
    D3DFMT_D24S8, 0, 0, 0 };
static IDirect3DDevice9 *d3dDevice;
static IDirect3D9 *d3d;
static LPD3DXEFFECT effect;
static D3DXMATRIX cameraMatrix;
static const float quadVerts[4*3] =
{
  1.0f,-1.0f,0.0f,
 -1.0f,-1.0f,0.0f,
  1.0f, 1.0f,0.0f,
 -1.0f, 1.0f,0.0f,
};
ID3DXFont* g_pFont[2] = {{0}};
float q[2] = {{0}};
float qu[2] = {{0}};

// HANDLES
#define numUniform 4
static D3DXHANDLE myHandles[numUniform];
#define HANDLE_CAMERAMATRIX  myHandles[0]
#define HANDLE_CAMERAPOSITION myHandles[1]
#define HANDLE_TEXTURE1 myHandles[2]
#define HANDLE_ANIMATION myHandles[3]

// THE RENDERTARGET STUFF
#define RENDER_TARGET_COUNT 2
#define RENDERTARGETS_WIDTH XRES
#define RENDERTARGETS_HEIGHT YRES
static LPDIRECT3DTEXTURE9 depthTex[RENDER_TARGET_COUNT];
static LPDIRECT3DSURFACE9 depthSur[RENDER_TARGET_COUNT];
#define fractalDepthTex1 depthTex[0]
#define fractalDepthSur1 depthSur[0]
#define fractalDepthTex2 depthTex[1]
#define fractalDepthSur2 depthSur[1]
static D3DFORMAT RenderTargetFormat[RENDER_TARGET_COUNT]={D3DFMT_G16R16F,D3DFMT_A8R8G8B8};
static LPDIRECT3DSURFACE9 screenDepthSur;

#define FONTNAME "Palatino Linotype"
static char *Uniform[numUniform]={"cm","cp","ts","an"};
// der shader source code  
static const char effectSourceCode[] =\
// ------parameter for handles
"float4x4 cm;"  // cameramatrix
"float4 cp,zm,an;" // cameraposition
"texture ts;"
// ------structures
"struct vso" // pixelshader receives
"{"
  "float4 psw:POSITION," // the quad position
  "ps:TEXCOORD0," // the quad position again
  "pt:TEXCOORD1," // the eye position
  "rd:TEXCOORD2;" // the eye position
"};"
// ------sampler and texture
"sampler ss=" 
"sampler_state"
"{"
    "texture=<ts>;"
    "magfilter=linear;"
    "addressu=clamp;"
    "addressv=clamp;"
"};"
// ------vertexshader
"vso v01(float4 ps:POSITION)"
"{"
  "vso o;"
  "o.psw=o.ps=ps;"
  "o.pt=cp;"
  "o.rd=cm[2]+cm[0]*ps.x*cm[3][3]+cm[1]*ps.y;" 
  "return o;"
"}"
// functions 
"float4 D(float3 p)"
"{"
  "return tex2Dlod(ss,float4(p*.0015+.5,0));"
"}"
#define NORMALDELTA "1"
"float3 N(float3 p)"
"{"
  "float3 o=p;"
  "o=p;o.x-="NORMALDELTA";""float ax=D(o).x;"
  "o=p;o.y-="NORMALDELTA";""float ay=D(o).x;"
  "o=p;o.x+="NORMALDELTA";""float bx=D(o).x;"
  "o=p;o.y+="NORMALDELTA";""float by=D(o).x;"
  "return normalize(float3(ax-bx,ay-by,.001));"
"}"
// ------pixelshader
"float4 p01(vso o):COLOR0"
"{"
  "float2 p2=o.ps.xy;"
  "p2.y+=sin(p2.x*500)*.01*an.w;"
  "float3 q=float3(p2-float2(sin(cp.w),cos(cp.w)*.5),0)/pow(1.005,an.z)-.6;"
  "float3 p=.001;"
  "int i;"
  "for(i=0;i<256;i++)"
  "{"
    "float t=atan2(length(p.xy),p.z)*5.1;"
    "float h=atan2(p.y,p.x)*5.1;"
    "q.z=i/32.;"
    "p=float3(sin(t)*cos(h),sin(t)*sin(h),cos(t))*pow(length(p),5.1)+q;"
    "if (dot(p,p)>an.x)"
      "break;"
  "}"
  "return float4(i/255.+cos(length(p2)/(an.w+.05))*an.w*.3,saturate((p.y*p.x)/length(p)),0,0);"
"}"
"float4 p02(vso o):COLOR0"
"{"
  "float3 p=o.pt.xyz;"
  "float3 d=normalize(o.rd.xyz)*2;" // doubled stepsize
  "int i=0,k=0;"
  "for(;i<128;i++)" // halved calculation depth
  "{"
    "if(p.z>D(p).x*1250)"
    "{"
      "p-=d;d*=0.5;if(k++>4)break;"
    "}"
    "p+=d;"
  "}"
  "float3 h=normalize(normalize(o.pt.xyz-p)+float3(0,0,1));"
  "float t=pow(abs((dot(N(p),h)).x),5)+D(p).y;"
  "float q=an.y/length(p-o.pt.xyz);"
  "float c=an.w;"
  "return (lerp(float4(.01,.02,.03,0),float4(.4,.3,.2,0),t*q)+float4(.025,.05,.1,0))*(sin(D(p).x*128+cp.w*40)*.25+1)*80/i+D(p).x*c;"
"}"
"float4 p03(vso o):COLOR0"
"{"
  "float4 c=0;"
  "float a=0;"
  "for(int y=-3;y<=3;y++)"
  "for(int x=-3;x<=3;x++)"
  "{"
    "float2 d=float2(o.ps.x+x*.01,-o.ps.y+y*.01)*.5+.5;"
    "float e=cos(sqrt(x*x+y*y)/3);"
    "c+=tex2D(ss,d)*e;"
    "a+=e;"
  "}"
  "return saturate(c/a-.45)*(an.y-20)/480+tex2D(ss,float2(o.ps.x,-o.ps.y)*.5+.5);"
"}"
// ------technique
"technique"
"{"
  "pass"
  "{"
    "vertexshader=compile vs_3_0 v01();"
    "pixelshader=compile ps_3_0 p01();"
    //"zenable=0;" 
    //"zwriteenable=0;" 
  "}"
  "pass"
  "{"
    "vertexshader=compile vs_3_0 v01();"
    "pixelshader=compile ps_3_0 p02();"
    //"zenable=0;" 
    //"zwriteenable=0;" 
  "}"
  "pass"
  "{"
    "vertexshader=compile vs_3_0 v01();"
    "pixelshader=compile ps_3_0 p03();"
    //"zenable=0;" 
    //"zwriteenable=0;" 
  "}"
"}";

static const char *fett[] =
{
  "STILL",
  "neutraespective esa-c01",
  "SCIENCE",
  "they considered",
  "IDEA",
  "to exclude that",
  "ALTAIRA",
  "these strange symbols for",
  "MORBIUS",
  "you still refuse to face the truth",
  "KRELL",
  "beyond the cataclysm of",
  "STILL",
  "but not everyone sees it",
  "MultiCore(no delay)?",
  "Good Evening",
};

D3DXVECTOR4 anim;
D3DXVECTOR4 campos;
D3DXVECTOR4 zoom;
void __fastcall Draw(int pass)
{
  UINT passCount;
  effect->SetTexture(HANDLE_TEXTURE1, pass == 2 ? fractalDepthTex2 : fractalDepthTex1);
  effect->SetMatrix(HANDLE_CAMERAMATRIX, &cameraMatrix);
  effect->SetVector(HANDLE_CAMERAPOSITION, &campos);
  effect->SetVector(HANDLE_ANIMATION, &anim);
  effect->Begin(&passCount,0);
  effect->BeginPass(pass);
  d3dDevice->SetFVF( D3DFVF_XYZ );
  d3dDevice->DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,2,quadVerts,3*sizeof(float));
  effect->EndPass();
  effect->End();
}

// MAX_SAMPLES gives you the number of samples for the whole song. we always produce stereo samples, so times 2 for the buffer
static SAMPLE_TYPE	lpSoundBuffer[MAX_SAMPLES*2];  
static HWAVEOUT	hWaveOut;

/////////////////////////////////////////////////////////////////////////////////
// initialized data
/////////////////////////////////////////////////////////////////////////////////

#pragma data_seg(".wavefmt")
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

#pragma data_seg(".wavehdr")
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

#define SAMPLE_FREQUENCY (44100)
#define ONEPATTERNSIZE (60.0f / ( (float)BPM * 4.0f ))
#define P1(pNr) (ONEPATTERNSIZE * pNr * 16.0f * 1000.0f)

static int TextTimesSub[]=
{
    (int)P1(3),
    (int)P1(21),
    (int)P1(34.625),
    (int)P1(38.125),
    (int)P1(56),
    (int)P1(64),
    (int)P1(73),
};

static int TextTimesScale[]=
{
    (int)P1(2),
    (int)P1(6),
    (int)P1(6),
    (int)P1(6),
    (int)P1(6),
    (int)P1(3),
    (int)P1(6),
};

static int fkk[2]={400*YRES/768,100*YRES/768};

static int hitScale[] =
{
  768,
  4,
};

static int hitVoice[] =
{
  2*5,
  2*4,
};

static int hitDisplace[] =
{
  480,
  -1,
};

#ifdef _DEBUG
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
#else
extern "C" __declspec(noreturn) void WinMainCRTStartup()
#endif
{
  if (MessageBox(NULL,fett[14],fett[15],MB_YESNO)==IDYES)
    CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0);
  else
    _4klang_render(lpSoundBuffer);

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
  //  OutputDebugString("EffectGenerationFailed\n");
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

  // ---------------------------------------------
  // BUILD THE RENDERTARGETS
  // ---------------------------------------------
  for (int i = 0; i < RENDER_TARGET_COUNT; ++i)
  {
    d3dDevice->CreateTexture(RENDERTARGETS_WIDTH, RENDERTARGETS_HEIGHT, 1, D3DUSAGE_RENDERTARGET, RenderTargetFormat[i], D3DPOOL_DEFAULT, &depthTex[i],0);
    depthTex[i]->GetSurfaceLevel(0,&depthSur[i]);
  }
  d3dDevice->GetRenderTarget(0,&screenDepthSur);
  waveOutOpen			( &hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
	waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
	waveOutWrite		( hWaveOut, &WaveHDR, sizeof(WaveHDR) );	

  for (int i = 0; i < 2; ++i)
  {
    D3DXCreateFont( d3dDevice,            // D3D device
                    fkk[i],      // Height
                    0,//fkk[i]*YRES/768/3,      // Width
                    FW_MEDIUM,            // Weight
                    0,                    // MipLevels, 0 = autogen mipmaps
                    0,                    // Italic
                    DEFAULT_CHARSET,      // CharSet
                    OUT_DEFAULT_PRECIS,   // OutputPrecision
                    DEFAULT_QUALITY,      // Quality
                    DEFAULT_PITCH | FF_DONTCARE, // PitchAndFamily
                    FONTNAME,             // pFaceName
                    &g_pFont[i]);            // ppFont
  };

  // ---------------------------------------------
  // START THE LOOP
  // ---------------------------------------------
  float globalTimef;
  do
  {
    waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
    globalTimef = MMTime.u.sample * (float)(1000.f / 44100.f);
    // get the timedelta
    float tdf = globalTimef * 0.0001f;
    float tdf2=(sin(tdf)+tdf);


    float *envb=&(&_4klang_envelope_buffer)[((MMTime.u.sample >> 8) << 5)];
    for (int i = 0; i < 2; ++i)
    {
      qu[i] = tdf*hitScale[i];
      if (( (*(envb+hitVoice[i])>0.75f)||(q[i]==0))&&(globalTimef<P1(60)))
        q[i]=hitDisplace[i]+qu[i]; 
    }

    D3DXVECTOR3 up(cos(tdf2),sin(tdf2),0);
    D3DXVECTOR3 camfocuspoint(0,cos(tdf),-64.f);
    campos.x = sin(tdf);
    campos.y = 0; // could be deleted
    campos.z = -71.f+cos(tdf*0.5f)*7.f;
    campos.w = tdf;
    LookAt(&cameraMatrix,(D3DXVECTOR3*)&campos,&camfocuspoint,&up);
    anim.x = (qu[1]-q[1])/(cos(tdf*3)*0.45f+0.5f); // squeeze
    anim.y = (q[0]-qu[0]);
    if (anim.y<20.f) anim.y=20.f;
    if (globalTimef<P1(24))
      anim.x = globalTimef/P1(6);
    anim.z = tdf*25.f;
    anim.w = 1.f-fabs(globalTimef-P1(21.5f))/P1(6.f);
    float w2= 1.f-fabs(globalTimef-P1(62.f))/P1(4.f);
    if (w2 > anim.w) anim.w=w2;
    if (anim.w<0) anim.w=0;
    anim.w*=0.75f;
    // begin the scene
    d3dDevice->BeginScene();
    d3dDevice->SetRenderTarget(0,fractalDepthSur1);
    Draw(0);

    // paint main pass
    cameraMatrix(3,3)=ASPECT;
    anim.w = sin(tdf*0.5f)*4.f;
    d3dDevice->SetRenderTarget(0,fractalDepthSur2);
    Draw(1);

    d3dDevice->SetRenderTarget(0,screenDepthSur);
    Draw(2);

    // draw the text overlays
    const char **f=fett;
    RECT rc;SetRect( &rc, 0, 400*YRES/768, 0, 0 );
    for (int i = 0; i < 7; ++i)
    {
      float c = 0.5f-fabs(globalTimef-TextTimesSub[i])/TextTimesScale[i];
      if(c>0)
      {
        for (int j=0; j < 2; ++j)
          g_pFont[j]->DrawText( NULL, f[j], -1, &rc, DT_NOCLIP, ((unsigned int)(c * 255.f)<<24) );
      }
      f+=2;
    }
    // display the scene
    d3dDevice->EndScene();
    d3dDevice->Present( NULL, NULL, NULL, NULL );
  } while (!GetAsyncKeyState(VK_ESCAPE) && (globalTimef<P1(76.5f)));

  ExitProcess(0);
}