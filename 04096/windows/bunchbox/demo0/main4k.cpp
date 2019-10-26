// BUNCHBOX, Brad Smith 9/18/2009

// main4k.cpp
//   a minimal setup for making a 4k application
//   define int main4k elsewhere as your entry point

// for logging
#ifdef _DEBUG
#include <cstdarg>
#include <cstdio>
#endif

// user's entry point
extern int main4k(const char * cmdline);

// debug logging

#ifdef _DEBUG
void log( const char * msg, ... )
{
	va_list args;
	va_start( args, msg );
	static char msg_out[ 1024 ];
	::vsnprintf_s( msg_out, 1024, 1024, msg, args );
	::OutputDebugString( msg_out );
}
#endif

// MSVC++ uses memset, malloc, free, and atexit intrinsicly

#pragma function(memset)

void *  __cdecl memset(void * ptr, int val, size_t num )
{
	for ( size_t i=0; i < num; ++i )
	{
		*(((char *)ptr)+i) = (char)val;
	}
	return ptr;
}

#pragma function(memcpy)

void * __cdecl memcpy(void * ptr, const void * src, size_t num )
{
	for ( size_t i=0; i < num; ++i )
	{
		*(((char *)ptr)+i) = *(((char *)src)+i);
	}
	return ptr;
}

// simple malloc implementation (if needed)

static unsigned char memory_bank[ 1 ]; // adjust size for your needs
static size_t memory_bank_pos = 0;

void * __cdecl malloc( size_t alloc_size )
{
	// very simple stack-type allocator
	const size_t pos = memory_bank_pos;
	memory_bank_pos += alloc_size;
	LOG("malloc(%10d) : total %10d\n",alloc_size,memory_bank_pos);
	FATAL( memory_bank_pos <= sizeof(memory_bank) ); // out of memory
	return memory_bank + pos;
}

void __cdecl free( void * addr )
{
	// do nothing
	(void)addr;
}

// atexit

void __cdecl atexit()
{
}

// MSVC++ requires this if floating points are used

extern "C" int _fltused = 1;

// OpenGL window setup

HWND	g_hWnd		= NULL;
HDC		g_hDC		= NULL;

void setup_window()
{
	BOOL success = TRUE;

#if FULLSCREEN
	{
		static DEVMODE mode ={
			"", // device name
			DM_SPECVERSION, 0, // version of struct
			sizeof(DEVMODE),
			0, // no extra data
			DM_PELSWIDTH | DM_PELSHEIGHT,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // unused
			"", // formname
			0, 0, // unused
			WIDTH, HEIGHT,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0 // unused
		};

		LONG result = ChangeDisplaySettings(&mode,CDS_FULLSCREEN);
		ASSERT( result == DISP_CHANGE_SUCCESSFUL );

		g_hWnd = CreateWindow(
			"edit",
			WINDOW_NAME,
			WS_POPUP | WS_VISIBLE | WS_MAXIMIZE,
			0, 0, 0, 0, // x, y, width, height
			0, 0, 0, 0 // parent, menu, instance, param
			);
	}
#else
	{
		g_hWnd = CreateWindow(
			"static",
			WINDOW_NAME,
			WS_EX_APPWINDOW | WS_VISIBLE | WS_SYSMENU,
			0, 0, WIDTH, HEIGHT, // x, y, width, height
			0, 0, 0, 0 // parent, menu, instance, param
			);
	}
#endif
	FATAL( g_hWnd );

	// setup OpenGL context

	g_hDC = GetDC( g_hWnd );
	FATAL( g_hDC );

	static const PIXELFORMATDESCRIPTOR pfd = {
		sizeof(PIXELFORMATDESCRIPTOR),
		1, // version
		PFD_DRAW_TO_WINDOW |
		PFD_SUPPORT_OPENGL |
		PFD_DOUBLEBUFFER
		,
		PFD_TYPE_RGBA,
		32, // bits
		0, 0, 0, 0, 0, 0, 0, 0, // unused bit/shift stuff
		0, 0, 0, 0, // unused accum bits stuff
		32, // depth bits
		0, // stencil bits
		0, // aux buffers
		PFD_MAIN_PLANE, // main layer
		0, // reserved
		0, 0, 0 // layer masks (not used)
	};

	int chosen_format = ChoosePixelFormat( g_hDC, &pfd );
	success = SetPixelFormat( g_hDC, chosen_format, &pfd );
	ASSERT( success == TRUE );

	HGLRC context = wglCreateContext( g_hDC );
	ASSERT( context );

	success = wglMakeCurrent( g_hDC, context );
	ASSERT( success == TRUE );

	// enable vsync if available
	typedef void (APIENTRY *PFNWGLEXTSWAPCONTROLPROC) (int);
	PFNWGLEXTSWAPCONTROLPROC wglSwapIntervalEXT =
		(PFNWGLEXTSWAPCONTROLPROC) wglGetProcAddress("wglSwapIntervalEXT");
	ASSERT( wglSwapIntervalEXT ); // vsync extension not available
	if ( wglSwapIntervalEXT )
	{
		wglSwapIntervalEXT(1); // attempt to enable vsync
	}

	// hide the cursor
	ShowCursor(FALSE);
}

void paint()
{
	SwapBuffers(g_hDC);
}

// real entry point

int WINAPI WinMain(
	HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	LPSTR lpCmdLine,
	int nCmdShow )
{
	return main4k(lpCmdLine);
}

// END OF FILE
