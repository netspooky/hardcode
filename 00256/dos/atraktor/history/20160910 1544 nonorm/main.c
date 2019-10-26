/* __/\  SimpleIntroTemplate [20070406] - a template to test new intro effects
* \\ .;= Created by Jan "Rrrola" Kadlec <rrrola@gmail.com>. Public Domain.
* / )"(  libraries: gdi32 user32 kernel32 scrnsave
* \/-mm */

#define COLOR        // 32bit color | 8bit palette
//#define SCREENSAVER  // .scr | .exe
//#define FULLSCREEN   // fullscreen | windowed
#define ZBUFFER      // zbuffer | additive
//#define BACKGROUND   // small copies | black
//#define TIMER        // redraw on timer | invalidate after redraw
#define FIXEDSPEED 6

#define CLASSNAME "@raktory"

#include <windows.h>
#include <math.h>
#include <stdio.h>
#ifdef SCREENSAVER
 #include <scrnsave.h>
#endif

#define FRAMES 256        // frames before reseeding
#define STARTFRAME -4     // frames to converge before drawing

#define WIDTH 320
#define HEIGHT 240
#define DRAW_POINTS 32768 // coords to store
#define NEW_POINTS 2048   // coords to generate each frame
#define INCSHIFT 5        // pixels needed for medium brightness
#define ZSHIFT 2          // pixel translucence
#define DARK 64           // minimum pixel brightness

#define FADESHIFT 4       // fadeout speed
#define BCGSHIFT 4        // background dimness (>= FADESHIFT)
#define BCGSPEED HEIGHT
#define SPEED (1/384.)
#define TIMER_INTERVAL 40 // in milliseconds

#define LMIN 1.01         // minimum required divergence (~ Lyapunov exponent)
#define LSTART 4e-21      // init and min value of divergence counter
#define LDIVERGE 3.4e38   // if it goes over, reseed

#define PERSPMULX (WIDTH/2)
#define PERSPMULY (WIDTH/2*4./3.*HEIGHT/WIDTH)
#define PERSPADD 1        // > 0.86603

HDC _hdc;           // screen context
#ifdef COLOR
unsigned long *_s;  // screen
#else
RGBQUAD _pal[256];  // palette
unsigned char *_s;  // screen
#endif


int S, next, frame, searches, restart=1;   // Seed, next generated point
long double A[4], L, x, y, z, dx, dy, dz;  // attractor coeffs, divergence counter, coords
float T, min, max, irng;           // time, min coord, max coord, 1/(max-min)
float p[DRAW_POINTS];              // stored coords
unsigned q[DRAW_POINTS];           // stored colors (transformed coords)


// random seed
unsigned rdtsc(void)
{
  unsigned r;
  asm ("rdtsc" : "=a" (r) : : "%edx" );
  return r;
}


// user init
void init(void)
{
}


// generates a new coordinate from 3 previous ones
void iterate(void)
{
  long double d;
  dx += x; dy += y; dz += z;
  d = x*sin((A[2]*z + A[3]) * (1.0f/-16256.0f)) + sin((A[0]*y + A[1])* (1.0f/-16256.0f)); x = y; y = z; z = d;
  d = dx*sin((A[2]*dz + A[3])* (1.0f/-16256.0f)) + sin((A[0]*dy + A[1])* (1.0f/-16256.0f)); dx = dy; dy = dz; dz = d;
  dx -= x; dy -= y; dz -= z;
  d = 1e-6 / sqrt(dx*dx + dy*dy + dz*dz);
  dx *= d; dy *= d; dz *= d;
  L *= d * LMIN;
  if (L < LSTART) L = LSTART;
  if (L > LDIVERGE) restart = 1;
}


