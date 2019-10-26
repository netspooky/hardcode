//==========================================================================================
// MINIMOD Main header file. Copyright (c), FireLight Multimedia 2000.
// Based on FMOD, copyright (c), FireLight Multimedia 2000.
//==========================================================================================

#ifndef _MINIMOD_H_
#define _MINIMOD_H_

//===============================================================================================
//= DEFINITIONS
//===============================================================================================

// fmod defined types
typedef struct FMUSIC_MODULE	FMUSIC_MODULE;

//===============================================================================================
//= FUNCTION PROTOTYPES
//===============================================================================================

#ifdef __cplusplus
extern "C" {
#endif

// ==================================
// Initialization / Global functions.
// ==================================
typedef void (*SAMPLELOADCALLBACK)(void *buff, int lenbytes, int numbits, int instno, int sampno);
typedef void (*FMUSIC_CALLBACK)(FMUSIC_MODULE *mod, unsigned char param);

// this must be called before FSOUND_Init!
void FSOUND_File_SetCallbacks(unsigned int	(*OpenCallback)(char *name),
                              void			(*CloseCallback)(unsigned int handle),
                              int			(*ReadCallback)(void *buffer, int size, unsigned int handle),
                              void			(*SeekCallback)(unsigned int handle, int pos, signed char mode),
                              int			(*TellCallback)(unsigned int handle));

signed char		FSOUND_Init(int mixrate, int vcmmode);
void			FSOUND_Close();

// =============================================================================================
// FMUSIC API
// =============================================================================================

// Song management / playback functions.
// =====================================
FMUSIC_MODULE * FMUSIC_LoadSong(char *data, SAMPLELOADCALLBACK sampleloadcallback);
signed char		FMUSIC_FreeSong(FMUSIC_MODULE *mod);
signed char		FMUSIC_PlaySong(FMUSIC_MODULE *mod);
signed char		FMUSIC_StopSong(FMUSIC_MODULE *mod);

// Runtime song information.
// =========================
int				FMUSIC_GetOrder(FMUSIC_MODULE *mod);
int				FMUSIC_GetRow(FMUSIC_MODULE *mod);
unsigned int	FMUSIC_GetTime(FMUSIC_MODULE *mod);
  
#ifdef __cplusplus
}
#endif

#endif
