#ifndef __VIDEO_H
#define __VIDEO_H

#ifndef STRICT
#define STRICT
#endif

#include <windows.h>
#include <ddraw.h>
#include <mmsystem.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include "base.h"
#include "color.h"
#include "globals.h"
#include "addition.h"
//#include "jpegdec.h"

#define SAFE_DELETE(p)  {if(p){delete (p);     (p)=NULL;}}
#define SAFE_RELEASE(p) {if(p){(p)->Release(); (p)=NULL;}}

#define _MABS(n) ((n)<0?(-n):(n))

HRESULT DDSurfaceClear(DWORD dwColor,LPDIRECTDRAWSURFACE7 pdds,RECT *rect=NULL);
void FullScreenCenter(RECT *rect);

//void 
//Class for 32bit video modes
class VideoDevice {
  protected:
    LPDIRECTDRAW7        v_pDD;
    LPDIRECTDRAWSURFACE7 v_pddsFrontBuffer;
  public:
    HWND                 v_hWnd;
    RECT                 v_rcWindow;
    RECT                 v_rcSrc;
    BOOL                 v_bWindowed;
    BOOL                 v_bCenter;

	  DWORD	      				  x_ofset;
	  DWORD				        	y_ofset;

    DWORD                 width;
    DWORD                 height;
    LPDIRECTDRAWSURFACE7 v_pddsBackBuffer;
    RECT                 rect; 
  public:
    VideoDevice();
	  ~VideoDevice();
    // Access functions
    HWND                 GetHWnd()           { return v_hWnd; }
    LPDIRECTDRAW7        GetDirectDraw()     { return v_pDD; }
    LPDIRECTDRAWSURFACE7 GetFrontBuffer()    { return v_pddsFrontBuffer; }
    LPDIRECTDRAWSURFACE7 GetBackBuffer()     { return v_pddsBackBuffer; }
    // Status functions
    BOOL    IsWindowed()                     { return v_bWindowed; }
    BOOL    IsCentered()                     { return v_bCenter; }
    BOOL    Exist();

    // Creation/destruction methods
    HRESULT CreateFullScreen(HWND hWnd, DWORD dwWidth, DWORD dwHeight,
							 DWORD dwBbWidth, DWORD dwBbHeight, DWORD dwBPP);
    HRESULT CreateWindowed(HWND hWnd, DWORD dwWidth, DWORD dwHeight, DWORD dwBPP);
    //HRESULT InitClipper();
    HRESULT UpdateBounds();
    virtual HRESULT DestroyObjects();
    virtual HRESULT Destroy() {return this->DestroyObjects();};

    // Display methods
    HRESULT Clear(DWORD dwColor = 0L){return DDSurfaceClear(dwColor,this->v_pddsBackBuffer);};
    HRESULT Show(DWORD dwWait = 0L);
};

#endif