#ifndef PLAY_H
#define PLAY_H

#define NUM_CHANNELS 6
#define TRACK_LENGTH 32
#define MAX_SONG_LENGTH 15
#define MAX_PATTERNS 10
#define MAX_TRACKS 11
#define MAX_INSTRUMENTS 6

#define Uint8 unsigned char
#define Sint16 signed short int

typedef struct Track_STRUCT
{
	char note[TRACK_LENGTH];
	char vol[TRACK_LENGTH];
	//int fx[TRACK_LENGTH];
} Track;

typedef struct Pattern_STRUCT
{
#ifdef __REORDERED_PATTERNS__
	// Con patterns reordenados
	char tracks[MAX_PATTERNS];
	char transpose[MAX_PATTERNS];
#else
	char tracks[NUM_CHANNELS];
	char transpose[NUM_CHANNELS];
#endif
} Pattern;


typedef struct Song_STRUCT
{
	char ptn_list[MAX_SONG_LENGTH];

	
#ifdef __REORDERED_PATTERNS__
	// Con patterns reordenados
	Pattern ptns[NUM_CHANNELS];
#else
	Pattern ptns[MAX_PATTERNS];
#endif

	Track tracks[MAX_TRACKS];

	Instr insts[MAX_INSTRUMENTS];

} Song;


#endif
