#include "notetable.h"
#include "sys/types.h"

// Total song length
#define SONGLEN ((11 * 4) + 1) // ~80 sec tj

// Pattern length in ticks
#define PATTLEN 16

// Tick length
#define TICKLEN 5500

// Detune amount for dual saw osc
#define DETUNE_AMT 30000

// Flag definitions
#define FILTER_LP 0
#define FILTER_HP 0x40
#define DIST 0x80
#define PITCH_SLIDE 0x20

// Osc types
#define SAW_DUAL 0x10
#define NOISE 0x08
#define SINE 0x02

typedef int16_t sample_t;
typedef unsigned char uint8_t;

#define VOICES_NORMAL 6
#define VOICES_CHORD 3

const signed char chords[] = {
    0, 4, 9, // min
    0, 3, 8,  // maj
    0, -1, -1, // 1
    0, 7, -1, // 1+5
};

#define SONGSTART 0

const uint8_t song[SONGLEN * (VOICES_NORMAL + 1)] = {
    // bd
    7, 7, 7, 7,

    7, 7, 7, 7,
    0, 0, 0, 7,

    0, 0, 0, 14, // däns tästä

    0, 0, 0, 14,
    0, 14, 0, 14,

    0, 0, 0, 0,
    0, 0, 0, 14,

    0, 0, 0, 18,
    
    0, 0, 0, 14,
    0, 0, 0, 18,

    22,

    // bass
    11, 11, 11, 11,

    21, 21, 21, 21,
    21, 21, 21, 1,

    1, 1, 6, 6,

    10, 10, 6, 6,
    10, 10, 6, 6,

    1, 1, 6, 6,
    1, 1, 10, 10,

    6, 1, 10, 10,

    1, 1, 6, 6,
    1, 1, 6, 6,

    7,

    // hihat
    7, 7, 7, 7,

    7, 7, 7, 7,
    7, 7, 7, 7,

    3, 3, 3, 3,

    3, 3, 3, 3,
    3, 3, 3, 3,

    3, 3, 3, 3,
    3, 3, 3, 3,

    3, 3, 3, 3,

    3, 3, 3, 3,
    3, 3, 3, 3,

    7,

    // dii
    7, 7, 7, 7,

    7, 7, 7, 7,
    7, 7, 7, 7,

    7, 7, 7, 7,

    5, 13, 5, 13,
    19, 20, 13, 5,

    17, 7, 7, 7,
    7, 7, 7, 7,

    7, 7, 7, 7,

    20, 5, 20, 13,
    19, 20, 13, 5,

    17,

    // dii2
    7, 7, 7, 7,

    7, 7, 7, 7,
    7, 7, 7, 7,

    7, 7, 7, 7,

    7, 7, 7, 7,
    7, 7, 7, 7,

    4, 4, 16, 16,
    4, 4, 16, 16,

    7, 7, 7, 7,

    4, 4, 16, 16,
    4, 4, 16, 16,

    22,

    // sd
    7, 7, 7, 7,

    7, 7, 7, 7,
    7, 7, 7, 7,

    8, 8, 8, 9,

    8, 8, 8, 9,
    8, 8, 8, 9,

    8, 8, 8, 9,
    8, 8, 8, 9,

    8, 8, 8, 9,

    8, 8, 8, 9,
    8, 8, 8, 9,

    7,

    // chord
    7, 7, 7, 7,

    7, 7, 7, 7,
    7, 7, 7, 7,

    2, 2, 12, 12,

    15, 15, 12, 12,
    15, 15, 12, 12,

    2, 2, 12, 12,
    2, 2, 15, 15,

    12, 2, 15, 15,

    2, 2, 12, 12,
    2, 2, 12, 12,

    7,
};

