#include "pwpdemo.h"

#include "font.h"

void writetext(char*txt,unsigned char*font)
{
   int wdt=0;

   int z=*txt-'A',a;

   while(z)
   {
      if(*font==0)z--;
      font++;
   }
   while((a=*font))
   {          
      char*d=   
      for(;a;a>>=1)
      {
         d+=
      }
   }
}
