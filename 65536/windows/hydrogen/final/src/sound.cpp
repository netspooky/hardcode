#include "sound.h"
#include "globals.h"
#include "resource.h"
#include ".\samplegn\generate.h"

extern "C" void FMUSIC_UpdateXM(FMUSIC_MODULE *mod);

FMUSIC_MODULE *mod;
unsigned int  fin;

void sampleloadcallback(void *buff, int lenbytes, int numbits, int instno, int sampno) {
  SampleInfo  si;
  memread((void*)&si,sizeof(si),fin);
  GenerateSample16((void*)buff,&si);
}

void UpdCallback(struct FMUSIC_MODULE *mod){
  needframes++;
  FMUSIC_UpdateXM(mod);
  return;
}

void	SoundStart (const char *fname) {
  int samples=0;

  fin = memopen(MAKEINTRESOURCE(SAMPLES));
  memread((void*)&samples,sizeof(int),fin);
	//FSOUND_File_SetCallbacks(fileopen, fileclose, fileread, fileseek, filetell);
	FSOUND_File_SetCallbacks(memopen, memclose, memread, memseek, memtell);
	FSOUND_Init (soundfreq, 0);
	mod = FMUSIC_LoadSong((char*)fname, sampleloadcallback);
  mod->Update=UpdCallback;
  memclose(fin);
}

void SoundPlay () {
  FMUSIC_PlaySong(mod);
}

void SoundStop() {
//  FMUSIC_StopSong(mod);
	FMUSIC_FreeSong(mod);
	FSOUND_Close();
}