/*************************\
 * Raycast test by Tbyte *
\*************************/
#include <windows.h>
#include <ddraw.h>
#include <float.h>
#include <math.h>

#define RELEASE(x) if(x){x->Release();x=NULL;}

#define SCREENX 320
#define SCREENY 240
#define BPP 16
#define PERSP SCREENX/2	// distance of the eye from the screen
#define OBJNUM 6		// number of objects
#define SHADOBJNUM 3	// number of objects, that can cast a shadow
#define SHSUBDIV 2
#define SUBDIV 4

#define OBJ_SPHERE 1
#define OBJ_CYLINDER 2
#define OBJ_FLAT 3

typedef struct
{
	int objtype;
	float x;
	float y;
	float z;
	float r;
	char red;
	char green;
	char blue;
	char res;
} OBJECT;

typedef struct
{
	int uObjNum;
	BOOL bCastShad;
	int nRed;
	int nGreen;
	int nBlue;
} PIXEL;

LPCSTR lpcstrClassName = "Cast";

HINSTANCE hInst;
HWND hMainWnd;
WNDCLASS wc = {NULL,NULL,NULL,NULL,NULL,NULL,NULL,(HBRUSH) 16,NULL,NULL};

LPDIRECTDRAW7 lpDD = NULL;
LPDIRECTDRAWSURFACE7 lpDDSPrimary = NULL;
LPDIRECTDRAWSURFACE7 lpDDSBack = NULL;
DDSURFACEDESC2 ddsd;
OBJECT objs[OBJNUM] =
{
	{OBJ_SPHERE,0,0,300,100,16,16,12},
	{OBJ_SPHERE,150,0,250,50,0,0,12},
	{OBJ_SPHERE,-150,-50,270,75,16,0,0},
	{OBJ_CYLINDER,0,0,300,800,0,16,0},
	{OBJ_FLAT,0,-400,0,1000,16,16,0},
	{OBJ_FLAT,0,400,0,1000,0,16,12}
};

PIXEL lpcPixels[SCREENY/SUBDIV+1][SCREENX/SUBDIV+1];
PIXEL *lpPixel;
float a,b,c,d,t;
float x;
float y;
float z = PERSP;
float currx,curry,currz;
float clx,cly,clz;
float nx,ny,nz;
float lx,ly,lz;
float cosa;
float maxt;
unsigned short *lpScreen;
unsigned short *lpScreen2;
int i,k;
unsigned int sx,sy;
int csrx,csgx,csbx,cerx,cegx,cebx,dcsrx,dcsgx,dcsbx,dcerx,dcegx,dcebx;
int red,green,blue,dred,dgreen,dblue;

unsigned int uCurrObj;
BOOL bCastShad;
BOOL bTrace;

DWORD dwStartTickCount;
DWORD dwCurrTickCount;

void Trace(void)
{
	maxt = FLT_MAX;
	for (i=0;i<OBJNUM;i++)
	{
		switch (objs[i].objtype)
		{
			case OBJ_SPHERE:
				a = x*x + y*y + z*z;
				b = 2*(objs[i].x*x + objs[i].y*y + objs[i].z*z);
				c = objs[i].x*objs[i].x + objs[i].y*objs[i].y + objs[i].z*objs[i].z - objs[i].r*objs[i].r;
				d = b*b - 4*a*c;
				if (d >= 0)
					t = (b - (float)sqrt(d))/(2*a);
				else
					t = -1.0;
				break;
			case OBJ_CYLINDER:
				a = x*x + z*z;
				b = 2*(objs[i].x*x + objs[i].z*z);
				c = objs[i].x*objs[i].x + objs[i].z*objs[i].z - objs[i].r*objs[i].r;
				d = b*b - 4*a*c;
				if (d >= 0)
					t = (b + (float)sqrt(d))/(2*a);
				else
					t = -1.0;
				break;
			case OBJ_FLAT:
				t = objs[i].y / y;
				break;
		}

		if ((t > 0.0) && (t<maxt))
		{
			maxt = t;
			uCurrObj = i;
		}
	}
	t = maxt;
	currx = t*x;
	curry = t*y;
	currz = t*z;

	clx = lx - currx;
	cly = ly - curry;
	clz = lz - currz;
	bCastShad = FALSE;
	for (k=0;k<SHADOBJNUM;k++)
	{
		a = clx*clx + cly*cly + clz*clz;
		b = 2*((lx-objs[k].x)*clx + (ly-objs[k].y)*cly + (lz-objs[k].z)*clz);
		c = (objs[k].x-lx)*(objs[k].x-lx) + (objs[k].y-ly)*(objs[k].y-ly) + (objs[k].z-lz)*(objs[k].z-lz) - objs[k].r*objs[k].r;
		d = b*b - 4*a*c;
		if (d >= 0.0)
		{
			t = (b - (float)sqrt(d))/(2*a);
			if ((t > 0.0) && (t < 0.99))
			{
				bCastShad = TRUE;
				cosa = 0.0;
				break;
			}
		}
	}
	if (!bCastShad)
	{
		switch (objs[uCurrObj].objtype)
		{
			case OBJ_SPHERE:
				nx = currx - objs[uCurrObj].x;
				ny = curry - objs[uCurrObj].y;
				nz = currz - objs[uCurrObj].z;
				break;
			case OBJ_CYLINDER:
				nx = objs[uCurrObj].x - currx;
				ny = 0.0;
				nz = objs[uCurrObj].z - currz;
				break;
			case OBJ_FLAT:
				nx = 0.0;
				ny = (objs[uCurrObj].y < 0.0) ? objs[uCurrObj].r : -objs[uCurrObj].r;
				nz = 0.0;
				break;
		}
		cosa = (clx*nx + cly*ny + clz*nz)/((float)sqrt(clx*clx + cly*cly + clz*clz)*objs[uCurrObj].r);
		if (cosa < 0.0)
			cosa = 0.0;
	}
}

