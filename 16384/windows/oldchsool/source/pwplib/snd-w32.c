#include "config.h"

#ifdef DRIVE_WIN32

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>

#include <windows.h>

#define TIMERHZ 72

#include "pwplib.h"

#define NUMBUFS 2

#define HARDBUFSIZE 65536

struct
{
  int      buffersize;
  HWAVEOUT outHandle;
  WAVEHDR  waveHdr[NUMBUFS];
  char     *bufData[NUMBUFS];
  int      currbuf;
  int      bufferptr;
  int      letsgo;
}
pwp_w32snd;

extern void gb_sound(int,int,int,int);

void win32snd_fill()
{
   while(pwp_w32snd.bufferptr<(HARDBUFSIZE-pwp_w32snd.buffersize))
   {
      pwplib.player();

      gb_genwave(pwp_w32snd.bufData[pwp_w32snd.currbuf] +
                 pwp_w32snd.bufferptr,
                 pwp_w32snd.buffersize);

      pwp_w32snd.bufferptr += pwp_w32snd.buffersize;
   }
  pwp_w32snd.waveHdr[pwp_w32snd.currbuf].lpData =
            pwp_w32snd.bufData[pwp_w32snd.currbuf];
  pwp_w32snd.waveHdr[pwp_w32snd.currbuf].dwBufferLength =
            pwp_w32snd.bufferptr;

  pwp_w32snd.bufferptr=0;

   waveOutPrepareHeader(
      pwp_w32snd.outHandle,
     &pwp_w32snd.waveHdr[pwp_w32snd.currbuf],
      sizeof(WAVEHDR));

   waveOutWrite(
          pwp_w32snd.outHandle,
         &pwp_w32snd.waveHdr[pwp_w32snd.currbuf],
          sizeof(WAVEHDR));

   pwp_w32snd.currbuf=(pwp_w32snd.currbuf+1)%NUMBUFS;
}

static void CALLBACK win32snd_callback(HWAVEOUT hwo,UINT uMsg,
       DWORD dwParam0, DWORD dwParam1, DWORD dwParam2)
{
   if(pwp_w32snd.letsgo==0) return;

/*
   if(pwp_w32snd.waveHdr[pwp_w32snd.currbuf].dwFlags&WHDR_PREPARED)
      waveOutUnprepareHeader(
        pwp_w32snd.outHandle,
       &pwp_w32snd.waveHdr[pwp_w32snd.currbuf],
            sizeof(WAVEHDR));
*/
   win32snd_fill();
}

void win32snd_restore()
{
}

void win32snd_start()
{
   if(pwp_w32snd.letsgo==0)
   {
     {int i=0;
      for(;i<NUMBUFS;i++) win32snd_fill();
     }

     pwp_w32snd.letsgo++;
   }
}

int win32snd_init()
{
   HANDLE bufHandle,waveHdrHandle;
   WAVEFORMATEX waveFormat;

   /************/

   /* try: 8000/8/1, 11025/8/1, 11025/16/1, 22050/16/1, 22050/16/2,
           44100/16/2 */

   waveFormat.wFormatTag = WAVE_FORMAT_PCM;
   waveFormat.nChannels = 1;
   waveFormat.nSamplesPerSec = 22050;
   waveFormat.wBitsPerSample = 8;
   waveFormat.nBlockAlign =
     waveFormat.nChannels * (waveFormat.wBitsPerSample/8);
   waveFormat.nAvgBytesPerSec =
     waveFormat.nSamplesPerSec * waveFormat.nBlockAlign;
   waveFormat.cbSize = 0;

   pwp_w32snd.letsgo=0;

   {int i=0;for(;i<NUMBUFS;i++)
   pwp_w32snd.bufData[i] = malloc(HARDBUFSIZE);
   }

   pwplib.sound=gb_sound;
   gb_init(waveFormat.nAvgBytesPerSec);

   pwp_w32snd.buffersize = waveFormat.nAvgBytesPerSec/TIMERHZ;
   pwp_w32snd.currbuf=0;
   pwp_w32snd.bufferptr = 0;
 
   {int r = waveOutOpen(&pwp_w32snd.outHandle,WAVE_MAPPER,&waveFormat,
                        (DWORD)win32snd_callback,0,
                        CALLBACK_FUNCTION);
    if(r) { printf("ERROR\n"); }
   }

   pwp_regdestr(win32snd_restore);

//   pwp_w32snd.buffersize = waveFormat.nAvgBytesPerSec/TIMERHZ;

   pwplib.loopflush = win32snd_start;

   return 1;
}

#endif

