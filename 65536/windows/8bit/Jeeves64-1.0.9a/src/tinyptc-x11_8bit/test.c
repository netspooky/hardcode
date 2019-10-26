/*
   TinyPTC by Gaffer
   www.gaffer.org/tinyptc
*/

#include "tinyptc.h"

#include "stdio.h"

#define WIDTH 320
#define HEIGHT 200
#define SIZE WIDTH*HEIGHT
   
typedef unsigned char peli;

static int noise;
static int carry;
static int seed = 0x12345;
static int i;
static peli pal[0x300];
static peli pixel[SIZE];

int main()
{
    if (!ptc_open("test",WIDTH,HEIGHT)) return 1;

    for(i=0; i<0x100; i++)
      {
        pal[i*3+0] = i;
        pal[i*3+1] = i;
        pal[i*3+2] = i;
      }

    if(!ptc_setpal(pal)) return 1;

    while (1)
    {
      int x;
      int y;
      for(y=0; y<(HEIGHT>>1); y++)
        for(x=0; x<WIDTH; x++)
        {
            noise = seed;
            noise >>= 3;
            noise ^= seed;
            carry = noise & 1;
            noise >>= 1;
            seed >>= 1;
            seed |= (carry << 30);
            noise &= 0xFF;
            pixel[y*WIDTH+x] = noise;
        }

      for(y=(HEIGHT>>1); y<HEIGHT; y++)
        for(x=0; x<WIDTH; x++)
            pixel[y*WIDTH+x] = (x * 0xFF / WIDTH);

      ptc_update(pixel);
    }
}
