#include <stdio.h>
#include <stdlib.h>

#include "pwplib.h"

char* pwp_get_locale()
{
#ifdef __POSIX__
   int lang=0,i=3;
   char*z;

   while(i)
   {
      i--;
      if(i==2)
         z=getenv("LANG");
         else
      if(i==1)
         z=getenv("LC_ALL");
         else
         {
            z=getenv("HOST");
            if(z!=NULL)z+=strlen(z)-2;
         }

      if(z!=NULL)
      {
         if(z[0]=='f' && z[1]=='i')return "fi";
         if(z[0]=='F' && z[1]=='I')return "fi";
      }
   }

   return "en";
#else
   return "fi";
#endif
}

