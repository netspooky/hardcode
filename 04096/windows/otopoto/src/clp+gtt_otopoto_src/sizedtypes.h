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

#ifndef SIZED_TYPES_H
#define SIZED_TYPES_H

#include <limits.h>


// NOTE: sizeof(char) <= sizeof(short) <= sizeof(int) 
//               <= sizeof(long) <= sizeof(long long)
// char  >= 8 bit
// short >= 16 bit
// long  >= 32 bit 

// Define SIZEOF_CHAR 
#if UCHAR_MAX == 0xff
#define SIZEOF_CHAR 1
#elif UCHAR_MAX == 0xffff
#define SIZEOF_CHAR 2
#elif UCHAR_MAX == 0xfffffffful
#define SIZEOF_CHAR 4
#elif UCHAR_MAX == 0xfffffffffffffffful
#define SIZEOF_CHAR 8
#endif // SIZEOF_CHAR

// Define SIZEOF_SHORT
#if USHRT_MAX == 0xffff
#define SIZEOF_SHORT 2
#elif USHRT_MAX == 0xfffffffful
#define SIZEOF_SHORT 4
#elif USHRT_MAX == 0xfffffffffffffffful
#define SIZEOF_SHORT 8
#endif // SIZEOF_SHORT

// Define SIZEOF_INT
#if UINT_MAX == 0xffff
#define SIZEOF_INT 2
#elif UINT_MAX == 0xfffffffful
#define SIZEOF_INT 4
#elif UINT_MAX == 0xfffffffffffffffful
#define SIZEOF_INT 8
#endif // SIZEOF_INT

// Define SIZEOF_LONG
#if ULONG_MAX == 0xfffffffful
#define SIZEOF_LONG 4
#elif ULONG_MAX == 0xfffffffffffffffful
#define SIZEOF_LONG 8
#endif // SIZEOF_LONG

// Define SIZEOF_LONG_LONG
#ifdef ULLONG_MAX
#if ULLONG_MAX == 0xffffffffull
#define SIZEOF_LONG_LONG 4
#elif ULLONG_MAX == 0xffffffffffffffffull
#define SIZEOF_LONG_LONG 8
#endif
#endif // SIZEOF_LONG_LONG
 
#define COMPILE_TIME_ASSERT(name, x)               \
	       typedef int SIZED_dummy_ ## name[(x) * 2 - 1]


// Define 8-bit types
#if SIZEOF_CHAR == 1
typedef unsigned char uint8;
typedef signed char    int8;
COMPILE_TIME_ASSERT(uint8, 1==sizeof(uint8));
COMPILE_TIME_ASSERT(int8, 1==sizeof(int8));
#define HAVE_INT8
#define HAVE_UINT8
#endif // short y siguientes tienen minimo 16 bits

// Define 16-bit types
#if SIZEOF_SHORT == 2
typedef unsigned short uint16;
typedef signed short    int16;
COMPILE_TIME_ASSERT(uint16, 2==sizeof(uint16));
COMPILE_TIME_ASSERT(int16, 2==sizeof(int16));
#define HAVE_INT16
#define HAVE_UINT16
#endif

// Define 32-bit types
#if SIZEOF_SHORT == 4
typedef unsigned short uint32;
typedef signed short    int32;
COMPILE_TIME_ASSERT(uint32, 4==sizeof(uint32));
COMPILE_TIME_ASSERT(int32, 4==sizeof(int32));
#define HAVE_INT32
#define HAVE_UINT32
#elif SIZEOF_INT == 4
typedef unsigned int   uint32;
typedef signed int      int32;
COMPILE_TIME_ASSERT(uint32, 4==sizeof(uint32));
COMPILE_TIME_ASSERT(int32, 4==sizeof(int32));
#define HAVE_INT32
#define HAVE_UINT32
#elif SIZEOF_LONG == 4
typedef unsigned long  uint32;
typedef signed long     int32;
COMPILE_TIME_ASSERT(uint32, 4==sizeof(uint32));
COMPILE_TIME_ASSERT(int32, 4==sizeof(int32));
#define HAVE_INT32
#define HAVE_UINT32
#elif SIZEOF_LONG_LONG == 4
typedef unsigned long long uint32;
typedef signed long long int32;
COMPILE_TIME_ASSERT(uint32, 4==sizeof(uint32));
COMPILE_TIME_ASSERT(int32, 4==sizeof(int32));
#define HAVE_INT32
#define HAVE_UINT32
#endif

// Define 64-bit types
#if SIZEOF_SHORT == 8
typedef unsigned short uint64;
typedef signed short    int64;
COMPILE_TIME_ASSERT(uint64, 8==sizeof(uint64));
COMPILE_TIME_ASSERT(int64, 8==sizeof(int64));
#define HAVE_INT64
#define HAVE_UINT64
#elif SIZEOF_INT == 8
typedef unsigned int   uint64;
typedef signed int      int64;
COMPILE_TIME_ASSERT(uint64, 8==sizeof(uint64));
COMPILE_TIME_ASSERT(int64, 8==sizeof(int64));
#define HAVE_INT64
#define HAVE_UINT64
#elif SIZEOF_LONG == 8
typedef unsigned long  uint64;
typedef signed long     int64;
COMPILE_TIME_ASSERT(uint64, 8==sizeof(uint64));
COMPILE_TIME_ASSERT(int64, 8==sizeof(int64));
#define HAVE_INT64
#define HAVE_UINT64
#elif SIZEOF_LONG_LONG == 8
typedef unsigned long long uint64;
typedef signed long long    int64;
COMPILE_TIME_ASSERT(uint64, 8==sizeof(uint64));
COMPILE_TIME_ASSERT(int64, 8==sizeof(int64));
#define HAVE_INT64
#define HAVE_UINT64
#endif

#ifndef HAVE_INT64
#warning "LLONG_MAX not defined. Trying with long long for 64 bit integers."
typedef unsigned long long uint64;
typedef signed long long    int64;
COMPILE_TIME_ASSERT(uint64, 8==sizeof(uint64));
COMPILE_TIME_ASSERT(int64, 8==sizeof(int64));
#define HAVE_INT64
#define HAVE_UINT64
#endif

#endif // SIZED_TYPES_H