// fadeout, blur, draws background
void blur(float sa, float sb)
{
  int i, j, adr, b, B;

#ifdef COLOR
  for (i=0; i<WIDTH*HEIGHT; i++)          _s[i] -= _s[i]+((1<<FADESHIFT)-1)*0x1010101 >> FADESHIFT & ((1<<8-FADESHIFT)-1)*0x1010101;
 #ifdef ZBUFFER
  for (i=0; i<WIDTH*HEIGHT; i++)          _s[i] -= _s[i]+((1<<FADESHIFT)-1)*0x1000000 >> FADESHIFT & ((1<<8-FADESHIFT)-1)*0x1000000;
 #endif
  for (i=0; i<=WIDTH*HEIGHT-2; i++)       _s[i] = ((_s[i]^_s[i+1]) >> 1 & 0x7F7F7F7F) + (_s[i]&_s[i+1]);
  for (i=WIDTH*HEIGHT-2; i>=0; i--)       _s[i+1] = ((_s[i]^_s[i+1]) >> 1 & 0x7F7F7F7F) + (_s[i]&_s[i+1]);
  for (i=0; i<=WIDTH*HEIGHT-WIDTH-1; i++) _s[i] = ((_s[i]^_s[i+WIDTH]) >> 1 & 0x7F7F7F7F) + (_s[i]&_s[i+WIDTH]);
  for (i=WIDTH*HEIGHT-WIDTH-1; i>=0; i--) _s[i+WIDTH] = ((_s[i]^_s[i+WIDTH]) >> 1 & 0x7F7F7F7F) + (_s[i]&_s[i+WIDTH]);

 #ifdef BACKGROUND
  b = (int)(BCGSPEED+sb*BCGSPEED) % HEIGHT;
  for (j=0, adr=0; B = b*WIDTH, j<HEIGHT; j++, b += 2, b >= HEIGHT && (b -= HEIGHT))
  { int a = (int)(BCGSPEED+sa*BCGSPEED) % WIDTH;
    for (i=0; i<WIDTH; i++, a += 2, a >= WIDTH && (a -= WIDTH), adr++)
    {
  #ifdef ZBUFFER
      _s[adr] += (_s[B+a]+BCGSHIFT-1 >> BCGSHIFT & ((1<<8-BCGSHIFT)-1)*0x1010101) >> 8;
  #else
      _s[adr] += _s[B+a]+BCGSHIFT-1 >> BCGSHIFT & ((1<<8-BCGSHIFT)-1)*0x1010101;
  #endif
    }
  }
 #endif

#else
  for (i=0; i<256; i++)
  { float R = sb/2+.5, G = sa/2+.5, B = (sa+sb)/-4+.5;
    _pal[i].rgbRed = i * R;
    _pal[i].rgbGreen = i * G;
    _pal[i].rgbBlue = i * B;
  }

  for (i=0; i<WIDTH*HEIGHT; i++)          _s[i] -= _s[i]+(1<<FADESHIFT)-1 >> FADESHIFT;
  for (i=0; i<=WIDTH*HEIGHT-2; i++)       _s[i] = (_s[i]+_s[i+1]) >> 1;
  for (i=WIDTH*HEIGHT-2; i>=0; i--)       _s[i+1] = (_s[i]+_s[i+1]) >> 1;
  for (i=0; i<=WIDTH*HEIGHT-WIDTH-1; i++) _s[i] = (_s[i]+_s[i+WIDTH]) >> 1;
  for (i=WIDTH*HEIGHT-WIDTH-1; i>=0; i--) _s[i+WIDTH] = (_s[i]+_s[i+WIDTH]) >> 1;

 #ifdef BACKGROUND
  b = (int)(256+sb*256) % HEIGHT;
  for (j=0, adr=0; B = b*WIDTH, j<HEIGHT; j++, b += 2, b >= HEIGHT && (b -= HEIGHT))
  { int a = (int)(256+sa*256) % WIDTH;
    for (i=0; i<WIDTH; i++, a += 2, a >= WIDTH && (a -= WIDTH), adr++)
    { _s[adr] += _s[B+a] >> BCGSHIFT;
    }
  }
 #endif
#endif
}


