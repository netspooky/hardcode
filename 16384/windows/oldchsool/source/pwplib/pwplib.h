#ifndef __PWPLIB_H
#define __PWPLIB_H

#define PWPLIB_VERSION "1.90"

#ifdef UNIX
#define __POSIX__
#endif

/************** user interface *************/

int     pwplib_init(int argc,char**argv);
int     pwplib_timer();
void    pwplib_shutdown();
void    pwplib_startup();

#define pwplib_buf  pwplib.videobuf.d
#define pwplib_bufw pwplib.videobuf.width
#define pwplib_bufh pwplib.videobuf.height

#define pwplib_prep_rast() pwplib.prep_rast()
#define pwplib_dump_rast() pwplib.dump_rast()

#define pwplib_prep_attr() pwplib.prep_attr()
#define pwplib_dump_attr() pwplib.dump_attr()

#define pwplib_prep_layered() pwplib.prep_layered()
#define pwplib_dump_layered() pwplib.dump_layered()

#define pwplib_loopflush() pwplib.loopflush()

#define pwplib_setplayer(p) pwplib.player=p
#define pwplib_player() pwplib.player()

#define pwplib_sound_off(c)       pwplib.sound(c,0,0,0)
#define pwplib_sound_n(c,n) p     pwplib.sound(c,n,128,128)
#define pwplib_sound_nv(c,n,v)    pwplib.sound(c,n,v,128)
#define pwplib_sound_nvr(c,n,v,r) pwplib.sound(c,n,v,r)

#define pwplib_locale  pwplib.set.lang

#define pwplib_setup(var) pwplib.setup[SETUP_##var]

/*******************************************/

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>

#ifdef __POSIX__

#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <term.h>
#include <signal.h>

#endif

#include "types.h"
#include "config.h"

#ifndef __PWPLIB_C
  extern
#endif
struct
{
   int argc;
   char**argv;

   struct
   {
      u8*d;
      int width,height;
      int aspect;
   }videobuf;

   void(*prep_rast)();
   void(*dump_rast)();

   void(*prep_attr)();
   void(*dump_attr)();

   void(*dump_layered)();
   void(*prep_layered)();

   void(*sound)(int ch,int note,int vol,int ratio);
   void(*loopflush)();
   void(*player)();

   /*** internal stuff ***/

   int timer_counter;
   
   int(*timerfunc)();

   int setup[20];
   
   struct
   {
      char*dev;
      char*term;
      char*lang;
      char*audev;
      
      int wanthelp;
      
      int framedelay;
      int framebytes;

      int infodelay;

      char temp_pad[12];
      
      /* etc... replace the whole setup structure */
   }set;
   
   int frame;
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
  SETUP_USERWIDTH,
  SETUP_WANTHELP
};

#ifndef __PWPLIB_C
  extern
#endif
  void pwp_timer_regframe(int bytes);

typedef struct
{
   char*name;
   int type;
   void*dflt;
   void**var;
}optab;

#define OPT_BIN     0
#define OPT_NOT     1
#define OPT_ONE     2
#define OPT_INT     3
#define OPT_STRING  4
#define OPT_SETDEF  5
#define OPT_NODEF   128

#define STDIN 0
#define STDOUT 1
#define STDERR 2

char* pwp_get_locale();
void pwplib_dump_rast_plain();
int pwp_timer_nrt();

#endif
