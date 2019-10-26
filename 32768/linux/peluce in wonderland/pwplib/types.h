typedef unsigned char u8;
typedef signed char s8;
typedef unsigned short int u16;
typedef signed short int s16;
typedef unsigned long int u32;
typedef signed long int s32;

#ifdef BIG_ENDIAN
  #define BYTES2(a,b) (((a)<<8)|(b))
  #define FIRSTBYTE(a)  ((a)>>8)
  #define SECONDBYTE(a) ((a)&0xff)
#else
  #define BYTES2(a,b) (((b)<<8)|(a))
  #define FIRSTBYTE(a)  ((a)&0xff)
  #define SECONDBYTE(a) ((a)>>8)
#endif
