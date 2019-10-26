#define __PWPLIB_C

#include "config.h"

#include <stdio.h>
#include <stdlib.h>

#include <windows.h>

#include "pwplib.h"

#define DESTRUCTORS 8

/******************** random stuff *************************/

extern void pwplib_dummy();
#define pwp_dummy pwplib_dummy

/********************* timer  ******************************/

#define TIMERHZ 72
int pwp_w32_ticks()
{
   int ticks = GetTickCount();
   
   return ((ticks*TIMERHZ)/1000);
// (10000000/10441));
}

/******************** initialization *********************/

int pwplib_initcore()
{
   pwplib_init_common();

   win32con_init();

   win32snd_init();

   pwplib.timerfunc = pwp_w32_ticks;


  if(pwplib.dump_rast==pwplib_dummy && pwplib.dump_attr!=pwplib_dummy)
      pwplib.dump_rast=pwplib_dump_rast_plain;

 return 1;
}

/*********************************************************************/

void pwplib_startup()
{
}

void pwplib_end()
{
  pwplib_shutdown();

  /* write some stuph */
}

/***************************************************************/

extern void pwplib_getopts();

int pwplib_init(int argc,char**argv)
{
//   printf("ME THINKS WIN32 ROOLZ\n\n");

   pwplib.argc=argc;
   pwplib.argv=argv;

   pwplib_getopts();

   pwplib_initcore();

   return 1;
}

