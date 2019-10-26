#include "notetable.h"

#define SONGLEN 26
#define PATTLEN 16
#define TICKLEN 10259
#define DETUNE_AMT 30000

#define FILTER_LP 0
#define FILTER_HP 0x40
#define FILTER_BP 0x80
#define FILTER_BYPASS 0xc0

#define PITCH_SLIDE 0x20

#define SAW_DUAL 0x10
#define NOISE 0x08
#define SQUARE 0x04
#define SINE 0x02

typedef int16_t sample_t;
typedef unsigned char uint8_t;

#define VOICES_NORMAL 5
#define VOICES_CHORD 3

const uint8_t chords[12] = {
    0, 3, 7, // min
    0, 4, 7, // maj
    0, 5, 8, // min joku
    0, 5, 9, // hmhmhhmm majjj
};

#define SONGSTART 0

const uint8_t song[SONGLEN * (VOICES_NORMAL + 1)] = {
    // sointu
    8, 8, 8, 8, 8, 8, 8, 8,
    7, 9, 7, 9, 7, 9, 7, 9,
    8, 8, 8, 8, 7, 9, 7, 9,
    7, 13,
    // diu
    8, 8, 8, 8, 4, 4, 4, 3,
    8, 8, 8, 8, 4, 4, 4, 3,
    10, 14, 10, 3, 4, 14, 10, 3,
    8, 8,
    // bas
    0, 1, 0, 1, 0, 1, 0, 1,
    0, 1, 0, 1, 0, 1, 0, 1,
    0, 1, 0, 1, 0, 1, 0, 1,
    8, 16,
    // bd
    8, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2,
    2, 15,
    // hh
    5, 5, 5, 5, 5, 5, 5, 5,
    5, 5, 5, 5, 5, 5, 5, 5,
    5, 5, 5, 5, 5, 5, 5, 5,
    5, 12,
    // sd
    8, 8, 6, 6, 6, 6, 6, 6,
    6, 6, 6, 6, 6, 6, 6, 6,
    6, 6, 6, 6, 6, 6, 6, 6,
    6, 11,
};

#define NUM_PATTERNS 17

const uint8_t patterns[NUM_PATTERNS * PATTLEN] = {
    // Bass patterns
    // 0
    c2 acc, c2, c3, c2, pp, c2, c3 acc, ds2,
    f2 acc, f2, f3, f2, pp, f2 acc, f3, f3,

    // 1
    gs1 acc, gs1, gs2, as1, as1, as2 acc, ds2, pp,
    pp, ds2 acc, ds1, ds2, g2, g2 acc, g3, g3,

    // bd
    // 2
    c2 acc, pp, c4 acc, pp, pp, pp, c2 acc, pp,
    c2 acc, pp, c4 acc, pp, pp, pp, c2 acc, pp,

    // hp diung 2
    // free
    c4 acc, pp, c4, d4, f5 acc, g5, g4, ds5 acc,
    f4, f5 acc, g5, pp, c4, pp, c4, pp,

    // hp diung
    // 4
    c4 acc, pp, c4, d4, ds4, c4 acc, g4, f4 acc,
    f4, f4, c4, pp, c4, pp, c4, pp,

    // sd
    // 5
    c4, c5, d5, d5, c4, g5, c7, c4,
    c4, c6, c1, c2, c4, c5, h7, c5,

    // sd nyt jo
    // 6
    pp, pp, c2 acc, pp, pp, pp, c2 acc, g6,
    pp, pp, c2 acc, pp, pp, pp, c2 acc, g7,

    // sointua
    // 7
    c1 C1, g0 C3, pp, pp, pp, pp, c1 C1, pp,
    c1 C3, gs0 C2, pp, pp, pp, pp, c1 C3, pp,

    // hilj.
    // 8
    pp, pp, pp, pp, pp, pp, pp, pp,
    pp, pp, pp, pp, pp, pp, pp, pp,

    // sointu2
    c1 C3, c1 C1, as0 C2, gs0 C2, pp, as0 C2, pp, c1 C1,
    pp, as0 C4, pp, as0 C2, as0 C2, pp, gs0 C2, as0 C2,

    // diu 3
    c4 acc, ds5 acc, gs5, d4, g5 acc, c4 acc, gs5 acc, c6 acc,
    f4, f4 acc, gs5 acc, gs5, c4, g5, gs5 acc, g5,

    // sd end
    // 11
    pp, pp, c2 acc, pp, pp, pp, c2 acc, pp,
    c1 acc, pp, pp, pp, pp, pp, pp, pp,

    // hh end
    // 12
    c4, c5, d5, d5, c4, g5, c7, c4,
    c4, c6, pp, pp, pp, pp, pp, pp,

    // sointu2
    c1 C3, c1 C1, c1 C3, pp, pp, as0 C2, pp, c1 C1,
    c1 C1, pp, pp, pp, pp, pp, pp, pp,

    // diu 4
    c4 acc, pp, c4, d4, gs5 acc, as5, g4, g5 acc,
    f4, f5, as4 acc, pp, c4, pp, c4 acc, c4,

    // bd end
    // 15
    c2 acc, pp, c4 acc, pp, pp, pp, c2 acc, pp,
    c2 acc, pp, pp, pp, pp, pp, pp, pp,

    // bass fianl
    pp, pp, pp, pp, pp, pp, pp, pp,
    c2 acc, c2, c2, c2, c2, c2, c2,
};

