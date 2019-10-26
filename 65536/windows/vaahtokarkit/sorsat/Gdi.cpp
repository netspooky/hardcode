#include "GDI.h"
#include "Error.h"
#include "Video.h"
#include <windows.h>

static HWND window=0;
static WNDCLASS wc;
static char *programname = "Assy intro";

static char bibuf[sizeof(BITMAPINFOHEADER)+12];
static BITMAPINFO &bi = *(BITMAPINFO*)&bibuf;
static BITMAPINFOHEADER &bih = bi.bmiHeader;



void gdiInit(int w,int h)
{
  memset(&wc,0,sizeof(wc));
  wc.style = CS_OWNDC;
  wc.lpfnWndProc = WndProc;
  wc.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
  wc.lpszClassName = programname;
  if(!RegisterClass(&wc)) error("Can't register window class");

  window=CreateWindow(programname,programname,WS_OVERLAPPEDWINDOW,0,0,w,h,NULL,NULL,0,NULL);
  if(!window) error("Can't create window");

	ShowWindow(window,SW_SHOW);
  UpdateWindow(window);
}

void gdiDeinit()
{
  if(window)
  {
    DestroyWindow(window);
    UnregisterClass(programname,0);
  }
  window = 0;
}

void gdiLockScreen(int &width,int &height,int &bpl,int &bpp,void **scrptr)
{
	memset(&bih, 0, sizeof(bih));
  bih.biSize = sizeof(bih);
  bih.biWidth = width;
  bih.biHeight = -height;
  bih.biPlanes = 1;
  bih.biBitCount = 32;
  bih.biCompression = BI_BITFIELDS;

  ((unsigned long*)bi.bmiColors)[0]=0x00ff0000;
  ((unsigned long*)bi.bmiColors)[1]=0x0000ff00;
  ((unsigned long*)bi.bmiColors)[2]=0x000000ff;

	HDC hdc = GetDC(window);

	if(hdc)
	{
		StretchDIBits(hdc,0,0,width,height,
                      0,0,width,height,
                      *scrptr,&bi,DIB_RGB_COLORS,SRCCOPY);
		ReleaseDC(window,hdc);
  }
}

void gdiUnlockScreen()
{
}

void gdiSync()
{
  MSG msg;
  if(PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
  {
		if(msg.message == WM_QUIT)
    {
      quitrequest=1;
    } else {
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}
}