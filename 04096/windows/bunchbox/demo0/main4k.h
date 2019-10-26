// BUNCHBOX, Brad Smith 9/18/2009

#ifndef MAIN4K_H
#define MAIN4K_H

// window parameters
#define FULLSCREEN 0
#define WIDTH  1280
#define HEIGHT 720
#define WINDOW_NAME "4k intro"


#define WIN32_LEAN_AND_MEAN
#include <windows.h>

// convenient types

typedef unsigned __int32		uint32;
typedef unsigned __int16		uint16;
typedef unsigned __int8			uint8;

typedef signed __int32			sint32;
typedef signed __int16			sint16;
typedef signed __int8			sint8;

// definitions for MSVC++

extern void * __cdecl memset(void * ptr, int val, size_t num );
extern void * __cdecl memcpy(void * ptr, const void * src, size_t num );
extern void * __cdecl malloc( size_t alloc_size );
extern void __cdecl free( void * addr );

// debug logging
#ifdef _DEBUG
extern void log( const char * msg, ... );
#	define LOG(x,...) log(x,__VA_ARGS__)
#	define ASSERT(x) {if(!(x)) {log( __FILE__ "(%d): " #x "\n", __LINE__ ); ::DebugBreak();}}
#	define FATAL(x) {ASSERT(x); if(!(x)) ExitProcess(-1);}
#else
#	define LOG(x,...) {}
#	define ASSERT(x) {}
#	define FATAL(x) {if(!(x)) ExitProcess(-1);}
#endif

// OpenGL window setup

extern HWND		g_hWnd;
extern HDC		g_hDC;

extern void setup_window();
extern void paint(); // swaps buffers, draws to screen

#endif // MAIN4K_H
