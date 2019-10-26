#include "notetable.h"
#include "sys/types.h"
#include "math.h"

#define SIN(x) dsinf(x)

// Total song length
#define SONGLEN (4 * 5 + 2 + 2)
#define SONGSTART 0

// Pattern length in ticks
#define PATTLEN 16

// Tick length
#define TICKLEN 6500

// Detune amount for dual saw osc
#define DETUNE_AMT 40000

// Flag definitions
#define FILTER_LP 0
#define FILTER_HP 0x40

// Osc types
#define SAW_DUAL 0x10
#define SINE 0x02

//
#define N_SINES 8

typedef unsigned char uint8_t;

#define VOICES 3

CONST uint8_t song[SONGLEN * VOICES] = {
	// surr
	0, 0,
	0, 0, 0, 0,

	1, 5, 1, 5,
	1, 5, 1, 5,
	11, 11, 1, 5,
	1, 11, 11, 5, 0, 0,

	/* 0, 0, 0, 0, */
	/* 0, 0, 0, 0, */
	/* 0, 0, 0, 0, */
	/* 0, 0, 0, 0, */

	// bass
	0, 0,
	0, 0, 0, 0,

	0, 0, 0, 0,
	2, 6, 2, 6,
	10, 10, 2, 6,
	6, 10, 15, 2, 17, 0,

	/* 0, 0, 0, 0, */
	/* 0, 0, 0, 0, */
	/* 0, 0, 0, 0, */
	/* 0, 0, 0, 0, */

	// plim
	7, 8,
	9, 12, 13, 4,

	3, 4, 3, 4,
	3, 4, 3, 4,
	14, 14, 3, 4,
	3, 14, 14, 4, 16, 0,

	/* 0, 0, 0, 0, */
	/* 0, 0, 0, 0, */
	/* 0, 0, 0, 0, */
	/* 0, 0, 0, 0 */
};

CONST uint8_t patterns[] = {
	// 0
	pp, pp, pp, pp, pp, pp, pp, pp,
	pp, pp, pp, pp, pp, pp, pp, pp,
	// 1 sur
	f2, f4, f3, f2, f1, f3, f2, f4,
	fs2, fs1, fs4, f3, ds2, as3, ds1, ds4,
	// 2
	f2, f2, pp, f2, pp, pp, pp, pp,
	pp, pp, pp, pp, pp, pp, pp, pp,
	// 3 plim
	c3, c5, c5, c6, pp, c4, pp, pp,
	c6, pp, pp, ds5, pp, pp, as5, pp,
	// 4 plim
	c3, c5, g5, c6, pp, c4, gs6, pp,
	g6, pp, gs6, g5, f4, f2, ds5, pp,
	// sur
	// 5
	f2, f4, f3, f2, f1, f3, f2, f4,
	fs2, fs1, fs5, as3, as2, f4, ds3, as3,
	// 6
	f2, f2, pp, f2, pp, pp, pp, pp,
	pp, pp, pp, pp, as2, as3, as2, pp,
	// 7 plim
	c3, pp, pp, pp, pp, ds4, pp, pp,
	pp, as3, pp, pp, pp, pp, pp, as4,
	// 8 plim
	pp, pp, pp, pp, f4, pp, pp, pp,
	pp, pp, ds5, pp, d5, pp, as4, pp,
	// 9 plim
	pp, pp, g4, c3, pp, pp, pp, pp,
	pp, pp, pp, pp, f4, g4, ds3, as4,
	// 10 b
	c3, c3, pp, c3, pp, pp, pp, pp,
	pp, pp, pp, pp, c2, c2, c2, pp,
	// 11 sur
	c2, c4, c3, c2, c1, c3, c2, as4,
	ds2, ds1, g4, f3, c2, c3, c1, c4,
	// 12 plim
	pp, pp, pp, pp, pp, c5, as4, f4,
	as2, pp, pp, pp, pp, pp, ds4, f4,
	// 13 plim
	g4, c3, pp, c5, pp, pp, c3, pp,
	c6, pp, g4, ds5, c4, pp, as5, pp,
	// 14 plim g
	g3, g4, g5, d6, pp, c6, pp, g5,
	g3, pp, pp, d4, pp, g5, as3, pp,
	// 15 b
	ds3, ds3, pp, ds3, pp, pp, pp, pp,
	pp, pp, pp, ds1, pp, ds1, ds1, pp,
	// 16 plim alas
	c6, g5, d5, c5, as3, g3, c3, c2,
	pp, pp, pp, pp, pp, pp, c7, pp,
	// 17 b
	f1, f1, f1, f1, f1, f1, f1, pp,
	pp, pp, pp, pp, pp, pp, pp, pp,
};

