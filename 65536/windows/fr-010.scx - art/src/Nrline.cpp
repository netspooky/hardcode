extern "C" const int _fltused = 0;

#include "NRLine.h"
#include "DrawObj.h"
#include "object3d.h"
#include "perlin.h"
#include "Drawing.h"
#include "linefont.h"
#include "TextureManager.h"
#include "stadt.h"
#include "types.h"
#include "soundsys.h"

Perlin  *perlin;
Scene3D *scene1;
Scene3D *scene2;
Scene3D *scene3;
Scene3D *scene4;
Scene3D *scene5;
Scene3D *scene6;
Scene3D *tbl;
Scene3D *freestyle;
Scene3D *haujobb;
Scene3D *kolor;
Scene3D *vacuum;
Scene3D *teklords;
Scene3D *smash;
Scene3D *designs;
Scene3D *matrix;

Object3D  *pCube, *pC1, *pC2, *pC3, *pC4, *t1;
LineFont  *linefont;
Matrix    m;
LineList  *lineList;
FaceList  *faceList;
Camera    *cam;	
CDrawing  *drawing;
TextureManager *texture;

int shouldStop;
int mz;
int fadestarted=0;
DEVMODE DevMode;
HINSTANCE hInst;	
char* szTitle = "NR";
char* szWindowClass = "NR";
HWND hWnd;
HDC g_hdc;
int texnum = 0;
int texcount = 64;
int seed=31337303;

RECT fullscreenRC={0, 0, 640, 480};

LPDIRECTDRAW                g_pDD = NULL;
LPDIRECTDRAWSURFACE         g_pDDSPrimary = NULL;
LPDIRECTDRAWSURFACE         g_pDDSBack = NULL;

BOOL                        g_bActive = FALSE;


float scene1CamKeys[]= {  0,  0, 0, -30,
                          6000,  10, - 2, -30,
                         12000,  10, +20, -40,
                        18000,   0, -20, -40,
                        20000,  -5, +10, -30,
                        22000,  10, -800, -330, 
                 999999999.0f ,   0 ,    0,    0};

float scene2CamKeys[]= {0,  0, 0, -30,
                          6000,  10, - 2, -30,
                         12000,  10, +20, -40,
                        18000,   0, -20, -40,
                        20000,  -5, +10, -30,
                        22000,  10, -800, -330, 
                 999999999.0f ,   0 ,    0,    0};

float scene3CamKeys[]= {0,  0, 0, -30,
                          6000,  10, - 2, -30,
                         12000,  10, +20, -40,
                        18000,   0, -20, -40,
                        22000,  -5, +10, -30,
                        25000,  1110, -1600, -330, 
                 999999999.0f ,   9990 ,   -66660,    -666660};





int __cdecl rand()
{
	seed=(seed*15625+1)&32767;
	return seed;
}

void *__cdecl operator new(unsigned int size) 
{ 
	return (char *) HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, size+32)+16; 
}

void __cdecl operator delete(void *p)
{
	HeapFree(GetProcessHeap(), 0, (char *) p-16);
}

int __cdecl atexit(void (__cdecl *)())
{
	return 0;
}

int lPitch;

void ExitTheShit()
{

	ssStop();
	ssClose();

#ifndef _DEBUG
  if (g_pDD)
	  g_pDD->RestoreDisplayMode();
	
  if (g_pDDSPrimary)
  {
	  g_pDDSPrimary->Release();
	  g_pDDSPrimary = NULL;
  }
	
  if (g_pDD)
  {
	  g_pDD->Release();
	  g_pDD = NULL;
  }
#else
  if (g_pDDSBack)
  {
    g_pDDSBack->Release();
    g_pDDSBack=0;
  }

  if (g_pDDSPrimary)
  {
    g_pDDSPrimary->Release();
    g_pDDSPrimary=0;
  }

  if (g_pDD)
  {
    g_pDD->Release();
    g_pDD=0;
  }
#endif
	
	CoUninitialize();
	
	ShowCursor(TRUE);
	ExitProcess(0);
}


HRESULT ShowFrame()
{
#ifndef _DEBUG
  if (!g_pDDSPrimary)
    return E_FAIL;

  return g_pDDSPrimary->Flip(0, DDFLIP_WAIT);
#else
  if (!g_pDDSPrimary)
    return E_FAIL;

  DDBLTFX fx;
  fx.dwSize=sizeof(fx);

  g_pDDSPrimary->Blt(&fullscreenRC, g_pDDSBack, &fullscreenRC, DDBLT_WAIT, 0);
#endif
}


