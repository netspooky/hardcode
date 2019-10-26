#ifndef FUCK1
  typedef unsigned char u8;
  typedef signed char s8;
  typedef unsigned short int u16;
  typedef signed short int s16;
  typedef unsigned long int u32;
  typedef signed long int s32;
#else
#  define u8 unsigned char
#  define s8 signed char
#  define u16 unsigned short int
#  define s16 signed short int
#  define u32 unsigned long int
#  define s32 signed long int
#endif

#ifdef BIG_ENDIAN
#  define BYTES2(a,b) (((a)<<8)|(b))
#  define FIRSTBYTE(a)  ((a)>>8)
#  define SECONDBYTE(a) ((a)&0xff)
#else
#  define BYTES2(a,b) (((b)<<8)|(a))
#  define FIRSTBYTE(a)  ((a)&0xff)
#  define SECONDBYTE(a) ((a)>>8)
#endif

#ifndef FUCK0
#  define TEMPMALL(a,b,c) a b[c]
#  define TEMPFREE(a)
#else
#  define TEMPMALL(a,b,c) a *b=malloc((c)*sizeof(a))
#  define TEMPFREE(a)     free(a)
#endif

#ifdef howmany
#  undef howmany
#endif

#ifdef minor
#  undef minor
#endif
