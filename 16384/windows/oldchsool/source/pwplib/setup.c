#include "config.h"
#include "pwplib.h"

#define DESTRUCTORS 8

/******************** random stuff *************************/

void pwplib_dummy(){}
#define pwp_dummy pwplib_dummy

void pwplib_dump_rast_plain()
{
   TEMPMALL(u8,tmp,pwplib.videobuf.width*pwplib.videobuf.height*2);
   u8
      *d=tmp,
      *parentbuf=pwplib.videobuf.d,
      *s=parentbuf;

   int i=pwplib.videobuf.width*pwplib.videobuf.height;
   
   for(;i;i--)
   {
#ifdef DRIVE_WIN32
      d[0]=176;
#else
      d[0]='%';
#endif
      d[1]=*s++;
      d+=2;
   }

   pwplib.videobuf.d=tmp;
   pwplib.dump_attr();
   pwplib.videobuf.d=parentbuf;

   TEMPFREE(tmp);
}

/********************* timer (unix) ************************/

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

int pwplib_timer()
{
        static int base=-1;int v;
        v=pwplib.timerfunc();
        if(base==-1)base=v;
        return v-base;
}

/********************* destructors, signals etc **********/

void(*pwp_destr[DESTRUCTORS])();

void pwp_regdestr(void(*func)())
{
   static int curr=0;
   pwp_destr[curr++]=func;
   pwp_destr[curr]=NULL;
}

void pwplib_shutdown()
{
   int i=0;

   while(pwp_destr[i]!=NULL)
         pwp_destr[i++]();
}

/******************** initialization *********************/

int pwplib_init_common()
{
   /*** base stuff ***/

   pwplib.sound=
   pwplib.loopflush=
   pwplib.player=
   pwplib.dump_attr=
   pwplib.dump_rast=
   pwplib.prep_attr=
   pwplib.prep_rast=
     pwplib_dummy;

   pwp_destr[0]=NULL;
}

/***********************************************/

void rmarg(int*argc,char**argv,int n)
{
   while(n<*argc)
   {
      argv[n]=argv[n+1];
      n++;
   }
   (*argc)--;
}

/*********************************************************************/

#define ARGC pwplib.argc
#define ARGV pwplib.argv
int getopts(optab*argin)
{
   int i=0;
   
   {optab*s0=argin;
    while(s0->name!=NULL)
    {
       *(s0->var)=s0->dflt;
       s0++;
    }
   }

   for(i=0;i<ARGC;)
   {
      int j=0;
      
      int match=0,wh=-1,lev=0,m=0;

      while(argin[j].name!=NULL)
      {
         char*s1=argin[j].name;
         char*s0=ARGV[i];
         int ngl=0,m=0;

         while(*s0)
         {
            if(*s0=='-')
               ngl=0;
            else
            if(*s0=='+')
               ngl=1;
            else
            {
               m++;
               if(*s0=='\0' || *s1=='\0')break;
                 else
               if((*s0|32)!=*s1)
               {
                  m=0;
                  break;
               }
               s1++;
            }
            s0++;
         }

         if(m>match)
         {
            match=m;
            lev=ngl;
            wh=j;
         }
         j++;
      }
      
      if(wh>=0)
      {
        rmarg(&ARGC,ARGV,i);
      
        switch((int)argin[wh].type)
        {
           case(OPT_BIN):
              *((int*)(argin[wh].var))=lev;
              break;

           case(OPT_NOT):
              *((int*)(argin[wh].var))=1-lev;
              break;

           case(OPT_ONE):
              *((int*)(argin[wh].var))=1;

           case(OPT_INT):
              if(ARGV[i]!=NULL)
              {
                 *((int*)(argin[wh].var))=atoi(ARGV[i]);
                 rmarg(&ARGC,ARGV,i);
              }
              break;
         
           case(OPT_STRING):
              if(ARGV[i]!=NULL)
              {
                 *((char**)(argin[wh].var))=strdup(ARGV[i]);
                 rmarg(&ARGC,&ARGV,1);
              }
              break;
        }
      }
       else i++;
   }
}
#undef ARGC
#undef ARGV

