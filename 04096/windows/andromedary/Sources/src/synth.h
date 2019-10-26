/*
    Andromedary
    Synth code
    Copyright (C) 2002 Henrik Rydgaard
    Copyright (C) 2005 Toni Lönnberg, Jetro Lauha
    Copyright (C) 2006 Jere Sanisalo, Jetro Lauha

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    
    NOTE: The original version of synth code by Henrik Rydgaard (Ector)
    was not licensed as GPL. Strictly the GPL applies only to the latest
    year 2006 modifications to the code.
*/

#ifndef SYNTH_H_INCLUDED
#define SYNTH_H_INCLUDED


#ifdef __cplusplus
extern "C" {
#endif


#define TEMPO 7500
#define TICK (TEMPO / 6)
//#define USE_CLIPPING
#define USE_VIBRATO
#define USE_HIHAT
//#define USE_NOTE_CUT

extern void initAndStartSound();

typedef unsigned int uint32;
typedef unsigned char uint8;

// Channel
typedef struct 
{
    // Filter properties
    uint8 cutoff;
    uint8 resonance;
    char transpose;     // transpose in octaves
    char lfo;           // filter sweep
    char envShift;
    char envShift2;
    uint8 detune;

    int originalVolume;
    int volume;
    int volumeFade;

#ifdef USE_VIBRATO
    float vibSpeed;
    float vibRange;
#endif

    int initPos2;       // oscillator2 init position
    int pos;            // oscillator position
    uint32 delta;       // its speed
    int pos2;           // oscillator2 position
    uint32 delta2;      // its speed

    int envPos;         // for envelope
    int filterPos;
    int filterDelta;

    uint8 note;         // 0 = off
} MelodyChannel;


enum
{
    SONGLENGTH = 36,
#ifdef USE_HIHAT
    NUMPATTERNS = 22,
#else
    NUMPATTERNS = 21,
#endif

    PATTERNLENGTH = 16,     // must be power of 2
    PATTERNLENGTH_SHIFT = 4,
#ifdef USE_HIHAT
    NUMCHANNELS = 9,
#else
    NUMCHANNELS = 8
#endif
};

extern MelodyChannel chans[NUMCHANNELS];
extern char seq[NUMCHANNELS][SONGLENGTH];
extern char patterns[NUMPATTERNS][PATTERNLENGTH];

// s = sharp note
#define HS (char)0x80   // hardsync

enum NOTES
{
#ifdef USE_NOTE_CUT
    xx = -2,
    oo = -1,
#else
    xx = -1,
#endif
    C1 = 0, Cs1, D1, Ds1, E1, F1, Fs1, G1, Gs1, A1, As1, B1,
    C2, Cs2, D2, Ds2, E2, F2, Fs2, G2, Gs2, A2, As2, B2,
    C3, Cs3, D3, Ds3, E3, F3, Fs3, G3, Gs3, A3, As3, B3,
    C4, Cs4, D4, Ds4, E4, F4, Fs4, G4, Gs4, A4, As4, B4,
    C5, Cs5, D5, Ds5, E5, F5, Fs5, G5, Gs5, A5, As5, B5,
    C6, Cs6, D6, Ds6, E6, F6, Fs6, G6, Gs6, A6, As6, B6,
    C7, Cs7, D7, Ds7, E7, F7, Fs7, G7, Gs7, A7, As7, B7,
};

extern int songPos;     // song position in 1/16 notes
extern int songTime;    // song time


#ifdef __cplusplus
};
#endif

#endif // !SYNTH_H_INCLUDED
