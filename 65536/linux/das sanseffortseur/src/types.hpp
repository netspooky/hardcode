/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *   This file is part of
 *       ______        _                             __ __
 *      / ____/____   (_)____ _ ____ ___   ____ _   / // /
 *     / __/  / __ \ / // __ `// __ `__ \ / __ `/  / // /_
 *    / /___ / / / // // /_/ // / / / / // /_/ /  /__  __/
 *   /_____//_/ /_//_/ \__, //_/ /_/ /_/ \__,_/     /_/.   
 *                    /____/                              
 *
 *   Copyright © 2003-2012 Brain Control, all rights reserved.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef TYPES_HPP
#define TYPES_HPP

// macros for concatenating strings for pre-processor
#define eTOKENPASTE_DEF(x, y)   x##y
#define eTOKENPASTE(x, y)       eTOKENPASTE_DEF(x, y)

#if defined(_MSC_VER)
// visual c++ specific stuff
#define eFASTCALL               __fastcall
#define eFORCEINLINE            __forceinline
#define eINLINE                 __inline
#define eNORETURN               __declspec(noreturn)
#define eALIGN16                __declspec(align(16))
#define eNAKED                  __declspec(naked)
#define eTHREADLOCAL            __declspec(thread)
#define eCALLBACK               __stdcall
#define eCDECL                  __cdecl
#else
#define eFASTCALL               __attribute__((fastcall))
#define eFORCEINLINE            inline __attribute__((always_inline))
#define eINLINE                 __inline
#define eNORETURN               __attribute__((noreturn))
#define eALIGN16                __attribute__((aligned (16)))
#define eCALLBACK               __attribute__((stdcall))
#define eCDECL                  //__attribute__((cdecl)) //Annoying warning
#endif

// own types
typedef unsigned char           eU8;
typedef signed char             eS8;
typedef unsigned short          eU16;
typedef short                   eS16;
typedef unsigned int            eU32;
typedef int                     eS32;
typedef float                   eF32;
#if defined(_MSC_VER)
typedef unsigned __int64        eU64;
typedef signed __int64          eS64;
#else
typedef unsigned long long      eU64;
typedef signed long long        eS64;
#endif
typedef double                  eF64;
typedef int                     eInt;
typedef char                    eChar;
typedef signed char             eBool;
typedef void *                  ePtr;
typedef const void *            eConstPtr;
typedef eU32                    eID;

// numerical limits (dont't change into consts, it's a size thing!)
#define eU32_MAX                (0xffffffffU)
#define eS32_MIN                (-2147483647-1)
#define eS32_MAX                (2147483647)
#define eU16_MAX                (0xffffU)
#define eS16_MIN                (-32768)
#define eS16_MAX                (32767)
#define eU8_MAX                 (0xffU)
#define eS8_MIN                 (-128)
#define eS8_MAX                 (127)

#define eF32_MAX                (3.402823466e+38F)
#define eF32_MIN                (-eF32_MAX)
#define eF32_INF                (1e30f)

// some constants
#define eTRUE                   (eBool)(!0)
#define eFALSE                  0
#define eNOID                   0

#endif // TYPES_HPP