/************************************/

optab main_init[]=
{
   /* stuph */
   "help",   OPT_ONE,(void*)0,(void*)&pwplib.setup[SETUP_WANTHELP],
   "shutup", OPT_ONE,(void*)0,(void*)&pwplib.setup[SETUP_SHUTUP],
   "infodelay",OPT_INT,(void*)100,(void*)&pwplib.set.infodelay,

   /* general */
   "nosound",OPT_ONE,(void*)0,(void*)&pwplib.setup[SETUP_NOSOUND],
   "novideo",OPT_ONE,(void*)0,(void*)&pwplib.setup[SETUP_NOVIDEO],

   /* video */
   "term",   OPT_STRING,(void*)NULL,(void*)&pwplib.set.term,
   "lang",   OPT_STRING,(void*)NULL,(void*)&pwplib.set.lang,
   "tty",    OPT_BIN,(void*)0,(void*)&pwplib.setup[SETUP_TTY], /* obsolete? */
   "pvp",    OPT_BIN,(void*)0,(void*)&pwplib.setup[SETUP_PVP],

   /* size */
   "height", OPT_INT,(void*)0,(void*)&pwplib.setup[SETUP_USERHEIGHT],
   "width",  OPT_INT,(void*)0,(void*)&pwplib.setup[SETUP_USERWIDTH],

   /* conversion */
   "trans",  OPT_INT,(void*)-1,(void*)&pwplib.setup[SETUP_TRANS],
   "colors", OPT_INT,(void*)-1,(void*)&pwplib.setup[SETUP_COLORS],
   "raster", OPT_INT,(void*)-1,(void*)&pwplib.setup[SETUP_RASTER],
   "halve",  OPT_BIN,(void*)1,(void*)&pwplib.setup[SETUP_HALVE],

   /* tty-etc stuff */
   "fps",    OPT_INT,(void*)0,(void*)&pwplib.setup[SETUP_FPS],
   "bps",    OPT_INT,(void*)0,(void*)&pwplib.setup[SETUP_BPS],
   "minfps", OPT_INT,(void*)0,(void*)&pwplib.setup[SETUP_MINFPS],
   "maxfps", OPT_INT,(void*)256,(void*)&pwplib.setup[SETUP_MAXFPS],
   "lossy",  OPT_BIN,(void*)0,(void*)&pwplib.setup[SETUP_LOSSY],
   "fdelay", OPT_INT,(void*)0,(void*)&pwplib.set.framedelay,
   "fbytes", OPT_INT,(void*)500,(void*)&pwplib.set.framebytes,

   /* audio options */
   "audev",  OPT_STRING,(void*)NULL,(void*)&pwplib.set.audev,
   "volume", OPT_INT,(void*)32,(void*)&pwplib.setup[SETUP_VOLUME],

   NULL,0,NULL,NULL
};

void printhelp()
{
         printf(
         "usage: %s [options] where options include:\n\n"

         "  help      this text\n"

         "\n"

         "  shutup    be quiet - only output the essentials\n"
         "  term s    set terminal type to s (e.g. xterm-color, vt100, ansi)\n"
         "  lang s    set locale/language to s (e.g. en, fi)\n"
         "  pvp       output in pwp video phormat (stdout)\n"

         "\n"

         "  nosound   no sound\n"
         "  novideo   no video output\n"

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

         "  fbytes n  bytes/frame threshold (optimize frame if exceeded)\n"
         "  fdelay n  delay after each frame (milliseconds)\n"

         "\n"

         "  bps n     non-rt: fix to n bits per second, no delay\n"
         "  fps n     non-rt: fix to n frames per second, no delay\n"
         "\n",pwplib.argv[0]);
}

void pwplib_getopts()
{
   getopts(main_init);

   if(pwplib.set.lang==NULL)
      pwplib.set.lang=pwp_get_locale();
}

