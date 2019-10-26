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

/* Original comments:
 *
 * synth
 * original version by ector
 * modified by tonic
 * heavily modified by !cube
 * and then again modified by tonic and xmunkki
 */

#define WIN32_LEAN_AND_MEAN
#define VC_EXTRALEAN
#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>
#include "minimath.h"
#include "synth.h"


#define TOTAL_HEADER_SIZE   44
#define WAVE_HDR_SIZE       36
#define AUDIO_SECONDS       92
#define WAV_FREQ            44100
#define WAV_DATA_SIZE       (AUDIO_SECONDS * WAV_FREQ * 2)
#define WAV_FILE_SIZE       (WAV_DATA_SIZE + TOTAL_HEADER_SIZE)

//#define SAVE_WAV


char wavHeader[TOTAL_HEADER_SIZE] = {
	'R','I','F','F',
	(char)((WAV_DATA_SIZE + WAVE_HDR_SIZE) & 0xff),
	(char)(((WAV_DATA_SIZE + WAVE_HDR_SIZE) >> 8) & 0xff),
	(char)(((WAV_DATA_SIZE + WAVE_HDR_SIZE) >> 16) & 0xff),
	(char)(((WAV_DATA_SIZE + WAVE_HDR_SIZE) >> 24) & 0xff),
	'W','A','V','E',
	'f','m','t',' ',
	16,             // 4 bytes chunk data size
	0,
	0,
	0,
	1,              // 2 bytes compression code (PCM)
	0,
	1,              // 2 bytes number of channels (mono)
	0,
	(char)WAV_FREQ, // sample rate
	(char)(WAV_FREQ>>8),
	0,
	0,
	(char)WAV_FREQ, // average bytes per second
	(char)(WAV_FREQ>>8),
	0,
	0,
	2,		// block align (bytes per sample slice)
	0,
	16,		// bits per sample
	0,
	'd','a','t','a',
	(char)(WAV_DATA_SIZE & 0xFF),
	(char)((WAV_DATA_SIZE >> 8) & 0xFF),
	(char)((WAV_DATA_SIZE >> 16) & 0xFF),
	(char)((WAV_DATA_SIZE >> 24) & 0xFF)
};

unsigned char wavFile[WAV_FILE_SIZE];
unsigned short *wav;


// Globals
int songPos = 0;    // 1/16 notes
int songTime = 0;   // samples
int tempoTime = 0;
int tickTime = 0;

#define LFO_BASE 0
#define LFO_PHASE PI
#define LFO_RANGE 128
#define LFO_SPEED (2 * PI) / (TEMPO * 32)

#define START_CHANNEL 0
#ifdef USE_HIHAT
#define END_CHANNEL 8
#else
#define END_CHANNEL 7
#endif

#define DELAY_CHANNELS 3
#define BASSDRUM_CHANNEL 5
#define SNARE_CHANNEL 6
#define HIHAT_CHANNEL 7
#define SHIFT_OPT (10 - BASSDRUM_CHANNEL)

#define DELAYSIZE (TEMPO * 3)
static int delayBuffer[DELAYSIZE];
static int delayPos = 0, cutAdd;
static int n1;
#ifdef USE_HIHAT
static int n2;
#endif


//static int My_Ftoi( float x )
#ifndef NOT_JERE
__forceinline int My_Ftoi( float x )
{
    int ret_val;
    __asm
    {
        fld dword ptr x
            //frndint
            fistp dword ptr ret_val
    }
    return ret_val;
}
#else
#define My_Ftoi
#endif


__forceinline void soundStep()
{
    int i;
    for (i = START_CHANNEL; i < END_CHANNEL; ++i) //for (i = 0; i < NUMCHANNELS; i++)
    {
        int pat = seq[i][(songPos >> PATTERNLENGTH_SHIFT) % SONGLENGTH];   // current pattern (with looping)
        
        if (pat)
        {
            int note = patterns[pat - 1][songPos & (PATTERNLENGTH - 1)];    // current note
            
            if (note != xx)
            {
                chans[i].note = (note & 0x7F);
                chans[i].delta = (uint32)My_Ftoi(398126.91177592743764172335600907f * pow(2.0f, (float)(chans[i].note + chans[i].transpose) / 12.0f));
                chans[i].delta2 = chans[i].delta + ((chans[i].detune) << 13);
                if (note & 0x80)
                {
                    chans[i].pos = 0;
                    chans[i].pos2 = chans[i].initPos2;
                }
                chans[i].envPos = 1 << 24;
                chans[i].volume = (chans[i].originalVolume << 8);

#ifdef USE_HIHAT
                if (!(note & 1) && (i == HIHAT_CHANNEL))
                    chans[i].volume = (chans[i].volume * 5) >> 3;
#endif
            }
        }
    }

    ++songPos;
}



