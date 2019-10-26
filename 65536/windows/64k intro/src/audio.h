#ifndef _Y16I_AUDIO_
#define _Y16I_AUDIO_

////////////////////////////////////////////////////////////////////////////////
// miniFMOD XM Player (doesn't using dll)
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <windows.h>
#include "another/minifmod.h"

class cAudio{
public:
	cAudio();
	~cAudio();
	int useSound;
	FMUSIC_MODULE *mod;
	int ord, row, tick;
	float playtime;
	
public:
	void init(char *n);
	void play(void);
	void statusUpdate(void);
	void stop(void);
};
#endif	// _Y16I_AUDIO_
