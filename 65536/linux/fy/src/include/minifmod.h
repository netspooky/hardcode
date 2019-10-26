#ifndef _MINIFMOD_H_
#define _MINIFMOD_H_


typedef void (*SAMPLELOADCALLBACK)(void *buff, int lenbytes, int numbits, int instno, int sampno);

#ifndef __COMPILE_MINIFMOD__
typedef struct FMUSIC_MODULE FMUSIC_MODULE;
#else
#include "music.h"
#endif


#ifdef __cplusplus
extern "C"
{
#endif


void FSOUND_File_SetCallbacks(unsigned int (*OpenCallback)(char *name),
                              void (*CloseCallback)(unsigned int handle),
                              int (*ReadCallback)(void *buffer, int size, unsigned int handle), void (*SeekCallback)(unsigned int handle, int pos, signed char mode),
                              int (*TellCallback)(unsigned int handle));

int FSOUND_Init(int mixrate, int vcmmode);
void FSOUND_Close();



FMUSIC_MODULE * FMUSIC_LoadSong(char *data, SAMPLELOADCALLBACK sampleloadcallback);
FMUSIC_MODULE * FMUSIC_LoadSongEx(const char *name_or_data, int offset, int length, unsigned int mode, const int *samplelist, int samplelistnum);
int FMUSIC_FreeSong(FMUSIC_MODULE *mod);
int FMUSIC_PlaySong(FMUSIC_MODULE *mod);
int FMUSIC_StopSong(FMUSIC_MODULE *mod);


int FMUSIC_GetOrder(FMUSIC_MODULE *mod);
int FMUSIC_GetRow(FMUSIC_MODULE *mod);
unsigned int FMUSIC_GetTime(FMUSIC_MODULE *mod);

#ifdef __cplusplus
}
#endif

#endif
