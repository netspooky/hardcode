#define DEBUG

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#ifdef DEBUG
#include <math.h>
#endif

#include "savexi.h"

static inline void sc(char *dst, const char *src)
{
  while(*src)
    *dst++=*src++;

}

static void initWAV(WAV *wav)
{
  sc(wav->name, "RIFF");
  sc(wav->type, "WAVE");

  sc(wav->fmt.name, "fmt ");
  wav->fmt.length=0x10;
  wav->fmt.type=WAVfmtMono;
  wav->fmt.channels=1;
  wav->fmt.rate=44100;
  wav->fmt.bitsPerSample=16;
  wav->fmt.bytesPerSample=2;
  wav->fmt.bytesPerSecond=wav->fmt.rate * wav->fmt.bytesPerSample;

  sc(wav->data.name, "data");
}

static int loadxi(const char *filename, XI *xi)
{
  int ret=0;

  FILE *f=fopen(filename, "rb");
  if(f==0)
  {
    fprintf(stderr, "could not open %s\n", filename);
    return -1;
  }

  int r=fread(xi, 1, sizeof(XI), f);
  if(r!=sizeof(XI))
  {
    fprintf(stderr, "could not read header\n");
    ret=-1;
  }

  if(fclose(f) < 0)
    fprintf(stderr, "could not close file\n");

  return ret;
}


int savexi(const char *filename, const char *insname, const signed short *buf, const int len)
{
  char fn[_MAX_PATH];
  strcpy(fn, filename);
  strcat(fn, ".wav");

  WAV wav;
  initWAV(&wav);

  wav.data.length=2*len;
  wav.length=WAVheaderLen+2*len;

  FILE *f=fopen(fn, "wb");
  if(f==0)
  {
    fprintf(stderr, "could not open %s\n", fn);
    return -1;
  }

  int w=fwrite(&wav, 1, sizeof(WAV), f);
  if(w<sizeof(WAV))
  {
    fprintf(stderr, "could not write header of %s\n", fn);
    fclose(f);
    return -1;
  }

  w=fwrite(buf, 2, len, f);
  if(w<len)
  {
    fprintf(stderr, "could not write data of %s\n", fn);
    fclose(f);
    return -1;
  }

  if(fclose(f) < 0)
    fprintf(stderr, "could not close %s\n", fn);

  //////////////////////////////////////////////////////////////////////////

  // calc the delta values
  signed short *buf2=new signed short[len];
  if(buf2==0)
  {
    fprintf(stderr, "not enough memory to convert to delta\n");
    return -1;
  }

  *buf2=*buf;
  for(int i=1; i<len; i++)
    buf2[i]=buf[i]-buf[i-1];

  strcpy(fn, filename);
  strcat(fn, ".xi");

  XI xi;
  if(loadxi(dummyXI, &xi) < 0)
  {
    fprintf(stderr, "could not load default XI %s\n", dummyXI);
    delete [] buf2;
    return -1;
  }

  xi.sample.loopStart=xi.sample.loopLength=0;
  xi.sample.length=(unsigned long)2*len;
  xi.sample.type=0x10;
  xi.sample.note=17;
  xi.sample.finetune=-27;
  xi.sample.volume=0x40;
	xi.sample.panning=0x80;
  xi.instrument.sampleNum=1;

	sc(xi.header.name,insname);

  f=fopen(fn, "wb");
  if(f==0)
  {
    fprintf(stderr, "could not open %s for output\n", fn);
    delete [] buf2;
    return -1;
  }

  w=fwrite(&xi, 1, sizeof(XI), f);
  if(w<sizeof(XI))
  {
    fprintf(stderr, "could not write header into %s\n", fn);
    fclose(f);
    delete [] buf2;
    return -1;
  }

  w=fwrite(buf2, 2, len, f);
  if(w<len)
  {
    fprintf(stderr, "could not write sample data into %s\n", fn);
    fclose(f);
    delete [] buf2;
    return -1;
  }

  if(fclose(f) < 0)
    fprintf(stderr, "could not close %s\n", fn);

  delete [] buf2;
  return 0;
}