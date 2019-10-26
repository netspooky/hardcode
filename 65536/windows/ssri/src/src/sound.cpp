/*
	Sound system via FMOD (_NOT_ MiniFMOD)
*/
#include <stdio.h>
#include "sound.hpp"

#include "fmod.h"

FMOD_SYSTEM *system;
FMOD_SOUND *fsound;
FMOD_CHANNEL *channel;

int Sound::getOrder()
{ 
	FMOD_Channel_GetPosition(channel, &fmod_sync, FMOD_TIMEUNIT_MODORDER);
	return fmod_sync;
}
int Sound::getRow()
{
	FMOD_Channel_GetPosition(channel, &fmod_sync, FMOD_TIMEUNIT_MODROW);
	return fmod_sync;
}
int Sound::getTime() { }

Sound::Sound()
{

}

Sound::~Sound()
{
	
}


bool Sound::init()
{	
/*	if (!FSOUND_Init(44100, 32, FSOUND_INIT_USEDEFAULTMIDISYNTH)) { return 1; }
	mod = FMUSIC_LoadSong("music.xm");

	FMUSIC_SetMasterVolume(mod, 192);
	FMUSIC_SetLooping(mod, 0);*/
fsound = 0;
FMOD_System_Create(&system);
FMOD_System_Init(system, 1, FMOD_INIT_NORMAL, NULL);
FMOD_System_CreateSound(system, "music.xm", FMOD_SOFTWARE | FMOD_CREATESTREAM, 0, &fsound);

	return true;
}

void Sound::play()
{
/*	FMUSIC_PlaySong(mod);*/
FMOD_System_PlaySound(system, FMOD_CHANNEL_FREE, fsound, 0, &channel);
}

void Sound::release()
{
/*	FMUSIC_StopSong(mod);
	FMUSIC_FreeSong(mod);
	FSOUND_Close();*/
FMOD_Sound_Release(fsound);
FMOD_System_Close(system);
FMOD_System_Release(system);
}
