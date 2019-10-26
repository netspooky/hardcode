; Clinkster music converted from music.xrns 2013-08-10 17:21:35

%define USES_SINE 1
%define USES_SAWTOOTH 1
%define USES_SQUARE 0
%define USES_PARABOLA 0
%define USES_TRIANGLE 1
%define USES_NOISE 0
%define USES_VELOCITY 0
%define USES_LONG_NOTES 0
%define USES_DELAY 0
%define USES_PANNING 0
%define USES_INDEXDECAY 1
%define USES_GAIN 1

%define SUBSAMPLES_PER_TICK 18248
%define MAX_INSTRUMENT_SUBSAMPLES 851968
%define MAX_TOTAL_INSTRUMENT_SAMPLES 1245184
%define MAX_RELEASE_SUBSAMPLES 196608
%define TOTAL_SAMPLES 3276800
%define MAX_TRACK_INSTRUMENT_RENDERS 30

%define MAX_DELAY_LENGTH 0
%define LEFT_DELAY_LENGTH 0
%define RIGHT_DELAY_LENGTH 0
%define DELAY_STRENGTH 0.00000000

%define NUMTRACKS 6
%define LOGNUMTICKS 10
%define MUSIC_LENGTH 704
%define TICKS_PER_SECOND 9.66666667


	section instdata data align=1

_InstrumentData:
	; 00:  Bass drum / 01|Bass drum
	db	2,1,0,0,0,54,1,56,0,9,0,0,0,0,-70,100,-59,2,-27
	db	28,1,0,0,1,0,10,1,0,-1
	; 01:  Snare / 02|Snare drum
	db	0,1,20,9,10,13,5,11,15,3,48,31,-38,-74,-82,71,-41,-34,-3
	db	28,8,0,11,9,8,4,0,-1
	; 02:  Snare / 02|Snare drum
	db	0,1,20,9,10,13,5,11,15,3,48,31,-38,-74,-82,71,-41,-34,-3
	db	52,34,8,6,0,11,8,0,-1
	; 03:  Bass / 00|Pad
	db	0,0,3,5,0,3,2,3,32,14,-12,-24,-74,-59,0,16,-1,-1,3
	db	40,20,16,12,8,0,1,12,8,2,0,0,16,8,4,2,0,1,16,12,4,0,1,8,4,0,-1
	; 04:  Lead / 03|Lead
	db	0,2,0,5,4,1,1,23,5,26,0,0,0,0,0,-13,-127,-6,4
	db	52,2,0,1,6,2,0,0,6,2,0,1,6,2,0,1,2,0,0,2,0,1,6,2,1,0,1,18,6,2,1,0,1,12,6,2,1,0,0,10,8,6,4,2,1,0,1,4,2,0,1,2,0,0,2,0,-1
	; 05:  Lead 2 / 04|Lead 2
	db	2,1,3,4,0,2,1,13,12,5,0,0,0,0,0,80,2,12,2
	db	50,12,8,4,0,1,16,12,0,1,8,2,0,0,16,8,4,2,0,1,12,8,4,0,1,8,0,-1
	db	-1

	section notepos data align=1

