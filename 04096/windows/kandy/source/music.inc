;
; Demo music
;
; Author:
;	thom
;	s_tec
;

k_music_tempo	equ	1111			;Samples per row count

;Bear in mind that the sample rate is 44100 sps. Therefore, a period
;of 1378 is about 1/32 of a second. This should be enough to express 32nd
;notes in 60bpm music (or something like that).

;-----------------------------------------------------------------------------
; s_music
;
; The data format is similar to a tracker. The first column gives the time
; difference between rows, and the remaining columns give the notes to play
; on each instrument. The time difference between rows is a multiple of the
; k_music_tempo constant defined above, and must be less than 256. The
; instrument columns contain standard note names, such as c4, g5s, or b3f.
; The note column can also contain the symbol x, which means to hold the
; previous note. The lowest note is a0, the middle C is c4, and the highest
; note is g9s.
;-----------------------------------------------------------------------------
s_music:

;	time	horn	bass	tink	wind	wind
db	16,	x,	x,	x,	x,	x	;First row not played
%if 1
;
;  An empty scene...
;
db	16,	c1,	c3,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	c3,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	c1,	x,	x,	x,	x
db	16,	x,	b3,	x,	x,	x
db	16,	x,	d3s,	x,	x,	x
db	16,	x,	g3,	x,	x,	x
;
db	16,	c1,	g3s,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	g3s,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	c1,	x,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	g3s,	x,	x,	x
db	16,	x,	x,	x,	x,	x
;
;  Things begin to fall...
;
db	16,	c1,	c3,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	c3,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	c1,	x,	x,	x,	x
db	16,	x,	b3,	x,	x,	x
db	16,	x,	d3s,	x,	x,	x
db	16,	x,	g3,	x,	x,	x
;
db	16,	c1,	e3,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	g3,	x,	x,	x
db	16,	c1,	e3,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	d3s,	x,	x,	x
db	16,	x,	x,	d8s,	x,	x
;
;  They explode...
;
db	16,	c1,	c3,	e8,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	c1,	x,	x,	x,	x
db	16,	x,	b3,	x,	x,	x
db	16,	x,	d3s,	x,	x,	x
db	16,	x,	g3,	e8,	x,	x
;
db	16,	c1,	g3s,	d8s,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	g3s,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	c1,	x,	x,	x,	x
db	16,	x,	b3,	x,	x,	x
db	16,	x,	d3s,	x,	x,	x
db	16,	x,	g3,	d8s,	x,	x
;
db	16,	c1,	c3,	e8,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	c1,	x,	x,	x,	x
db	16,	x,	b3,	x,	x,	x
db	16,	x,	d3s,	x,	x,	x
db	16,	x,	g3,	e8,	x,	x
;
db	16,	c1,	e3,	d8s,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	e1,	x,	x,	x,	x
db	16,	x,	x,	e8,	x,	x
db	16,	c1,	e3,	d8s,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	g1s,	x,	x,	x,	x
db	16,	x,	x,	d8,	x,	x
;
;  Mr. Spiky attacks...
;
db	16,	c1,	x,	d8s,	x,	x
db	16,	x,	x,	x,	g4s,	x
db	16,	c1,	x,	x,	a5,	x
db	16,	x,	x,	d8s,	x,	x
db	16,	c1,	x,	x,	g4s,	x
db	16,	x,	x,	x,	a5,	x
db	16,	c1,	x,	d8s,	x,	x
db	16,	x,	x,	x,	x,	x
;
db	16,	c1,	x,	d8s,	x,	x
db	16,	x,	x,	x,	g4s,	x
db	16,	c1,	x,	x,	a5,	x
db	16,	x,	x,	x,	f4,	x
db	16,	c1,	x,	x,	f4s,	x
db	16,	x,	x,	x,	x,	x
db	16,	c1,	x,	x,	x,	x
db	16,	x,	x,	x,	x,	x
;
db	16,	c1,	x,	x,	x,	x
db	16,	x,	x,	x,	g4s,	x
db	16,	c1,	x,	x,	a5,	x
db	16,	x,	x,	d8s,	x,	x
db	16,	c1,	x,	x,	g4s,	x
db	16,	x,	x,	x,	a5,	x
db	16,	c1,	x,	d8s,	x,	x
db	16,	x,	x,	x,	x,	x
;
db	16,	c1,	x,	d8s,	x,	x
db	16,	x,	x,	x,	g4s,	x
db	16,	c1,	x,	x,	a5,	x
db	16,	x,	x,	x,	f4,	x
db	16,	c1,	x,	d8s,	x,	x
db	16,	x,	x,	x,	f4,	x
db	16,	c1,	x,	x,	f4s,	x
db	16,	x,	x,	x,	d4,	x
%endif
;
;  Minor 49'er...
;
db	16,	c1,	g3,	x,	c4,	e4f
db	16,	x,	c3,	x,	x,	x
db	16,	x,	e3f,	x,	x,	x
db	16,	x,	c3,	x,	d4,	f4
db	16,	c1,	g3,	x,	e4f,	g4
db	16,	x,	c3,	x,	x,	x
db	16,	x,	e3f,	x,	x,	x
db	16,	x,	c3,	x,	d4,	f4
;
db	16,	c1,	g3,	x,	e4f,	g4
db	16,	x,	c3,	x,	x,	x
db	16,	x,	f3,	x,	f4,	a5f
db	8,	x,	c3,	x,	x,	x
db	8,	x,	x,	x,	f4,	a5f
db	16,	c1,	g3,	x,	e4f,	g4
db	16,	x,	c3,	x,	x,	x
db	16,	x,	e3f,	x,	x,	x
db	16,	x,	c3,	x,	e4f,	g4
;
db	16,	d1,	g3,	x,	d4,	f4
db	16,	x,	b3,	x,	x,	x
db	16,	x,	f3,	x,	x,	x
db	16,	x,	b3,	x,	e4f,	g4
db	16,	d1,	g3,	x,	d4,	f4
db	16,	x,	b3,	x,	x,	x
db	16,	x,	f3,	x,	x,	x
db	16,	x,	b3,	x,	e4f,	g4
;
db	16,	d1,	g3,	x,	d4,	f4
db	16,	x,	b3,	x,	e4f,	g4
db	16,	x,	d3,	x,	f4,	a5f
db	16,	x,	b3,	x,	g4,	b5f
db	16,	d1,	g3,	x,	f4,	b5
db	16,	x,	b3,	x,	x,	x
db	16,	x,	g3,	x,	f4,	b5
db	16,	x,	b3,	x,	x,	x
;
;  Major general...
;
db	16,	c1,	g3,	x,	e4,	c5
db	16,	x,	c3,	c8,	x,	x
db	16,	x,	e3,	b8,	x,	x
db	16,	x,	c3,	a8,	f4,	d5
db	16,	c1,	g3,	g7,	e4,	c5
db	16,	x,	c3,	f7,	x,	x
db	16,	x,	e3,	e7,	x,	x
db	16,	x,	c3,	d7,	f4,	d5
;
db	16,	c1,	g3,	c7,	e4,	c5
db	16,	x,	c3,	c8,	f4,	d5
db	16,	x,	e3,	b8,	e4,	c5
db	16,	x,	c3,	a8,	f4,	d5
db	16,	c1,	g3,	g7,	g4,	e5
db	16,	x,	c3,	f7,	x,	x
db	16,	x,	e3,	e7,	x,	x
db	16,	x,	c3,	d7,	x,	x
;
db	16,	c1,	g3,	c7,	d4,	b5
db	16,	x,	c3,	x,	x,	x
db	16,	x,	e3,	x,	x,	x
db	16,	x,	c3,	c7,	x,	x
db	16,	c1,	c4,	e7,	e4,	c5
db	16,	x,	e3,	x,	x,	x
db	16,	x,	g3,	x,	e4,	c5
db	8,	x,	e3,	e7,	x,	x
db	8,	x,	x,	x,	e4,	c5

