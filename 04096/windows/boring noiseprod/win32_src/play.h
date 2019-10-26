#ifndef _TRACK_H_
#define _TRACK_H_

//#include "SDL.h"
#include "synth.h"

#define PLAYLIST_LENGTH 13 
#define NUM_PATTERNS 12
#define NUM_TRACKS 9 
#define NUM_INSTRUMENTS 5 
#define NUM_RHYTHM_CHANNELS 1
#define NUM_CHANNELS 5 
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

	Channel chans[NUM_CHANNELS];
	
	Track tracks[NUM_TRACKS];
	Instrument insts[NUM_INSTRUMENTS];
} Song;

#endif


