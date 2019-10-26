//
// TinyPTC by Gaffer
// www.gaffer.org/tinyptc
//

#include "tinyptc.h"

#define WIDTH 320
#define HEIGHT 200
#define SIZE WIDTH*HEIGHT
   
static int noise;
static int carry;
static int index;
static int seed = 0x12345;
static int pixel[SIZE];

int main()
{
    if (!ptc_open("test",WIDTH,HEIGHT)) return 1;
    while (1)
    {
        for (index=0; index<SIZE; index++)
        {
            noise = seed;
            noise >>= 3;
            noise ^= seed;
            carry = noise & 1;
            noise >>= 1;
            seed >>= 1;
            seed |= (carry << 30);
            noise &= 0xFF;
            pixel[index] = (noise<<16) | (noise<<8) | noise;
        }
        ptc_update(pixel);
    }
}