void Render(void)
{
	lpScreen = lpScreen2 = (unsigned short*) ddsd.lpSurface;
	lpPixel = (PIXEL*) &lpcPixels;
	for (y=-SCREENY/2;y<SCREENY/2+1;y+=SUBDIV)
	{
		for (x=-SCREENX/2;x<SCREENX/2+1;x+=SUBDIV)
		{
			Trace();
			lpPixel->bCastShad = bCastShad;
			lpPixel->nRed = (unsigned int)(15.0f*16777216.0f*cosa) + (objs[uCurrObj].red << 24);
			lpPixel->nGreen = (unsigned int)(47.0f*16777216.0f*cosa) + (objs[uCurrObj].green << 24);
			lpPixel->nBlue = (unsigned int)(19.0f*16777216.0f*cosa) + (objs[uCurrObj].blue << 24);
			lpPixel->uObjNum = uCurrObj;
			lpPixel++;
		}
	}
	lpPixel = (PIXEL*) &lpcPixels;
	for (sy=0;sy<SCREENY/SUBDIV;sy++)
	{
		for (sx=0;sx<SCREENX/SUBDIV;sx++)
		{
			bTrace = TRUE;
			if ((lpPixel->bCastShad == (lpPixel+1)->bCastShad) && ((lpPixel+1)->bCastShad == (lpPixel+SCREENX/SUBDIV+1)->bCastShad) && ((lpPixel+SCREENX/SUBDIV+1)->bCastShad == (lpPixel+SCREENX/SUBDIV+2)->bCastShad) && (lpPixel->uObjNum == (lpPixel+1)->uObjNum) && ((lpPixel+1)->uObjNum == (lpPixel+SCREENX/SUBDIV+1)->uObjNum) && ((lpPixel+SCREENX/SUBDIV+1)->uObjNum == (lpPixel+SCREENX/SUBDIV+2)->uObjNum))
				bTrace = FALSE;
			csrx = lpPixel->nRed;
			csgx = lpPixel->nGreen;
			csbx = lpPixel->nBlue;
			cerx = (lpPixel+1)->nRed;
			cegx = (lpPixel+1)->nGreen;
			cebx = (lpPixel+1)->nBlue;
			dcsrx = ((lpPixel+SCREENX/SUBDIV+1)->nRed - csrx) >> SHSUBDIV;
			dcsgx = ((lpPixel+SCREENX/SUBDIV+1)->nGreen - csgx) >> SHSUBDIV;
			dcsbx = ((lpPixel+SCREENX/SUBDIV+1)->nBlue - csbx) >> SHSUBDIV;
			dcerx = ((lpPixel+SCREENX/SUBDIV+2)->nRed - cerx) >> SHSUBDIV;
			dcegx = ((lpPixel+SCREENX/SUBDIV+2)->nGreen - cegx) >> SHSUBDIV;
			dcebx = ((lpPixel+SCREENX/SUBDIV+2)->nBlue - cebx) >> SHSUBDIV;
			for (y=(float)-SCREENY/2+sy*SUBDIV;y<(float)-SCREENY/2+sy*SUBDIV+SUBDIV;y++)
			{
				red = csrx;
				green = csgx;
				blue = csbx;
				dred = (cerx - csrx) >> SHSUBDIV;
				dgreen = (cegx - csgx) >> SHSUBDIV;
				dblue = (cebx - csbx) >> SHSUBDIV;
				for (x=(float)-SCREENX/2+sx*SUBDIV;x<(float)-SCREENX/2+sx*SUBDIV+SUBDIV;x++)
				{
					if (bTrace)
					{
						Trace();
						*lpScreen = (short)(19.0*cosa) + objs[uCurrObj].blue + (((short)(47.0*cosa) + objs[uCurrObj].green) << 5) + (((short)(15.0*cosa) + objs[uCurrObj].red) << 11);
					}
					else
						*lpScreen = (blue >> 24) | ((green & 0xFF000000) >> 19) | ((red & 0xFF000000) >> 13);
					lpScreen++;
					red += dred;
					green += dgreen;
					blue += dblue;
				}
				csrx += dcsrx;
				csgx += dcsgx;
				csbx += dcsbx;
				cerx += dcerx;
				cegx += dcegx;
				cebx += dcebx;
				lpScreen += (ddsd.lPitch >> 1) - SUBDIV;
			}
			lpPixel++;
			lpScreen2 += SUBDIV;
			lpScreen = lpScreen2;
		}
		lpPixel++;
		lpScreen2 += (ddsd.lPitch << (SHSUBDIV-1)) - SCREENX;
		lpScreen = lpScreen2;
	}
}

