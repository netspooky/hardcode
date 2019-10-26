/*
    Andromedary
    Copyright (C) 2006 Jere Sanisalo, Jetro Lauha

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef MINIMATH_H_INCLUDED
#define MINIMATH_H_INCLUDED


#undef PI
#define PI 3.1415926535897932f

//#pragma intrinsic(sin, cos)

// we want only pow implementation of functions below
// when intrinsic functions are in use
/*#ifdef _DEBUG
#include <math.h>
#endif*/

#define sin inlineSin
#define cos inlineCos
#define sqrt inlineSqrt

#define pow inlinePow
#define rand inlineRand
#define srand inlineSrand
#undef RAND_MAX
#define RAND_MAX 65535

#define randf inlineRandf


static unsigned int randseed = 0;

static void inlineSrand(unsigned int seed)
{
    randseed = seed;
}

static unsigned int inlineRand()
{
    randseed = randseed * 0x343fd + 0x269ec3;
    return randseed >> 16;
}

static float inlineRandf(float scale)
{
    return scale * rand() / RAND_MAX;
}


static /*__forceinline*/ float inlineSin(float v)
{
    volatile float res;
    __asm
    {
        fld v
        fsin
        fstp res
    }
    return res;
}

static /*__forceinline*/ float inlineCos(float v)
{
    volatile float res;
    __asm
    {
        fld v
        fcos
        fstp res
    }
    return res;
}

static /*__forceinline*/ float inlineSqrt(float v)
{
    volatile float res;
    __asm
    {
        fld v
        fsqrt
        fstp res
    }
    return res;
}


// don't care about FDIV bugs (FPREM below triggers this)
#pragma warning(disable : 4725)

static /*__forceinline*/ float inlinePow(float base,float exp)
{
    float tmpVal;
    _asm
    {
        fld [exp];
        fld [base];
        fyl2x;
        fld1;
        fld st(1);
        fprem;
        f2xm1;
        faddp st(1),st(0);
        fscale;
        fxch;
        fstp st(0);
        fstp [tmpVal];
    }
    return tmpVal;
}


static /*inline*/ int inlineFtoi( float x )
{
	int ret_val;
	__asm
	{
		fld dword ptr x
		fistp dword ptr ret_val
	}
	return ret_val;
}


#endif // !MINIMATH_H_INCLUDED
