// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#include <conio.h>

void palSetPal(const unsigned char *pal, int first, int num)
{
  int i;
  num*=3;
  outp(0x3c8,first);
  for (i=0; i<num; i++)
    outp(0x3c9, *pal++);
}

void palFadeBlack(const unsigned char *pal, int first, int num, int pos)
{
  int i;
  num*=3;
  outp(0x3c8,first);
  for (i=0; i<num; i++)
    outp(0x3c9, (*pal++*pos)>>6);
}

void palFadeWhite(const unsigned char *pal, int first, int num, int pos)
{
  int i;
  num*=3;
  outp(0x3c8,first);
  for (i=0; i<num; i++)
    outp(0x3c9, (*pal++*pos+64*63-pos*63)>>6);
}

void palFade2(const unsigned char *pal1, const unsigned char *pal2, int first, int num, int pos)
{
  int i;
  num*=3;
  outp(0x3c8,first);
  for (i=0; i<num; i++)
    outp(0x3c9, (*pal1++*pos + (64-pos)* *pal2++)>>6);
}

void palSetWhiteness()
{
  int i;
  outp(0x3c8,0);
  for (i=0; i<768; i++)
    outp(0x3c9, 63);
}

void palSetBlackness()
{
  int i;
  outp(0x3c8,0);
  for (i=0; i<768; i++)
    outp(0x3c9, 0);
}

void palInterpolCols(unsigned char *pal, int r1, int g1, int b1, int r2, int g2, int b2, int n)
{
  int j;
  for (j=0; j<n; j++)
  {
    *pal++=(j*r2+(n-j)*r1)/n;
    *pal++=(j*g2+(n-j)*g1)/n;
    *pal++=(j*b2+(n-j)*b1)/n;
  }
}

void palMakeBCW(unsigned char *pal, int r, int g, int b, int c, int w)
{
  palInterpolCols(pal, 0, 0, 0, r, g, b, c);
  palInterpolCols(pal+c*3, r, g, b, 63, 63, 63, w);
}