const uint8_t patterns[] = {
    // BD
    // 0
    c2 acc, pp, pp, pp, c2 acc, pp, pp, pp,
    c2 acc, pp, pp, pp, c2 acc, pp, pp, pp,

    // bass 1
    // 1
    f2 acc, f2, f3 acc, f2, f2 acc, f2, gs3 acc, c2 acc,
    c2, c3, c2 acc, cs3, cs2, ds2, ds2 acc, ds3,

    // chord 1 f
    // 2
    f0 C4, f0 C3, g1 C2, ds1 C3, g1 C2, gs1 C1, pp, gs1 C1,
    pp, f1 C3, c1 C2, gs0 C4, gs1 C1, gs1 C1, as1 C3, f0 C4,

    // hihat
    // 3
    c1, c1, c1 acc, c1, c1, c1, c1 acc, c1,
    c1, c1, c1 acc, c1 acc, c1, c1 acc, c1, c1,

    // dii 1
    // 4
    c4, pp, c5 acc, c4, as3, c4 acc, c5, c4,
    pp, c4, c5 acc, c4, as3, c4 acc, c5, c4,

    // dii 2
    // 5
    ds5, ds5, ds5, ds5, ds5, ds5, f5, f5,
    f5, f5, f5, f5, gs5, gs5, gs5, gs5, 

    // bass 2
    // 6
    cs2 acc, cs2, cs3 acc, cs2, cs2 acc, cs2, cs3 acc, c2 acc,
    cs2 acc, cs2, cs3 acc, cs2, cs2 acc, cs2, cs3 acc, gs2 acc,

    // hilj
    // 7
    pp, pp, pp, pp, pp, pp, pp, pp,
    pp, pp, pp, pp, pp, pp, pp, pp,

    // sd 1
    // 8
    pp, pp, pp, pp, c1, pp, pp, pp, 
    pp, pp, pp, pp, c1, pp, pp, pp, 

    // sd 2
    // 9
    pp, pp, pp, pp, c1, pp, pp, pp, 
    pp, pp, pp, pp, c1, c2, pp, c1, 

    // bass 2
    // 10
    as2 acc, as2, as3 acc, as2, as2 acc, as2, gs3 acc, as2 acc,
    as2 acc, as2, as3 acc, as2, as2 acc, as2, gs3 acc, as2 acc,

    // dii 
    // 11 b
    f2, pp, pp, pp, gs2, pp, gs3 acc, pp,
    g2, pp, pp, pp, g3, pp, pp, pp,

    // chord 2 g#
    // 12
    cs1 C4, cs1 C3, f1 C2, pp, f1 C2, f1 C2, pp, f1 C2,
    cs1 C3, f1 C3, c1 C2, gs0 C4, gs1 C1, gs1 C1, as1 C3, f0 C4,

    // dii 3
    // 13
    gs5, gs5, gs5, gs5, g5, g5, g5, g5,
    f5, f5, f5, f5, g5, g5, g5, g5,

    // BD2
    // 14
    c2 acc, pp, pp, pp, c2 acc, pp, pp, pp,
    c2 acc, pp, pp, pp, c2 acc, pp, c2 acc, pp,

    // chord 3 a#min
    // 15
    cs1 C4, cs1 C3, cs1 C1, pp, cs1 C1, cs1 C1, pp, cs1 C1,
    cs1 C4, cs1 C3, cs1 C1, pp, cs1 C1, cs1 C1, pp, cs1 C1,

    // dii /203948
    // 16
    c4, pp, cs5 acc, cs4, cs3, cs4 acc, cs5, cs4,
    pp, cs4, gs5 acc, cs4, cs3, cs4 acc, cs5, cs4,

    // BD
    // 17
    c6, c6, c6, c6, c6, pp, g5, pp,
    c5, pp, c5, pp, pp, pp, pp, pp,

    // BD
    // 18
    c2 acc, pp, c2 acc, pp, c2 acc, pp, c2 acc, pp,
    c2 acc, c2 acc, c2 acc, c2 acc, c2 acc, c2 acc, c2 acc, c2 acc,

    // dii 3
    // 19
    gs5, gs5, gs5, gs5, gs5, gs5, as5, as5,
    as5, as5, as5, as5, c6, c6, c6, c6,

    //dii 2
    // 20
    c6, c6, c6, c6, as5, as5, as5, as5,
    gs5, gs5, gs5, gs5, as5, as5, as5, as5,

    // kakkabasso
    // 21
    f2 acc, pp, f3 acc, f3, gs2 acc, pp, gs3 acc, pp,
    g2, pp, g3 acc, g2, g2, pp, ds3 acc, pp,

    // loppu
    // 22
    f1 acc, f2, pp, c1, pp, c3, c1, pp,
    pp, pp, pp, pp, pp, pp, pp, pp,
 };

#define INSTR_LEN 6

#define INSTR_FLAGS 0
#define INSTR_VOL 1
#define INSTR_VOLSLIDE 2
#define INSTR_PITCHSLIDE 3
#define INSTR_Q 4
#define INSTR_F 5

