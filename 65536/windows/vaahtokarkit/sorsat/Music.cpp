#include "music.h"
#include "error.h"
#include <minifmod.h>
#include <string.h>

char *music_data;
int music_size,music_pos,nosound=0;

unsigned int memopen(char *name) {
	return 1;
}

void memclose(unsigned int handle) {
}

int memread(void *buffer, int size, unsigned int handle) {
	if(music_pos + size >= music_size)
		size = music_size - music_pos;

	memcpy(buffer, (char *)music_data+music_pos, size);
	music_pos += size;
	
	return size;
}

void memseek(unsigned int handle, int pos, signed char mode) {
	if (mode == SEEK_SET) 
		music_pos = pos;
	else if (mode == SEEK_CUR) 
		music_pos += pos;
	else if (mode == SEEK_END)
		music_pos = music_size + pos;

	if (music_pos > music_size)
		music_pos = music_size;
}

int memtell(unsigned int handle)
{
	return music_pos;
}

void musicInit() {
  if(nosound) return;

  FSOUND_File_SetCallbacks(memopen,memclose,memread,memseek,memtell);
  if(!FSOUND_Init(22050,0)) nosound=1;
}

void musicDeinit() {
  if(nosound) return;
  FSOUND_Close();
}

/*
void instruments(void *buff, int lenbytes, int numbits, int instno, int sampno)
{
  char *dat = (char *) buff;
  printf("%d %d\n",instno,lenbytes);

  for(int i=0; i<lenbytes; i++)
  {
    float a = sinf(3.141592f*2.0f*i/63)*60.0f;
    float b = sinf(3.141592f*2.0f*i/33)*30.0f;
    float c = sinf(3.141592f*2.0f*i/50)*10.0f;

    dat[i]=(int)(a+b+c);
  }
}
*/

void *musicLoad(char *b,int size) {
  if(nosound) return 0;

  music_pos=0;
  music_size=size;
  music_data=b;

//  m = FMUSIC_LoadSong("",instruments);
  return FMUSIC_LoadSong("",0);
}

void musicPlay(void *m) {
  if(nosound) return;
  if(m) FMUSIC_PlaySong((FMUSIC_MODULE *)m);
}
