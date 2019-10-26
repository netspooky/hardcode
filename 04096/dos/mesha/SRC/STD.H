#ifndef __STD_H
#define __STD_H

/*---------------------------------------------------------------------*/
typedef unsigned char   boolean;

#ifndef NULL
#define NULL    0
#endif

#define NO      0
#define YES     1

#define OFF     0
#define ON      1

#define FALSE   0
#define TRUE    1

#define FAIL    0
#define OK      1
/*---------------------------------------------------------------------*/

typedef unsigned char   byte;
typedef unsigned int    word;

typedef unsigned short  word16;
typedef unsigned long   word32;

/* to avoid redefinition of this types */
#undef uchar
#define uchar _uchar_
#undef uint
#define uint _uint_
#undef ulong
#define ulong _ulong_
#undef ushort
#define ushort _ushort_

typedef unsigned int    uint;
typedef unsigned char   uchar;
typedef unsigned long   ulong;
typedef unsigned short  ushort;
typedef signed int      sint;
typedef signed char     schar;
typedef signed long     slong;
typedef signed short    sshort;

typedef unsigned int    tSize;
typedef unsigned long   tlSize;

typedef unsigned int    tNo;
typedef unsigned long   tlNo;

typedef unsigned int    tIndex;
typedef unsigned long   tlIndex;

typedef unsigned int    tId;

typedef unsigned short  ufix16;
typedef unsigned long   ufix32;
typedef signed short    sfix16;
typedef signed long     sfix32;

#define SHORTFIX_UNIT   0x100
#define LONGFIX_UNIT    0x10000

#if defined( __WATCOMC__ )
#pragma aux AuxASM "_*" parm [ EAX EDX EBX ECX ESI EDI ] modify exact [ EAX ]
#pragma pack(8)
#endif

#endif
