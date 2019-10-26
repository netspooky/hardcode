; Clinkster music converted from music.xrns 2014-06-06 21:27:51

%define USES_SINE 1
%define USES_SAWTOOTH 0
%define USES_SQUARE 1
%define USES_PARABOLA 1
%define USES_TRIANGLE 1
%define USES_NOISE 0
%define USES_VELOCITY 0
%define USES_LONG_NOTES 0
%define USES_DELAY 0
%define USES_PANNING 0
%define USES_INDEXDECAY 1
%define USES_GAIN 1

%define SUBSAMPLES_PER_TICK 22048
%define MAX_INSTRUMENT_SUBSAMPLES 2424832
%define MAX_TOTAL_INSTRUMENT_SAMPLES 1048576
%define MAX_RELEASE_SUBSAMPLES 262144
%define TOTAL_SAMPLES 6946816
%define MAX_TRACK_INSTRUMENT_RENDERS 10

%define MAX_DELAY_LENGTH 0
%define LEFT_DELAY_LENGTH 0
%define RIGHT_DELAY_LENGTH 0
%define DELAY_STRENGTH 0.00000000

%define NUMTRACKS 6
%define LOGNUMTICKS 11
%define MUSIC_LENGTH 1248
%define TICKS_PER_SECOND 8.00000000


	section instdata data align=1

_InstrumentData:
	; 00:  Track 01 / 00|bass
	db	3,2,6,5,0,32,1,13,16,32,0,0,0,0,-8,-6,-34,1,-9
	db	26,96,32,0,1,28,0,4,4,0,-1
	; 01:  Track 02 / 01|bells
	db	0,2,7,7,0,3,7,12,0,32,0,36,0,0,0,-12,-43,4,17
	db	62,1,0,1,1,0,4,1,0,-1
	; 02:  Track 03 / 02|basicbassdrum
	db	0,0,0,0,0,0,1,12,0,48,24,0,-70,0,0,0,-59,2,-27
	db	28,1,0,-1
	; 03:  Track 03 / 03|snare1
	db	3,0,46,52,32,3,40,31,0,32,47,21,0,-19,-16,68,-120,-2,0
	db	4,1,0,23,1,0,-1
	; 04:  Track 04 / 04|hihat
	db	0,0,13,23,0,5,12,37,2,32,55,22,0,0,0,30,-59,-6,-19
	db	64,1,0,-1
	; 05:  Track 05 / 05|mainsynth1
	db	1,1,6,6,20,30,12,12,16,32,0,0,0,0,0,0,-34,1,11
	db	62,18,12,10,4,0,1,8,2,0,4,4,2,0,1,66,2,0,-1
	db	-1

	section notepos data align=1

_NotePositions:
	; 00:  Track 01 / 00|bass
	; position 1 - pattern 0
	db	32,28,4
	; position 2 - pattern 0
	db	32,28,4
	; position 3 - pattern 2
	db	32,28,4
	; position 4 - pattern 2
	db	32,28,4
	; position 5 - pattern 3
	db	32,28,4
	; position 6 - pattern 3
	db	32,28,4
	; position 7 - pattern 0
	db	32,28,4
	; position 8 - pattern 4
	db	32,28,4
	; position 9 - pattern 4
	db	32,28,4
	; position 10 - pattern 4
	db	32,28,4
	; position 11 - pattern 4
	db	32,28,4
	; position 12 - pattern 2
	db	32,28,4
	; position 14 - pattern 6
	db	96,28,4
	; position 15 - pattern 7
	db	32,28,4
	; position 16 - pattern 6
	db	32,28,4
	; position 17 - pattern 7
	db	32,28,4

	; 01:  Track 02 / 01|bells
	; position 3 - pattern 2
	db	-1,160,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 4 - pattern 2
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 5 - pattern 3
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 6 - pattern 3
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 8 - pattern 4
	db	66,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 9 - pattern 4
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 10 - pattern 4
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 11 - pattern 4
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 12 - pattern 2
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 13 - pattern 5
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 14 - pattern 6
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 15 - pattern 7
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 16 - pattern 6
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 17 - pattern 7
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	; position 18 - pattern 5
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

	; 02:  Track 03 / 02|basicbassdrum
	; position 5 - pattern 3
	db	-2,32,2,30,2
	; position 6 - pattern 3
	db	30,2,30,2
	; position 8 - pattern 4
	db	94,2,8,6,2,14,2,8
	; position 9 - pattern 4
	db	22,2,8,6,2,14,2,8
	; position 10 - pattern 4
	db	22,2,8,6,2,14,2,8
	; position 11 - pattern 4
	db	22,2,8,6,2,14,2,8
	; position 14 - pattern 6
	db	-1,150,2,8,6,2,14,2,8
	; position 15 - pattern 7
	db	22,2,8,6,2,14,2,8
	; position 16 - pattern 6
	db	22,2,8,6,2,14,2,8
	; position 17 - pattern 7
	db	22,2,8,6,2,14,2,8

	; 03:  Track 03 / 03|snare1
	; position 5 - pattern 3
	db	-2,36,24,8,16,8
	; position 6 - pattern 3
	db	8,24,8,16,8
	; position 8 - pattern 4
	db	72,8,8,8,8,8,8,8
	; position 9 - pattern 4
	db	8,8,8,8,8,8,8,8
	; position 10 - pattern 4
	db	8,8,8,8,8,8,8,8
	; position 11 - pattern 4
	db	8,8,8,8,8,8,8,8
	; position 14 - pattern 6
	db	-1,136,8,8,8,8,8,8,8
	; position 15 - pattern 7
	db	8,8,8,8,8,8,8,8
	; position 16 - pattern 6
	db	8,8,8,8,8,8,8,8
	; position 17 - pattern 7
	db	8,8,8,8,8,8,8,8

	; 04:  Track 04 / 04|hihat
	; position 8 - pattern 4
	db	-2,224,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,1,1
	; position 9 - pattern 4
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,1,1
	; position 10 - pattern 4
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,1,1
	; position 11 - pattern 4
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,1,1
	; position 14 - pattern 6
	db	-1,130,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,1,1
	; position 15 - pattern 7
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,1,1
	; position 16 - pattern 6
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,1,1
	; position 17 - pattern 7
	db	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,1,1

	; 05:  Track 05 / 05|mainsynth1
	; position 14 - pattern 6
	db	-4,96,8,4,2,4,4,10,8,4,2
	; position 15 - pattern 7
	db	18,8,4,2,4,4,10,8,4,2,12,2,2
	; position 16 - pattern 6
	db	2,8,4,2,4,4,10,8,4,2
	; position 17 - pattern 7
	db	18,8,4,2,4,4,10,8,4,2,12,2,2


	section notesamp data align=1

