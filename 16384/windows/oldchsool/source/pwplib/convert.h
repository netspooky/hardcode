#include "pwplib.h"

#ifndef __CONVERT_C
  extern
#endif
struct
{
  u8  rast[256*2];
  u8  font[256],col[256];

  u16 tab1to12[256];
  /*  tab1to22 */
  
  u16 megatab[256*256];
  u16 rasthalve[256*256];

  void(*orig_dump_attr)();
}pwpconv;
