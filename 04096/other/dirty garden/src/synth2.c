#include "syn_defs.h"

#ifdef SYN_TESTOUT
#include <stdlib.h> // rand()
IFUNCTION void writeaudio(int16_t *out) {
#else
IFUNCTION void writeaudio() {
    int16_t *out = audio_buffer;
#endif
    int i, k, m, del, type, dlen;
	sample_t *mxr;
    char *s = song;

    for (i = 0; i < S_SONGLEN; i++) {

	if (!(i % S_TICKLEN)) {
	    if ((++patternpos) >= S_PATTERN_LEN) {
		s++;
		patternpos = 0;
	    }

	    DBG(fprintf(stderr, "%d %d\n", songpos, patternpos));

	    for (k = 0; k < S_NUM_TRACKS; k++) {
		int *note = &patterns[(s[S_SONG_PATTERNS * k] * S_PATTERN_LEN + patternpos) * 2];
		DBG(fprintf(stderr, "osc %d\n", k));
		// note[0] delay line idx, note[1] trigger action, note[2] delay line len
		del = note[0] & 0x0f;
		type = (note[0] >> 4);
		dlen = note[1];

		if (dlen) {
		    delays[del].len = dlen;
		}
		if (type) {

		    // trigger a note
		    int i;
		    DelayLine *d = &delays[del];
		    sample_t *l = lines + S_DELAY_LEN_MAX * del;
		    int bdf = 800; // bd freq counter
		    
		    for (i = 0; i < d->len; i++) {
			sample_t val = 0.0f;
			if (type == 1 && i < 11) {
				val = (i & 1) ? -1 : 1;
			} else if (type == 2) {
			    // saw
			    val = -0.5 + (sample_t)i / d->len;
			} else if (type == 3) {
			    // bd
			    if (i % bdf > (bdf >> 1)) {
				val = 1.0f;
			    } else {
				val = -1.0f;
			    }
			    if (bdf > 20 && !(i % 20)) bdf--;
			} else if (type == 4) {
#ifdef SYN_TESTOUT
			    val = -0.5 + rand() / (sample_t)(RAND_MAX);
#else
			    val = frand2(0.5);
#endif
			}
			l[(d->pos + i) % d->len] = val;
		    }

		}
	    }
	}

	mxr = mixer;
	for (k = 0; k < S_NUM_DELAYS; k++) {
	    sample_t s = 0;
	    for (m = 0; m < S_NUM_DELAYS; m++) {
		s += tmp[m] * (*mxr);
		mxr++;
	    }

	    {
		DelayLine *d = &delays[k];
		sample_t sum;
		sample_t a;
		sample_t *l = lines + S_DELAY_LEN_MAX * k;
		
		sum = s + l[d->pos] * d->f1 +
			  l[(d->pos + 1) % d->len] * d->f2;
		l[d->pos] = sum;
		
		if (--d->pos < 0) {
		    d->pos += d->len;
		}
		
		a = fabs(sum);
		if (a > 1.0f) {
		    sum /= a;
		}
		tmp[k] = sum;
	    }
	}

	// master out
	*(out++) = (int16_t)(tmp[0] * 32000.f);
	*(out++) = (int16_t)(tmp[1] * 32000.f);
    }
}
