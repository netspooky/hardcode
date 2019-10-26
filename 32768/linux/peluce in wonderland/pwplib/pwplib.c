#include "config.h"
#define __PWPLIB_C

#include <stdio.h>
#include <stdlib.h>

#include <signal.h>
#include <time.h>
#include <sys/time.h>

#include "pwplib.h"

void pwplib_dummy(){}

void pwplib_dump_rast_plain()
{
   u8 tmp[pwplib.videobuf.width*pwplib.videobuf.height*2],*d=tmp,
      *parentbuf=pwplib.videobuf.d,
      *s=parentbuf;

   int i=pwplib.videobuf.width*pwplib.videobuf.height;
   
   for(;i;i--)
   {
      d[0]=176; /* non-ibm uses '%' */
      d[1]=*s++;
      d+=2;
   }

   pwplib.videobuf.d=tmp;
   pwplib.dump_ibm();
   pwplib.videobuf.d=parentbuf;
}

#define TIMERHZ 72
int pwp_timer_nrt()
{
   static int lastctr=0,framectr=0;

   if(pwplib.setup[SETUP_BPS])
   {
      pwplib.timer_counter++; /* kludge */
      return (pwplib.timer_counter*TIMERHZ)/(pwplib.setup[SETUP_BPS]>>3);
   }
    else
   {
      if(pwplib.timer_counter!=lastctr)
      {
         framectr++;
         lastctr=pwplib.timer_counter;
      }
       else 
          pwplib.timer_counter++;
      return (framectr*TIMERHZ)/pwplib.setup[SETUP_FPS];
   }
}
int pwp_unix_tod()
{
        struct timeval tod;
        gettimeofday(&tod,NULL);
        return (tod.tv_sec*TIMERHZ)+(tod.tv_usec*TIMERHZ/1000000);
}
int pwplib_timer()
{
        static int base=-1;int v;
        v=pwplib.timerfunc();
        if(base==-1)base=v;
        return v-base;
}

/********************/

int pwplib_initcore()
{
   pwplib.sound=
   pwplib.loopflush=
   pwplib.player=
   pwplib.dump_ibm=
   pwplib.dump_rast=
     pwplib_dummy;

   /* video */

   #ifdef DRIVE_VIDEO

   #ifdef DRIVE_PVP
   if(pwplib.setup[SETUP_PVP])
     pvp_init();
   else
   #endif
   if(!pwplib.setup[SETUP_NOVIDEO])
   {
     if(!pwplib.setup[SETUP_TTY])
     {
      #ifdef DRIVE_VCSA
       if(!vcsa_init())
       {
          pwpwrite("*** WARNING: COULDN'T GET VCSA - PLEASE GIVE THE PROPER\n"
                   "    PERMISSIONS TO YOUR /dev/vcsa* DEVICES\n"
                   "    THIS WOULDN'T NORMALLY CAUSE A PROBLEM BUT THERE'S AN\n"
                   "    ANNOYING BUG IN THE DRIVER CODE I'M UNABLE TO FIX TODAY\n"
                   "    (wait for the final version with a non-broken library)\n\n");
          pwplib.setup[SETUP_TTY]++;
       }
      #else
          pwplib.setup[SETUP_TTY]=1;
      #endif
     }

     #ifdef DRIVE_TTY
     if(pwplib.setup[SETUP_TTY])
     {
        tty_init();
     }
     #endif

     conv_init();
   }
   #endif

   /* audio */
   #ifdef DRIVE_AUDIO
   if(!pwplib.setup[SETUP_NOSOUND])
   {
     #ifdef DRIVE_OSS
     if(!oss_init())
     {
       pwpwrite("can't access sound device. switching to nosound.\n");
     }else
     {
       char tmp[100];
       sprintf(tmp,"\rsound settings: volume=%i\n",pwplib.setup[SETUP_VOLUME]);
       pwpwrite(tmp);
     }
     #endif
   }
   else
   pwpwrite("no sound output.\n");
   #endif

   if(pwplib.dump_rast==pwplib_dummy && pwplib.dump_ibm!=pwplib_dummy)
      pwplib.dump_rast=pwplib_dump_rast_plain;

   if(pwplib.setup[SETUP_BPS]|pwplib.setup[SETUP_FPS])
   {
      char tmp[100];
      sprintf(tmp,"non-realtime output (bps=%d fps=%d)\n",
        pwplib.setup[SETUP_BPS],pwplib.setup[SETUP_FPS]);
      pwpwrite(tmp);

      pwplib.timerfunc=pwp_timer_nrt;
      pwplib.timer_counter=0;
   }
    else
      pwplib.timerfunc=pwp_unix_tod;

   if(pwplib.setup[SETUP_USERHEIGHT])pwplib.videobuf.height=pwplib.setup[SETUP_USERHEIGHT];
   if(pwplib.setup[SETUP_USERWIDTH])pwplib.videobuf.width=pwplib.setup[SETUP_USERWIDTH];

   {char tmp[100];
   sprintf(tmp,"pwplib now controls a %d x %d framebuffer",
      pwplib.videobuf.width,pwplib.videobuf.height);
   pwpwrite(tmp);
   }


   return 1;
}
