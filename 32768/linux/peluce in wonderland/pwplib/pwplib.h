#ifndef __PWPLIB_H
#define __PWPLIB_H

#define PWPLIB_VERSION "0.92"

#include "types.h"

#ifndef __PWPLIB_C
  extern
#endif
struct
{
   int*argc;
   char**argv;

   struct
   {
      char*d;
      int width,height;
      int aspect;
   }videobuf;

   void(*dump_ibm)();
   void(*dump_rast)();
   void(*dump_layered)();
   
   void(*prep_ibm)();
   void(*prep_rast)();
   void(*prep_layered)();

   void(*sound)(int ch,int note,int vol);
   void(*loopflush)();
   void(*player)();

   int setup[20];
   
   int timer_counter;

   int(*timerfunc)();
}pwplib;

enum
{
  SETUP_NOSOUND=0,
  SETUP_NOVIDEO,
  SETUP_VOLUME,
  SETUP_TRANS,
  SETUP_COLORS,
  SETUP_RASTER,
  SETUP_HALVE,
  SETUP_TTY,
  SETUP_FPS,
  SETUP_BPS,
  SETUP_LOSSY,
  SETUP_PVP,
  SETUP_MINFPS,
  SETUP_MAXFPS,

  SETUP_SHUTUP,
  SETUP_USERHEIGHT,
  SETUP_USERWIDTH
};

#ifndef __PWPLIB_C
  extern
#endif
  void pwp_timer_regframe(int bytes);

#ifndef __PWPLIB_C
  extern
#endif
  int pwplib_init(int*argc,char**argv);

#endif
