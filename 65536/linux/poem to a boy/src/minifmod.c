/*  =========================================================================== */
/*  MiniFMOD test player */
/*  Copyright (c), Firelight Multimedia, 2000. */
/*  =========================================================================== */
/*  fscked up for `fylltro' */


#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#include "module.h"
#include "minifmod.h"
#include "cdebug.h"

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

  /*  Initialize */
  if (!FSOUND_Init(44100, 0))
  {
    dprint("fmod: Error upon initialization.\n");
    exit(1);
  }

  /*  Load song */
  mod = FMUSIC_LoadSong(MODULE_DATA, NULL);
  if (!mod)
  {
    FSOUND_Close();
    dprint("fmod: Error loading song\n");
    exit(1);
  }

  /*  Play song */
  FMUSIC_PlaySong(mod);

  return mod;
}