_NoteSamples:
	; 00:  Track 01 / 00|bass
	; position 1 - pattern 0
	db	2,3,1
	; position 2 - pattern 0
	db	2,3,1
	; position 3 - pattern 2
	db	2,3,1
	; position 4 - pattern 2
	db	2,3,1
	; position 5 - pattern 3
	db	2,3,1
	; position 6 - pattern 3
	db	2,3,1
	; position 7 - pattern 0
	db	2,3,1
	; position 8 - pattern 4
	db	2,3,1
	; position 9 - pattern 4
	db	2,3,1
	; position 10 - pattern 4
	db	2,3,1
	; position 11 - pattern 4
	db	2,3,1
	; position 12 - pattern 2
	db	2,3,0
	; position 14 - pattern 6
	db	2,3,1
	; position 15 - pattern 7
	db	2,3,1
	; position 16 - pattern 6
	db	2,3,1
	; position 17 - pattern 7
	db	2,3,0
	db	-1

	; 01:  Track 02 / 01|bells
	; position 3 - pattern 2
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 4 - pattern 2
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 5 - pattern 3
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 6 - pattern 3
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 8 - pattern 4
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 9 - pattern 4
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 10 - pattern 4
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 11 - pattern 4
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 12 - pattern 2
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 13 - pattern 5
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 14 - pattern 6
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 15 - pattern 7
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 16 - pattern 6
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 17 - pattern 7
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	; position 18 - pattern 5
	db	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	db	-1

	; 02:  Track 03 / 02|basicbassdrum
	; position 5 - pattern 3
	db	0,0,0,0
	; position 6 - pattern 3
	db	0,0,0,0
	; position 8 - pattern 4
	db	0,0,0,0,0,0,0,0
	; position 9 - pattern 4
	db	0,0,0,0,0,0,0,0
	; position 10 - pattern 4
	db	0,0,0,0,0,0,0,0
	; position 11 - pattern 4
	db	0,0,0,0,0,0,0,0
	; position 14 - pattern 6
	db	0,0,0,0,0,0,0,0
	; position 15 - pattern 7
	db	0,0,0,0,0,0,0,0
	; position 16 - pattern 6
	db	0,0,0,0,0,0,0,0
	; position 17 - pattern 7
	db	0,0,0,0,0,0,0,0
	db	-1

	; 03:  Track 03 / 03|snare1
	; position 5 - pattern 3
	db	0,0,0,0,0
	; position 6 - pattern 3
	db	0,0,0,0,0
	; position 8 - pattern 4
	db	0,0,1,0,0,1,0,0
	; position 9 - pattern 4
	db	0,0,1,0,0,1,0,0
	; position 10 - pattern 4
	db	0,0,1,0,0,1,0,0
	; position 11 - pattern 4
	db	0,0,1,0,0,1,0,0
	; position 14 - pattern 6
	db	0,0,1,0,0,1,0,0
	; position 15 - pattern 7
	db	0,0,1,0,0,1,0,0
	; position 16 - pattern 6
	db	0,0,1,0,0,1,0,0
	; position 17 - pattern 7
	db	0,0,1,0,0,1,0,0
	db	-1

	; 04:  Track 04 / 04|hihat
	; position 8 - pattern 4
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	; position 9 - pattern 4
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	; position 10 - pattern 4
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	; position 11 - pattern 4
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	; position 14 - pattern 6
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	; position 15 - pattern 7
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	; position 16 - pattern 6
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	; position 17 - pattern 7
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	-1

	; 05:  Track 05 / 05|mainsynth1
	; position 14 - pattern 6
	db	4,6,9,3,3,2,4,6,9,0
	; position 15 - pattern 7
	db	4,6,9,3,3,2,4,6,9,1,5,7,9
	; position 16 - pattern 6
	db	4,6,9,3,3,2,4,6,9,0
	; position 17 - pattern 7
	db	4,6,9,3,3,2,4,6,9,1,5,7,8
	db	-1

