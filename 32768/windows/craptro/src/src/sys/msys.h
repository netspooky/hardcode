//--------------------------------------------------------------------------//
// iq . 2003/2008 . code for 64 kb intros by RGBA                           //
//--------------------------------------------------------------------------//

#ifndef _MSYS_H_
#define _MSYS_H_

#define XRES        640
#define YRES        480

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <mmsystem.h>

#include "msys_types.h"
#include "msys_glext.h"
#include "msys_debug.h"

int  msys_init( uint64 h );
void msys_end( void );

long GetTime();

#endif

