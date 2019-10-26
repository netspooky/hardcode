#ifndef __SOUND_H_
#define __SOUND_H_

#include ".\minifmod\minifmod.h"
#include ".\minifmod\sound.h"
#include ".\minifmod\music.h"
#include "addition.h"
#include <stdio.h>


void    SoundStart (const char *fname);
void    SoundPlay ();
void    SoundStop ();
extern FMUSIC_MODULE *mod;
#endif