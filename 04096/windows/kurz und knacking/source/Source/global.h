#ifndef GLOBAL_H
#define GLOBAL_H

#define WIN32_LEAN_AND_MEAN

#define FULLSCREEN
//#define SAFE_CODE
#define AUDIO
#define SHADOWS

#ifdef _DEBUG
	#define SAFE_CODE
#endif

// if no fullscreen fake use this..
#define RESX					1024
#define RESY					768

// assume :>
#define TEXTURE_RES				2
#define PLANE_SUBX				50
#define PLANE_SUBY				50
#define PLANE_TEXX				10.5f
#define PLANE_TEXY				10.5f

#ifdef SAFE_CODE
	#define TITLE				"[safe]"
#else
	#ifdef FULLSCREEN
		#define TITLE			""
	#else
		#define TITLE			"[unsafe]"
	#endif
#endif

#define MAX_PARTICLE_SYSTEMS	550

#ifdef SAFE_CODE

	#include "glwindow.h"
	#include <stdlib.h>
	glwindow glw;

#else

	#include <windows.h>
	#include <gl/gl.h>
	#include <gl/glu.h>
	#include <stdlib.h>

	extern PIXELFORMATDESCRIPTOR	pfd;
	extern HWND						hwnd;
	extern HDC						device;

#endif

#endif