// generates points and normalizes tham
void generate(void)
{
  int i, k;
  for (k = 0; k < NEW_POINTS; k++)
  { if (restart)
    { restart = 0; frame = STARTFRAME; searches++;
      S = ((S>>13) + (S<<13) + rdtsc()) & 0xFFFF;
      S = S&0xFF | 0xFC00;
//      for (i = 0; i < 4; i++) A[i] = (S>>i*4 & 0xF)*M_PI/16 - M_PI/2;  //((S>>i*8 & 0xFF)-.5)*M_PI/256 - M_PI/2;  // -pi/2..pi/2
      for (i = 0; i < 4; i++) { A[i] = (signed short)S; S = (S>>4 | S<<12) & 0xFFFF; }
      L = LSTART;
      min = 1e6; max = -1e6;
      dx = 1e-6; dy = dz = x = y = z = 0;
    }

    iterate();

    if (frame >= 0)
    { if (min > z) { min = z; irng = 1/(max-min); }
      if (max < z) { max = z; irng = 1/(max-min); }
      p[next] = (z-min) * irng - .5;
      q[next] = (sin(p[next]*M_PI)/2+.5) * 256;
      if (++next == DRAW_POINTS) next = 0;
    }
  }
}


// sets a pixel
void pset(unsigned adr, unsigned c, unsigned R, unsigned G)
{ unsigned t;

#ifdef COLOR
  unsigned char *a = (unsigned char *)_s + adr*4;

 #ifdef ZBUFFER
  t = ((a[3]+1 << ZSHIFT) - (a[3]+1) + c) >> ZSHIFT;
  if (a[3] >= t+2) return;
  a[3] = t;
 #endif
  unsigned rc=c*R>>8, gc=c*G>>8, bc=(c+c-rc-gc)>>1;
  t = ((a[0]+1 << INCSHIFT) - (a[0]+1) + bc) >> INCSHIFT; if (a[0] < t) a[0] = t;
  t = ((a[1]+1 << INCSHIFT) - (a[1]+1) + gc) >> INCSHIFT; if (a[1] < t) a[1] = t;
  t = ((a[2]+1 << INCSHIFT) - (a[2]+1) + rc) >> INCSHIFT; if (a[2] < t) a[2] = t;

#else
  unsigned char *a = _s + adr;
  t = ((*a+1 << INCSHIFT) - (*a+1) + c) >> INCSHIFT;
  if (*a < t) *a = t;
#endif
}


// draws the next frame
void draw(void)
{
  int i,j,k;
  float sa = sin(T*SPEED), sb = sin(T*SPEED*1.4426950408889634),
        ca = cos(T*SPEED), cb = cos(T*SPEED*1.4426950408889634);

  blur(sa, sb);

  generate();

  for (k = 4; k < DRAW_POINTS; k++)
  { unsigned mx, my;
    float t, u = p[k], v = p[k-1], w = p[k-2];
    t = u*ca + v*sa;
    v = -u*sa + v*ca;
    u = t*cb + w*sb;
    w = -t*sb + w*cb;
    t = PERSPMULY / (w+PERSPADD);

    if ((my = v*t + HEIGHT/2) < HEIGHT-1)
    { if ((mx = (PERSPMULX/PERSPMULY)*u*t + WIDTH/2) < WIDTH-1)
      { unsigned adr = my*WIDTH+mx,
                 c = DARK + 0.5*(256-DARK) - w*0.57735027*(256-DARK);
        pset(adr + (k>>0&1) + (k>>0&2)*WIDTH/2, c, q[k-3], q[k-4]);
        pset(adr + (k>>2&1) + (k>>2&2)*WIDTH/2, c, q[k-3], q[k-4]);
        pset(adr + (k>>4&1) + (k>>4&2)*WIDTH/2, c, q[k-3], q[k-4]);
      }
    }
  }

  if (++frame >= FRAMES) restart=1, searches=0;
}


