/* Useful typedefs and macros (for MinGW).
 * [2009-02-11] Implemented by Jan Kadlec <rrrola@gmail.com>. Public Domain.
 */

#ifndef COMMON_H_INCLUDED
#define COMMON_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


///////////////////////////////////////////////////////////////////// Types //

/* Integer types with exact size.
 */
typedef signed char        S8;
typedef signed short       S16;
typedef signed int         S32;
typedef signed long long   S64;
typedef unsigned char      U8;
typedef unsigned short     U16;
typedef unsigned int       U32;
typedef unsigned long long U64;

/* Integer type that can hold a pointer.
 */
typedef unsigned int       PTR;


/////////////////////////////////////////////////// Debugging and profiling //

#define warn(...)          ( fprintf(stderr, __VA_ARGS__), 1 )
#define die(...)           ( fprintf(stderr, __VA_ARGS__), exit(__LINE__), 1 )  // use: test || die

#define rdtsc()            ({ U64 r; __asm__ __volatile__ ("rdtsc" : "=A"(r) ); r; })


///////////////////////////////////////////////////////////// Useful macros //

#define min(a,b)           ((a)<(b)?(a):(b))
#define max(a,b)           ((a)>(b)?(a):(b))
#define clamp(l,a,h)       min(max(l,a),h)
#define swap(a,b)          ({ typeof(b) __tmp=(b); (b)=(a); (a)=__tmp; })

#define stringf(s,...)     ( snprintf(s, 256, __VA_ARGS__), s )
#define strf(...)          ( snprintf(s, 256, __VA_ARGS__), s )  // generic name for a string :-)

#define fopenr(name)       ( (fr = fopen(name, "rb")) || die("Couldn't open file \"%s\"!", name) )
#define fopenw(name)       ( (fw = fopen(name, "wb")) || die("Couldn't open file \"%s\"!", name) )
#define read(to, bytes)    fread(to, 1, bytes, fr)
#define write(from, bytes) fwrite(from, 1, bytes, fw)

#define zero(p, bytes)     memset((void*)(p), 0, bytes)
#define alloc(p, elems)    ( ((p) = (typeof(p)) malloc((elems)*sizeof(*(p)))) || die("Allocation error!") )
#define reAlloc(p, elems)  ( ((p) = (typeof(p)) realloc((p), (elems)*sizeof(*(p)))) || die("Allocation error!") )

#define alloc_aligned(p, elems, align) \
( ((p) = (typeof(p)) malloc((elems)*sizeof(*(p)) + sizeof(void*)+(align)-1 ))    \
  ? ( ((void**)( (PTR)(p) + sizeof(void*)+(align)-1 & ~((align)-1) ))[-1] = (p), \
      (p) = (typeof(p)) ( (PTR)(p) + sizeof(void*)+(align)-1 & ~((align)-1) ) )  \
  : die("Allocation error!")                                                     \
)

#define allocZ(p, elems) \
  ( alloc(p,elems), zero(p,(elems)*sizeof(*(p))) )

#define allocZ_aligned(p, elems, align) \
  ( alloc_aligned(p,elems,align), zero(p,(elems)*sizeof(*(p))) )

#define free_aligned(p)    free(((void**)(p))[-1])

#endif // COMMON_H_INCLUDED
