#include "Video.h"
#include "Error.h"
#include "Timer.h"
#include <string.h>

Bitmap *screen;
int quitrequest=0;
int keydown=0;

#include "DD.h"

void videoInit(int w,int h)
{
  screen = new Bitmap(w,h*2/4);
  ddInit(w,h);
}

void videoDeinit()
{
  if(screen) delete screen;
  screen = 0;
  ddDeinit();
}

void videoRefresh()
{
  int w,h,bpl,bpp;
  char *d,*s=(char *)screen->data[0];

  ddLockScreen(w,h,bpl,bpp,(void **)&d);

  h=h*2/4;
  d+=(h/6)*bpl;

  switch(bpp) 
  {
    case 32:
      _asm
      {
        mov edi,d   
        mov esi,s

        mov eax,w
        shl eax,2
        mov ebx,bpl
        sub ebx,eax

        mov eax,w

        mov ecx,h
          l0:
          mov edx,ecx
          mov ecx,eax
          rep movsd
          add edi,ebx

          mov ecx,edx
          loop l0
      }
      break;

    case 16:
      { // Ei jaksa nyt asmia s‰‰t‰‰
        int b=bpl-(w)*2,*so=(int *)s;
        
        for(int y=0;y<h;y++)
        {
          for(int x=0;x<w;x++)
          {
            short *de=(short *)d;
            *(de)=((*so>>8)&0xF800) + ((*so>>5)&0x07E0) + ((*(so++)>>3)&0x001F);
            d+=2;
          }
          d+=b;
        }
      }
      break;
  }
  ddUnlockScreen();
  ddSync();
}