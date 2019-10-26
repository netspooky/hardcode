/*  =========================================================================== */
/*  MiniFMOD test player */
/*  Copyright (c), Firelight Multimedia, 2000. */
/*  =========================================================================== */
/*  fscked up for `flause' */

#ifndef CHEAP
#include <stdio.h>
#endif
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#include "module.h"
#include "minifmod.h"

volatile unsigned long int written;
unsigned int memopen(char *na);
void memclose(unsigned int handle);
int memread(void *buffer, int size, unsigned int handle);
void memseek(unsigned int handle, int pos, signed char mode);
int memtell(unsigned int handle);

typedef struct
{
  int length;
  int pos;
  void *data;
}
MEMFILE;

unsigned int memopen(char *na)
{
  MEMFILE *memfile;
  if ((memfile = (MEMFILE *)calloc(sizeof(MEMFILE),1))) { 
    memfile->data = &MODULE_DATA;
    memfile->length = sizeof(MODULE_DATA);
    memfile->pos = 0;
  }
  return((unsigned int)memfile);
}

void memclose(unsigned int handle)
{
  MEMFILE *memfile = (MEMFILE *)handle;
/*   free(memfile->data); */
  free(memfile);
}

int memread(void *buffer, int size, unsigned int handle)
{
  MEMFILE *memfile = (MEMFILE *)handle;

  if (memfile->pos + size >= memfile->length)
    size = memfile->length - memfile->pos;

  memcpy(buffer, (char *)memfile->data+memfile->pos, size);
  memfile->pos += size;

  return(size);
}

void memseek(unsigned int handle, int pos, signed char mode)
{
  MEMFILE *memfile = (MEMFILE *)handle;

  if (mode == SEEK_SET)
    memfile->pos = pos;
  else if (mode == SEEK_CUR)
    memfile->pos += pos;
  else if (mode == SEEK_END)
    memfile->pos = memfile->length + pos;

  if (memfile->pos > memfile->length)
    memfile->pos = memfile->length;
}

int memtell(unsigned int handle)
{
  MEMFILE *memfile = (MEMFILE *)handle;
  return(memfile->pos);
}


FMUSIC_MODULE *fmod_init()
{
  FMUSIC_MODULE *mod;
  FSOUND_File_SetCallbacks(memopen, memclose, memread, memseek, memtell);
  written = 0;
#ifndef CHEAP
  fprintf(stderr,"fmod_init\n");
  fprintf(stderr,"MiniFMOD XM player.\n");
  fprintf(stderr,"Copyright (c) Firelight Multimedia, 2000.\n");
#endif

  /*  Initialize */
  if (!FSOUND_Init(44100, 0))
  {
#ifndef CHEAP
    fprintf(stderr,"fmod: Error upon initialization.\n");
#endif
    exit(1);
  }

  /*  Load song */
  mod = FMUSIC_LoadSong(MODULE_DATA, NULL);
  if (!mod)
  {
    FSOUND_Close();
#ifndef CHEAP
    fprintf(stderr,"fmod: Error loading song\n");
#endif
    exit(1);
  }

  /*  Play song */
  FMUSIC_PlaySong(mod);
/* SHUTDOWN 
  FMUSIC_StopSong(mod);
  FMUSIC_FreeSong(mod);
  FSOUND_Close();
  */

  return mod;
}
