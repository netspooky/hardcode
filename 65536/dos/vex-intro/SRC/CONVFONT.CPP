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



// convert the tga font piccy to an internal format

#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>

void main()
{
  unsigned char *buf=new unsigned char [64000];
  short f=open("hooks.tga", O_RDONLY|O_BINARY);
  lseek(f, 18+768, SEEK_SET);
  read(f, buf, 64000);
  close(f);
  unsigned short i, j;

  f=open("hooks.fnt", O_WRONLY|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
  for (i=0; i<20; i++)
    for (j=0; j<4; j++)
      write(f, buf+i*320+j*20*320, 256);
  close(f);
}
