#include <stdio.h>
#include <stdlib.h>

#include "pwplib.h"

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

void pwpwrite(char*z)
{
  if(!pwplib.setup[SETUP_SHUTUP])
  fprintf(stderr,"%s",z);
}

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

  fputs(pwplogo,stderr);
  pwpwrite("shutting down multimedia subsystems\n"
           "operation finished - support pwp\n\n\n");
}

int pwplib_init(int*argc,char**argv)
{
   int i=0,quit=0;

   pwplib.argc=argc;
   pwplib.argv=argv;

   pwplib.setup[SETUP_VOLUME]=32;
   pwplib.setup[SETUP_NOSOUND]=pwplib.setup[SETUP_NOVIDEO]=0;
   pwplib.setup[SETUP_COLORS]=-1;
   pwplib.setup[SETUP_TRANS]=-1;
   pwplib.setup[SETUP_HALVE]=1;  /* !!! */
   pwplib.setup[SETUP_RASTER]=-1;
   pwplib.setup[SETUP_TTY]=0;
   pwplib.setup[SETUP_BPS]=0;
   pwplib.setup[SETUP_FPS]=0;
   pwplib.setup[SETUP_LOSSY]=0;
   pwplib.setup[SETUP_PVP]=0;
   pwplib.setup[SETUP_SHUTUP]=0;
   pwplib.setup[SETUP_USERHEIGHT]=0;
   pwplib.setup[SETUP_USERWIDTH]=0;

   for(;i<*argc;i++)
   {
     char*s=argv[i];
     while(*s=='-')s++;
     
     switch((int)s[0])
     {
       case('h'):
       
         if(s[2]=='i')
         {
           if(argv[i+1]!=NULL)
           pwplib.setup[SETUP_USERHEIGHT]=atoi(argv[i+1]);
           i++;
         }
         else
       
         printf(
         "usage: %s [options] where options include:\n\n"

         "  help      this text\n"

         "\n"

         "  tty       output in ansi/vt102 codes (stderr)\n"
         "  pvp       output in pwp video phormat (stdout)\n"

         "\n"

         "  nosound   no sound\n"
         "  novideo   no video output\n"
         "  shutup    be quiet - only output the essentials\n"

         "\n"
         
         "  height x  set buffer height (default = fullwindow)\n"
         "  width x   set buffer width (default = fullwindow)\n"
         
         "\n"

         "  volume v  set soft volume to v (numeric, default 32)\n"
         "  colors x  color configuration: 0=16x16, 1=8fg 2=8bg, 3=8x8\n"
         "            8=monochrome, 9=vtattributes\n"
         "  trans n   charset: 1=ibm, 2=ascii, 3=ascii-pure\n"
         "  raster n  raster rendering mode: 0==fg+bg 1=fgonly 2=mono\n"
         "  ascii     pure ascii: no colors, no attributes\n"
         "  nohalve   always use one character cell to represent a pixel\n"

         "\n"

         /* maxfps, minfps */

         "  bps n     fix to n bits per second, no delay\n"
         "  fps n     fix to n frames per second, no delay\n"
         "\n",argv[0]);
         quit=1;
         break;

       case('f'):
         pwplib.setup[SETUP_FPS]=atoi(argv[i+1]);
         i++;
         break;

       case('n'):
         if(s[2]=='s')
           pwplib.setup[SETUP_NOSOUND]++;
          else
         if(s[2]=='v')
           pwplib.setup[SETUP_NOVIDEO]++;
         else
           pwplib.setup[SETUP_HALVE]=0;
         break;

       case('s'):
          pwplib.setup[SETUP_SHUTUP]++;
         break;

       case('b'):
         if(argv[i+1]!=NULL)
         {
           pwplib.setup[SETUP_BPS]=atoi(argv[i+1]);
           i++;
         }break;

       case('v'):
         if(argv[i+1]!=NULL)
         {
           pwplib.setup[SETUP_VOLUME]=atoi(argv[i+1]);
           i++;
         }break;

       case('c'):
         if(argv[i+1]!=NULL)
         {
           pwplib.setup[SETUP_COLORS]=atoi(argv[i+1]);
           i++;
         }break;

       case('a'):
         pwplib.setup[SETUP_TRANS]=3;
         pwplib.setup[SETUP_COLORS]=8;
         pwplib.setup[SETUP_RASTER]=2;
         break;

       case('r'):
         if(argv[i+1]!=NULL)
         {
           pwplib.setup[SETUP_RASTER]=atoi(argv[i+1]);
           i++;
         }break;

       case('t'):
         if(s[1]=='r')
         {
           if(argv[i+1]!=NULL)
           {
             pwplib.setup[SETUP_TRANS]=atoi(argv[i+1]);
             i++;
           }
         }else pwplib.setup[SETUP_TTY]++;
         break;

       case('l'):
         pwplib.setup[SETUP_LOSSY]++;
         break;
       
       case('w'):
       {
         if(argv[i+1]!=NULL)
         pwplib.setup[SETUP_USERWIDTH]=atoi(argv[i+1]);
         i++;
       }break;
     }
   }
   if(quit)return 0;
   
   fprintf(stderr,"ok\n");
   
   if(!pwplib.setup[SETUP_SHUTUP])
   {
      fputs(pwplogo,stderr);
      pwpwrite("pwplib " PWPLIB_VERSION" initializing ........\n");
   }

   if(!pwplib_initcore())
   {
      pwpwrite("initialization failed!\n");
      return 0;
   }

   return 1;
}
