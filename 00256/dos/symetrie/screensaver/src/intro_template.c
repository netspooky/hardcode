/* Template for testing new intros (for MinGW).
 * [2007-11-20] Implemented by Jan Kadlec <rrrola@gmail.com>. Public Domain.
 */

/*
Include this file after defining the macros OUTPUT, COLOR, WIDTH, HEIGHT and NAME (see below).
You need to compile for the Windows subsystem and link with: libgdi32.a libuser32.a libkernel32.a libscrnsave.a, in that order.
Your program should consist of these three functions:
*/

int init(void);            // Called on startup. Returns 0 if everything OK, exits otherwise.
char* frame(double time);  // Called on redraw, gets time in seconds, returns window title (or NULL for FPS).
void cleanup(void);        // Called on exit.

/*
Screen output:
 TRUECOLOR: unsigned _[y*WIDTH + x] = (a<<24) + (r<<16) + (g<<8) + b
 PALETTE:   unsigned char _[y*WIDTH + x] = palette index
            unsigned char _palette[256*3]
*/

///////////////////////////////////////////////////////////////////////////////

#define WINDOW      0   // Output: centered EXE/stretched EXE/screensaver(.scr)
#define MAXIMIZED   1
#define FULLSCREEN  1
#define SCREENSAVER 2
#if (defined OUTPUT && OUTPUT!=WINDOW && OUTPUT!=MAXIMIZED && OUTPUT!=SCREENSAVER)
#  undef OUTPUT
#endif
#ifndef OUTPUT
#  define OUTPUT WINDOW
#endif

#define TRUECOLOR 0     // Color format: 32bpp/8bpp
#define PALETTE   1
#if (defined COLOR && COLOR!=TRUECOLOR && COLOR!=PALETTE)
#  undef COLOR
#endif
#ifndef COLOR
#  define COLOR TRUECOLOR
#endif

#ifndef TIMER           // Milliseconds per frame. If 0, redraws immediately.
#  define TIMER 0
#endif

#ifndef WIDTH           // Window dimensions
#  ifndef HEIGHT
#    define WIDTH 320
#  else
#    define WIDTH ((HEIGHT)*4/3)
#  endif
#endif
#ifndef HEIGHT
#  define HEIGHT ((WIDTH)*3/4)
#endif

#ifndef NAME            // Window name
#  define NAME "Intro"
#endif

///////////////////////////////////////////////////////////////////////////////

#include <windows.h>

#if OUTPUT==SCREENSAVER
#  include <scrnsave.h>
#endif


// Screen context

HDC _hdc;

#if COLOR==PALETTE
unsigned char _palette[256*3];  // red, green, blue
unsigned char *_;
#else
unsigned *_;
#endif


// Time in seconds

double _starttime, _lasttime;

double getTime(void)
{ LARGE_INTEGER freq, cnt;
  QueryPerformanceCounter(&cnt);
  QueryPerformanceFrequency(&freq);
  return freq.QuadPart ? (double)cnt.QuadPart/freq.QuadPart : 0;
}



// Window proc

