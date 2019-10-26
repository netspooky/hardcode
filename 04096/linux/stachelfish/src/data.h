/** \file data.h
 * \brief Defines more logical names for common datatypes.
 * 
 * This file defines new names for the most used c/c++ data types.
 * This is done because this way all types look similar, some are shorter 
 * (unsigned) and porting a program to another compiler and/or architecture
 * will be easier.
 * The number in each type means the length in byte.
 * 
 * last time modified: 29.11.03
 */

#ifndef _DATA_H_
#define _DATA_H_

    /* *******************************************
     *                                   integer:
     */
    typedef unsigned char        int1u;
    typedef          char        int1;
    typedef unsigned short       int2u;
    typedef          short       int2;
    typedef unsigned int         int4u;
    typedef          int         int4;
 // typedef unsigned long        int4u;
 // typedef          long        int4;
    typedef unsigned long long   int8u;
    typedef          long long   int8;

    /* *******************************************
     *                                     float:
     */
    typedef          float       float4;
    typedef          double      float8;
 // typedef          long double float10;
    typedef          long double float12;

#endif