#define INSTR_LEN 3

#define INSTR_VOL 0
#define INSTR_Q 1
#define INSTR_F 2

// vol, Q, F
CONST int16_t instruments[(VOICES - 1) * INSTR_LEN] = {
	32000, 10000, 9000,
	26000, 22000, 7000,
};

FUNCTION void writeaudio(void) {
	// These do something
	int v, i, row, s, k;
	// Dual saw osc state
	int osc1 = 0;
	int osc2 = 0;
	// Filter state
	int lp = 0;
	int hp = 0;
	int bp = 0;

	for (v = 0; v < VOICES; v++) { // DEBUG
		int16_t *op = audio_buffer + ((uint64_t)44100 * CAMERA_FADE / 1000); // output goes here
		// sine osc state
		float sinev[N_SINES] = {0};
		float sadd[N_SINES] = {0};
		float sphase[N_SINES] = {0};
		int csin = 0; // next sine osc to reset

		for (i = SONGSTART; i < SONGLEN; i++) {
			int16_t *instr; // ptr to current instrument
			uint8_t *ppos; // ptr to current pattern pos
			int q, f; // filter parameters for instrument

			// pattern pos & instr param ptrs
			instr = (int16_t*)instruments + (v * INSTR_LEN);
			ppos = (uint8_t*)patterns + PATTLEN * song[i + SONGLEN * v];

			for (row = 0; row < PATTLEN; row++) {
				uint8_t note = *ppos;
				int vol = instr[INSTR_VOL];
				int a = freqtable[note % 12];
				int add = 0;

				add = (a << (note / 12)) << 8;

				// instrument params
				q = instr[INSTR_Q];
				f = instr[INSTR_F];
				csin = (csin + 1) % N_SINES;

				// reset next sine osc
				if (note != pp) {
					sphase[csin] = 0;
					sadd[csin] = (float)(add / 510000);
					sinev[csin] = 2500.0;
				}

				for (s = 0; s < TICKLEN; s++) {
					float s_in = 0;
					int in;
					int op_s = (int)(*op);

					if (v == (VOICES - 1)) {
						// update sine oscillators
						for (k = 0; k < N_SINES; k++) {
							sphase[k] += sadd[k];
							sinev[k] *= 0.99996;
							s_in += SIN((float)(sphase[k]) / 1000) * sinev[k];
						}
						*(op) = (int16_t)(op_s + (int)s_in);
					} else { 
						// cutoff slide
						if (f > 4000 && ((int)op & 4)) {
							f--;
						}

						// update dual saw
						osc1 += add;
						osc2 += add + DETUNE_AMT;
						in = (osc1 >> 20) + (osc2 >> 20);

						// apply volume
						in = (in * vol) >> 14;

						// filters
						lp = lp + ((f * bp) >> 15);
						hp = in - ((bp * q) >> 15) - lp;
						bp = ((f * hp) >> 15) + bp;

						if (note) {
							switch (v) {
								case 1:
									{
										*(op) = (int16_t)(op_s + lp);
										break;
									}
								case 0:
									*(op) = (int16_t)(op_s + hp);
									break;
								default:
									break;
							}
						}
					}
					op++;
				}
				ppos++;
			}
		}
	}
	return;
}
