/*
---------------------
This is the source of etram/Collapse, a 4k intro released at breakpoint'05
Copyright (C) 2005 by Bernat Muñoz García (aka shash/Collapse)
Linux port (C) 2005 by Jorge Gorbe Moya (aka slack/Necrostudios)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; version 2
of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
---------------------
*/

#ifndef __TYPES__
#define __TYPES__

#define w_screen	800
#define h_screen	600
#define w_bpp		32

#define u32 unsigned int
#define u16 unsigned short
#define s32 int
#define u8 unsigned char
#define s8 char
#define SQR(a) ((a)*(a))
#define PI 3.141592f

// built-ins
#define sinf(x) __builtin_sinf(x)
#define cosf(x) __builtin_cosf(x)
#define fabsf(x) __builtin_fabsf(x)

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
//#include "SDL.h"
//#include <GL/gl.h>              // OpenGL
//#include <GL/glu.h>             // GLU library
#endif
