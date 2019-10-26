/*
   Voxel Bukkake - A 4k intro for BCNparty'101.
   Copyright (C) 2005 Jorge Gorbe (aka slack/Necrostudios)

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License version 2
   as published by the Free Software Foundation.
*/

#ifndef _TRACK_H_
#define _TRACK_H_

#include "SDL.h"
#include "synth.h"

#define PLAYLIST_LENGTH 64
#define NUM_PATTERNS 32
#define NUM_TRACKS 16 
#define NUM_INSTRUMENTS 5 
#define NUM_RHYTHM_CHANNELS 4
#define NUM_CHANNELS 8 
#define TRACK_LENGTH 16

typedef struct _Track
{
	/* Una nota ocupa 8 bits, de los cuales:
	 *
	 *   7   6    5   4   3   2   1   0
	 * -----------------------------------
	 * |  Vol. |        Nº nota          |
	 * -----------------------------------
	 */

	Uint8 notes[TRACK_LENGTH];
	Uint8 instrument;
} Track;


typedef struct _Channel
{
	Uint8 pat[NUM_PATTERNS];
} Channel;

typedef struct _Rhythm_Channel
{
	Uint16 pat[NUM_PATTERNS];
} Rhythm_Channel;

typedef struct _Song
{
	float row_duration; // en segundos
	Uint8 playlist[PLAYLIST_LENGTH];

	Rhythm_Channel rhythms[NUM_RHYTHM_CHANNELS];
	Channel chans[NUM_CHANNELS];
	
	Uint8 rhythm_notes[NUM_RHYTHM_CHANNELS];
	Uint8 rhythm_insts[NUM_RHYTHM_CHANNELS];
	Track tracks[NUM_TRACKS];
	Instrument insts[NUM_INSTRUMENTS];
} Song;

#endif