#if OUTPUT==SCREENSAVER
LRESULT WINAPI ScreenSaverProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
#else
LRESULT CALLBACK WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
#endif
{ HDC hdc;
  PAINTSTRUCT ps;
  RECT r;
  BITMAPINFO bi;
  double time;
  unsigned keyboard;

  switch (msg)
  {
   case WM_CREATE:

    memset(&(bi.bmiHeader), 0, sizeof(BITMAPINFOHEADER));
    bi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    bi.bmiHeader.biWidth = WIDTH;
    bi.bmiHeader.biHeight = -HEIGHT;  // top-down
    bi.bmiHeader.biPlanes = 1;
    #if COLOR==PALETTE
    bi.bmiHeader.biBitCount = 8;
    #else
    bi.bmiHeader.biBitCount = 32;
    #endif

    hdc = GetDC(hWnd);
    _hdc = CreateCompatibleDC(hdc);
    SelectObject(_hdc, CreateDIBSection(hdc, &bi, DIB_RGB_COLORS, (void**)&_, 0, 0));
    ReleaseDC(hWnd, hdc);

    _starttime = _lasttime = getTime();

    #if TIMER==0
    InvalidateRect(hWnd, 0, 0);
    #else
    SetTimer(hWnd, 1, TIMER, 0);
    #endif

    if (init())
    { cleanup();
      SendMessage(hWnd, WM_SYSCOMMAND, SC_CLOSE, 0);
    }

    break;

   case WM_PAINT:
/*  // for interactive testing :)
    keyboard = (GetAsyncKeyState(VK_LEFT)    &0x8000) >> 15 |
               (GetAsyncKeyState(VK_UP)      &0x8000) >> 14 |
               (GetAsyncKeyState(VK_RIGHT)   &0x8000) >> 13 |
               (GetAsyncKeyState(VK_DOWN)    &0x8000) >> 12 |
               (GetAsyncKeyState('Q')        &0x8000) >> 11 |
               (GetAsyncKeyState('W')        &0x8000) >> 10 |
               (GetAsyncKeyState('E')        &0x8000) >> 9 |
               (GetAsyncKeyState('R')        &0x8000) >> 8 |
               (GetAsyncKeyState('A')        &0x8000) >> 7 |
               (GetAsyncKeyState('S')        &0x8000) >> 6 |
               (GetAsyncKeyState('D')        &0x8000) >> 5 |
               (GetAsyncKeyState('F')        &0x8000) >> 4 |
               (GetAsyncKeyState('Z')        &0x8000) >> 3 |
               (GetAsyncKeyState('X')        &0x8000) >> 2 |
               (GetAsyncKeyState('C')        &0x8000) >> 1 |
               (GetAsyncKeyState('V')        &0x8000) >> 0;
*/
    time = getTime();
    char* title = frame(time - _starttime);

    #if COLOR==PALETTE
    { RGBQUAD p[256];
      int i;
      for (i=0; i<256; i++)
      { p[i].rgbRed   = _palette[i*3];
        p[i].rgbGreen = _palette[i*3 + 1];
        p[i].rgbBlue  = _palette[i*3 + 2];
      }
      SetDIBColorTable(_hdc, 0, 256, p);
    }
    #endif

    hdc = BeginPaint(hWnd, &ps);
    if (!title)
    { char title[256];
      sprintf(title, NAME " [%.3lf fps]", 1./(time - _lasttime));
      SetWindowText(hWnd, title);
    }
    else
    { SetWindowText(hWnd, title);
    }
    GetClientRect(hWnd, &r);
    StretchBlt(hdc, 0, 0, r.right, r.bottom, _hdc, 0, 0, WIDTH, HEIGHT, SRCCOPY);
    EndPaint(hWnd, &ps);
    #if TIMER==0
    InvalidateRect(hWnd, 0, 0);
    #endif

    _lasttime = time;

    break;

   #if TIMER!=0
   case WM_TIMER:
    InvalidateRect(hWnd, 0, 0);
    break;
   #endif

   #if OUTPUT!=SCREENSAVER
   case WM_KEYDOWN:
    if (wParam == VK_ESCAPE)
    { cleanup();
      SendMessage(hWnd, WM_SYSCOMMAND, SC_CLOSE, 0);
    }
    break;
   #endif

   case WM_DESTROY:
    PostQuitMessage(0);
    break;

   default:
    #if OUTPUT==SCREENSAVER
    return DefScreenSaverProc(hWnd, msg, wParam, lParam);
    #else
    return DefWindowProc(hWnd, msg, wParam, lParam);
    #endif
  }
  return 0;
}


#if OUTPUT==SCREENSAVER

BOOL WINAPI ScreenSaverConfigureDialog(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{ return FALSE;
}


BOOL WINAPI RegisterDialogClasses(HANDLE hInst)
{ return TRUE;
}

#else  // OUTPUT!=SCREENSAVER

int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrev, LPSTR lpszArg, int nShow)
{
  WNDCLASSEX wc;
  memset(&wc, 0, sizeof(WNDCLASSEX));
  wc.cbSize = sizeof(WNDCLASSEX);
  wc.style = CS_HREDRAW | CS_VREDRAW;
  wc.lpfnWndProc = (WNDPROC)WndProc;
  wc.hInstance = hInst;
  wc.hCursor = LoadCursor(0, IDC_ARROW);
  wc.lpszClassName = NAME;
  if (!RegisterClassEx(&wc)) goto error;

  #if OUTPUT==MAXIMIZED
  HWND hWnd = CreateWindowEx(WS_EX_TOPMOST, NAME, NAME, WS_POPUP, 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), 0, 0, hInst, 0);
  if (!hWnd) goto error;
  ShowCursor(FALSE);
  #else
  HWND hWnd = CreateWindowEx(WS_EX_PALETTEWINDOW, NAME, NAME, WS_OVERLAPPEDWINDOW, 0, 0, 0, 0, 0, 0, hInst, 0);
  if (!hWnd) goto error2;

  RECT r = {0, 0, WIDTH, HEIGHT};
  AdjustWindowRectEx(&r, GetWindowLong(hWnd, GWL_STYLE), GetMenu(hWnd) != 0, GetWindowLong(hWnd, GWL_EXSTYLE));
  int w = r.right - r.left,
      h = r.bottom - r.top;
  SetWindowPos(hWnd, 0, (GetSystemMetrics(SM_CXSCREEN)-w)/2, (GetSystemMetrics(SM_CYSCREEN)-h)/2, w, h, SWP_NOZORDER | SWP_NOACTIVATE);
  #endif

  ShowWindow(hWnd, nShow);

  MSG msg;
  while (GetMessage(&msg, 0, 0, 0))
  { TranslateMessage(&msg);
    DispatchMessage(&msg);
  }
  return msg.wParam;

 error2:
  DestroyWindow( hWnd );

 error:
  MessageBox(0, "Couldn't create window!", "Error", MB_ICONEXCLAMATION|MB_SYSTEMMODAL);
  return 0;
}

#endif