static int synthrandseed = 0x2;
__forceinline int synthrand()
{
    synthrandseed *= 16807;
    return synthrandseed;
}


__forceinline void sound_fillBuffer()
{
    int i, wave, c, v, t;
    short *fillPos = wav;

    for (i = 0; i < WAV_DATA_SIZE / 2; ++i) 
    {
        cutAdd = LFO_BASE + (int)My_Ftoi(LFO_RANGE * ((float)cos(LFO_PHASE + (float)songTime * LFO_SPEED)));

        if (tempoTime == 0)
            soundStep();    // step song forward

        wave = 0;   // current sample
        v = 0;

        for (c = START_CHANNEL; c < END_CHANNEL; ++c) //for (c = 0; c < NUMCHANNELS; c++)
        {
            int sample, sample2;

            // if note cut is needed, remove comments
#ifdef USE_NOTE_CUT
            if (chans[c].note != oo)
#endif
            {
#ifdef USE_VIBRATO
                int vibrato = (int)My_Ftoi(sin((float)songTime / chans[c].vibSpeed) * chans[c].vibRange);
#endif

                sample = (int)(chans[c].pos >> 18);

                sample2 = (int)(chans[c].pos2 >> 18);
                sample = sample - sample2;

                t = chans[c].pos >> 26;
#ifdef USE_VIBRATO
                chans[c].pos += chans[c].delta + vibrato;         // go forward saw wave
                chans[c].pos2 += chans[c].delta2 + vibrato;       // go forward saw wave
#else
                chans[c].pos += chans[c].delta;         // go forward saw wave
                chans[c].pos2 += chans[c].delta2;       // go forward saw wave
#endif

                if (t != (chans[c].pos >> 26))
                {
#ifdef USE_HIHAT
                    if (c == SNARE_CHANNEL)
                        n1 = synthrand() & 0x3fff;
                    else if (c == HIHAT_CHANNEL)
                        n2 = synthrand() & 0x3fff;
#else
                    if (c == SNARE_CHANNEL)
                        n1 = synthrand() & 0x3fff;
#endif
                }

                chans[c].envPos -= chans[c].envPos >> chans[c].envShift;
            }
#ifdef USE_NOTE_CUT
            else sample = 0;
#endif

            if (c == DELAY_CHANNELS)
            {
                //-- DELAY -------------------------------------------
                // do delay effect here so that it will not affect drums
                // TODO: FIX DELAY
                /*
                v = (delayBuffer[delayPos] * 5) >> 3;
                delayBuffer[delayPos] = v + wave;
                ++delayPos;
                if (delayPos >= DELAYSIZE)
                    delayPos = 0;
                */
                /*
                if (++delayPos >= 0)
                {
                    v = (wav[delayPos] * 5) >> 5;
                }
                */
                v = (delayBuffer[delayPos] * 5) >> 3;
                delayBuffer[delayPos] = wave;
                delayPos = (delayPos + 1) % DELAYSIZE;
                
                //-- END DELAY -------------------------------------------
            }

            if (c == BASSDRUM_CHANNEL || c == SNARE_CHANNEL)
            {
                chans[c].delta -= chans[c].delta >> (c + SHIFT_OPT);
                chans[c].delta2 = chans[c].delta;
                if (c == SNARE_CHANNEL) sample += n1;
            }
#ifdef USE_HIHAT
            else if (c == HIHAT_CHANNEL)
            {
                sample = n2;
            }
#endif

            // volume
            sample = (sample * (chans[c].volume >> 8)) >> 8;

            if (tickTime == 0)
            {
                chans[c].volume -= chans[c].volumeFade;
                if (chans[c].volume < 0) chans[c].volume = 0;
            }

            {
                int cut = chans[c].cutoff + (chans[c].envPos >> chans[c].envShift2);
                if (chans[c].lfo)
                    cut += cutAdd;

                if (cut < 10)
                    cut = 10;

                chans[c].filterDelta = (chans[c].filterDelta * chans[c].resonance) >> 8;
                chans[c].filterDelta += ((sample - chans[c].filterPos) * cut) >> 11;
                chans[c].filterPos += chans[c].filterDelta;
            }

            wave += chans[c].filterPos;
        }

        {

            int sample = (wave + v) >> 1;
#ifdef USE_CLIPPING
            if (sample < -32768) sample = -32768;
            if (sample > 32767) sample = 32767;
#endif

#ifdef _DEBUG
            if (i >= WAV_DATA_SIZE / 2)
                MessageBox(NULL, "Too much audio data!", "Error", MB_OK);
#endif
            fillPos[i] = sample;
        }

        ++songTime;
        if (++tempoTime > TEMPO)
            tempoTime = 0;
        if (++tickTime > TICK)
            tickTime = 0;
    }
}


