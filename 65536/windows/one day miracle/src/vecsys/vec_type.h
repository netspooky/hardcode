/*
 *
 *      VecSys Type Definitions
 *
 *      - tyyppien m„„rittely siirrett„viksi
 *
 */

#ifndef VEC_TYPE_H
#define VEC_TYPE_H

/*      kokonaisluvut       */

typedef signed char     int8;
typedef signed short    int16;
typedef signed long     int32;

typedef unsigned char   uint8;
typedef unsigned short  uint16;
typedef unsigned long   uint32;

/*      reaaliluvut         */

#ifndef VEC_NO_FLOAT
typedef float           vec_fp;     //      floating point
#else
typedef long            vec_fp;     //      fixed point
#endif

#endif

