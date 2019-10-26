/*****************************************************************************
                                  ATTENTION!
                           this source is VOTEWARE,
              you may only use it to the conditions listed below:

  -You may modify it, or use parts of it in your own source as long as
    this header stays on top of all files containing this source.
  -You must give proper credit to the author, Niklas Beisert / pascal.
  -You may not use it in commercial productions without the written
    permission of the author.
  -AND MOST IMPORTANT: you have to buy an Assembly '94 CD-ROM
    by Sound Solutions (if you don't have it already) and vote for VEX-InTrO
    in the PC-64k-Intro-Compo! (if you have already sent your voting card,
    buy another one and fill it out CORRECTLY!!!)
*****************************************************************************/



// merge 2 4-color tgas for crossfade

#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>

void main()
{
  unsigned char *buf=new unsigned char [64000];
  unsigned char *buf2=new unsigned char [64000];
  if (!buf||!buf2)
    return;
  int f=open("asscont.tga", O_RDONLY|O_BINARY);
  lseek(f, 18+768, SEEK_SET);
  read(f, buf, 64000);
  close(f);
  f=open("pdpres.tga", O_RDONLY|O_BINARY);
  lseek(f, 18+768, SEEK_SET);
  read(f, buf2, 64000);
  close(f);
  long i;
  for (i=0; i<64000; i++)
    buf2[i]|=buf[i]<<2;
  f=open("pdpres.scr", O_WRONLY|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
  write(f, buf2, 64000);
  close(f);
}