LRESULT CALLBACK WindowProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam)
{
	switch(uMsg)
	{
		case WM_KEYDOWN:
			DestroyWindow(hMainWnd);
			return 0;
		case WM_DESTROY:
			PostQuitMessage(0);
			return 0;
	}
	return DefWindowProc(hWnd,uMsg,wParam,lParam);
}

int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,LPSTR lpCmdLine,int nCmdShow)
{
	MSG msg;

	hInst = hInstance;

	wc.hInstance = hInst;
	wc.lpszClassName = lpcstrClassName;
	wc.lpfnWndProc = WindowProc;
	wc.hIcon = LoadIcon(NULL,IDI_APPLICATION);
	wc.hCursor = LoadCursor(NULL,IDC_ARROW);
	//wc.hbrBackground = (HBRUSH) GetStockObject(BLACK_BRUSH);

	RegisterClass(&wc);

	hMainWnd = CreateWindow(lpcstrClassName,"RayCast",0,0,0,320,240,NULL,NULL,hInst,NULL);

	ShowCursor(FALSE);

	// Create main DirectDraw object
	DirectDrawCreateEx(NULL,(LPVOID*)&lpDD,IID_IDirectDraw7,NULL);

	// Get exclusive mode
	lpDD->SetCooperativeLevel(hMainWnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);

	// Set video mode
	lpDD->SetDisplayMode(SCREENX,SCREENY,BPP,0,0);

	// Create surfaces
	ZeroMemory(&ddsd,sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);
	ddsd.dwFlags = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
	ddsd.ddsCaps.dwCaps = DDSCAPS_COMPLEX | DDSCAPS_FLIP | DDSCAPS_PRIMARYSURFACE;
	ddsd.dwBackBufferCount = 1;
	lpDD->CreateSurface(&ddsd,&lpDDSPrimary,NULL);
	ddsd.ddsCaps.dwCaps = DDSCAPS_BACKBUFFER;
	lpDDSPrimary->GetAttachedSurface(&ddsd.ddsCaps,&lpDDSBack);

	dwStartTickCount = GetTickCount();
	while (TRUE)
	{
		if (PeekMessage(&msg,NULL,0,0,PM_REMOVE))
		{
			if (msg.message == WM_QUIT)
				break;
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		else
		{
			// Main loop
			lpDDSBack->Lock(NULL,&ddsd,DDLOCK_WAIT,NULL);
			dwCurrTickCount = GetTickCount() - dwStartTickCount;
			lx = 500.0f*(float)cos((float)(dwCurrTickCount)/2000.0f);
			ly = 150.0f*(float)sin((float)(dwCurrTickCount)/2500.0f);
			lz = 500.0f*(float)sin((float)(dwCurrTickCount)/2000.0f)-400.0f;
			for (k=0;k<SHADOBJNUM;k++)
			{
				objs[k].x = 100.0f*(float)cos((float)(dwCurrTickCount+(k<<12))/3000.0f);
				objs[k].y = 75.0f*(float)sin((float)(dwCurrTickCount+(k<<12))/4000.0f);
				objs[k].z = 100.0f*(float)cos((float)(dwCurrTickCount+(k<<12))/2500.0f)+300.0f;
			}
			Render();
			lpDDSBack->Unlock(NULL);
			lpDDSPrimary->Flip(NULL,DDFLIP_WAIT);
		}
	}
	RELEASE(lpDDSPrimary)
	RELEASE(lpDD)
	ShowCursor(TRUE);
	return msg.wParam;
}
