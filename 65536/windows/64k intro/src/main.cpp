#include "everything.h"														// Header File For The NeHeGL Basecode
////////////////////////////////////////////////////////////////////////////////
// global

cAudio bgm;																		// 

//Screen size
cSize2f window;


////////////////////////////////////////////////////////////////////////////////
// WindowProc
LRESULT CALLBACK WindowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch(uMsg){
		case WM_CREATE:
		case WM_DESTROY:
		case WM_SIZE:
			return 0;
		case WM_CLOSE:
			PostQuitMessage(0);
			return 0;
		case WM_KEYDOWN:
			switch(wParam){
				case VK_ESCAPE:
					PostQuitMessage(0);
					return 0;
			}
			return 0;
		default:
			return DefWindowProc(hWnd, uMsg, wParam, lParam);
	}
}


////////////////////////////////////////////////////////////////////////////////
// Windows Main
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	HDC hDC=NULL;
	HWND hWnd;
	HGLRC hRC;																	// Rendering Context
	
	window.w=1024;
	window.h=768;
	char* className="64k-Intro";
	WNDCLASS wc;
	DWORD dwExStyle=WS_EX_APPWINDOW | WS_EX_WINDOWEDGE;
	DWORD dwStyle = WS_OVERLAPPEDWINDOW;
	
	RECT WindowRect;
	WindowRect.left=(long)0;
	WindowRect.right=(long)window.w;
	WindowRect.top=(long)0;
	WindowRect.bottom=(long)window.h;
	
	wc.style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
	wc.lpfnWndProc = WindowProc;
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hInstance = hInstance;
	wc.hIcon = LoadIcon( NULL, IDI_APPLICATION );
	wc.hCursor = LoadCursor( NULL, IDC_ARROW );
	wc.hbrBackground = (HBRUSH)GetStockObject( BLACK_BRUSH );
	wc.lpszMenuName = NULL;
	wc.lpszClassName = className;
	
	if (!RegisterClass( &wc ))	return 0;
	
	// change screen resolution
	DEVMODE dmScreenSettings;
	memset(&dmScreenSettings,0,sizeof(dmScreenSettings));
	dmScreenSettings.dmSize=sizeof(dmScreenSettings);
	dmScreenSettings.dmPelsWidth	= window.w;
	dmScreenSettings.dmPelsHeight	= window.h;
	dmScreenSettings.dmBitsPerPel	= 32;
	dmScreenSettings.dmFields=DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;
	ChangeDisplaySettings(&dmScreenSettings,CDS_FULLSCREEN);
	
	dwExStyle=WS_EX_APPWINDOW;
	dwStyle=WS_POPUP;
	ShowCursor(FALSE);
	
	AdjustWindowRectEx(&WindowRect, dwStyle, FALSE, dwExStyle);
	
	hWnd = CreateWindowEx(	dwExStyle,
							className, "64k-Intro",
							WS_CLIPSIBLINGS | WS_CLIPCHILDREN | dwStyle,
							0, 0,
							WindowRect.right-WindowRect.left,
							WindowRect.bottom-WindowRect.top,
							NULL,
							NULL,
							hInstance,
							NULL
						);
	hDC = GetDC(hWnd);
	
	hDC = GetDC(hWnd);
	
	// init GL window
	PIXELFORMATDESCRIPTOR pfd;
	ZeroMemory( &pfd, sizeof( pfd ) );
	pfd.nSize = sizeof( pfd );
	pfd.nVersion = 1;
	pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
	pfd.iPixelType = PFD_TYPE_RGBA;
	pfd.cColorBits = 24;
	pfd.cDepthBits = 16;
	pfd.iLayerType = PFD_MAIN_PLANE;
	
	// Find A Compatible Pixel Format
	GLuint iFormat = ChoosePixelFormat(hDC, &pfd);
	SetPixelFormat(hDC, iFormat, &pfd);
	hRC = wglCreateContext(hDC);
	wglMakeCurrent(hDC, hRC);
	
	ShowWindow(hWnd, SW_SHOW);
	SetForegroundWindow(hWnd);
	SetFocus(hWnd);
	
	// reshape gl
	glViewport(0, 0,(GLsizei)(window.w),(GLsizei)(window.h));					// Reset The Current Viewport
	glMatrixMode(GL_PROJECTION);												// Select The Projection Matrix
	glLoadIdentity();															// Reset The Projection Matrix
	gluPerspective(45.0, (GLfloat)(window.w)/(GLfloat)(window.h), 1.0, 1000.0);
	glMatrixMode(GL_MODELVIEW);													// Select The Modelview Matrix
	
	glInit();
	
	// MP3 LOAD
	bgm.init("intromusic");
	bgm.play();
	
	MSG msg;
	while(true){
		PeekMessage(&msg, NULL, 0, 0, PM_REMOVE);
		if(msg.message==WM_QUIT){
			return 0;
		}
		else{
			glDraw();
			SwapBuffers(hDC);
			TranslateMessage( &msg );
			DispatchMessage( &msg );
		}
	}
	bgm.stop();
	return 0;
}