void initAndStartSound()
{
    int a;
    wav = (short *)(wavFile + TOTAL_HEADER_SIZE);
    for (a = TOTAL_HEADER_SIZE; a--;)
        wavFile[a] = wavHeader[a];
    for (a = DELAYSIZE; a--;)
        delayBuffer[a] = 0;

    sound_fillBuffer();

#ifdef SAVE_WAV
    {
        FILE *f;
        f=fopen("out.wav", "wb");
        fwrite(wavFile, WAV_FILE_SIZE, 1, f);
        fclose(f);
    }
#endif // SAVE_WAV

    PlaySound(wavFile, 0, SND_ASYNC | SND_MEMORY);
}


#define PAD_RESO 235
#define PAD_VOLUME 150
#define PAD_FADEOUT 100

#define CHORD_RESO 250
#define CHORD_VOLUME 60
#define CHORD_FADEOUT 80
#define CHORD_TRANSPOSE (2 * 12)
#define CHORD_TYPE 1
#define CHORD_LFO 1
#define CHORD_ENVSHIFT 4
#define CHORD_ENVSHIFT2 17
#define CHORD_DETUNE 8
#define CHORD_INITPOS2 0
#define CHORD_VIBSPEED 1200
#define CHORD_VIBRANGE 400000

//#pragma data_seg( "a1" )

