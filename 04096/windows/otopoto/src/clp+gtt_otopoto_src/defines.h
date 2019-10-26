/*
	This file is part of "otopoto / Collapse & Gatitos".

    "otopoto / Collapse & Gatitos" is free software: you can redistribute
	it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

    "otopoto / Collapse & Gatitos" is distributed in the hope that it will
	be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with "otopoto / Collapse & Gatitos".  If not, see 
	<http://www.gnu.org/licenses/>.
*/

#ifndef DEFINES_H
#define DEFINES_H

	#define FULLSCREEN
	//#define FULLSCREEN_FORCE_BPP
	#define xres 1280
	#define yres 720
	//#define xres 640
	//#define yres 480

	//#define MUTE_MUSIC
	//#define NO_MUSIC
	//#define LINUX
	//#define OUTFILE "salida.raw"
	#define SYNTH_CPU_HUNGRY // (activar si el sinte se pinza)

	#ifndef LINUX
		#include <windows.h>

		#define WINDOWS_32
		#define FASTCALL	__fastcall
		#define NAKED		__declspec(naked)
		//#define USE_ASM 0
	#else
		#define FASTCALL	__attribute__((fastcall))
		#define NAKED		// mmmmm, desnudo
		#define USE_ASM 0
	#endif

	
	#define u32  unsigned int
	#define s32    signed int
	#define u16  unsigned short
	#define s16    signed short
	#define  u8  unsigned char
	#define  s8			  char

	#define SQR(a) ((a)*(a))

	#include <GL/gl.h>
	#include <GL/glu.h>
	#include <math.h>
	#include <stdlib.h>
	#include "glext.h"

#endif // DEFINES_H