HRESULT InitDX()
{
	DDSURFACEDESC ddsd;

  if (FAILED(DirectDrawCreate(0, &g_pDD, 0)))
    ExitTheShit();
	
#ifndef _DEBUG
  g_pDD->SetCooperativeLevel(hWnd, DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN | DDSCL_FPUPRESERVE);
  g_pDD->SetDisplayMode(640, 480, 32);
#else
  g_pDD->SetCooperativeLevel(hWnd, DDSCL_NORMAL | DDSCL_FPUPRESERVE);
#endif

  // WERTE HERREN KOEN UND HINRICHS! hätten sie an die folgenden 5 zeilen gedacht, wäre ihnen
  // so mancher bug erspart geblieben. zum glück ist es mir rechtzeitig eingefallen.
  // vielen dank für ihre aufmerksamkeit.

  __asm {
    push  01e3fh;
    fldcw [esp];
    pop   eax;
  };
  
  for(int i=0; i<sizeof(ddsd); i++)
		((char*)(&ddsd))[i]=0;

#ifndef _DEBUG
  ddsd.dwSize = sizeof(ddsd);
  ddsd.dwFlags = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
	ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE | DDSCAPS_FLIP | DDSCAPS_COMPLEX;
	ddsd.dwBackBufferCount = 2;
	    
	if (FAILED(g_pDD->CreateSurface(&ddsd, &g_pDDSPrimary, NULL)))
    ExitTheShit();
	
	ddsd.ddsCaps.dwCaps = DDSCAPS_BACKBUFFER;

	if (FAILED(g_pDDSPrimary->GetAttachedSurface(&ddsd.ddsCaps, &g_pDDSBack)))
    ExitTheShit();



#else
  ddsd.dwSize = sizeof(ddsd);
  ddsd.dwFlags = DDSD_CAPS;
  ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;

  if (g_pDD->CreateSurface(&ddsd, &g_pDDSPrimary, 0)!=DD_OK)
    ExitTheShit();

  ddsd.dwFlags = DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT;
  ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN;
  ddsd.dwWidth = 640;
  ddsd.dwHeight = 480;
  
  if (g_pDD->CreateSurface(&ddsd, &g_pDDSBack, 0)!=DD_OK)
    ExitTheShit();

  IDirectDrawClipper *clip;

  if (g_pDD->CreateClipper(0, &clip, 0)!=DD_OK)
    ExitTheShit();

  clip->SetHWnd(0, hWnd);
  g_pDDSPrimary->SetClipper(clip);
  clip->Release();
#endif

  DDBLTFX fx;
  fx.dwSize=sizeof(fx);
  fx.dwFillColor=0xffffff;
  g_pDDSBack->Blt(0, 0, 0, DDBLT_COLORFILL|DDBLT_WAIT, &fx);

	ShowFrame();
	
	return S_OK;
}


void InitObjects()
{
	texture = new TextureManager(texcount);

	drawing = new CDrawing();
	lineList = new LineList();
	faceList = new FaceList();
	perlin = new Perlin();
	scene1  = new Scene3D();
	scene1->buildfirstScene(linefont);
	scene1->cam.posKeys=scene1CamKeys;

	scene2  = new Scene3D();
	scene2->buildsecondScene(linefont);
	scene2->cam.posKeys=scene2CamKeys;

	scene3  = new Scene3D();
	scene3->buildthirdScene(linefont);
	scene3->cam.posKeys=scene3CamKeys;

	scene4  = new Scene3D();
	scene4->buildScene(kasparov);

	scene5  = new Scene3D();
	scene5->buildScene(bug);

	scene6  = new Scene3D();
	scene6->buildScene(stadt);
}


/*
static LARGE_INTEGER starttime;
static LARGE_INTEGER freq;
static int gettime()
{
  LARGE_INTEGER time;
  QueryPerformanceCounter(&time);
  
  __asm {
    mov eax, dword ptr [time]
    sub eax, dword ptr [starttime]
    mov edx, dword ptr [time+4]
    sbb edx, dword ptr [starttime+4]
    mov ebx, dword ptr [freq]
    div ebx
  }
}
*/


void lock()
{
  DDSURFACEDESC ddsd;
	ddsd.dwSize = sizeof(ddsd);
	if (FAILED(g_pDDSBack->Lock(NULL,&ddsd,DDLOCK_WAIT,NULL)))
    ExitTheShit();
	drawing->vscreen = (unsigned int*)(ddsd.lpSurface);
  lPitch = ddsd.lPitch/4;
}


void unlock()
{
	if (FAILED(g_pDDSBack->Unlock(NULL)))
    ExitTheShit();
}


