// ===========================================================================
//  system_file.c
// ---------------------------------------------------------------------------
//  MiniFMOD public source code release.
//  This source is provided as-is.  Firelight Multimedia will not support
//  or answer questions about the source provided.
//  MiniFMOD Sourcecode is copyright (c) 2000, Firelight Multimedia.
//  MiniFMOD Sourcecode is in no way representative of FMOD 3 source.
//  Firelight Multimedia is a registered business name.
//  This source must not be redistributed without this notice.
// ===========================================================================

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "minifmod.h"
#include "system_file.h"
#include "system_memory.h"
#include "sound.h"


unsigned int (*FSOUND_File_OpenCallback)(char *name) = NULL;
void (*FSOUND_File_CloseCallback)(unsigned int handle) = NULL;
int (*FSOUND_File_ReadCallback)(void *buffer, int size, unsigned int handle) = NULL;
void (*FSOUND_File_SeekCallback)(unsigned int handle, int pos, signed char mode) = NULL;
int (*FSOUND_File_TellCallback)(unsigned int handle) = NULL;


void FSOUND_File_SetCallbacks(unsigned int (*OpenCallback)(char *name), void (*CloseCallback)(unsigned int handle), int (*ReadCallback)(void *buffer, int size, unsigned int handle), void (*SeekCallback)(unsigned int handle, int pos, signed char mode), int (*TellCallback)(unsigned int handle))
{
  if (!OpenCallback || !CloseCallback || !ReadCallback || !SeekCallback || !TellCallback)
  {
    FSOUND_File_OpenCallback = NULL;
    FSOUND_File_CloseCallback = NULL;
    FSOUND_File_ReadCallback = NULL;
    FSOUND_File_SeekCallback = NULL;
    FSOUND_File_TellCallback = NULL;
  }
  else
  {
    FSOUND_File_OpenCallback = OpenCallback;
    FSOUND_File_CloseCallback = CloseCallback;
    FSOUND_File_ReadCallback = ReadCallback;
    FSOUND_File_SeekCallback = SeekCallback;
    FSOUND_File_TellCallback = TellCallback;
  }
}

FSOUND_FILE_HANDLE *FSOUND_File_Open(void *data, signed char type, int length)
{
  FSOUND_FILE_HANDLE *handle;

  handle = (FSOUND_FILE_HANDLE *)FSOUND_Memory_Alloc(sizeof(FSOUND_FILE_HANDLE));
  handle->type = type;
  handle->length = length;
  handle->userhandle = FSOUND_File_OpenCallback(data);

  if (!handle->userhandle)
  {
    FSOUND_Memory_Free(handle);
    return NULL;
  }

  return(handle);
}

void FSOUND_File_Close(FSOUND_FILE_HANDLE *handle)
{
  if (!handle)
    return;
   FSOUND_File_CloseCallback(handle->userhandle);
   FSOUND_Memory_Free(handle);
}

int FSOUND_File_Read(void *buffer, int size, FSOUND_FILE_HANDLE *handle)
{
  if (!handle)
    return 0;
  return(FSOUND_File_ReadCallback(buffer, size, handle->userhandle));
}

void FSOUND_File_Seek(FSOUND_FILE_HANDLE *handle, int pos, signed char mode)
{
  if (!handle)
    return;
  FSOUND_File_SeekCallback(handle->userhandle, pos, mode);
}

int FSOUND_File_Tell(FSOUND_FILE_HANDLE *handle)
{
  if (!handle)
    return 0;
  return(FSOUND_File_TellCallback(handle->userhandle));
}
