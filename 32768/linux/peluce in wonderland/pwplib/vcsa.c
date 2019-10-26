#include "config.h"

#ifdef DRIVE_VCSA

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/stat.h>
#include <sys/ioctl.h>
#include <linux/kd.h>

#include "pwplib.h"

/******************** vcsa code ********************/

struct{
   int fd;
   int width,height;
}pwp_vcsa;

void vcsa_dump()
{
   char*buf=pwplib.videobuf.d;
   int ptr=4+pwp_vcsa.width*
           ((pwp_vcsa.height-pwplib.videobuf.height)&~1);
   if(ptr<4)ptr=4;

   if(pwp_vcsa.width==pwplib.videobuf.width)
   {
      lseek(pwp_vcsa.fd,ptr,SEEK_SET);
      write(pwp_vcsa.fd,buf,
            pwplib.videobuf.width*pwplib.videobuf.height*2);
   }else
   {
      int y=0,y1=pwplib.videobuf.height,w=pwplib.videobuf.width;
      ptr+=((pwp_vcsa.width-pwplib.videobuf.width)&~1);
      if(y1>pwp_vcsa.height)y1=pwp_vcsa.height;
      if(w>pwp_vcsa.width)w=pwp_vcsa.width;
      w<<=1;
      for(;y<y1;y++)
      {
         lseek(pwp_vcsa.fd,ptr,SEEK_SET);
         write(pwp_vcsa.fd,buf,w);
         buf+=pwplib.videobuf.width*2;
         ptr+=pwp_vcsa.width*2;
      }
   }

   pwplib.timer_counter+=pwp_vcsa.width*pwp_vcsa.height*2;
}

int vcsa_get()
{
   int vcsa;
   int majmin;

   { struct stat sbuf;
     int stderr2=dup(fileno(stderr));
     fstat(stderr2,&sbuf);
     majmin=sbuf.st_rdev;
     close(stderr2);
   }

   if((majmin&~0x63)==4*256)
   {
      char buf[20];
      sprintf(buf,"/dev/vcsa%i",majmin&63);
      vcsa=open(buf,O_RDWR);
      if(vcsa>=0)return vcsa;
   }
   vcsa=open("/dev/vcsa",O_RDWR);
   if(vcsa>=0)return vcsa;

   return -1;
}

int vcsa_init() /* init vcsa device */
{
   unsigned char vcsahdr[4];
   int vcsa=vcsa_get();
   if(vcsa<0)return 0;

   read(vcsa,vcsahdr,4);
   pwp_vcsa.fd=vcsa;
   pwplib.videobuf.height=pwp_vcsa.height=vcsahdr[0];
   pwplib.videobuf.width=pwp_vcsa.width=vcsahdr[1];

   {char tmp[100];
    sprintf(tmp,"\rlinux console device (/dev/vcsa) - size %i x %i\n",
      pwp_vcsa.width,pwp_vcsa.height);
    pwpwrite(tmp);}

   if(pwplib.setup[SETUP_TRANS]<0)pwplib.setup[SETUP_TRANS]=0;
   if(pwplib.setup[SETUP_COLORS]<0)pwplib.setup[SETUP_COLORS]=2;
   if(pwplib.setup[SETUP_RASTER]<0)pwplib.setup[SETUP_RASTER]=0;

   pwplib.dump_ibm=&vcsa_dump;
   return 1;
}

#endif

/*
    optional eliteness for vcsa support:

    colordump: only write to attribute bytes => you can run videos in
    the textmode background while doing something else

*/
