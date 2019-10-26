/*  =========================================================================== */
/*   minifmod.h */
/*  --------------------------------------------------------------------------- */
/*   MiniFMOD public source code release. */
/*   This source is provided as-is.  Firelight Multimedia will not support */
/*   or answer questions about the source provided. */
/*   MiniFMOD Sourcecode is copyright (c) 2000, Firelight Multimedia. */
/*   MiniFMOD Sourcecode is in no way representative of FMOD 3 source. */
/*   Firelight Multimedia is a registered business name. */
/*   This source must not be redistributed without this notice. */
/*  =========================================================================== */

/*  =========================================================================== */
/*   MiniFMOD Main header file. Copyright (c), FireLight Multimedia 2000. */
/*   Based on FMOD, copyright (c), FireLight Multimedia 2000. */
/*  =========================================================================== */

#ifndef _MINIFMOD_H_
#define _MINIFMOD_H_

/*  =========================================================================== */
/*  = DEFINITIONS                                                             = */
/*  =========================================================================== */

typedef void (*SAMPLELOADCALLBACK)(void *buff, int lenbytes, int numbits, int instno, int sampno);
/* typedef void (*FMUSIC_CALLBACK)(FMUSIC_MODULE *mod, unsigned char param); */

#ifndef __COMPILE_MINIFMOD__
typedef struct FMUSIC_MODULE FMUSIC_MODULE;
#else
#include "music.h"
#endif

/*  =========================================================================== */
/*  = FUNCTION PROTOTYPES                                                     = */
/*  =========================================================================== */

#ifdef __cplusplus
extern "C"
{
#endif

/*  Initialization / Global functions. */
/*  ================================== */

/*  this must be called before FSOUND_Init! */
void FSOUND_File_SetCallbacks(unsigned int (*OpenCallback)(char *name),
                              void (*CloseCallback)(unsigned int handle),
                              int (*ReadCallback)(void *buffer, int size, unsigned int handle), void (*SeekCallback)(unsigned int handle, int pos, signed char mode),
                              int (*TellCallback)(unsigned int handle));

int FSOUND_Init(int mixrate, int vcmmode);
void FSOUND_Close(void);

/*  =========================================================================== */
/*  = FMUSIC API                                                              = */
/*  =========================================================================== */

/*  Song management / playback functions. */
/*  ===================================== */

FMUSIC_MODULE * FMUSIC_LoadSong(char *data, SAMPLELOADCALLBACK sampleloadcallback);
int FMUSIC_FreeSong(FMUSIC_MODULE *mod);
int FMUSIC_PlaySong(FMUSIC_MODULE *mod);
int FMUSIC_StopSong(FMUSIC_MODULE *mod);

/*  Runtime song information. */
/*  ========================= */

int FMUSIC_GetOrder(FMUSIC_MODULE *mod);
int FMUSIC_GetRow(FMUSIC_MODULE *mod);
unsigned int FMUSIC_GetTime(FMUSIC_MODULE *mod);

#ifdef __cplusplus
}
#endif

#endif
