#pragma once

#undef UNICODE
#undef _UNICODE

#define WIN32_LEAN_AND_MEAN
#define NOGDICAPMASKS		// CC_*, LC_*, PC_*, CP_*, TC_*, RC_
//#define NOVIRTUALKEYCODES	// VK_*
#define NOWINMESSAGES		// WM_*, EM_*, LB_*, CB_*
//#define NOWINSTYLES		// WS_*, CS_*, ES_*, LBS_*, SBS_*, CBS_*
#define NOSYSMETRICS		// SM_*
#define NOMENUS				// MF_*
#define NOICONS				// IDI_*
#define NOKEYSTATES			// MK_*
#define NOSYSCOMMANDS		// SC_*
#define NORASTEROPS			// Binary and Tertiary raster ops
#define NOSHOWWINDOW		// SW_*
#define OEMRESOURCE			// OEM Resource values
#define NOATOM				// Atom Manager routines
#define NOCLIPBOARD			// Clipboard routines
#define NOCOLOR				// Screen colors
//#define NOCTLMGR			// Control and Dialog routines
#define NODRAWTEXT			// DrawText() and DT_*
//#define NOGDI				// All GDI defines and routines
//#define NOKERNEL			// All KERNEL defines and routines
//#define NOUSER			// All USER defines and routines
#define NONLS				// All NLS defines and routines
#define NOMB				// MB_* and MessageBox()
#define NOMEMMGR			// GMEM_*, LMEM_*, GHND, LHND, associated routines
#define NOMETAFILE			// typedef METAFILEPICT
#define NOMINMAX			// Macros min(a,b) and max(a,b)
#define NOMSG				// typedef MSG and associated routines
#define NOOPENFILE			// OpenFile(), OemToAnsi, AnsiToOem, and OF_*
#define NOSCROLL			// SB_* and scrolling routines
#define NOSERVICE			// All Service Controller routines, SERVICE_ equates, etc.
#define NOSOUND				// Sound driver routines
#define NOTEXTMETRIC		// typedef TEXTMETRIC and associated routines
#define NOWH				// SetWindowsHook and WH_*
#define NOWINOFFSETS		// GWL_*, GCL_*, associated routines
#define NOCOMM				// COMM driver routines
#define NOKANJI				// Kanji support stuff.
#define NOHELP				// Help engine interface.
#define NOPROFILER			// Profiler interface.
#define NODEFERWINDOWPOS	// DeferWindowPos routines
#define NOMCX				// Modem Configuration Extensions



//
//
//
#ifndef _DEBUG
#pragma comment(linker, "/NODEFAULTLIB")
#pragma optimize("gsy", on)
#pragma check_stack(off)
#pragma runtime_checks("", off)
#endif
#pragma comment(lib, "imm32.lib")
#pragma comment(lib, "winmm.lib")
#pragma comment(lib, "opengl32.lib")
#pragma comment(lib, "glu32.lib")

//
//
//
#include <windows.h>
#include <mmsystem.h>
#include <tchar.h>
#include <GL/gl.h>
#include <GL/glu.h>

//
//
//
#include "mymath.h"

//
//	code from IN4K
//
#define GLCOLOR_FCOLOR(x)		static_cast<int>((x) * 255.0)
#define GLCOLOR_RGBA(r,g,b,a)	((GLCOLOR_FCOLOR(r)<<0) | (GLCOLOR_FCOLOR(g)<<8) | (GLCOLOR_FCOLOR(b)<<16) | (GLCOLOR_FCOLOR(a)<<24))
#define glColor4_CONST(r,g,b,a)	do { var.glcolor_tmp = GLCOLOR_RGBA(r,g,b,a); glColor4ubv((unsigned char*)&var.glcolor_tmp); } while(0)

//
//
//
#define	malloc(x)	GlobalAlloc(GMEM_FIXED | GMEM_ZEROINIT, (x))

typedef int TICK;
#define TICK_PER_SEC	1000
//#define GET_TICK()	static_cast<TICK>(GetTickCount())
#define GET_TICK()		static_cast<TICK>(timeGetTime())
#define TICK_TO_SEC(t)	(static_cast<float>(t) * (1.0f / ((float)TICK_PER_SEC)))
#define SEC_TO_TICK(s)	static_cast<TICK>((s) * ((float)TICK_PER_SEC))
