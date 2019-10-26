/* 
  *      Copyright (C) 2004 Jorge Gorbe Moya <slack@frikis.org>
  *
  *
  *      This program is free software; you can redistribute it and/or modify
  *      it under the terms of the GNU General Public License version 2, as 
  *      published by the Free Software Foundation.
  *
  *      This program is distributed in the hope that it will be useful,
  *      but WITHOUT ANY WARRANTY; without even the implied warranty of
  *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *      GNU General Public License for more details.
  *
  *      You should have received a copy of the GNU General Public License
  *      along with this program; if not, write to the
  *      Free Software Foundation, Inc.,
  *      59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */



#ifndef PLAY_H
#define PLAY_H

#define NUM_CHANNELS 6
#define TRACK_LENGTH 32
#define MAX_SONG_LENGTH 32
#define MAX_PATTERNS 16
#define MAX_TRACKS 16
#define MAX_INSTRUMENTS 8

typedef struct Track_STRUCT
{
	Uint8 note[TRACK_LENGTH];
	Uint8 vol[TRACK_LENGTH];
	//int fx[TRACK_LENGTH];
} Track;

typedef struct Pattern_STRUCT
{
	int tracks[NUM_CHANNELS];
	int transpose[NUM_CHANNELS];
} Pattern;

typedef struct Song_STRUCT
{
	int ptn_list[MAX_SONG_LENGTH];
	int speed;	// Rows-per-beat
	float tempo;	// BPM
	Pattern ptns[MAX_PATTERNS];
	Track tracks[MAX_TRACKS];
	Instr insts[MAX_INSTRUMENTS];
} Song;


#endif
