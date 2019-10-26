// Release build?
#ifdef NDEBUG
# define RELEASE
#else
# define DEBUG
#endif

// System includes
#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include <windows.h>
#include <GL/gl.h>

#ifdef DEBUG
# include <mmsystem.h>
# include <stdio.h>
#endif

#include "glext.h"

// Define to be at full screen
#ifdef RELEASE
# define FULLSCREEN
#endif

//#define XRES 1280
//#define YRES 720
#define XRES 1024
#define YRES 768

// Force inlining
#define DO_INLINE __forceinline

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;
typedef signed char sint8;
typedef signed short sint16;
typedef signed int sint32;

#pragma data_seg(".dshader")
static const char *Shader_glsl =
#include "shader_code.h"
;

#pragma data_seg(".dpfd")
static const PIXELFORMATDESCRIPTOR g_pfd = {0,0,PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

#pragma data_seg(".dscrset")
static DEVMODEA g_screen_settings = { {0},
    #if _MSC_VER < 1400
    0,0,148,0,0x001c0000,{0},0,0,0,0,0,0,0,0,0,{0},0,32,XRES,YRES,0,0,      // Visual C++ 6.0, 2003
    #else
    0,0,156,0,0x001c0000,{0},0,0,0,0,0,{0},0,32,XRES,YRES,{0}, 0,           // Visual Studio 2005
    #endif
    #if(WINVER >= 0x0400)
    0,0,0,0,0,0,
    #if (WINVER >= 0x0500) || (_WIN32_WINNT >= 0x0400)
    0,0
    #endif
    #endif
};

// OpenGL ext functions
#ifdef DEBUG
const static char *g_func_names[] =
{
	"glCreateProgram",
	"glCreateShader",
	"glShaderSource",
	"glCompileShader",
	"glAttachShader",
	"glLinkProgram",
	"glUseProgram",
	"glGetObjectParameterivARB",
	"glGetInfoLogARB",
};
static const int g_func_cnt = sizeof(g_func_names) / sizeof(g_func_names[0]);

static void *g_func_ptrs[g_func_cnt];

#define oglCreateProgram		((PFNGLCREATEPROGRAMPROC)g_func_ptrs[0])
#define oglCreateShader			((PFNGLCREATESHADERPROC)g_func_ptrs[1])
#define oglShaderSource			((PFNGLSHADERSOURCEPROC)g_func_ptrs[2])
#define oglCompileShader		((PFNGLCOMPILESHADERPROC)g_func_ptrs[3])
#define oglAttachShader			((PFNGLATTACHSHADERPROC)g_func_ptrs[4])
#define oglLinkProgram			((PFNGLLINKPROGRAMPROC)g_func_ptrs[5])
#define oglUseProgram			((PFNGLUSEPROGRAMPROC)g_func_ptrs[6])
#define oglGetObjectParameteriv	((PFNGLGETOBJECTPARAMETERIVARBPROC)g_func_ptrs[7])
#define oglGetInfoLog			((PFNGLGETINFOLOGARBPROC)g_func_ptrs[8])
#endif

// Polls for a new shader from file
#ifdef DEBUG
static const char *g_shader_file_name = "Shader.glsl";

static void Poll_Shader_File()
{
	static DWORD g_last_poll_time = 0;
	static FILETIME g_last_filetime = { 0, 0 };

	// Poll a couple of times in a second
	DWORD cur_time = GetTickCount();
	if ((g_last_poll_time == 0) ||
		(g_last_poll_time > cur_time) ||
		((cur_time - g_last_poll_time) >= 200))
	{
		g_last_poll_time = cur_time;
	}
	else
	{
		return;
	}

	// Get the file last modified
	WIN32_FILE_ATTRIBUTE_DATA file_attr;
	ZeroMemory(&file_attr, sizeof(file_attr));
	if (!GetFileAttributesExA(g_shader_file_name, GetFileExInfoStandard, &file_attr))
		return;

	// File changed?
	if (file_attr.ftLastWriteTime.dwHighDateTime < g_last_filetime.dwHighDateTime)
		return;
	if (file_attr.ftLastWriteTime.dwHighDateTime == g_last_filetime.dwHighDateTime &&
		file_attr.ftLastWriteTime.dwLowDateTime <= g_last_filetime.dwLowDateTime)
		return;

	g_last_filetime = file_attr.ftLastWriteTime;
	OutputDebugStringA("Shader file changed, recompiling!\n");

	// Reload the shader
	static const int g_file_buffer_size = 256 * 1024;
	static char g_file_buffer[g_file_buffer_size];

	ZeroMemory(&g_file_buffer[0], g_file_buffer_size);

	HANDLE fin = CreateFileA(g_shader_file_name, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (fin == INVALID_HANDLE_VALUE)
	{
		OutputDebugStringA("Error opening file!");
		return;
	}
	DWORD read_amt = 0;
	ReadFile(fin, &g_file_buffer[0], g_file_buffer_size, &read_amt, NULL);
	CloseHandle(fin);

	// Compile the shader
	int p = oglCreateProgram();
    int fs_id = oglCreateShader(GL_FRAGMENT_SHADER);
	const char *shader = g_file_buffer;
    oglShaderSource(fs_id, 1, &shader, 0);
    oglCompileShader(fs_id);
    oglAttachShader(p,fs_id);
    oglLinkProgram(p);
    oglUseProgram(p);

	// Any errors?
    int result;
	static const int info_size = 8192;
    static char info[info_size];
    oglGetObjectParameteriv(fs_id,   GL_OBJECT_COMPILE_STATUS_ARB, &result);
	oglGetInfoLog(fs_id,   info_size, NULL, (char *)info);
	if (!result)
	{
		OutputDebugStringA("Shader compile error:\n");
		OutputDebugStringA(info);
		OutputDebugStringA("\n");
		return;
	}

    oglGetObjectParameteriv(p, GL_OBJECT_LINK_STATUS_ARB, &result);
	oglGetInfoLog(p, info_size, NULL, (char*)info);
	if (!result)
	{
		OutputDebugStringA("Shader link error:\n");
		OutputDebugStringA(info);
		OutputDebugStringA("\n");
		return;
	}

	OutputDebugStringA("Shader updated!");
}
#endif

// Main entrypoint
#ifdef RELEASE
#pragma code_seg(".code_main")
__declspec(naked)
	void entrypoint(void)
#else
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
#endif
{{
	// Function prolog
#ifdef RELEASE
	__asm enter 0x10, 0;
	__asm pushad;
#endif

	// Change to full screen
#ifdef FULLSCREEN
    //if (ChangeDisplaySettings(&g_screen_settings,CDS_FULLSCREEN)!=DISP_CHANGE_SUCCESSFUL) return;
	ChangeDisplaySettingsA(&g_screen_settings, CDS_FULLSCREEN);
//	ShowCursor(0);
#endif

	// Create the window
#ifdef DEBUG
    HWND hwnd = CreateWindowExA( WS_EX_APPWINDOW|WS_EX_WINDOWEDGE, "edit", "1k", 
                                WS_VISIBLE|WS_CAPTION|WS_CLIPSIBLINGS|WS_CLIPCHILDREN, 
                                0, 0, XRES, YRES, 0, 0, 0, 0 );
    HDC hdc = GetDC(hwnd);
#else
	HDC hdc = GetDC(CreateWindowA("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0));
#endif

	// Init the OpenGL
	SetPixelFormat(hdc, ChoosePixelFormat(hdc, &g_pfd), &g_pfd);
	wglMakeCurrent(hdc, wglCreateContext(hdc));

    // Init the OpenGL extensions
#ifdef DEBUG
    for (int i=0; i < g_func_cnt; ++i)
    {
        g_func_ptrs[i] = wglGetProcAddress(g_func_names[i]);
        if (!g_func_ptrs[i])
		{
			OutputDebugStringA("OpenGL extension function not found:\n");
			OutputDebugStringA(g_func_names[i]);
			OutputDebugStringA("\n");
            return 0;
		}
    }
#endif

    // Create the shader
	{
		const int p = ((PFNGLCREATEPROGRAMPROC)wglGetProcAddress("glCreateProgram"))();
		const int s = ((PFNGLCREATESHADERPROC)wglGetProcAddress("glCreateShader"))(GL_FRAGMENT_SHADER);	
		((PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource"))(s, 1, &Shader_glsl, 0);
		((PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader"))(s);
		((PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader"))(p,s);
		((PFNGLLINKPROGRAMPROC)wglGetProcAddress("glLinkProgram"))(p);
		((PFNGLUSEPROGRAMPROC)wglGetProcAddress("glUseProgram"))(p);
	}

	// Init the timer resolution
#ifdef DEBUG
	timeBeginPeriod(1);
#endif

	// The main loop
	DWORD start_t = GetTickCount();

#ifdef DEBUG
	bool done = false;
    while( !done )
    {
        MSG msg; 
        while( PeekMessageA( &msg,0,0,0,PM_REMOVE ) ) 
        {
            done |= (GetAsyncKeyState(VK_ESCAPE)!=0);
            DispatchMessage( &msg );
        }

		// Poll the shader for changes
#ifdef DEBUG
		Poll_Shader_File();
#endif

		// Poll for time reset
#ifdef DEBUG
		if (GetAsyncKeyState(VK_F2))
		{
			OutputDebugStringA("Restarting the timer..\n");
			start_t = GetTickCount();
		}
#endif

		// Blit to the screen
		int t = GetTickCount() - start_t;
		glColor3us(t, t, t);
		glRecti(1, 1, -1, -1);
		SwapBuffers(hdc);

		// Give some time to other processes
        Sleep(1);
    }

    ExitProcess(0);
#else // #ifdef DEBUG -- This is the release loop:
loop:
	SetCursorPos(0, 0);
	int t = GetTickCount() - start_t;
	glColor3us(t, t, t);
	glRecti(1, 1, -1, -1);
	SwapBuffers(hdc);
	if (GetAsyncKeyState(VK_ESCAPE) | (t>>16))
	    ExitProcess(0);
	goto loop;
#endif
}}