// flags, vol, vol slide, pitch slide, Q, F
const signed short instruments[(VOICES_NORMAL + 1) * INSTR_LEN] = {
    // bd
    FILTER_LP | SINE | PITCH_SLIDE, 15000, 5, 100, 30000, 30000,
    // bass
    FILTER_LP | SAW_DUAL, 32000, 6, 0, 10000, 10000,
    // hihat
    FILTER_HP | NOISE,                    28000, 20, 0, 4000, 5000,
    // dii
    FILTER_LP | SAW_DUAL, 13000, 0, 0, 4000, 8000,
    // dii2
    FILTER_LP | SAW_DUAL | DIST, 8000, 7, 0, 4000, 5000,
    // sd
    FILTER_LP | NOISE, 32000, 4, 1, 10000, 20000,

    // sointu
    FILTER_HP | SAW_DUAL, 19000, 2, 0, 30000, 1500,
};

void writeaudio(sample_t *out) {
    // These do something
    int v, i, row, s;
    // Oscillator state
    int osc1 = 0;
    int osc2 = 0;
    // Filter state
    int lp = 0;
    int hp = 0;
    int bp = 0;
    int d_2 = 0;
    
    for (v = 0; v < (VOICES_NORMAL + VOICES_CHORD); v++) {
	sample_t *op = out;
	
	for (i = SONGSTART; i < SONGLEN; i++) {
	    signed short *instr; // ptr to current instrument
	    uint8_t *pattern; // ptr to pattern
	    int q, f; // filter parameters for instrument
	    int filtertype; // filter type, from instrument flags
	    int dist; // distortion on / off
	    int cflag = (v >= VOICES_NORMAL); // regular instrument or chord?

	    // set pattern pointer
	    if (cflag) {
		instr = instruments + VOICES_NORMAL * INSTR_LEN;
		pattern = patterns + PATTLEN * song[i + SONGLEN * VOICES_NORMAL];
	    } else {
		instr = instruments + (v * INSTR_LEN);
		pattern = patterns + PATTLEN * song[i + SONGLEN * v];
	    }

    
	    for (row = 0; row < PATTLEN; row++) {
		// reset sine osc every row to keep
		// bd in phase
		int sin = 0;
		int cos = 10000;
		int extra = 0;
		uint8_t note = *pattern;
		uint8_t n = note & 0x7f;
		int vol = instr[INSTR_VOL];
		// instrument params
		q = instr[INSTR_Q];
		f = instr[INSTR_F];
		filtertype = instr[INSTR_FLAGS] & 0x40;
		dist = instr[INSTR_FLAGS] & 0x80;

		if (cflag && note != pp) {
		    int cn = chords[(v - VOICES_NORMAL) + (3 * (note >> 6))];
		    if (cn >= 0) {
			n += cn;
			n &= 0x3f;
			n += 36;
		    } else {
			note = 0;
		    }
		} else if (note & 0x80) {
		    // accent
		    f += 10000;
		    vol += 5000;
		    if (instr[INSTR_FLAGS] & PITCH_SLIDE) {
			extra = 220000;
		    }
		}
		
		for (s = 0; s < TICKLEN; s++) {
		    int a = freqtable[n % 12];
		    int add = 0;

		    add = ((a + extra) << (n / 12)) << 8;

		    // cutoff slide
		    if (f > 4000 && ((int)op & 4)) {
			f--;
		    }

		    // pitch slide
		    if (extra > 100) {
			extra -= instr[INSTR_PITCHSLIDE];
		    }
		    
		    // update oscillators
		    osc1 += add;
		    osc2 += add + DETUNE_AMT;
		    
		    if (instr[INSTR_FLAGS] & NOISE) {
			osc1 *= osc2;
		    }
		    int in;
		    if (instr[INSTR_FLAGS] & SINE) {
			sin += ((add >> 16) * cos) >> 16;
			cos -= ((add >> 16) * sin) >> 16;
			in = sin;
		    } else { // SAW_DUAL
			in = (osc1 >> 20) + (osc2 >> 20);
		    }
		    
		    // vol slide
		    if (vol > 100) {
			vol -= instr[INSTR_VOLSLIDE];
		    }

		    // apply volume
		    in = (in * vol) >> 15;

		    // filters
		    lp = lp + ((f * bp) >> 15);
		    hp = in - ((bp * q) >> 15) - lp;
		    bp = ((f * hp) >> 15) + bp;

		    if (note) {
			switch (filtertype) {
			case FILTER_LP:
			    // "distortion" here
			{
			    sample_t o = lp;
			    if (dist) {
				o = o & 0x08f0;
			    }
			    *(op) += o;
			    break;
			}
			case FILTER_HP:
			    *(op) += hp;
			    break;
			}
		    }
		    op++;
		}
		pattern++;
	    }
	}
    }
    return;
}
