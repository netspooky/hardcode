#include <stdio.h>
#include <stdlib.h>
#include "../pwplib/pwplib.h"

char setup_english=0;

extern void playtick();

int main(int argc,char**argv)
{
   if(!pwplib_init(&argc,argv))return 1;

   pwpwrite("final isi (1st at abduction '98 pc introcompo)\n");

   pwplib.videobuf.width=80;
   pwplib.videobuf.height=50;
   
   if(!pwplib.setup[SETUP_NOSOUND])
      pwplib.player=playtick;

   precalx();
   
   pwpwrite(setup_english?"using the english language\n"
                         :"puhumme suomea\n");

   pwplib_startup();
   
   demoloop();
   
   timer_off();

   pwplib_end();

   return 0;
}
