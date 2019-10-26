#include "config.h"

#ifdef DRIVE_HPUX

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/audio.h>

#include "pwplib.h"

#define TIMERHZ 72

struct{
   int fd;
   char buf[4096];
   int buflgt;
   int freq;
}pwp_hpuxsnd;

extern void gb_sound(int,int,int,int);

void hpuxsnd_loopflush()
{
  for(;;)
  {
    struct audio_status bi;
    ioctl(pwp_hpuxsnd.fd,AUDIO_GET_STATUS,&bi);
    if(bi.transmit_exact_count>3000)break;

    pwplib.player();
    gb_genwave(pwp_hpuxsnd.buf,pwp_hpuxsnd.buflgt);
    write(pwp_hpuxsnd.fd,pwp_hpuxsnd.buf,pwp_hpuxsnd.buflgt);

    if(bi.transmit_buffer_count>6000)break;
  }
}

void hpuxsnd_restore()
{
  close(pwp_hpuxsnd.fd);
}

int hpuxsnd_init()
{
  pwp_hpuxsnd.fd=open("/dev/audio",O_WRONLY);
  if(pwp_hpuxsnd.fd<0)return 0;

    ioctl(pwp_hpuxsnd.fd,AUDIO_SET_TXBUFSIZE,2048); 
    ioctl(pwp_hpuxsnd.fd,AUDIO_SET_SAMPLE_RATE,8000);
    ioctl(pwp_hpuxsnd.fd,AUDIO_SET_CHANNELS,AUDIO_CHANNEL_0|AUDIO_CHANNEL_1);
    ioctl(pwp_hpuxsnd.fd,AUDIO_SET_DATA_FORMAT,AUDIO_FORMAT_LINEAR8BIT);

  pwpwrite("* HP-UX sound\n");

  pwp_hpuxsnd.freq=8000;
  pwp_hpuxsnd.buflgt=pwp_hpuxsnd.freq/TIMERHZ;

  pwplib.sound=gb_sound;
  pwplib.loopflush=hpuxsnd_loopflush;
  gb_init(pwp_hpuxsnd.freq);

  pwp_regdestr(hpuxsnd_restore);

  return 1;
}
#endif
