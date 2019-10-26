#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>
#include <GL/gl.h>
#include "main.h"

/*static WNDCLASS wc = {
  CS_OWNDC,
  DefWindowProc,
  0,
  0,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  "4k"
  };*/

static PIXELFORMATDESCRIPTOR pfd = {
  sizeof(PIXELFORMATDESCRIPTOR),
  1,
  PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,
  PFD_TYPE_RGBA,
  0, 0, 0, 0, 0, 0,
  0, 0,
  0, 0, 0, 0, 0,
  32,
  0, 0,
  PFD_MAIN_PLANE,
  0,
  0, 0, 0,
};

#ifdef SOUND
#define N_SAMPLES (16*5088*33)
static struct {
  char riff[4];
  uint32 size;
  char wave[4];
  char fmt[4];
  uint32 num;
  uint16 format;
  uint16 channels;
  uint32 freq;
  uint32 abps;
  uint16 blockalign;
  uint16 bitdepth;
  char data[4];
  uint32 datasize;
} __attribute__((packed)) wave = {
  { 'R', 'I', 'F', 'F' },
  sizeof(wave) + N_SAMPLES*2,
  { 'W', 'A', 'V', 'E' },
  { 'f', 'm', 't', ' ' },
  0x10,
  1,
  1,
  44100,
  88200,
  2,
  16,
  { 'd', 'a', 't', 'a' },
  N_SAMPLES*2
};
int16 wave_data[sizeof(wave)+N_SAMPLES];
#endif

void
mainCRTStartup()
{
  int i;
  HWND hWnd;
  HDC hDC;
  HGLRC hGLRC;
  DEVMODE dm;
  MSG msg;
  int32 start, time;
  
#ifdef SOUND
  memcpy(wave_data, &wave, sizeof(wave));
  synth_init();
  synth_render((int16 *)(wave_data + sizeof(wave)), N_SAMPLES);
#endif
  
  //  RegisterClass(&wc);

  //  hWnd = CreateWindowEx(WS_EX_TOPMOST, "4k", "4k", WS_VISIBLE | WS_POPUPWINDOW, 0, 0, 640, 480, NULL, NULL, NULL, NULL);
  
  hWnd = CreateWindowEx(WS_EX_TOPMOST, "EDIT", "4k", WS_VISIBLE | WS_POPUPWINDOW, 0, 0, 640, 480, NULL, NULL, NULL, NULL);
  
#ifdef FULLSCREEN
  //  memset(&dm, 0, sizeof(DEVMODE));
  dm.dmSize = sizeof(DEVMODE);
  dm.dmPelsWidth = 640;
  dm.dmPelsHeight = 480;
  dm.dmBitsPerPel = 32;
  dm.dmFields = DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT;
  ChangeDisplaySettings(&dm, CDS_FULLSCREEN);
#endif
  
  hDC = GetDC(hWnd);
  SetPixelFormat(hDC, ChoosePixelFormat(hDC, &pfd), &pfd);
  
  hGLRC = wglCreateContext(hDC);
  wglMakeCurrent(hDC, hGLRC);

  intro_init();
  
  ShowCursor(0);

#ifdef SOUND
#if 1
  sndPlaySound((LPCSTR)wave_data, SND_NODEFAULT + SND_ASYNC + SND_MEMORY);
#else
  {
  FILE *file = fopen("tune.wav", "wb");
  fwrite(wave_data, sizeof(wave_data), 1, file);
  fclose(file);
  }
#endif
#endif
  
  start = GetTickCount();

  while (1) {

#if 0    
    if (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) {
      switch (msg.message) {
      case WM_KEYUP:
	if (msg.wParam == VK_ESCAPE) 
	  goto end;
	break;
	/*default:	
	  TranslateMessage(&msg);
	  DispatchMessage(&msg);
	  break;*/
      }
    }
#else
    if (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) 
      if (msg.wParam == VK_ESCAPE) 
	goto end;
#endif
   
    time = GetTickCount() - start;
    if (time > LENGTH)
      goto end;

    intro_run(time);
    
    SwapBuffers(hDC); 		
  }

 end:  

#ifdef FULLSCREEN
  ChangeDisplaySettings(NULL, 0);
#endif

  ExitProcess(0);
}