;
db	8,	c1,	c3,	g7,	e4,	c5
db	16,	x,	x,	g7,	x,	x
db	16,	x,	x,	g7,	x,	x
db	8,	x,	x,	d7,	x,	x
db	16,	x,	x,	e7,	x,	x
db	16,	x,	x,	c7,	x,	x
db	16,	x,	x,	x,	x,	x
db	16,	c2,	c3,	c8,	x,	x
db	16,	x,	x,	x,	x,	x
;

db	255,	x,	x,	x,	x,	x	;Song must be as long as the
db	255,	x,	x,	x,	x,	x	; demo to avoid a segfault
db	255,	x,	x,	x,	x,	x
db	255,	x,	x,	x,	x,	x
db	255,	x,	x,	x,	x,	x
db	255,	x,	x,	x,	x,	x
db	255,	x,	x,	x,	x,	x

;-----------------------------------------------------------------------------
; Envelopes for the various instruments. These envelopes set the duration
; and volume of each instrument's notes. The first column must be a decimal
; number, and gives the amplitude. The second value is an integer, and gives
; the time difference until the envelope reaches the next amplitude value.
; The total instrument length is the sum of the individual time differences.
;-----------------------------------------------------------------------------

k_bass_length	equ	45000
s_bass_env:	dd	0.0,	4000
		dd	2.4,	2000
		dd	1.8,	36000
		dd	1.2,	3000
		dd	0.0

k_horn_length	equ	46000
s_horn_env:	dd	0.0,	4000
		dd	0.45,	40000
		dd	0.35,	2000
		dd	0.0

k_tink_length	equ	28000
s_tink_env:	dd	0.0,	500
		dd	0.08,	2500
		dd	0.04,	25000
		dd	0.0

k_wind_length	equ	36000
s_wind_env:	dd	0.0,	4000
		dd	0.3,	2000
		dd	0.25,	16000
		dd	0.1,	14000
		dd	0.0

		;Master volume slider:
s_synth_master:	dd	0.25,	k_music_tempo*16*8     ;First two opening measures
		dd	0.8,	k_music_tempo*16*(8*7) ;Opening body
		dd	0.8,	k_music_tempo*16*(8*4) ;Fireball
		dd	0.8,	k_music_tempo*16*(8*4) ;Closing 1
		dd	0.8,	k_music_tempo*16*(8*4) ;Closing 2
		dd	0.75

;-----------------------------------------------------------------------------
; Instrument parameters.
;-----------------------------------------------------------------------------

s_wind_shift:	dd	0.006			;Wind frequency shift
s_bass_lfo0:	dd	0.0003			;LFO frequency 
s_bass_lfo1:	dd	0.05			;LFO amplitude 
s_bass_level:	dd	0.1
s_horn_lfo0:	dd	0.0003			;LFO frequency 
s_horn_lfo1:	dd	0.10			;LFO amplitude 
s_horn_lpf:	dd	0.97			;Filter pole location
