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



// calculates a plasma
// wid=1<<(resbit+xabits)
// hgt=1<<(resbit+yabits)
// col=1<<colbits
// roughness=p

void makeplasma(unsigned char *buf, short resbit, short xabits=0, short yabits=0, short colbits=8, short p=500, long seed=0x17091977)
{
  long resx=1<<(xabits+resbit);
  long resy=resx<<(yabits+resbit);
  unsigned short resx1=resx-1;
  unsigned short resy1=resy-resx;
  short colmask=-1<<colbits;

  long mx2=1<<resbit;
  long my2=resx<<resbit;
  long x,y;
  for (x=0; x<resx; x+=mx2)
    for (y=0; y<resy; y+=my2)
      buf[x+y]=((seed=0x015a4e35*seed+1)>>16)&~colmask;
  short k;
  for (k=0; k<resbit; k++)
  {
    unsigned short mx=mx2>>1;
    unsigned short my=my2>>1;
    for (y=0; y<resy; y+=my2)
      for (x=0; x<resx; x+=mx2)
      {
        short c=((unsigned short)buf[x+y]+buf[x+((y+my2)&resy1)]+buf[((x+mx2)&resx1)+y]+buf[((x+mx2)&resx1)+((y+my2)&resy1)]+2+((((seed=0x015a4e35*seed+1)>>16)*(p*3))>>17))>>2;
        buf[x+mx+y+my]=c&colmask?c&0x8000?0:~colmask:c;
      }
    for (y=0; y<resy; y+=my2)
      for (x=0; x<resx; x+=mx2)
      {
        short c=((unsigned short)buf[((x-mx)&resx1)+y+my]+buf[x+y]+buf[x+mx+y+my]+buf[x+((y+my2)&resy1)]+2+((((seed=0x015a4e35*seed+1)>>16)*p)>>16))>>2;
        buf[x+y+my]=c&colmask?c&0x8000?0:~colmask:c;
      }
    for (y=0; y<resy; y+=my2)
      for (x=0; x<resx; x+=mx2)
      {
        short c=((unsigned short)buf[x+y]+buf[x+mx+((y-my)&resy1)]+buf[((x+mx2)&resx1)+y]+buf[x+mx+y+my]+2+((((seed=0x015a4e35*seed+1)>>16)*p)>>16))>>2;
        buf[x+mx+y]=c&colmask?c&0x8000?0:~colmask:c;
      }
    mx2=mx;
    my2=my;
    p>>=1;
  }
}
