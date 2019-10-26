/*
	Sound system via FMOD (_NOT_ MiniFMOD)
*/
#include <stdio.h>
#include "sound.hpp"

#include "resource.h"
#include "fmod.h"

FMOD_SYSTEM *system;
FMOD_SOUND *fsound;
FMOD_CHANNEL *channel;

Sound::Sound()
{

}

Sound::~Sound()
{
	
}


bool Sound::init()
{	
	fsound = 0;
	FMOD_System_Create(&system);
	FMOD_System_Init(system, 1, FMOD_INIT_NORMAL, NULL);
	FMOD_System_CreateSound(system, "music.xm", FMOD_SOFTWARE | FMOD_CREATESTREAM, 0, &fsound);
		
	return true;
}

void Sound::play()
{
	FMOD_System_PlaySound(system, FMOD_CHANNEL_FREE, fsound, 0, &channel);
}

void Sound::release()
{
	FMOD_Sound_Release(fsound);
	FMOD_System_Close(system);
	FMOD_System_Release(system);
}
