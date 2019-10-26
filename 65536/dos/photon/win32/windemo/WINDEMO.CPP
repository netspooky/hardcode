/******************************************************************************

    Sorry for the messy code ...

    I know there is some problems with timing etc. Most of the code is "patched"
    in...
    It will all be better in later releases. :)

    It done using Watcom 11.0 with directx SDK and Midas.

    If you have any suggestions etc. then contact me:

    Henrik Thygesen (rbecue/purple)

    Email: hkt@ruc.dk

******************************************************************************/

//#pragma library (ddraw)
//#pragma library (winmm)

#include <stdio.h>
#include <windows.h>
#include <windowsx.h>
#include <time.h>
#include <mmsystem.h>
#include "midasdll.h"
#include <ddraw.h>
#include "example.h"              //The demo .h
#include "windemo.h"
#include <string.h>

/*************************************************************************

        Title and Name of demo-window

*************************************************************************/
#define NAME "photon"
#define TITLE "Photon by purple"


IDirectDraw            *dd;
IDirectDrawSurface     *FrontBuffer;
IDirectDrawSurface     *BackBuffer;
IDirectDrawSurface     *OffBuffer;
IDirectDrawClipper     *Clipper;      // clipper for primary

#include "bcopy.c"

BOOL bActive;
static HWND		hwndApp;
static HACCEL		hAccelApp;


int rgbmask=0;
int screenbpp=0;  //screen bpp writemode
int fullscreen=1;
int offscreen=0;
int backscreen=1;
RECT rfs;
RECT clrc;
RECT rwnd;

int error;

unsigned        position;               /* Current position */
unsigned        pattern;                /* Current pattern number */
unsigned        row;                    /* Current row number */
int             syncInfo;               /* Music synchronization info */

//volatile unsigned   frameCount;

DWORD FrameTime;
DWORD FrameTime0;




/*************************************************************************

        Misc Window and DirectDraw setup routines.

*************************************************************************/




BOOL DDInit()
{
    HRESULT err;

    err = DirectDrawCreate(NULL, &dd, NULL);

    if (err != DD_OK)
        return FALSE;

if (fullscreen){
    err = dd->SetCooperativeLevel(hwndApp,
        DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN | DDSCL_NOWINDOWCHANGES);
} else{
    err = dd->SetCooperativeLevel(NULL,
        DDSCL_NORMAL);
}
    if (err != DD_OK)
        return FALSE;

    return TRUE;
}

ChangeVideo(){
    HRESULT err;

VideoClose();

rgbmask=0;
screenbpp=0;  //screen bpp writemode
offscreen=0;
backscreen=1;

DDInit();

if (fullscreen){
    err = dd->SetCooperativeLevel(hwndApp,
        DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN | DDSCL_NOWINDOWCHANGES);
} else{
    err = dd->SetCooperativeLevel(NULL,
        DDSCL_NORMAL);
}

        VideoOpen(320,200,32);

}