_NotePositions:
	; 00:  Bass drum / 01|Bass drum
	; position 0 - pattern 0
	db	0,10,6,2,8,6,6,1,1,2,6,2,8,5
	; position 1 - pattern 0
	db	1,10,6,2,8,6,6,1,1,2,6,2,8,5
	; position 2 - pattern 0
	db	1,10,6,2,8,6,6,1,1,2,6,2,8,5
	; position 3 - pattern 1
	db	1,10,6,2,8,6,6,1,1,2,6,2,5,3,5
	; position 4 - pattern 2
	db	1,10,6,2,8,6,6,1,1,2,6,2,8,5
	; position 5 - pattern 1
	db	1,10,6,2,8,6,6,1,1,2,6,2,5,3,5
	; position 6 - pattern 3
	db	1,10,6,2,8,6,1,1,1,1,6,6,2,5,3
	; position 7 - pattern 2
	db	6,10,6,2,8,6,6,1,1,2,6,2,8,5
	; position 8 - pattern 2
	db	1,10,6,2,8,6,6,1,1,2,6,2,8,5
	; position 9 - pattern 1
	db	1,10,6,2,8,6,6,1,1,2,6,2,5,3,5
	; position 10 - pattern 5
	db	1,10,6,2,8,1,5,7,3,6,1,1,1,1

	; 01:  Snare / 02|Snare drum
	; position 0 - pattern 0
	db	4,8,8,8,8,8,8,8
	; position 1 - pattern 0
	db	8,8,8,8,8,8,8,8
	; position 2 - pattern 0
	db	8,8,8,8,8,8,8,8
	; position 3 - pattern 1
	db	8,8,8,8,8,8,8,8
	; position 4 - pattern 2
	db	8,8,8,8,8,8,8,8
	; position 5 - pattern 1
	db	8,8,8,8,8,8,8,8
	; position 6 - pattern 3
	db	8,8,8,8,8,8,8,8
	; position 7 - pattern 2
	db	8,8,8,8,8,8,8,8
	; position 8 - pattern 2
	db	8,8,8,8,8,8,8,8
	; position 9 - pattern 1
	db	8,8,8,8,8,8,8,8
	; position 10 - pattern 5
	db	8,8,8,8,8,8

	; 02:  Snare / 02|Snare drum
	; position 0 - pattern 0
	db	32,30
	; position 1 - pattern 0
	db	34,30
	; position 2 - pattern 0
	db	34,30
	; position 3 - pattern 1
	db	34,30
	; position 4 - pattern 2
	db	34,30
	; position 5 - pattern 1
	db	34,30
	; position 7 - pattern 2
	db	98,30
	; position 8 - pattern 2
	db	34,30
	; position 9 - pattern 1
	db	34,30

	; 03:  Bass / 00|Pad
	; position 0 - pattern 0
	db	4,16,16,16,8
	; position 1 - pattern 0
	db	8,16,16,16,8
	; position 2 - pattern 0
	db	8,16,16,16,8
	; position 3 - pattern 1
	db	8,16,16,16,8
	; position 4 - pattern 2
	db	8,12,4,12,4,12,4,8
	; position 5 - pattern 1
	db	8,16,16,16,8
	; position 6 - pattern 3
	db	8,20,4,8,4,12,2,2
	; position 7 - pattern 2
	db	12,12,4,12,4,12,4,8
	; position 8 - pattern 2
	db	8,12,4,12,4,12,4,8
	; position 9 - pattern 1
	db	8,16,16,16,8
	; position 10 - pattern 5
	db	8

	; 04:  Lead / 03|Lead
	; position 1 - pattern 0
	db	70,2,2,2,2,2,6,2,2,2,2,2,6,2,2,2,2,2,6,2,2,2
	; position 2 - pattern 0
	db	10,2,2,2,2,2,6,2,2,2,2,2,6,2,2,2,2,2,6,2,2,2
	; position 3 - pattern 1
	db	8,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,2
	; position 4 - pattern 2
	db	6,2,2,2,2,2,6,2,2,2,2,2,6,2,2,2,2,2,6,2,2,2,2,2
	; position 5 - pattern 1
	db	6,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,2
	; position 6 - pattern 3
	db	14,2,2,12,2,2,6,2,2,2,2,2,2
	; position 7 - pattern 2
	db	18,2,2,2,2,2,6,2,2,2,2,2,6,2,2,2,2,2,6,2,2,2,2,2
	; position 8 - pattern 2
	db	6,2,2,2,2,2,6,2,2,2,2,2,6,2,2,2,2,2,6,2,2,2,2,2
	; position 9 - pattern 1
	db	6,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,2
	; position 10 - pattern 5
	db	2,1,1,1,1

	; 05:  Lead 2 / 04|Lead 2
	; position 2 - pattern 0
	db	-1,132,12,16,12,4,4,8
	; position 3 - pattern 1
	db	8,12,4,16,12,4,8
	; position 4 - pattern 2
	db	8,8,8,8,8,8,8,8
	; position 5 - pattern 1
	db	8,12,4,16,12,4,8
	; position 6 - pattern 3
	db	4,2,2
	; position 8 - pattern 2
	db	-1,128,8,8,8,8,8,8,8
	; position 9 - pattern 1
	db	8,12,4,16,12,4,8
	; position 10 - pattern 5
	db	4


	section notesamp data align=1

