#include "main.h"

FMUSIC_MODULE *tune;
unsigned int fileopen(char *name);
unsigned int fileopen(char *name)
{
  return((unsigned int)fopen(name, "rb"));
}
void fileclose(unsigned int handle)
{
  fclose((FILE *)handle);
}
int fileread(void *buffer, int size, unsigned int handle)
{
  return(fread(buffer, 1, size, (FILE *)handle));
}
void fileseek(unsigned int handle, int pos, signed char mode)
{
  fseek((FILE *)handle, pos, mode);
}
int filetell(unsigned int handle)
{
  return(ftell((FILE *)handle));
}

int initsound(void){

  tune = NULL;
  
  FSOUND_File_SetCallbacks(fileopen, fileclose, fileread, fileseek, filetell);
  if(!FSOUND_Init(44100, 0)){
    printf("Failed to initialise fmod at 44100khz. Bad driver?\n");
    return 1;
  }

  tune = FMUSIC_LoadSong("tune.xm", 0);
  if(tune == NULL){
    printf("Failed to load song.\n");
    return 1;
  }

  return 0;
}