BOOL DDSetMode(int width, int height, int bpp)
{
    HRESULT err;
    DDSURFACEDESC ddsd;
    DDSCAPS caps;
    RECT cl;
    ZeroMemory(&ddsd, sizeof(ddsd));
    ddsd.dwSize = sizeof(ddsd);

if(fullscreen){
    GetWindowRect(hwndApp, &rwnd);
    SetWindowPos(hwndApp, HWND_TOPMOST, 0, 0, 640, 480, NULL);
    UpdateWindow(hwndApp);

    err = dd->SetDisplayMode(width, height, bpp);
    if (err != DD_OK)
        return FALSE;

    backscreen=1;
    ddsd.dwFlags = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
    ddsd.dwBackBufferCount = 2;
    ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE |
                          DDSCAPS_FLIP |
                          DDSCAPS_COMPLEX |
                          DDSCAPS_VIDEOMEMORY;
    err = dd->CreateSurface(&ddsd, &FrontBuffer, NULL);

    if (err != DD_OK){
        ddsd.dwBackBufferCount = 1;
        err = dd->CreateSurface(&ddsd, &FrontBuffer, NULL);
        if (err != DD_OK){
            ddsd.dwBackBufferCount = 0;
            offscreen=1;
            backscreen=0;
            err = dd->CreateSurface(&ddsd, &FrontBuffer, NULL);
            if (err != DD_OK){
                    return FALSE;
            }
        }
    }

    caps.dwCaps = DDSCAPS_BACKBUFFER;
    err = FrontBuffer->GetAttachedSurface(&caps, &BackBuffer);
    if (err != DD_OK)
        return FALSE;
}else{
    /************ Windowed application ***************/
    SetWindowPos(hwndApp, HWND_TOPMOST, rwnd.left, rwnd.top, rwnd.right-rwnd.left, rwnd.bottom-rwnd.top, NULL);
    UpdateWindow(hwndApp);

    ZeroMemory(&ddsd, sizeof(ddsd));
    ddsd.dwSize = sizeof(ddsd);

    backscreen=0;
    offscreen=1;
    ddsd.dwFlags = DDSD_CAPS;
    ddsd.dwBackBufferCount = 0;
    ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE |
                          DDSCAPS_VIDEOMEMORY;
    err = dd->CreateSurface(&ddsd, &FrontBuffer, NULL);
    if (err != DD_OK)
        return FALSE;

/* Setup clipping */

    err = dd->CreateClipper( 0, &Clipper, NULL );
        if( err != DD_OK )
                return FALSE;

    err = Clipper->SetHWnd( 0, hwndApp );
        if( err != DD_OK )
                return FALSE;


    err = FrontBuffer->SetClipper( Clipper );
        if( err != DD_OK )
                return FALSE;

}

int r, g, b;
    dd->GetDisplayMode(&ddsd);
    //screenbpp=ddsd.ddpfPixelFormat.dwRGBBitCount;
    r=ddsd.ddpfPixelFormat.dwRBitMask;
    g=ddsd.ddpfPixelFormat.dwGBitMask;
    b=ddsd.ddpfPixelFormat.dwBBitMask;

    screenbpp=ddsd.ddpfPixelFormat.dwRGBBitCount;
    //screenbpp=24;
int screenbpp1;
    screenbpp1=r+g+b;
    if(screenbpp1==65535) screenbpp=16;
    if(screenbpp1==65535) screenbpp=16;
    if(screenbpp1==32767) screenbpp=15;
    if((r==0x7c00) && (g==0x3e0) && (b==0x1f)){
        rgbmask=1;
    }else

    if((r==0xf800) && (g==0x7e0) && (b==0x1f)){
        rgbmask=2;
    }

    rfs.left=0;
    rfs.top=0;
    rfs.right=width;
    rfs.bottom=height;

    caps.dwCaps = DDSCAPS_BACKBUFFER;

// Create off-screen surface.

    DDBLTFX fx;
    fx.dwSize=sizeof(fx);
    fx.dwFillColor=0;
    //FrontBuffer->Blt(&cr, NULL, NULL, DDBLT_COLORFILL, &fx);



        ddsd.dwSize = sizeof( ddsd );

    //Tell DDRAW which fields are valid
        ddsd.dwFlags = DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH;


    //Ask for a simple off-screen surface, sized
        //100 by 100 pixels
            ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN;
            ddsd.dwHeight = 200;
            ddsd.dwWidth = 320;

    err = dd->CreateSurface(&ddsd, &OffBuffer, NULL);
    if (err != DD_OK)
        return FALSE;

    return TRUE;
};

void DDTerm()
{
    if (BackBuffer)  BackBuffer->Release(),     BackBuffer = NULL;
    if (FrontBuffer) FrontBuffer->Release(),    FrontBuffer = NULL;
    if (OffBuffer)   OffBuffer->Release(),      OffBuffer = NULL;
    if (dd)          dd->Release(),             dd = NULL;
}

long FAR PASCAL WindowProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
	PAINTSTRUCT	ps;
        LPPOINT cspos;

    switch(message)
	{
		case WM_ACTIVATEAPP:
			bActive = wParam;
			break;
		case WM_CREATE:
			break;
                case WM_SETCURSOR:
                        if(fullscreen){
                                SetCursor(NULL);
                                return TRUE;
                        }

                case WM_KEYDOWN:
			switch(wParam)
			{
				case 0x1B:	// Escape
					PostMessage(hWnd, WM_CLOSE, 0, 0);
					break;
                                case VK_F12:
                                        if(fullscreen) fullscreen=0;
                                        else fullscreen=1;
                                        ChangeVideo();
					break;
			}

		case WM_PAINT:
			BeginPaint(hWnd, &ps);
                        GetClientRect(hWnd, &clrc);
                        EndPaint(hWnd, &ps);
			break;

                case WM_DESTROY:
			//finiObjects();
			PostQuitMessage(0);
			break;
	}
    return DefWindowProc(hWnd, message, wParam, lParam);
}

