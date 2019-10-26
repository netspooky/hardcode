// main.cpp

#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include <windows.h>
#include <GL/gl.h>
#include <math.h>
#include "glext.h"
#include "mmsystem.h"

extern "C" int _fltused = 0;

#define ISFULLSCREEN
#define XRES    1280 // 800
#define YRES    1024 // 600

const static char *fragmentShader="\
	void main()\
	{\
	   vec4 f=gl_Color*1e3;\
	   vec4 p=gl_FragCoord;\
	   vec4 d=p-f;d*=d;\
	   int w=4*f.w+2e2*sin((d.x+d.y)*1e-5+f.z*1.2);\
	   p=floor(p/w)*w;\
	   p=int(p-int(p/w)*w);\
	   int v=w*(sin(f.z*2)*.2);\
	   int c=p.x>v&&p.y>v;\
	   gl_FragColor=vec4(c,c,c,1);\
	}";

static float g_fMod_ = 0.0f;

#ifdef _DEBUG

const static PIXELFORMATDESCRIPTOR pfd = {0,0,PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};


const static char *funcNames[] = { "glCreateProgram",
                                   "glCreateShader",
                                   "glShaderSource",
                                   "glCompileShader",
                                   "glAttachShader",
                                   "glLinkProgram",
                                   "glUseProgram",
				   "glUniform1f",
				   "glGetUniformLocation" };

static void *funcPtrs[9];

#define oglCreateProgram ((PFNGLCREATEPROGRAMPROC)funcPtrs[0])
#define oglCreateShader  ((PFNGLCREATESHADERPROC)funcPtrs[1])
#define oglShaderSource  ((PFNGLSHADERSOURCEPROC)funcPtrs[2])
#define oglCompileShader ((PFNGLCOMPILESHADERPROC)funcPtrs[3])
#define oglAttachShader  ((PFNGLATTACHSHADERPROC)funcPtrs[4])
#define oglLinkProgram   ((PFNGLLINKPROGRAMPROC)funcPtrs[5])
#define oglUseProgram    ((PFNGLUSEPROGRAMPROC)funcPtrs[6])
#define oglUniform1f    ((PFNGLUNIFORM1FPROC)funcPtrs[7])
#define oglGetUniformLocation    ((PFNGLGETUNIFORMLOCATIONPROC)funcPtrs[8)]

static RECT rec = { 0, 0, XRES, YRES };