// window proc
#ifdef SCREENSAVER
LRESULT WINAPI ScreenSaverProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
#else
LRESULT CALLBACK WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
#endif
{ HDC hdc;
  PAINTSTRUCT ps;
  RECT r;
  BITMAPINFO bi;
  LARGE_INTEGER freq, cnt;
  char s[128];

  switch (msg)
  {case WM_CREATE:
    memset(&(bi.bmiHeader), 0, sizeof(BITMAPINFOHEADER));
    bi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    bi.bmiHeader.biWidth = WIDTH;
    bi.bmiHeader.biHeight = -HEIGHT;

    bi.bmiHeader.biPlanes = 1;
   #ifdef COLOR
    bi.bmiHeader.biBitCount = 32;
   #else
    bi.bmiHeader.biBitCount = 8;
   #endif
    hdc = GetDC(hWnd);
    SelectObject(_hdc = CreateCompatibleDC(hdc), CreateDIBSection(hdc, &bi, DIB_RGB_COLORS, (void**)&_s, 0, 0));
    ReleaseDC(hWnd, hdc);
    init();
   #ifdef TIMER
    SetTimer(hWnd, 1, TIMER_INTERVAL, 0);
   #else
    InvalidateRect(hWnd, 0, 0);
   #endif
    break;

   case WM_PAINT:
   #ifndef FIXEDSPEED
    QueryPerformanceCounter(&cnt);
    QueryPerformanceFrequency(&freq);
    freq.QuadPart ? (T = 70. * cnt.QuadPart / freq.QuadPart) : (T += 3);
   #else
    T += FIXEDSPEED;
   #endif
    draw();
   #ifndef COLOR
    SetDIBColorTable(_hdc, 0, 256, _pal);
   #endif
    hdc = BeginPaint(hWnd, &ps);
    sprintf(s, frame>0 ? "#%d [%04X] %.0f %.0f %.0f %.0f (%.3f ~ %.3f) %d" : "#%d [%08X]",
      searches, S, (double)A[0], (double)A[1], (double)A[2], (double)A[3], min, max, frame);
    SetWindowText(hWnd, s);
    GetClientRect(hWnd, &r);
    StretchBlt(hdc, 0, 0, r.right, r.bottom, _hdc, 0, 0, WIDTH, HEIGHT, SRCCOPY);
    EndPaint(hWnd, &ps);
  #ifdef TIMER
    break;

   case WM_TIMER:
  #endif
    InvalidateRect(hWnd, 0, 0);
    break;

   #ifndef SCREENSAVER
   case WM_KEYDOWN:
    if (wParam == VK_ESCAPE) SendMessage(hWnd, WM_SYSCOMMAND, SC_CLOSE, 0);
    break;
   #endif

   case WM_DESTROY:
    PostQuitMessage(0);
    break;

   default:
   #ifdef SCREENSAVER
    return DefScreenSaverProc(hWnd, msg, wParam, lParam);
   #else
    return DefWindowProc(hWnd, msg, wParam, lParam);
   #endif
  }
  return 0;
}


// dummy screensaver procs
#ifdef SCREENSAVER
BOOL WINAPI ScreenSaverConfigureDialog(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{ return FALSE;
}


BOOL WINAPI RegisterDialogClasses(HANDLE hInst)
{ return TRUE;
}


// setup, message loop
#else
int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrev, LPSTR lpszArg, int nShow)
{ WNDCLASSEX wc;
  memset(&wc, 0, sizeof(WNDCLASSEX));
  wc.cbSize = sizeof(WNDCLASSEX);
  wc.style = CS_HREDRAW | CS_VREDRAW;
  wc.lpfnWndProc = (WNDPROC)WndProc;
  wc.hInstance = hInst;
  wc.hCursor = LoadCursor(0, IDC_ARROW);
  wc.lpszClassName = CLASSNAME;
  if (!RegisterClassEx(&wc)) {
    MessageBox(0, "Couldn't create window!", "Error", MB_ICONEXCLAMATION|MB_OK|MB_SYSTEMMODAL);
    return 0;
  }

 #ifdef FULLSCREEN
  HWND hWnd = CreateWindowEx(WS_EX_TOPMOST, CLASSNAME, 0, WS_POPUP, 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), 0, 0, hInst, 0);
  if (!hWnd) {
    MessageBox(0, "Couldn't create window!", "Error", MB_ICONEXCLAMATION|MB_OK|MB_SYSTEMMODAL);
    return 0;
  }
  ShowCursor(FALSE);
 #else
  HWND hWnd = CreateWindowEx(WS_EX_PALETTEWINDOW, CLASSNAME, 0, WS_OVERLAPPEDWINDOW, 0, 0, 0, 0, 0, 0, hInst, 0);
  if (!hWnd) {
    MessageBox(0, "Couldn't create window!", "Error", MB_ICONEXCLAMATION|MB_OK|MB_SYSTEMMODAL);
    return 0;
  }
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
}
#endif