static BOOL InitWindow(HINSTANCE hInstance, int nCmdShow)
{
    WNDCLASS wc;
    char buf[256];

    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = WindowProc;
    wc.cbClsExtra = 0;
    wc.cbWndExtra = 0;
    wc.hInstance = hInstance;
    wc.hIcon = LoadIcon( hInstance, IDI_APPLICATION );
    wc.hCursor = LoadCursor( NULL, IDC_ARROW );
    wc.hbrBackground = NULL;
    wc.lpszMenuName = NAME;
    wc.lpszClassName = NAME;
    RegisterClass( &wc );

    hwndApp = CreateWindowEx(WS_EX_TOPMOST, NAME, TITLE, WS_OVERLAPPEDWINDOW|WS_POPUP|WS_CAPTION |WS_VISIBLE| WS_SYSMENU , 0, 0, 320, 200, NULL, NULL, hInstance, NULL);
    if(!hwndApp)                                                            //WS_OVERLAPPEDWINDOW| WS_POPUP|WS_CAPTION|WS_BORDER
		return FALSE;
    ShowWindow(hwndApp, nCmdShow);
    UpdateWindow(hwndApp);
    GetWindowRect(hwndApp, &rwnd);
    return TRUE;


}



/*************************************************************************

        Our small demolibrary.

*************************************************************************/

void timerpoll(){
  FrameTime = timeGetTime();

  if (FrameTime - FrameTime0 > (1000/70))
    {
      frameCount +=((FrameTime-FrameTime0)/(1000/70));
      FrameTime0=FrameTime;
    }


}

int FramesTotal;

VideoNextframe(){
RECT s, d;
POINT pt;
        FramesTotal++;
        s.left=0;
        s.right=320;
        s.top=0;
        s.bottom=200;

        if(offscreen){
                if(fullscreen){
                        memcpy(&d, &rfs, sizeof(RECT));
                }else{
                        d.left=clrc.left;
                        d.right=clrc.right;
                        d.top=clrc.top;
                        d.bottom=clrc.bottom;
                        pt.x = pt.y = 0;
                        ClientToScreen( hwndApp, &pt );
                        OffsetRect(&d, pt.x, pt.y);
                }
                FrontBuffer->Blt(&d, OffBuffer, &s, DDBLT_WAIT, NULL);
        }

        if(fullscreen && backscreen)
                FrontBuffer->Flip(NULL, NULL); //DDFLIP_WAIT);
}

void VideoFrame(void *vscr){
int pitch;
lfbstruct vinfo;
void * dscr;
int y;
    if(VideoLock(&vinfo)){
        dscr=vinfo.lfb;
        mpitch=pitch=vinfo.pitch;

        if (screenbpp==32){
             for(y=0;y<200;y++)
             memcpy((char*)dscr+y*pitch,(char*)vscr+y*320*4,320*4);
        }else
        if (screenbpp==24){
             for(y=0;y<200;y++)
             memcpy32bto24b((char*)dscr+y*pitch,(char*)vscr+y*320*4,320*4);
        }else
        if (screenbpp==16 || screenbpp==15){
             if(rgbmask==1){
                for(y=0;y<200;y++)
                memcpy32bto16b1((char*)dscr+y*pitch,(char*)vscr+y*320*4,320*4);
             }else
             if(rgbmask==2)
                for(y=0;y<200;y++)
                memcpy32bto16b2((char*)dscr+y*pitch,(char*)vscr+y*320*4,320*4);
        }else
        if (screenbpp==216 || screenbpp==215){
             memset(dscr, 0, 2*40*640);
             memset((char*)dscr+640*2*440, 0, 2*40*640);
             if(rgbmask==1){
             for(y=0;y<200;y++)
             memcpy32bto16b320d1((char*)dscr+y*pitch*2+pitch*40,(char*)vscr+y*320*4,320*4);
             }else
             if(rgbmask==2)
             for(y=0;y<200;y++)
             memcpy32bto16b320d2((char*)dscr+y*pitch*2+pitch*40,(char*)vscr+y*320*4,320*4);

        }
        VideoUnlock();
        VideoNextframe();
    }
}

