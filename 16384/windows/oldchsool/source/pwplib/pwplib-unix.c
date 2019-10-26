#define __PWPLIB_C

#include "config.h"

#include <stdio.h>
#include <stdlib.h>

#include <signal.h>
#include <time.h>
#include <sys/time.h>

#include "pwplib.h"
#include "tty.h"

#define DESTRUCTORS 8

/******************** random stuff *************************/

extern void pwplib_dummy();
#define pwp_dummy pwplib_dummy

void pwpwrite(char*z)
{
  if(!pwplib.setup[SETUP_SHUTUP])
  {
     fprintf(stderr,"%s",z);
     usleep(1000*pwplib.set.infodelay);
  }
}

/********************* timer  ******************************/

#define TIMERHZ 72
int pwp_unix_tod()
{
        struct timeval tod;
        gettimeofday(&tod,NULL);
        return (tod.tv_sec*TIMERHZ)+(tod.tv_usec*TIMERHZ/1000000);
}

/********************* destructors, signals etc **********/

void pwp_fatalsignal(int n)
{
   char buf[40];

   pwplib_shutdown();

   sprintf(buf,"* died to signal %d\n",n);
   pwpwrite(buf);
   
   exit(1);
}

/******************** initialization *********************/

int pwplib_initcore()
{
   pwplib_init_common();

   /*** set signals ***/

   signal(SIGTERM,pwp_fatalsignal);
   signal(SIGINT,pwp_fatalsignal);
   signal(SIGQUIT,pwp_fatalsignal);
   signal(SIGKILL,pwp_fatalsignal);
   signal(SIGSEGV,pwp_fatalsignal);

   /*** video ***/

#   ifdef DRIVE_VIDEO

#   ifdef DRIVE_X11
   if(pwp_X11_init())
   {   
   }
   else
#   endif
#   ifdef DRIVE_PVP
   if(pwplib.setup[SETUP_PVP])
     pvp_init();
   else
#   endif
   if(!pwplib.setup[SETUP_NOVIDEO])
   {
     tty_init();
   }
#   endif

   /*** audio ***/
#  ifdef DRIVE_AUDIO
   if(!pwplib.setup[SETUP_NOSOUND])
   {
      int snd=0;
#ifdef DRIVE_OSS
        if(!snd) { if(oss_init())snd++; }
#endif

#ifdef DRIVE_HPUX
        if(!snd) { if(hpuxsnd_init())snd++; }
#endif

        if(!snd)
        pwpwrite("* couldn't init sound. going silent.\n");

   }
   else
     pwpwrite("* no sound, as requested\n");
#  endif

   /*** fallbacks - remove? ***/

   if(pwplib.dump_rast==pwplib_dummy && pwplib.dump_attr!=pwplib_dummy)
      pwplib.dump_rast=pwplib_dump_rast_plain;

   /*** timer ***/

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

   /*** hmmm ***/

   if(pwplib.setup[SETUP_HALVE])
      pwplib.videobuf.height<<=1;

     /* only allow if smaller than original? */

   if(pwplib.setup[SETUP_USERHEIGHT])
      pwplib.videobuf.height=pwplib.setup[SETUP_USERHEIGHT];
   if(pwplib.setup[SETUP_USERWIDTH])
      pwplib.videobuf.width=pwplib.setup[SETUP_USERWIDTH];

   /*** done ***/
   
#   ifdef DRIVE_VIDEO
   if(!pwplib.setup[SETUP_NOVIDEO])
   {char tmp[100];
   sprintf(tmp,"* pwplib now controls a %d x %d framebuffer\n",
      pwplib.videobuf.width,pwplib.videobuf.height);
   pwpwrite(tmp);
   }
#  endif

   return 1;
}

/************************************/

const char*pwplogo=
"\033[2J\033[H\n"
"   \033[36;46mMMmmmmmmMM\033[0m\n"
"       \033[36;46mMM\033[0m\n"
"    \033[31;41mxxxxxxxxxxxx\033[0m\n"
"    \033[31;41mxxxxxxxxxxxxxxxxxxx\033[0m\n"
"   \033[31;41mxxxxxxxxx\033[0m\n"
"   \033[33;43mZZZZZ\033[34;44m....\033[0m        %%%%%%%%%  %%%        %%%  %%%%%%%%%\n"
"  \033[37;47m@@@@\033[34;44m......\033[0m        %%%%%%%%%. %%%....... %%%. %%%%%%%%%....\n"
"  \033[37;47m@@@@\033[34;44m....\033[37mo\033[34m.\033[0m   .....%%%   %%%  %%%   %%%  %%%  %%%   %%%\n"
" \033[37;47m@@@@@@@\033[34;44m....\033[0m        %%%   %%%  %%%   %%%  %%%  %%%   %%%\n"
" \033[37;47m@@@@@@@@@@@\033[0m        %%%%  %%%  %%%   %%%  %%%  %%%%  %%%\n"
" \033[37;47m@@@@@@@@@@@@@\033[0m      %%%%  %%%  %%%   %%%  %%%  %%%%  %%%\n"
" \033[37;47m@@@@@@@@@@@@@@@\033[0m    %%%%%%%%%  %%%   %%%  %%%  %%%%%%%%%\n"
"  \033[37;47m@@@@\033[0m              %%%%%%%%%  %%%   %%%  %%%  %%%%%%%%%\n"
"  \033[37;47m@@@@@@\033[0m            %%%        %%%%% %%%  %%%  %%%\n"
"  \033[37;47m@@@@@@@@@@\033[0m  \033[31;41mxx\033[0m    %%%        %%%%% %%%  %%%  %%%\n"
"  \033[37;47m@@@@@@@@@@@@@@\033[0m    %%%        %%%%% %%%% %%%  %%%\n"
"   \033[37;47m@@@@@@@@@@@\033[0m      %%%        %%%%% %%%% %%%  %%%\n"
"   \033[37;47m@@@@@@@@@\033[0m   .....%%%....... %%%%%%%%%%%%%%. %%%..........\n"
"     \033[37;47m@@@@@\033[0m          %%%        %%%%%%%%%%%%%%  %%%\n"
"     \033[37;47m@@@@\033[0m\n\n";


void pwplib_startup()
{
  if(!pwplib.setup[SETUP_SHUTUP])
  {
     pwpwrite("starting up.... 2sec delay for ^C");
     sleep(2);
  }

  /* send initstuff? */
}

void pwplib_end()
{
  if(pwplib.setup[SETUP_SHUTUP])return;

  pwplib_shutdown();
  sleep(2);

  fputs(pwplogo,stderr);
  pwpwrite("shutting down multimedia subsystems\n"  
           "operation finished - support pwp\n\n\n");
}

/***************************************************************/

int pwplib_init(int argc,char**argv)
{
   int i=0,quit=0;

   pwplib.argc=argc;
   pwplib.argv=argv;

   pwplib_getopts();

   if(pwplib.setup[SETUP_WANTHELP])
   {
      printhelp();
      exit(0);
      pwplib.setup[SETUP_SHUTUP]++;
   }

   if(!pwplib.setup[SETUP_SHUTUP])
   {
      fputs(pwplogo,stderr);
      pwpwrite("pwplib " PWPLIB_VERSION " initializing..\n\nrun with --help for some options\n\n");
   }
   
   {char buf[40];
    sprintf(buf,"* using locale '%s'\n",pwplib.set.lang);
    pwpwrite(buf);
   }

   if(!pwplib_initcore())
   {
      pwpwrite("initialization failed!\n");
      return 0;
   }

   if(pwplib.setup[SETUP_WANTHELP])
      return 0;

   return 1;
}
