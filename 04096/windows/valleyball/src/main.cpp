#ifdef _DEBUG
#include <time.h>
#include <io.h>
#include <process.h>
#include "Shaders.h"
#include "small.h"
#include "synth.h"
#else
#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include <windows.h>
#include <stdio.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include "glext.h"
#include "small.h"
#include "synth.h"
#include "release.h"
#endif

#pragma data_seg(".vertexshader")
static char* vsh = "varying vec4 Y;varying vec2 Z;void main(){Y=gl_Color;Z=(gl_Vertex.xy*vec2(Y.w,1))*.5+.5;gl_Position=gl_Vertex;}";

#pragma data_seg(".resolutionX")
static const int gi_ScreenWidth = 640;

#pragma data_seg(".resolutionY")
static const int gi_ScreenHeight = 480;

#pragma data_seg(".aspectratio")
static const float gf_AspectRatio = 1.3281250000f; // smaller version for 4:3
//static const float gf_AspectRatio = 1.7734375000f; // smaller version for 16:9
//static const float gf_AspectRatio = 1.25f; // smaller version for 5:4
//static const float gf_AspectRatio = 1.6015625000f; // smaller version for 16:10

#ifdef _DEBUG
#pragma bss_seg(".debugnothing")
HANDLE gh_ShaderCompileEvent;
static char** gs_LastShader_;
static __time64_t gi_ShaderChangedDate;
static unsigned int gi_ShaderProgram;
static unsigned int gi_LastShaderProgram;
#pragma data_seg(".debuginfo")
static const char* gs_VertexShader = "generic.vs";
static const char* gs_ShaderFile = "mark.fs";
#endif

#pragma data_seg(".pfd")
static const PIXELFORMATDESCRIPTOR pfd={
	0, 1, PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER, PFD_TYPE_RGBA, 32, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 8
};

#pragma data_seg(".dms")
static DEVMODE dmScreenSettings={
	"",0,0,sizeof(dmScreenSettings),0,DM_PELSWIDTH|DM_PELSHEIGHT,
	0,0,0,0,0,0,0,0,0,0,0,0,0,"",0,0,gi_ScreenWidth,gi_ScreenHeight
};

#pragma code_seg(".compile")
__forceinline unsigned int compileShader(const char* vsh, const char* fsh)
{
	GLuint s,p;
	p = ((PFNGLCREATEPROGRAMPROC)wglGetProcAddress("glCreateProgram"))();
	s = ((PFNGLCREATESHADERPROC)(wglGetProcAddress("glCreateShader")))(GL_VERTEX_SHADER);
	((PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource")) (s, 1, &vsh, NULL);
	((PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader"))(s);
	((PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader")) (p,s);
	s = ((PFNGLCREATESHADERPROC)wglGetProcAddress("glCreateShader"))(GL_FRAGMENT_SHADER);	
	((PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource")) (s, 1, &fsh, NULL);
	((PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader"))(s);
	((PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader")) (p,s);
	((PFNGLLINKPROGRAMPROC)wglGetProcAddress("glLinkProgram"))(p);
	((PFNGLUSEPROGRAMPROC)wglGetProcAddress("glUseProgram"))(p);
	return p;
}

#pragma code_seg(".main")

#ifdef _DEBUG
DWORD WINAPI filemon(void* args)
{
	while (true)
	{
		_finddata_t fdata;
		long hfile = _findfirst(gs_ShaderFile, &fdata);
		if (hfile != -1)
		{
			if (fdata.time_write != gi_ShaderChangedDate)
			{
				gi_ShaderChangedDate = fdata.time_write;
				::SetEvent(gh_ShaderCompileEvent);
				std::cout << "Shader loaded." << std::endl;
			}
			_findclose(hfile);
		}
		::Sleep(100);
	}
	return 0;
}
#endif

void _cdecl main()
{
#ifdef _DEBUG
	//ChangeDisplaySettings (&dmScreenSettings,CDS_FULLSCREEN); 
	//HDC hDC = GetDC(CreateWindow("edit", 0, WS_POPUP | WS_VISIBLE | WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0));
	HDC hDC = GetDC(CreateWindow("static", "Test", WS_EX_APPWINDOW | WS_VISIBLE | WS_SYSMENU, 0, 0, gi_ScreenWidth, gi_ScreenHeight, 0, 0, 0, 0));
	SetPixelFormat(hDC, ChoosePixelFormat(hDC, &pfd), &pfd);
	wglMakeCurrent(hDC, wglCreateContext(hDC));
	initShaders();
	gh_ShaderCompileEvent = ::CreateEvent(NULL, FALSE, FALSE, TEXT("WriteEvent")); 
	SetThreadPriority((HANDLE)CreateThread(0, 0, &filemon, 0, 0, 0), THREAD_PRIORITY_BELOW_NORMAL);
	::Sleep(1000);

#else
	ChangeDisplaySettings (&dmScreenSettings,CDS_FULLSCREEN); 
	HDC hDC = GetDC(CreateWindow("edit", 0, WS_POPUP | WS_VISIBLE | WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0));
	//HDC hDC = GetDC(CreateWindow("static", "Test", WS_EX_APPWINDOW | WS_VISIBLE | WS_SYSMENU, 0, 0, gi_ScreenWidth, gi_ScreenHeight, 0, 0, 0, 0));
	SetPixelFormat(hDC, ChoosePixelFormat(hDC, &pfd), &pfd);
	wglMakeCurrent(hDC, wglCreateContext(hDC));
	compileShader(vsh, fsh);
#endif

#ifdef _DEBUG
	if (::WaitForSingleObject(gh_ShaderCompileEvent, 0) == WAIT_OBJECT_0)
	{
		::Sleep(250);
		gi_ShaderProgram = createProgram(createVertexShader(gs_VertexShader), createFragmentShader(gs_ShaderFile));

		((PFNGLUSEPROGRAMPROC)wglGetProcAddress("glUseProgram"))(gi_ShaderProgram);
		PrintErrors();
	}
	glColor4f(0,0,0, float(gi_ScreenWidth)/gi_ScreenHeight);
	glRectf(-1, -1, 1, 1);
	SwapBuffers(hDC);
#endif

	InitSound();
loop:
	ShowCursor(FALSE);
	
#ifdef _DEBUG
	if (::WaitForSingleObject(gh_ShaderCompileEvent, 0) == WAIT_OBJECT_0)
	{
		::Sleep(250);
		gi_ShaderProgram = createProgram(createVertexShader(gs_VertexShader), createFragmentShader(gs_ShaderFile));

		((PFNGLUSEPROGRAMPROC)wglGetProcAddress("glUseProgram"))(gi_ShaderProgram);
		PrintErrors();
	}
#endif

	float lf_Time = get_Time() * 71.0f / 240.0f;
	glLoadIdentity();
	glRotatef(-90.0f * lf_Time - 90.0f, 0, 1, 0);
	glColor4f(get_Envelope(7), lf_Time, get_Envelope(2), gf_AspectRatio);
	glRects(-1, -1, 1, 1);
	SwapBuffers(hDC);
	if (!GetAsyncKeyState(VK_ESCAPE) && lf_Time < 30.0f) goto loop;	
	ExitProcess(0);
}
