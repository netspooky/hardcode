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



// these functions originally read from an packed overlay

#include <io.h>
#include <fcntl.h>

short oopen(const char *name)
{
  return open(name, O_RDONLY|O_BINARY);
}

long oread(short hnd, void *buf, unsigned short len)
{
  return read(hnd, buf, len);
}

long oseek(short hnd, long pos, short type)
{
  return lseek(hnd, pos, type);
}

void oclose(short hnd)
{
  close(hnd);
}
