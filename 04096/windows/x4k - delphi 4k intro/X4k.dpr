program X4k;

///////////////////////////
// X4k - Delphi 4k intro //
// Created by XProger    //
// mail: XProger@list.ru //
///////////////////////////

uses
 Windows, Messages, OpenGL;

/// INIT ///
var
 wndclass : WNDCLASSEX;
 Handle   : HWND;
 DC       : HDC;
 msg      : TMSG;
/// DEMO ///
const
 N = 30;
 C = 18;

var
 Sphere : GLUquadricObj;
 Line   : array [0..N-1] of single;
 Col    : array [0..N-1, 0..2] of single;
 k      : single;
 t, t0  : DWORD;
 poly   : integer;
 count  : integer;
 fontbase : GLuint;

function WndProc(hwnd: DWORD; message: UINT; wParam: Longint; lParam: LongInt): LongInt; stdcall;
begin
if (message = WM_CHAR) and (wParam = VK_ESCAPE) then
 begin
 PostQuitMessage(0);
 Result := 0;
 end
else
 Result := DefWindowProc(hwnd, message, wParam, lParam);
end;

var
 pfd     : PIXELFORMATDESCRIPTOR;
 iFormat : integer;
 font    : HFONT;
var
 i, j, p : integer;
 Rad     : single;
 cc      : single;
 w, h    : integer;
begin
randomize;
ZeroMemory(@wndclass, sizeof(WNDCLASSEX));
with wndclass do
 begin
 cbSize        := sizeof(WNDCLASSEX);
 style         := CS_HREDRAW or CS_VREDRAW or CS_OWNDC;
 lpfnWndProc   := @WndProc;
 lpszClassName := 'X';
 end;
RegisterClassEx(wndclass);

w := GetSystemMetrics(SM_CXSCREEN);
h := GetSystemMetrics(SM_CYSCREEN);
glViewPort(0, 0, w, h);
Handle := CreateWindowEx(WS_EX_TOPMOST,
                         'X', 'X',
                         WS_POPUP,
                         0, 0, w, h, 0, 0, 0, nil);
DC := GetDC(Handle);

FillChar(pfd, SizeOf(PIXELFORMATDESCRIPTOR), 0);
with pfd do
 begin
 nSize      := SizeOf(TPIXELFORMATDESCRIPTOR);
 nVersion   := 1;
 dwFlags    := PFD_DRAW_TO_WINDOW or
               PFD_SUPPORT_OPENGL or
               PFD_DOUBLEBUFFER;
 iPixelType := PFD_TYPE_RGBA;
 cColorBits := 16;
 cDepthBits := 16;
 iLayerType := PFD_MAIN_PLANE;
 end;

iFormat := ChoosePixelFormat(DC, @pfd);
SetPixelFormat(DC, iFormat, @pfd);
wglMakeCurrent(DC, wglCreateContext(DC));

/// INIT DEMO OBJECTS ///
glEnable(GL_BLEND);
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Sphere := gluNewQuadric;

fontbase := glGenLists(96);
font := CreateFont(20, 8, 0, 0, 0, 0, 0, 0, DEFAULT_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS,
                   ANTIALIASED_QUALITY, FW_BOLD or FF_DONTCARE or DEFAULT_PITCH, 'impact');
SelectObject(DC, font);
wglUseFontBitmaps(DC, 32, 96, fontbase);
DeleteObject(font);

ShowWindow(Handle, SW_SHOW);
ShowCursor(false);

t         := GetTickCount;
t0        := t;
poly      := 0;
count     := 0;
k         := 0;
col[0][random(3)] := 1;
while true do
 begin
 while PeekMessage(msg, 0, 0, 0, PM_REMOVE) do
  begin
  TranslateMessage(msg);
  DispatchMessage(msg);
  if msg.message = WM_QUIT then Exit;
  end;

 if GetTickCount - t > 20 then
  begin
  t := GetTickCount;
  glClear(GL_COLOR_BUfFER_BIT or GL_DEPTH_BUfFER_BIT);

/// UPDATE ///
for i := 0 to (t - t0) div 20 do
 begin
 if random(100) = 0 then
  begin
  inc(poly, 64);
  if poly > 255 then poly := 255;
  k := random*2*pi;
  p := random(6);
  if p < 3 then
   Col[0][p] := 1
  else
   Col[0][p - 3] := 0;
  end;

 Line[0] := Line[0] + sin(k)/20;
 for j := 0 to N - 2 do
  begin
  Line[j + 1] := Line[j + 1] + (Line[j] - Line[j + 1])/8;
  for p := 0 to 2 do
   Col[j + 1][p] := Col[j + 1][p] + (Col[j][p] - Col[j + 1][p])/16;
  end;
 dec(poly, 2);
 if poly < 0 then poly := 0;
 inc(count);
 end;

/// DRAW ///
glMatrixMode(GL_PROJECTION);
glLoadIdentity;
gluPerspective(90, 640/480, 0.5, 1000);
glMatrixMode(GL_MODELVIEW);
glLoadIdentity;
glTranslatef(0, 0, -700);

glEnable(GL_DEPTH_TEST);
glColor3fv(@Col[0]);
gluSphere(Sphere, 30, 32, 32);

for i := 0 to C - 1 do
 begin
 glRotatef(360/C, 0, 0, 1);
 glPushMatrix;
 for j := 1 to N - 2 do
  begin
  Rad := 30/(exp(0.3 * ln(j)));
  glTranslatef(cos(Line[j + 1])*Rad*2, sin(Line[j + 1])*Rad*2, -1);
  cc := 1 - j / N;
  glColor3f(col[j][0]*cc, col[j][1]*cc, col[j][2]*cc);
  gluSphere(Sphere, Rad, 3, 3);
  end;
 glPopMatrix;
 end;

glDisable(GL_DEPTH_TEST);
glMatrixMode(GL_PROJECTION);
glLoadIdentity;
glOrtho(0, 640, 480, 0, -1, 1);
glMatrixMode(GL_MODELVIEW);
glLoadIdentity;

if poly <> 0 then
 begin
 glColor4f(col[0][0], col[0][1], col[0][2], poly/255);
 glBegin(GL_QUADS);
  glVertex2f(  0,   0);
  glVertex2f(640,   0);
  glVertex2f(640, 480);
  glVertex2f(  0, 480);
 glEnd;
 end;

if count < 1000 then
 begin
 cc  := (1000 - count)/1000;
 Rad := sin(count/1000*pi);
 glColor4f(1, 1, 0, cc);
 glRasterPos2f(620 - Rad*600, 400);
 glListBase(fontbase - 32);
 glCallLists(16, GL_UNSIGNED_BYTE, PChar('Delphi 4k INTRO!'));
 glColor4f(0, 1, 0, cc);
 glRasterPos2f(120, 420 - Rad*400);
 glCallLists(11, GL_UNSIGNED_BYTE, PChar('Believe it!'));
 glColor4f(0, 0, 1, cc);
 glRasterPos2f(480, Rad*400);
 glCallLists(15, GL_UNSIGNED_BYTE, PChar('Code by XProger'));
 end;

  t0 := t; 
  SwapBuffers(DC);
  end;
 end;

end.
