/*  SD_MIX.H

by yzi/fit 1997, 1998

versio 0.01.9873459879827934879578




changes: 08.05.1997
         0.10 - this finally works
              - added MIX_LARGESTBLOCK

         29.04.1997
         0.01 - everything is new

*/


#ifndef SD_MIX_H
#define SD_MIX_H

/* Tämä! */
#ifndef MIX_LARGESTBLOCK
#define MIX_LARGESTBLOCK 10240
#endif

#include "sd_main.h"

void sd_mix_stereo (signed short *dest, int length, int to16bit);
void sd_mix_mono (unsigned char *dest, int length, int to16bit);
void sd_mix_init (int rate);
void sd_mix_setfunctions ();

extern int sd_mix_interpolation;
extern int sd_mix_rate;

#endif
