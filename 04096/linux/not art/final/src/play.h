#ifndef _TRACK_H_
#define _TRACK_H_

#include "SDL.h"
#include "synth.h"

#define PLAYLIST_LENGTH 21
#define NUM_PATTERNS 16 
#define NUM_TRACKS 10 
#define NUM_INSTRUMENTS 5 
#define NUM_CHANNELS 7
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

typedef struct _Pattern
{
	Uint8 channels[NUM_CHANNELS]; // upper nibble indica transpose
				      // lower nibble num. de track
} Pattern;

typedef struct _Song
{
	float row_duration; // en segundos
	Uint8 playlist[PLAYLIST_LENGTH];
	Pattern ptns[NUM_PATTERNS];
	Track tracks[NUM_TRACKS];
	Instrument insts[NUM_INSTRUMENTS];
} Song;

#endif