//--------------------------------------------------------------------------//
static LRESULT CALLBACK WndProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam )
{
	// salvapantallas
	if( uMsg==WM_SYSCOMMAND && (wParam==SC_SCREENSAVE || wParam==SC_MONITORPOWER) )
		return( 0 );

	// boton x o pulsacion de escape
	if( uMsg==WM_CLOSE || uMsg==WM_DESTROY || (uMsg==WM_KEYDOWN && wParam==VK_ESCAPE) )
		{
		PostQuitMessage(0);
        return( 0 );
		}

    if( uMsg==WM_CHAR )
        {
        if( wParam==VK_ESCAPE )
            {
            PostQuitMessage(0);
            return( 0 );
            }
        }

    return( DefWindowProc(hWnd,uMsg,wParam,lParam) );
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{ 
	WNDCLASS		wc;

	// create window
	ZeroMemory( &wc, sizeof(WNDCLASS) );
	wc.style         = CS_OWNDC|CS_HREDRAW|CS_VREDRAW;
	wc.lpfnWndProc   = WndProc;
	wc.hInstance     = hPrevInstance;
	wc.lpszClassName = "iq";

	if( !RegisterClass(&wc) )
	return( 0 );

	const int dws = WS_VISIBLE | WS_CAPTION | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_SYSMENU;
	AdjustWindowRect( &rec, dws, 0 );
	HWND hWnd = CreateWindowEx( WS_EX_APPWINDOW | WS_EX_WINDOWEDGE, wc.lpszClassName, "accio", dws,
				(GetSystemMetrics(SM_CXSCREEN)-rec.right+rec.left)>>1,
				(GetSystemMetrics(SM_CYSCREEN)-rec.bottom+rec.top)>>1,
				rec.right-rec.left, rec.bottom-rec.top, 0, 0, hPrevInstance, 0 );
	if( !hWnd )
	return( 0 );

	HDC hDC=GetDC(hWnd);
	if( !hDC )
	return( 0 );

	// init opengl
	int pf = ChoosePixelFormat(hDC,&pfd);
	if( !pf )
	return( 0 );
    
	if( !SetPixelFormat(hDC,pf,&pfd) )
	return( 0 );

	HGLRC hRC = wglCreateContext(hDC);
	if( !hRC )
	return( 0 );

	if( !wglMakeCurrent(hDC,hRC) )
	return( 0 );

	// init extensions
	for( int i=0; i<(sizeof(funcPtrs)/sizeof(void*)); i++ )
	{
		funcPtrs[i] = wglGetProcAddress( funcNames[i] );
		if( !funcPtrs[i] )
			return 0;
	}

	// create shader
	int p = oglCreateProgram();
	//    int v = oglCreateShader(GL_VERTEX_SHADER);
	//    oglShaderSource(v, 1, &vertexShader, 0);
	//    oglCompileShader(v);
	//    oglAttachShader(p,v);
	int f = oglCreateShader(GL_FRAGMENT_SHADER);	
	oglShaderSource(f, 1, &fragmentShader, 0);
	oglCompileShader(f);
	oglAttachShader(p,f);
	oglLinkProgram(p);
	oglUseProgram(p);
	
	ShowCursor( 0 );
#else

const static PIXELFORMATDESCRIPTOR pfd = {0,0,PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

static DEVMODE screenSettings = { 
    #if _MSC_VER < 1400
    {0},0,0,148,0,0x001c0000,{0},0,0,0,0,0,0,0,0,0,{0},0,32,XRES,YRES,0,0,      // Visual C++ 6.0
    #else
    {0},0,0,156,0,0x001c0000,{0},0,0,0,0,0,{0},0,32,XRES,YRES,{0}, 0,           // Visuatl Studio 2005
    #endif
    #if(WINVER >= 0x0400)
    0,0,0,0,0,0,
    #if (WINVER >= 0x0500) || (_WIN32_WINNT >= 0x0400)
    0,0
    #endif
    #endif
    };

void entrypoint( void )
{
	// full screen
	if( ChangeDisplaySettings(&screenSettings,CDS_FULLSCREEN)!=DISP_CHANGE_SUCCESSFUL) return; ShowCursor( 0 );

	// create windows
	HDC hDC = GetDC( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0,0,0,0,0,0,0,0) );

	// init opengl
	SetPixelFormat(hDC, ChoosePixelFormat(hDC, &pfd), &pfd);
	wglMakeCurrent(hDC, wglCreateContext(hDC));

	// create shader
	const int p = ((PFNGLCREATEPROGRAMPROC)wglGetProcAddress("glCreateProgram"))();
	const int s = ((PFNGLCREATESHADERPROC)wglGetProcAddress("glCreateShader"))(GL_FRAGMENT_SHADER);	
	((PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource"))(s, 1, &fragmentShader, 0);
	((PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader"))(s);
	((PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader"))(p,s);
	((PFNGLLINKPROGRAMPROC)wglGetProcAddress("glLinkProgram"))(p);
	((PFNGLUSEPROGRAMPROC)wglGetProcAddress("glUseProgram"))(p);
#endif // _DEBUG
	
	do
	{
		POINT oMousePos;
		GetCursorPos( &oMousePos );
		long int liTime = GetTickCount();
		if( liTime % 1000 < 8 )
		{
			g_fMod_ += ( oMousePos.x / 1000.0f );
			Beep( int( 4000.0f * g_fMod_ ), 100 );
		}
		glColor4f(
			oMousePos.x * 0.001f,
			( YRES - oMousePos.y ) * 0.001f,
			liTime * 0.000001f,
			g_fMod_ ); 
		g_fMod_ *= 0.965f;

		glRects( -1, -1, 1, 1 );
		
		SwapBuffers( hDC ); //wglSwapLayerBuffers( hDC, WGL_SWAP_MAIN_PLANE );
	}
	while ( !GetAsyncKeyState( VK_ESCAPE ) );

	ExitProcess( 0 );
}
