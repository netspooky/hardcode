
#include "ModPlayer.h"
#include <windows.h>

#include "../data/music.h"		// xm

typedef struct 
{
	int length;
	int pos;
	void *data;
} MEMFILE;

unsigned int memopen(char *name)
{
	MEMFILE *memfile;

	memfile = new MEMFILE;
	memfile->length = sizeof( music );
	memfile->data = (void*)music;
	memfile->pos = 0;

	return reinterpret_cast<unsigned int>( memfile );
}

void memclose(unsigned int handle)
{
	MEMFILE *memfile = (MEMFILE*)handle;
	delete memfile;
}

int memread(void *buffer, int size, unsigned int handle)
{
	MEMFILE *memfile = (MEMFILE*)handle;

	if (memfile->pos + size >= memfile->length)
		size = memfile->length - memfile->pos;

	memcpy(buffer, (char *)memfile->data+memfile->pos, size);
	memfile->pos += size;
	
	return size;
}

void memseek(unsigned int handle, int pos, signed char mode)
{
	MEMFILE *memfile = (MEMFILE*)handle;

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
	MEMFILE *memfile = (MEMFILE*)handle;
	return memfile->pos;
}

ModPlayer::ModPlayer() {

	FSOUND_File_SetCallbacks( memopen, memclose, memread, memseek, memtell );
	mod = FMUSIC_LoadSong( 0, 0 );
}

ModPlayer::~ModPlayer() {
	FMUSIC_FreeSong( mod );
}

void ModPlayer::play() {
	FMUSIC_PlaySong( mod );
}

void ModPlayer::stop() {
	FMUSIC_StopSong( mod );
}