MelodyChannel chans[NUMCHANNELS] =
{
    /* PLUCK */
    {
        /*cutoff*/      100,
        /*reso*/        253,
        /*transpose*/   (4 * 12),
        /*lfo*/         1,
        /*envshift*/    24,
        /*envshift2*/   17,
        /*detune*/      12,
        /*org.volume*/  50,
        /*volume*/      0,
        /*fadeout*/     (10 << 8),
#ifdef USE_VIBRATO
        /*vibSpeed*/    600,
        /*vibRange*/    150000,
#endif
        /*initPos2*/    (8192 << 18)
    },

    /* CHORD1 */
    {
        /*cutoff*/      0,
        /*reso*/        CHORD_RESO, 
        /*transpose*/   CHORD_TRANSPOSE, 
        /*lfo*/         CHORD_LFO, 
        /*envshift*/    CHORD_ENVSHIFT, 
        /*envshift2*/   CHORD_ENVSHIFT2, 
        /*detune*/      CHORD_DETUNE,
        /*volume*/      CHORD_VOLUME, 
        0, 
        /*fadeout*/     CHORD_FADEOUT, 
#ifdef USE_VIBRATO
        /*vibSpeed*/    CHORD_VIBSPEED,
        /*vibRange*/    CHORD_VIBRANGE,
#endif
        /*initPos2*/    CHORD_INITPOS2
    },

    /* CHORD2 */
    {
        /*cutoff*/      0,
        /*reso*/        CHORD_RESO, 
        /*transpose*/   CHORD_TRANSPOSE, 
        /*lfo*/         CHORD_LFO, 
        /*envshift*/    CHORD_ENVSHIFT, 
        /*envshift2*/   CHORD_ENVSHIFT2, 
        /*detune*/      CHORD_DETUNE,
        /*volume*/      CHORD_VOLUME, 
        0, 
        /*fadeout*/     CHORD_FADEOUT, 
#ifdef USE_VIBRATO
        /*vibSpeed*/    CHORD_VIBSPEED,
        /*vibRange*/    CHORD_VIBRANGE,
#endif
        /*initPos2*/    CHORD_INITPOS2
    },
    /* PAD OCTAVE 1 */
    {
        /*cutoff*/      0, 
        /*reso*/        PAD_RESO,
        /*transpose*/   (-1 * 12),
        /*lfo*/         1, 
        /*envshift*/    24,
        /*envshift2*/   17, 
        /*detune*/      6,
        /*volume*/      PAD_VOLUME,
        0,
        /*fadeout*/     PAD_FADEOUT,
#ifdef USE_VIBRATO
        /*vibSpeed*/    1600,
        /*vibRange*/    150000,
#endif
        /*initPos2*/    (8192 << 18)
    },

    /* PAD OCTAVE 2 */
    {
        /*cutoff*/      0, 
        /*reso*/        PAD_RESO,
        /*transpose*/   0,
        /*lfo*/         1, 
        /*envshift*/    24,
        /*envshift2*/   17, 
        /*detune*/      6,
        /*volume*/      PAD_VOLUME,
        0,
        /*fadeout*/     PAD_FADEOUT,
#ifdef USE_VIBRATO
        /*vibSpeed*/    1600,
        /*vibRange*/    150000,
#endif
        /*initPos2*/    (8192 << 18)
    },

    /* BASSDRUM */
    {
        /*cutoff*/      0, 
        /*reso*/        0,
        /*transpose*/   (6 * 12)-4,
        /*lfo*/         0, 
        /*envshift*/    24,
        /*envshift2*/   17,
        /*detune*/      6,
        /*volume*/      250,
        0,
        /*fadeout*/     (10 << 8),
#ifdef USE_VIBRATO
        /*vibSpeed*/    1,
        /*vibRange*/    1,
#endif
        /*initPos2*/    (8192 << 18)
    },

    /* SNARE */
    {
        /*cutoff*/      0, 
        /*reso*/        251,
        /*transpose*/   (4 * 12),
        /*lfo*/         0, 
        /*envshift*/    24,
        /*envshift2*/   16,
        /*detune*/      0,
        /*volume*/      80,
        0,
        /*fadeout*/     (4 << 8),
#ifdef USE_VIBRATO
        /*vibSpeed*/    1,
        /*vibRange*/    1,
#endif
        /*initPos2*/    (8192 << 18)
    },

#ifdef USE_HIHAT
    /* HIHAT */
    {
        /*cutoff*/      0, 
        /*reso*/        0,
        /*transpose*/   (7 * 12),
        /*lfo*/         0, 
        /*envshift*/    24,
        /*envshift2*/   15,
        /*detune*/      0,
        /*volume*/      165,
        0,
        /*fadeout*/     (70 << 8),
#ifdef USE_VIBRATO
        /*vibSpeed*/    1,
        /*vibRange*/    1,
#endif
        /*initPos2*/    0
    },
#endif
};


enum
{
    L1 = 1,
    L2,
    L3,
    L4,
    C_C4,
    C_C5,
    C_A3,
    C_A4,
    C_G4,
    C_G5,
    C_E4,
    C_E5,
    BD1,
    BD2,
    SN1,
    SN2,
    H
};

//#pragma data_seg( "a2" )



