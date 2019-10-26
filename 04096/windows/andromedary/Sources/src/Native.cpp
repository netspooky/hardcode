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

#include "Native.h"

extern "C"
{

#if 0
void * __cdecl memset( void *data, int val, size_t size )
{
    // SIZE: 0x38
/*	char *dst = (char *) data;
    while ( size-- > 0 ) *dst++ = (char) val;
    return dst;*/

    // SIZE: 0x20
    uint *dst = (uint *) data;
    size >>= 2;
    while ( size-- > 0 ) *dst++ = val;
    return dst;
}
#endif

float ValTwo( signed char c )
{
    return c/63.f;
}

float ValInt( signed char c )
{
    return (float)c;
}

void Vec_Add_Mul( float *dst, const float *s1, const float *s2, float mul )
{
    dst[ 0 ] = s1[ 0 ] + s2[ 0 ] * mul;
    dst[ 1 ] = s1[ 1 ] + s2[ 1 ] * mul;
    dst[ 2 ] = s1[ 2 ] + s2[ 2 ] * mul;
}

float Vec_Dot( const float *v1, const float *v2 )
{
    return ( v1[ 0 ] * v2[ 0 ] ) + ( v1[ 1 ] * v2[ 1 ] ) + ( v1[ 2 ] * v2[ 2 ] );
}

void Vec_Cross( float *out, const float *v1, const float *v2 )
{
    out[ 0 ] = v1[ 1 ] * v2[ 2 ] - v1[ 2 ] * v2[ 1 ];
    out[ 1 ] = v1[ 2 ] * v2[ 0 ] - v1[ 0 ] * v2[ 2 ];
    out[ 2 ] = v1[ 0 ] * v2[ 1 ] - v1[ 1 ] * v2[ 0 ];
}

void Vec_Normalize( float *vec )
{
    float len = My_Sqrt( Vec_Dot( vec, vec ) );
    vec[ 0 ] /= len; vec[ 1 ] /= len; vec[ 2 ] /= len;
}

float Vec_Len( const float *v )
{
    return My_Sqrt( v[0]*v[0] + v[1]*v[1] + v[2]*v[2] );
}

void Vec_Make_Normal( float *dest_normal, const float *v1, const float *v2, const float *v3 )
{
    float g_normal_side_u[3];
    float g_normal_side_v[3];
    
    Vec_Add_Mul( g_normal_side_u, v2, v1, -1 );
    Vec_Add_Mul( g_normal_side_v, v3, v1, -1 );
    Vec_Cross( dest_normal, g_normal_side_u, g_normal_side_v );
}

} // extern "C"