#define INSTR_LEN 6
// flags, vol, vol slide, pitch slide, Q, F
const signed short instruments[(VOICES_NORMAL + 1) * INSTR_LEN] = {
    // sointu
    FILTER_HP | SAW_DUAL,            19500, 0, 0, 12000, 3000,
    // dii
    FILTER_BP | SAW_DUAL,                 21000,0, 0, 700, 28000,
    // bääs
    FILTER_LP | SAW_DUAL,          18000, 0, 50, 7000, 18000,
    // bd
    FILTER_LP | SINE | PITCH_SLIDE, 17000, 1, 170, 30000, 30000,
    // sd
    FILTER_HP | NOISE,                    32600, 20, 0, 4000, 5000,
    // sd joo
    FILTER_HP | NOISE,                    22000, 2, 0, 10000, 1000,
};

void writeaudio(sample_t *out) {
    int v, i, row, s;
    int osc1 = 0;
    int osc2 = 0;
    int sin = 0;
    int cos = 10000;
    // filter state
    int lp = 0;
    int hp = 0;
    int bp = 0;
    int d_2 = 0;
    
    for (v = 0; v < (VOICES_NORMAL + VOICES_CHORD); v++) {
	sample_t *op = out;
	
	for (i = SONGSTART; i < SONGLEN; i++) {
	    signed short *instr;
	    uint8_t *pattern;
	    int q, f;
	    int filtertype;
	    int cflag = (v < VOICES_CHORD);

	    if (cflag) {
		instr = instruments;
		pattern = patterns + PATTLEN * song[i];
	    } else {
		int a = v - (VOICES_CHORD - 1);
		instr = instruments + (a * INSTR_LEN);
		pattern = patterns + PATTLEN * song[i + SONGLEN * a];
	    }

	    // instrument params
	    q = instr[4];
	    f = instr[5];
	    filtertype = instr[0] & 0xc0;
	    
	    for (row = 0; row < PATTLEN; row++) {
		int extra = 0;
		uint8_t note = *pattern;
		uint8_t n = note & 0x7f;
		int vol = instr[1];

		if (cflag && note != pp) {
		    n += chords[(v + (3 * (note >> 6)))];
		    n &= 0x3f;
		    n += 48;
		} else if (note & 0x80) {
		    // accent
		    f = 10000;
		    if (instr[0] & PITCH_SLIDE) {
			extra = 220000;
		    }
		}
		
		for (s = 0; s < TICKLEN; s++) {
		    int a = freqtable[n % 12];
		    int add = 0;

		    if (note) {
			add = ((a + extra) << (n / 12)) << 8;
		    }

		    // cutoff slide
		    if (f > 4000 && ((int)op & 4)) {
			f--;
		    }

		    // pitch slide
		    if (extra > 0) {
			extra -= instr[3];
		    }
		    
		    // update oscillators
		    osc1 += add + extra;
		    osc2 += add + extra + DETUNE_AMT;
		    
		    if (instr[0] & NOISE) {
			osc1 *= osc2;
		    }
		    int in = osc1 >> 20;
		    if (instr[0] & SQUARE) {
			in &= (-(1 << 32 - 1) >> 19);
		    } else {
			in + osc2 >> 20;
		    }
		    if (instr[0] & SINE) {
			sin += ((add >> 16) * cos) >> 16;
			cos -= ((add >> 16) * sin) >> 16;
			in = sin;
		    }
		    
		    if (vol > 100) {
			vol -= instr[2];
		    }

		    // volume
		    in = (in * vol) >> 15;

		    // filter
		    lp = lp + ((f * bp) >> 15);
		    hp = in - ((bp * q) >> 15) - lp;
		    bp = ((f * hp) >> 15) + bp;

		    if (note != pp) {
			switch (filtertype) {
			case FILTER_LP:
			    *(op) += lp;
			    break;
			case FILTER_HP:
			    *(op) += hp;
			    break;
			case FILTER_BP:
			    *(op) += bp;
			    break;
			    /*
			      case FILTER_BYPASS:
			      *(op++) += in;
			      break;
			    */
			};
		    }
		    
		    if (v < 2) {
			*op -= (*(op - TICKLEN * 3)) >> 4;
		    }

		    op++;
		}
		pattern++;
	    }
	}
    }
    return;
}
