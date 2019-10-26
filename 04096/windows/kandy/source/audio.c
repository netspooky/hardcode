/* -*- Mode: C++; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/*
 * Renders the audio to a buffer and saves it as a PCM .wav file.
 *
 * Author:
 *  s_tec
 */

#include <stdio.h>

void _synth_init();
void _synth_write(short *data, unsigned size);

/* Windows SDK stuff: */
#define DWORD unsigned long int
#define WORD unsigned short int
#define BYTE unsigned char
#define WAVE_FORMAT_PCM 1
typedef struct { 
  WORD  wFormatTag;
  WORD  nChannels;
  DWORD nSamplesPerSec;
  DWORD nAvgBytesPerSec;
  WORD  nBlockAlign;
  WORD  wBitsPerSample;
  /*WORD  cbSize;*/
} WAVEFORMATEX; 

/* Wave file format: */
typedef struct {
  BYTE	        riff[4];        /* "RIFF" */
	DWORD	        filesize;       /* Total file size */
	BYTE	        wave[4];        /* "WAVE" */
	BYTE	        fmt_[4];        /* "fmt " */
	DWORD	        formatsize;     /* Format data size */
	WAVEFORMATEX  format;         /* Audio data format */
	BYTE	        data[4];	      /* "data" */
	DWORD	        datasize;       /* Audio data size */
} WAVEHEADER;

/**
 * Program body
 */
int main()
{
  const chan = 1;
  const bits = 16;
  const align = chan * bits / 8;
  const sps = 44100;
  const size = 44100 * 120;

  WAVEHEADER header = {
    "RIFF",
    sizeof(WAVEHEADER) + size * align,
    "WAVE",
    "fmt ",
    sizeof(WAVEFORMATEX),
    {
      WAVE_FORMAT_PCM,
      chan,
      sps,
      sps * align,
      align,
      bits
    },
    "data",
    size * align
  };
  
  short data[size];

  printf("Generating audio... ");
  
  _synth_init();
  _synth_write(data, size * align);

  FILE *file = fopen("audio.wav", "wb");
  fwrite(&header, sizeof(WAVEHEADER), 1, file);
  fwrite(&data, size, align, file);
  fclose(file);

  printf("Done.\n");
  return 0;
}
