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

#ifndef __NATIVE_H
#define __NATIVE_H

#include <string.h>
#include <math.h>

typedef unsigned char uchar;
typedef unsigned short ushort;
typedef unsigned int uint;
typedef unsigned int size_t;

// Constants
#define EPSILON 0.0001f
#define PI 3.1415927f

#ifdef DEV_DEBUG
# define DEV_DEBUG_CODE( x ) x
#else
# define DEV_DEBUG_CODE( x )
#endif

extern "C"
{
    
#ifndef NOT_JERE
    
static inline void My_Memcpy( void *d, const void *s, int amt )
{
    uint *_d = (uint *) d;
    uint *_s = (uint *) s;
    amt >>= 2;
    while ( amt-- > 0 ) *_d++ = *_s++;
}

void *My_Malloc( int amt );

static inline void My_Memset( void *data, int val, size_t size )
{
    uint *dst = (uint *) data;
    size >>= 2;
    while ( size-- > 0 ) *dst++ = val;
}


static inline float My_Sin( float x )
{
    float ret_val;
    __asm
    {
        fld dword ptr x
        fsin
        fstp dword ptr ret_val
    }
    return ret_val;
}

static inline float My_Cos( float x )
{
    float ret_val;
    __asm
    {
        fld dword ptr x
        fcos
        fstp dword ptr ret_val
    }
    return ret_val;
}

// Returns atan(a,b)
static inline float My_Atan( float a, float b )
{
    float ret_val;
    __asm
    {
        fld dword ptr a
        fld dword ptr b
        fpatan
        fstp dword ptr ret_val
    }
    return ret_val;
}

static inline float My_Sqrt( float x )
{
    float ret_val;
    __asm
    {
        fld dword ptr x
        fsqrt
        fstp dword ptr ret_val
    }
    return ret_val;
}

static inline int My_Ftoi( float x )
{
    int ret_val;
    __asm
    {
        fld dword ptr x
        fistp dword ptr ret_val
    }
    return ret_val;
}

static inline float My_Abs( float x )
{
    return (x<0) ? -x : x;
}
#else

#define My_Memset memset
#define My_Memcpy memcpy
#define My_Sin (float)sin
#define My_Cos (float)cos
#define My_Atan(a,b) (float)atan2(a,b)
#define My_Sqrt (float)sqrt
#define My_Abs (float)fabs
#define My_Ftoi(x) (int)(x)

#endif // NOT_JERE


/*
// -2..2
#define FLOAT_TWO(x) ValTwo((signed char)(x*63))
float ValTwo( signed char c );
// -127..127
#define FLOAT_INT(x) ValInt((signed char)(x))
float ValInt( signed char c );
*/
#define FLOAT_TWO(x) (x)
#define FLOAT_INT(x) (x)

static inline void Vec_Set( float *dst, float val )
{
/*    uint *d = (uint *) dst;
    d[ 0 ] = d[ 1 ] = d[ 2 ] = *( (uint *) &val);*/
    My_Memset( dst, *((int*) &val), 3*4 );
}

static inline void Vec_Copy( float *dst, const float *src )
{
/*    uint *d = (uint *) dst;
    uint *s = (uint *) src;
    d[ 0 ] = s[ 0 ];
    d[ 1 ] = s[ 1 ];
    d[ 2 ] = s[ 2 ];*/
    My_Memcpy( dst, src, 3*4 );
}

static void Vec_Neg( float *vec )
{
    vec[ 0 ] = -vec[ 0 ];
    vec[ 1 ] = -vec[ 1 ];
    vec[ 2 ] = -vec[ 2 ];
}


void Vec_Add_Mul( float *dst, const float *s1, const float *s2, float mul );
float Vec_Dot( const float *v1, const float *v2 );
void Vec_Cross( float *out, const float *v1, const float *v2 );


static void Vec_Scale( float *v, float mul )
{
    v[0] *= mul;
    v[1] *= mul;
    v[2] *= mul;
}

void Vec_Normalize( float *vec );
float Vec_Len( const float *v );

static float Vec_Dist( const float *v1, const float *v2 )
{
    float dx = v2[0]-v1[0];
    float dy = v2[1]-v1[1];
    float dz = v2[2]-v1[2];
    return My_Sqrt( dx*dx + dy*dy + dz*dz );
}

void Vec_Make_Normal( float *dest_normal, const float *v1, const float *v2, const float *v3 );

}

#endif
