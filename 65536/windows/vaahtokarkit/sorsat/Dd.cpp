#include "DD.h"
#include "Error.h"
#include "Video.h"
#include <windows.h>
#include <ddraw.h>

static HWND window=0;
static WNDCLASS wc;
static LPDIRECTDRAW	ddraw = 0;
static LPDIRECTDRAWSURFACE frontbuffer = 0;
static int screendepth = 0;

Bitmap *screen;
int quitrequest=0;
int keydown=0;

LRESULT CALLBACK WndProc(HWND hWnd,UINT message,WPARAM wParam,LPARAM lParam)
{
  switch(message)
  {
    case WM_CLOSE:		
    case WM_DESTROY:
      quitrequest=1;
      PostQuitMessage(0);
			return 0;

    case WM_CHAR:
      keydown = wParam;
      return 0;

    default:
		  return DefWindowProc(hWnd,message,wParam,lParam);
  }
}

void videoInit(int w,int h)
{
  char *dderr = "DD error %d";
  char *programname = "Assy intro";

  memset(&wc,0,sizeof(wc));
  wc.style = CS_OWNDC;
  wc.lpfnWndProc = WndProc;
  wc.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
  wc.lpszClassName = programname;
  if(!RegisterClass(&wc)) error(dderr,1);

  window=CreateWindowEx(WS_EX_TOPMOST,programname,programname,WS_POPUP,0,0,w,h,0,0,0,0);
  if(!window) error(dderr,2);

  ShowWindow(window,SW_SHOW);
  UpdateWindow(window);

	if(DirectDrawCreate( NULL, &ddraw, NULL )) error(dderr,3);

	if(ddraw->SetCooperativeLevel(window,DDSCL_EXCLUSIVE|DDSCL_FULLSCREEN|DDSCL_ALLOWREBOOT)) error(dderr,4);

  if(ddraw->SetDisplayMode(w,h,32))
  {
    if(ddraw->SetDisplayMode(w,h,16))
    {
      error(dderr,5);
    }
    else screendepth=16;
  }
  else screendepth=32;

  DDSURFACEDESC ddsd;
  memset(&ddsd, 0, sizeof(ddsd) );
	ddsd.dwSize = sizeof(ddsd);
	ddsd.dwFlags = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
	ddsd.dwBackBufferCount = 1;
	ddsd.ddsCaps.dwCaps = DDSCAPS_FLIP | DDSCAPS_COMPLEX | DDSCAPS_VIDEOMEMORY | DDSCAPS_PRIMARYSURFACE;

	if(ddraw->CreateSurface(&ddsd,&frontbuffer,NULL)) error(dderr,6);

  screen = new Bitmap(w,h-h/4);
  videoRefresh();

  SetCursor(0);
}

void videoDeinit()
{
  if(frontbuffer) frontbuffer->Release();
  if(ddraw)
  {
    ddraw->RestoreDisplayMode();
    ddraw->SetCooperativeLevel(window,DDSCL_NORMAL);
    ddraw->Release();
  }
  ddraw = 0;
  frontbuffer = 0;
  /*
  if(window)
  {
    DestroyWindow(window);
    UnregisterClass(programname,0);
  }

  window = 0;  
  */
}

void videoRefresh()
{
  if(frontbuffer->IsLost()==DDERR_SURFACELOST) frontbuffer->Restore();

	DDSURFACEDESC ddsd;
	memset( &ddsd, 0, sizeof(ddsd) );
	ddsd.dwSize = sizeof(ddsd);
	if(frontbuffer->Lock(NULL, &ddsd, DDLOCK_SURFACEMEMORYPTR | DDLOCK_WAIT | DDLOCK_WRITEONLY, NULL)) return;

  int w=ddsd.dwWidth;
  int h=ddsd.dwHeight*3/4;
  int bpl=ddsd.lPitch;
  int bpp=screendepth;
  char *d = (char *) ddsd.lpSurface;

  char *s=(char *)screen->data[0];

  d+=(h/6)*bpl;

  switch(bpp) 
  {
    case 32:
      _asm
      {
        mov edi,d   
        mov esi,s

        mov eax,w
        shl eax,2
        mov ebx,bpl
        sub ebx,eax

        mov eax,w

        mov ecx,h
          l0:
          mov edx,ecx
          mov ecx,eax
          rep movsd
          add edi,ebx

          mov ecx,edx
          loop l0
      }
      break;

    case 16:
      { // Ei jaksa nyt asmia s‰‰t‰‰
        int b=bpl-(w)*2,*so=(int *)s;
        
        for(int y=0;y<h;y++)
        {
          for(int x=0;x<w;x++)
          {
            short *de=(short *)d;
            *(de)=((*so>>8)&0xF800) + ((*so>>5)&0x07E0) + ((*(so++)>>3)&0x001F);
            d+=2;
          }
          d+=b;
        }
      }
      break;
  }

	frontbuffer->Unlock(0);

  MSG msg;
  if(PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
  {
    if(msg.message == WM_QUIT) quitrequest=1;
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }
}