void doFrame()
{
  int frame=ssGetTime();

  DDBLTFX fx;
  fx.dwSize=sizeof(fx);
  fx.dwFillColor=0xffffff;
  g_pDDSBack->Blt(0, 0, 0, DDBLT_COLORFILL|DDBLT_WAIT, &fx);


	faceList->clear();
  lineList->clear();

	mz=FALSE;
	int dodraw=TRUE;

	if(frame<20000)
	{
		scene1->drawScene(frame,lineList,faceList);
	}
	else if(frame<40000)	
	{
		scene2->drawScene(frame-20000,lineList,faceList);
	}
	else if(frame<65000)
	{
		scene3->o[1]->m.Rotation(Vector((float)frame/2000.0f,(float)frame/1900.0f,(float)frame/1700.0f));
		scene3->drawScene(frame-40000,lineList,faceList);
	}
	else if(frame<68000);
	else if(frame<=89500)
	{
		scene4->drawScene((frame-69000)/50.0f,lineList,faceList);		
	}
	else if(frame<136000)
	{
		dodraw=FALSE;
		scene5->drawScene((frame-90000)/50.0f,lineList,faceList);
		mz=TRUE;
		faceList->doClip(mz);
		lineList->doClip(faceList);
		lock();
		faceList->draw(drawing);	
		lineList->draw(drawing);
		unlock();
		if(frame<92000);
		else if(frame<94000)
			drawing->DrawText(linefont,"fan",350,250,0.06f, 200,1);
		else if(frame<96000);		
		else if(frame<98000)
			drawing->DrawText(linefont,"freestyle",100,200,0.05f, 200,1);
		else if(frame<100000);
		else if(frame<102000)
			drawing->DrawText(linefont,"haujobb",100,200,0.05f, 200,1);
		else if(frame<104000);
		else if(frame<106000)
			drawing->DrawText(linefont,"kolor",50,250,0.05f, 200,1);
		else if(frame<108000);
		else if(frame<110000)
			drawing->DrawText(linefont,"aardbei",50,150,0.05f, 200,1);
		else if(frame<112000);
		else if(frame<114000)
			drawing->DrawText(linefont,"SCALA",25,100,0.05f, 200,1);
		else if(frame<116000);
		else if(frame<118000)
			drawing->DrawText(linefont,"matrix",75,200,0.05f, 200,1);
		else if(frame<120000);
		else if(frame<122000)
		{
			drawing->DrawText(linefont,"all we",75,150,0.05f, 200,1);
			drawing->DrawText(linefont,"forgot",275,250,0.05f, 200,1);
		}
	}
	else if(frame<=157000)
	{
		scene6->drawScene((frame-140000)/20.0f,lineList,faceList);		
	}
	else if(frame<167000)
	{
		dodraw=FALSE;
		lock();
		drawing->DrawText(linefont,"code:",25,75,0.05f, 200,1);
		drawing->DrawText(linefont,"entropy",100,150,0.05f, 200,1);
		drawing->DrawText(linefont,"peci",100,250,0.05f, 200,1);
		drawing->DrawText(linefont,"3d-design:",25,375,0.05f, 200,1);
		drawing->DrawText(linefont,"ruul",100,450,0.05f, 200,1);		
		unlock();
	}
	else
    ExitTheShit();

  if (dodraw)
	{
		faceList->doClip(mz);
	  lineList->doClip(faceList);
		lock();
		faceList->draw(drawing);	
		lineList->draw(drawing);
		unlock();
	}

}


int WINAPI WinMainCRTStartup()
{
	
	MSG msg;
	WNDCLASS wc;

	hInst = GetModuleHandle(0); 

	wc.style			    = CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc		= (WNDPROC)WndProc;
	wc.cbClsExtra		  = 0;
	wc.cbWndExtra		  = 0;
	wc.hInstance		  = hInst;
	wc.hIcon			    = NULL;
	wc.hCursor			  = 0;//LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground	= 0;//(HBRUSH)(COLOR_WINDOW+1);
	wc.lpszMenuName		= NULL;
	wc.lpszClassName	= szWindowClass;
	
  RegisterClass(&wc);

	hWnd = CreateWindow(szWindowClass, szTitle, WS_POPUP | WS_VISIBLE, 0, 0, 640, 480, NULL, NULL, hInst, NULL);

	g_hdc = GetDC(hWnd);
	linefont = new LineFont("Times New Roman",g_hdc);
	ReleaseDC(hWnd,g_hdc);
 
	ShowCursor(FALSE);
	ShowWindow(hWnd, SW_SHOW);
	UpdateWindow(hWnd);

  CoInitialize(0);
	if (FAILED(InitDX()))
	{
		CoUninitialize();
		return 0;
	}

	ssInit(tune,hWnd);

	InitObjects();

	ssPlay();
	while (ssGetTime()<0) {}

	while (1) 
	{
		if(PeekMessage(&msg,hWnd, 0, 0, 0)) 
		{					
			GetMessage(&msg,0,0,0);
			TranslateMessage(&msg);
			DispatchMessage(&msg);	
		}
		else 
			if (g_bActive)	
			{			
				drawing->t = (float)ssGetTime()*0.001f;
        texnum=(ssGetTime()/150)&63;

				doFrame();
				ShowFrame();
				ssDoTick();
			}		        

	}

	return 0;
}


LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message) 
	{
  case WM_ACTIVATE:
    g_bActive = wParam;
    break;

  case WM_PAINT:
    ValidateRect(hWnd, 0);
    return TRUE;

	case WM_KEYDOWN:
		if(wParam != VK_ESCAPE)   						
			break;

  case WM_CLOSE:
	case WM_DESTROY:
	case WM_QUIT:
		ExitTheShit();
		break;
	}

	return DefWindowProc(hWnd, message, wParam, lParam);
}