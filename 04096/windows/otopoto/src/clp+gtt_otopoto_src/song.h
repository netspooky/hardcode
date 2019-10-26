/*
	This file is part of "otopoto / Collapse & Gatitos".

    "otopoto / Collapse & Gatitos" is free software: you can redistribute
	it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

    "otopoto / Collapse & Gatitos" is distributed in the hope that it will
	be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with "otopoto / Collapse & Gatitos".  If not, see 
	<http://www.gnu.org/licenses/>.
*/

#ifndef SONG_H
#define SONG_H

#include "sizedtypes.h"

// uncompressed song size == 
//          NUM_PATTERNS*NUM_CHANNELS
//          + NUM_TRACKS*TRACK_LENGTH
//          + INSTRUMENT_DATA_LENGTH
//          + PLAYLIST_LENGTH

#define NUM_PATTERNS 17
#define NUM_CHANNELS 8
#define NUM_TRACKS 15 
#define TRACK_LENGTH 12 
#define INSTRUMENT_DATA_LENGTH 159
#define PLAYLIST_LENGTH 40

typedef struct
{
	uint8 notes[TRACK_LENGTH];
	uint8 instrument;
} Track;

typedef struct
{
	uint8 patterns[NUM_PATTERNS][NUM_CHANNELS];
    int8 transpose[NUM_PATTERNS][NUM_CHANNELS];
	Track tracks[NUM_TRACKS];
	uint8 instrument_data[INSTRUMENT_DATA_LENGTH];
	uint8 playlist[PLAYLIST_LENGTH];
} Song;



#endif