int cb_x, cb_y, cb_b, cb_found;
HRESULT CALLBACK ModeCallback(LPDDSURFACEDESC pdds, LPVOID lParam)
{
    int width  = pdds->dwWidth;
    int height = pdds->dwHeight;
    int bpp    = pdds->ddpfPixelFormat.dwRGBBitCount;
	if( (cb_x==width) && (cb_y==height) && (cb_b==bpp) ){
		cb_found=1;
		return TRUE;
	}
	
    //return S_TRUE to stop enuming modes, S_FALSE to continue
    return FALSE;
}
BOOL VideoFindmode(int width, int height, int bpp){
	cb_x=width; cb_y=height; cb_b=bpp; cb_found=0;
	dd->EnumDisplayModes(0,NULL,NULL,ModeCallback);
	if(cb_found) return TRUE; else return FALSE;
}




BOOL VideoOpen(int x, int y, int depth){

  screenbpp=32;
  if(DDSetMode(320,200,32))
  return(TRUE);

  screenbpp=24;
  if(DDSetMode(320,200,24))
  return(TRUE);

  screenbpp=16;
  if(DDSetMode(320,200,16))
  return(TRUE);

  if(DDSetMode(640,480,16)){
        screenbpp=216;
        return(TRUE);
  }

  if(DDSetMode(640,480,15)){
        screenbpp=215;
        return(TRUE);
  }

  return (FALSE);
};

BOOL VideoClose(){
	DDTerm();
        return TRUE;
};

void Mso(){
    MIDASsetOption(MIDAS_OPTION_DSOUND_HWND, (DWORD) hwndApp);
};

int os_stuff(void){
MSG msg;
while (PeekMessage(&msg, 0, 0, 0, PM_REMOVE))
		{
			if (msg.message == WM_QUIT)
				break;

			if (!hwndApp || !TranslateAccelerator(hwndApp, hAccelApp, &msg))
			{
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}
		}
		if (msg.message == WM_QUIT)
				return 1;
return 0;
}

BOOL VideoLock(lfbstruct * lfb){
DDSURFACEDESC ddsd; 
IDirectDrawSurface *pdds;

  if (OffBuffer->IsLost() == DDERR_SURFACELOST)
        OffBuffer->Restore();
  if (FrontBuffer->IsLost() == DDERR_SURFACELOST)
        FrontBuffer->Restore();

  if(offscreen)
  pdds=OffBuffer;
  else
  if(backscreen)
  pdds=BackBuffer;
  else
  pdds=FrontBuffer;

    ddsd.dwSize = sizeof(ddsd);

	if((pdds->Lock(NULL, &ddsd, DDLOCK_WAIT, NULL))
            != DD_OK)
                return FALSE;;
	
	lfb->lfb=ddsd.lpSurface;
	lfb->pitch=ddsd.lPitch;
	return TRUE;
};

void VideoUnlock(void){
IDirectDrawSurface *pdds;

  if(offscreen)
  pdds=OffBuffer;
  else
  if(backscreen)
  pdds=BackBuffer;
  else
  pdds=FrontBuffer;
  pdds->Unlock(NULL);
};


/*************************************************************************

        Startup (like main() in dos)

*************************************************************************/
int PASCAL WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
int i;
HDC hdc;
int length;
char ach[128];
COLORREF haje;
RECT rect;
int x, y;  
int logo;
lpCmdLine = lpCmdLine;
  hPrevInstance = hPrevInstance;


    if(!InitWindow(hInstance, nCmdShow))
		return FALSE;

    if(DDInit()==FALSE) return 1;

  FrameTime0 = FrameTime = timeGetTime();

int Timebegin, Timeend;
  Timebegin=timeGetTime();
  FramesTotal=0;
    DemoMain();
  Timeend=timeGetTime();

 

length=wsprintf(ach, "Runtime: %dsecs. Frames: %d", (Timeend-Timebegin)/1000, FramesTotal);


    return 0;
}