_NoteSamples:
	; 00:  Bass drum / 01|Bass drum
	; position 0 - pattern 0
	db	0,0,0,2,0,0,2,1,2,0,0,2,0,0
	; position 1 - pattern 0
	db	0,0,0,2,0,0,2,1,2,0,0,2,0,0
	; position 2 - pattern 0
	db	0,0,0,2,0,0,2,1,2,0,0,2,0,0
	; position 3 - pattern 1
	db	0,0,0,2,0,0,2,1,2,0,0,2,0,0,0
	; position 4 - pattern 2
	db	0,0,0,2,0,0,2,1,2,0,0,2,0,0
	; position 5 - pattern 1
	db	0,0,0,2,0,0,2,1,2,0,0,2,0,0,0
	; position 6 - pattern 3
	db	0,0,0,2,0,0,0,0,0,0,0,0,2,0,0
	; position 7 - pattern 2
	db	0,0,0,2,0,0,2,1,2,0,0,2,0,0
	; position 8 - pattern 2
	db	0,0,0,2,0,0,2,1,2,0,0,2,0,0
	; position 9 - pattern 1
	db	0,0,0,2,0,0,2,1,2,0,0,2,0,0,0
	; position 10 - pattern 5
	db	0,0,0,2,0,0,0,0,0,0,0,0,0,0
	db	-1

	; 01:  Snare / 02|Snare drum
	; position 0 - pattern 0
	db	0,2,0,2,0,2,0,2
	; position 1 - pattern 0
	db	0,2,0,2,0,2,0,2
	; position 2 - pattern 0
	db	0,2,0,2,0,2,0,2
	; position 3 - pattern 1
	db	0,2,0,2,0,2,0,2
	; position 4 - pattern 2
	db	0,2,0,2,0,2,0,2
	; position 5 - pattern 1
	db	0,2,0,2,0,2,0,2
	; position 6 - pattern 3
	db	0,2,0,3,0,2,0,2
	; position 7 - pattern 2
	db	0,2,0,2,0,2,0,2
	; position 8 - pattern 2
	db	0,2,0,2,0,2,0,2
	; position 9 - pattern 1
	db	0,2,0,2,0,2,0,2
	; position 10 - pattern 5
	db	0,2,0,2,0,1
	db	-1

	; 02:  Snare / 02|Snare drum
	; position 0 - pattern 0
	db	3,2
	; position 1 - pattern 0
	db	3,2
	; position 2 - pattern 0
	db	3,2
	; position 3 - pattern 1
	db	3,2
	; position 4 - pattern 2
	db	3,2
	; position 5 - pattern 1
	db	3,1
	; position 7 - pattern 2
	db	3,2
	; position 8 - pattern 2
	db	3,2
	; position 9 - pattern 1
	db	3,0
	db	-1

	; 03:  Bass / 00|Pad
	; position 0 - pattern 0
	db	1,7,11,14,8
	; position 1 - pattern 0
	db	1,7,11,14,8
	; position 2 - pattern 0
	db	1,7,11,14,8
	; position 3 - pattern 1
	db	1,7,11,14,8
	; position 4 - pattern 2
	db	2,15,12,9,4,9,14,5
	; position 5 - pattern 1
	db	1,7,11,14,8
	; position 6 - pattern 3
	db	0,13,3,15,2,10,6,2
	; position 7 - pattern 2
	db	2,15,12,9,4,9,14,5
	; position 8 - pattern 2
	db	2,15,12,9,4,9,14,5
	; position 9 - pattern 1
	db	1,7,11,14,8
	; position 10 - pattern 5
	db	1
	db	-1

	; 04:  Lead / 03|Lead
	; position 1 - pattern 0
	db	14,24,28,29,18,13,24,28,27,24,27,17,27,28,24,27,18,22,27,28,18,20
	; position 2 - pattern 0
	db	14,24,28,29,18,13,24,28,27,24,27,17,27,28,24,27,18,22,27,28,18,21
	; position 3 - pattern 1
	db	28,14,27,14,24,14,27,10,23,24,8,27,8,28,8,24,8,26,27,8,24,10,18,7,14,18,24,17
	; position 4 - pattern 2
	db	14,7,18,6,24,3,18,7,24,4,27,1,27,2,28,0,29,3,28,6,27,4,18,5
	; position 5 - pattern 1
	db	28,14,27,14,24,14,27,10,23,24,8,27,8,28,8,24,8,26,27,8,24,10,18,7,14,18,24,18
	; position 6 - pattern 3
	db	28,27,16,27,24,9,14,24,18,10,18,27,12
	; position 7 - pattern 2
	db	14,7,18,6,24,3,18,7,24,4,27,1,27,2,28,0,29,3,28,6,27,4,18,5
	; position 8 - pattern 2
	db	14,7,18,6,24,3,18,7,24,4,27,1,27,2,28,0,29,3,28,6,27,4,18,5
	; position 9 - pattern 1
	db	28,14,27,14,24,14,27,10,23,24,8,27,8,28,8,24,8,26,27,8,24,10,18,7,14,18,24,18
	; position 10 - pattern 5
	db	15,25,19,11,13
	db	-1

	; 05:  Lead 2 / 04|Lead 2
	; position 2 - pattern 0
	db	4,7,0,13,9,14,8
	; position 3 - pattern 1
	db	4,13,7,11,2,5,8
	; position 4 - pattern 2
	db	14,8,12,5,12,8,1,5
	; position 5 - pattern 1
	db	4,13,7,11,2,5,9
	; position 6 - pattern 3
	db	10,6,3
	; position 8 - pattern 2
	db	14,8,12,5,12,8,1,5
	; position 9 - pattern 1
	db	4,13,7,11,2,5,9
	; position 10 - pattern 5
	db	3
	db	-1

