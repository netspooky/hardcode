/*  sd_dsp16.c

by yzi/fit 1997 + Marq 1998

versio 0.01

changes: 29.04.1997
         0.01 - everything is new
         2.9.2002: Some minor cleaning for SDL
*/

#include <SDL/SDL.h>
#include <stdio.h>
#include <stdlib.h>

#include "sd_main.h"
#include "sd_dsp16.h"
#include "sd_mix.h"

#define	dsp16_hand sd_hand

static int basefreq=DSP16_MAXRATE;

static SDL_AudioSpec wanted;

extern void mix_newhand(void *udata, Uint8 *stream, int len);

void dsp16_init()
{
        sd_mix_init(basefreq);
}

int dsp16_initcard(int freq)
{
	basefreq = freq;
	wanted.freq = freq;
	if(freq<44100)
	        wanted.format = AUDIO_U8;
	else
	        wanted.format = AUDIO_S16SYS;

        wanted.channels = 1;    /* 1 = mono, 2 = stereo */
#ifndef BUFSIZE
#define BUFSIZE 2048
#endif
        wanted.samples = BUFSIZE;
        wanted.callback = mix_newhand;
        wanted.userdata = NULL;

	if(SDL_OpenAudio(&wanted,NULL)<0)
		return(0);
	
	return(1);
}

void dsp16_dummyfunction()
{
}

void dsp16_playsample(int dmabuf, int dmabuflen)
{
}

void dsp16_start()
{
}

void dsp16_stop()
{
}

void dsp16_shutdown()
{
	SDL_CloseAudio();
}

int sd_dsp16_detect (int *base, int *irq, int *dma)
{
        return (SD_OK);
}

/* No, they are NOT base address, IRQ or DMA with SDL */
int sd_dsp16_init (int base, int irq, int dma)
{
        if (!dsp16_initcard(base))
        {
                sd_errorstr = "SDL audio error";
                return SD_ERR;
        }

        /* Asetellaan funktiot */
        sd_init = dsp16_init;

        sd_secondhand = dsp16_dummyfunction;
        sd_start = dsp16_start;
        sd_stop = dsp16_stop;
        sd_shutdown = dsp16_shutdown;

        sd_mix_setfunctions(); /* Mikseri asettelee omat funktionsa. */

        sd_devicename = "SDL audio";

	return SD_OK;
}