// song orders with pattern for each channel 
// time goes horizontally, 0 = no pattern
char seq[NUMCHANNELS][SONGLENGTH] =
{   //                |**-----------  ***------------.  |**-------------  ***------------.  |**-------------  ***------------.  |**----------.  !  !  !  !
    {   0, 0,   0, 0,   0,  0,   0, 0,  0,  0,   0,  0,
                                                          0,  0,   0,  0,  L3,  0,  L4,  0,  L1, L1,  L2, L2,  L3, L3,  L4, L4,   0, 0,   0, 0, 0, 0, 0, 0 },
    {   0, 0,   0, 0,   0, 0,   0, 0,C_C4,  0,C_A3,  0,C_G4,  0,C_E4,  0,C_C4,  0,C_A3,  0,C_G4,  0,C_E4,  0,C_C4,  0,C_A3,  0,C_G4, 0,C_E4, 0, 0, 0, 0, 0 },
    {   0, 0,   0, 0,   0, 0,   0, 0,C_C5,  0,C_A4,  0,C_G5,  0,C_E5,  0,C_C5,  0,C_A4,  0,C_G5,  0,C_E5,  0,C_C5,  0,C_A4,  0,C_G5, 0,C_E5, 0, 0, 0, 0, 0 },
    {C_C4, 0,   0, 0,C_G4, 0,   0, 0,   0,  0,C_A4,  0,C_G4,  0,C_E4,  0,C_C4,  0,C_A4,  0,C_G4,  0,C_E4,  0,C_C4,  0,C_A4,  0,C_G4, 0,C_E4, 0, 0, 0, 0, 0 },
    {C_C4, 0,   0, 0,C_G4, 0,   0, 0,   0,  0,C_A4,  0,C_G4,  0,C_E4,  0,C_C4,  0,C_A4,  0,C_G4,  0,C_E4,  0,C_C4,  0,C_A4,  0,C_G4, 0,C_E4, 0, 0, 0, 0, 0 },
    {   0, 0,   0, 0,   0, 0,   0, 0,   0,  0,   0,BD2, BD1,BD2, BD1,BD2, BD1,BD2, BD1,BD2, BD1,BD2, BD1,BD2, BD1,BD2, BD1,BD2,   0, 0,   0, 0, 0, 0, 0, 0 },
    {   0, 0,   0, 0,   0, 0,   0, 0,   0,  0,   0,  0,   0,  0,   0,SN2, SN1,SN2, SN1,SN2, SN1,SN2, SN1,SN2, SN1,SN2, SN1,SN2,   0, 0,   0, 0, 0, 0, 0, 0 },
#ifdef USE_HIHAT
    {    0, 0,   0, 0,   0, 0,   0, 0,   0,  0,   0,  0,   H,  H,   H,  H,   H,  H,   H,  H,   H,  H,   H,  H,   H,  H,   H,  H,   H, H,   0, 0, 0, 0, 0, 0 },
#endif
};

// patterns (x = no note)

#define BASSDRUM C1 | HS
#define SNARE G2 | HS
#define HIHAT1 Cs2
#define HIHAT2 C2

//#pragma data_seg( "a3" )

char patterns[NUMPATTERNS][PATTERNLENGTH] = 
{
    // sekv
    { G3 | HS, xx, xx, xx, G4, xx, xx, xx, xx, xx, F4, xx, G4, xx, xx, xx },
    { E3 | HS, xx, xx, xx, E4, xx, xx, xx, A4, xx, xx, xx, E4, xx, D4, xx },
    { C3 | HS, xx, xx, xx, C4, xx, xx, xx, F4, xx, xx, xx, C4, xx, As3, xx },
    { A2 | HS, xx, xx, xx, A3, xx, xx, xx, A4, xx, xx, xx, E3, xx, G3, xx },

    // chords
    { C4 | HS, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx },
    { C5 | HS, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx },
    { A3 | HS, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx },
    { A4 | HS, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx },
    { G4 | HS, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx },
    { G5 | HS, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx },
    { E4 | HS, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx },
    { E5 | HS, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx },

    // drums
    { BASSDRUM, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, BASSDRUM, xx, BASSDRUM },
    { BASSDRUM, xx, xx, xx, BASSDRUM, xx, xx, xx, xx, xx, xx, BASSDRUM, xx, xx, xx, xx },
    { xx, xx, xx, xx, SNARE, xx, xx, xx, xx, xx, xx, xx, SNARE, xx, xx, xx },
    { xx, xx, xx, xx, SNARE, xx, xx, xx, xx, xx, xx, xx, xx, xx, SNARE, xx },
#ifdef USE_HIHAT
    { xx, xx, HIHAT1, HIHAT2, xx, xx, HIHAT1, HIHAT2, xx, xx, HIHAT1, HIHAT2, HIHAT1, HIHAT2, HIHAT1, HIHAT2 },
#endif
};
