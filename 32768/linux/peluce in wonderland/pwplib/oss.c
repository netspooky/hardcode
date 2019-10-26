#include "config.h"

#ifdef DRIVE_OSS

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#include <linux/soundcard.h>

#include "pwplib.h"

#define TIMERHZ 72

struct{
   int fd;
   char buf[4096];
   int buflgt;
   int freq;
}pwp_oss;

extern void gb_sound(int,int,int);

void oss_loopflush()
{
  for(;;)
  {audio_buf_info bi;ioctl(pwp_oss.fd,SNDCTL_DSP_GETOSPACE,&bi);
    if(bi.fragments==1)break;
    pwplib.player();
    gb_genwave(pwp_oss.buf,pwp_oss.buflgt);
    write(pwp_oss.fd,pwp_oss.buf,pwp_oss.buflgt);
    if(bi.fragments<3)break;
  }
}

int oss_init()
{
  pwp_oss.fd=open("/dev/dsp",O_WRONLY);
  if(pwp_oss.fd<0)return 0;

  pwpwrite("OSS compatible sound\n");

  pwp_oss.freq=8000;
  pwp_oss.buflgt=pwp_oss.freq/TIMERHZ;

  pwplib.sound=gb_sound;
  pwplib.loopflush=oss_loopflush;
  gb_init(pwp_oss.freq);

  return 1;
}
#endif
