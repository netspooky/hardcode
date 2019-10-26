#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "mygl.h"
#include "main.h"
#include "ogl.h"

HDC			hDC;
i8			full;
HGLRC		hRC;
HWND		hWnd;
int			PixelFormat;
HINSTANCE	hInstance;

extern LRESULT CALLBACK CommonWndProc(HWND	hWnd,UINT uMsg,WPARAM wParam,LPARAM	lParam);

void flip(void)
{
	wglMakeCurrent(hDC,hRC);
	SwapBuffers(hDC);
}

int initGL(void)
{
	WNDCLASS wc;
	DWORD wStyle;
	PIXELFORMATDESCRIPTOR pfd;
	DEVMODE dmScreenSettings;
	float m[16];

	full=1;

/////////////////////////////////////////////////////////////////////////////////////
//
// create win32 window 
//

	hInstance			= GetModuleHandle(NULL);				// Grab An Instance For Our Window
	
	//define the window class
	wc.style			= CS_HREDRAW | CS_VREDRAW | CS_OWNDC;	// Redraw On Size, And Own DC For Window.
	wc.lpfnWndProc		= (WNDPROC) DefWindowProc;				// WndProc Handles Messages
	wc.cbClsExtra		= 0;									// No Extra Window Data
	wc.cbWndExtra		= 0;									// No Extra Window Data
	wc.hInstance		= hInstance;							// Set The Instance
	wc.hIcon			= 0;//LoadIcon(NULL, IDI_WINLOGO);			// Load The Default Icon
	wc.hCursor			= 0;//LoadCursor(NULL, IDC_ARROW);			// Load The Arrow Pointer
	wc.hbrBackground	= (HBRUSH) COLOR_GRAYTEXT;				// Background For GL
	wc.lpszMenuName		= NULL;									// We Don't Want A Menu
	wc.lpszClassName	= "moo";							// Set The Class Name	
	
	//register the window class
	if (!RegisterClass(&wc))
		return 0;

	//define window style
	wStyle=WS_CLIPSIBLINGS|WS_CLIPCHILDREN|WS_VISIBLE;
	//wExStyle|=WS_EX_APPWINDOW;
	wStyle|=WS_POPUP;
	//ShowCursor(FALSE);
	
	//create the window
	hWnd=CreateWindow("moo","moo",wStyle,0,0,640,480,NULL,NULL,hInstance,NULL);

	//did window create?
	if (!hWnd)
		return 0;

	//ShowWindow(hWnd,SW_SHOW);
	//SetForegroundWindow(hWnd);
	//SetFocus(hWnd);
	
/////////////////////////////////////////////////////////////////////////////////////
//
// create OPENGL context
//
	if (full)
	{
		memset(&dmScreenSettings,0,sizeof(dmScreenSettings));
		dmScreenSettings.dmSize=sizeof(dmScreenSettings);
		dmScreenSettings.dmPelsWidth	= 640;
		dmScreenSettings.dmPelsHeight	= 480;
		dmScreenSettings.dmBitsPerPel	= 32;
		dmScreenSettings.dmFields=DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;
		ChangeDisplaySettings(&dmScreenSettings,CDS_FULLSCREEN);
	}

	//our PIXELFORMAT
	memset(&pfd,0,sizeof(pfd));
	pfd.nSize=sizeof(PIXELFORMATDESCRIPTOR);
	pfd.nVersion=1;
	pfd.dwFlags=PFD_DRAW_TO_WINDOW|PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER;
	pfd.iPixelType=PFD_TYPE_RGBA;							// Request An RGBA Format
	pfd.cColorBits=32;
	pfd.cDepthBits=16;
	pfd.iLayerType=PFD_MAIN_PLANE;

	//got a valid DC?
	hDC=GetDC(hWnd);
	if (!hDC)
		return 0;
	
	//valid pixelformat?
	PixelFormat=ChoosePixelFormat(hDC,&pfd);

	//set pixelformat
	if(!SetPixelFormat(hDC,PixelFormat,&pfd))
		return 0;

	//create our GL rendering context(RC)
	hRC=wglCreateContext(hDC);
	if (!hRC)
		return 0;
		
	//make this our current context
	if(!wglMakeCurrent(hDC,hRC))
		return 0;
	
	wglMakeCurrent(hDC,hRC);
	//ShowWindow(hWnd,SW_SHOW);
	//SetForegroundWindow(hWnd);
	wglMakeCurrent(hDC,hRC);
	//SetFocus(hWnd);
	glViewport(0,0,640,480);						// Reset The Current Viewport

	glMatrixMode(GL_PROJECTION);						// Select The Projection Matrix
	memset(m,0,64);
	m[0]=1.344f;
	m[5]=1.792f;
	m[10]=-1.002002f;
	m[14]=-0.2002002f;
	m[11]=-1.0f;
	glLoadMatrixf(m);
	return 1;
}

int deinitGL(void)
{
	//return to desktop res
	if (full)
	{
		ChangeDisplaySettings(NULL,0);
		//ShowCursor(TRUE);
	}

	//free rendering context
	if (hRC)
	{
		if (!wglMakeCurrent(NULL,NULL))
		{};//return 0;

		if (!wglDeleteContext(hRC))
			return 0;
		hRC=NULL;
	}

	//free device context
	if (hDC)
	{
		if  (!ReleaseDC(hWnd,hDC))
			return 0;
		hDC=NULL;
	}

	//destroy window
	if (hWnd)
	{
		if (!DestroyWindow(hWnd))
			return 0;
		hWnd=NULL;
	}
	return 1;
}