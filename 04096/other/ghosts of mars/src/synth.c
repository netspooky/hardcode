
#define OVERSAMPLE_FACTOR 16
#define OSCS_PER_INSTR 6

#if defined(USE_LD)
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/uniform_int.hpp>
#include <boost/random/uniform_real.hpp>
#include <boost/random/variate_generator.hpp>

/// Mersenne random number generator.
static boost::mt19937 g_mt_rand;
#endif

#include "songdata.h"

typedef union {
    unsigned char c_val[4];
    float f_val;
} c_float;

#define ROWLEN (8 * 1400 * OVERSAMPLE_FACTOR)



static int oscillators[NUM_TRACKS * OSCS_PER_INSTR];

#define TRACK_VOL(x) (x / OVERSAMPLE_FACTOR / (4294967296.0f / 25000.0f))

struct instrument {
    float vol;
    c_float flt_co;
    float flt_decay;
    float flt_fb;
    float decay;
    float pitches[OSCS_PER_INSTR];
    int square;
};

static struct instrument instruments[] = {
    {TRACK_VOL(0.08f),
     { {0x00, 0x00, 0x65, 0x3c} },
     0.9999994f,
     1.0f,
     1.0f,
     {0.994f,1.000f, 1.007f, 0.5f, 0.5007f},
     0},

    {TRACK_VOL(0.18f),
     { {0x00, 0x00, 0xa3, 0x3c} },
     0.99998f,
     0.99f,
     0.999985f,
     {1.0f,1.01f},
     0},

    {TRACK_VOL(0.15f),
     { {0x00, 0x00, 0xcc, 0x3d} },
     0.99998f,
     0.7f,
     0.999999f,
     {1.0f,1.005f, 1.01f},
     1},
    
    {TRACK_VOL(0.080f),
     { {0x00, 0x00, 0x99, 0x3d} },
     0.9999999f,
     0.25f,
     1.0f,
     {0.5f, 0.998f,1.002f, 1.496f, 1.500f},
     0},

    {TRACK_VOL(0.13f),
     { {0x00, 0x00, 0x23, 0x3c} },
     0.99998f,
     1.0f,
     1.0f,
     {0.994f,1.000f, 1.006f, 0.5f, 0.501f},
     0},

    {TRACK_VOL(0.29f),
     { {0x00, 0x00, 0xa3, 0x3b} },
     1.0000038f,
     0.6f,
     0.99999965f,
     {0.999f,1.0000f, 1.002f},
     0},

    {TRACK_VOL(0.20f),
     { {0x00, 0x00, 0x4c, 0x3e} },
     0.999999f,
     0.5f,
     1.0f,
     {1.0f,1.01f, 0.99f},
     1},

    {TRACK_VOL(0.07f),
     { {0x00, 0x00, 0x75, 0x3c} },
     1.0000016f,
     0.5f,
     1.0000006f,
     {1.0f, 2.001f, 1.2599f, 2.2600f, 1.4983f, 2.4984f},
     0},
/*  rumpu */
    {TRACK_VOL(100000.0f),
     { {0x00, 0x00, 0xcc, 0x3c} },
     0.999997f,
     0.3f,
     0.99998f,
     {0},
     2},
};

struct track_state {
    float vol;
    float flt_co;
    int instr;
    int note;
    int octave;
    float flt_p1;
    float flt_p2;
};

static struct track_state tracks[NUM_TRACKS];


static float filter(float in, struct instrument *instr,
	      struct track_state *track) {
    float fb_amt = instr->flt_fb * (track->flt_co * 3.296875f - 0.00497436523438f);
    float feedback = fb_amt * (track->flt_p1 - track->flt_p2);

    track->flt_p1 = in * track->flt_co +
	track->flt_p1 * (1 - track->flt_co) +
	feedback;
    track->flt_p2 = track->flt_p1 * track->flt_co * 2 +
	track->flt_p2 * (1 - track->flt_co * 2);
    
    return track->flt_p2;
}

static unsigned int songpos = 0;
static unsigned int row = 0;
static float sum = 0.0f;
static unsigned int out_count = 0;

static void render(int16_t *out, int count) {
    
    while (count > 0) {
	int t;
	struct track_state *track = tracks;
	for (t = 0; t < NUM_TRACKS; ++t, ++track) {
	    const unsigned char *p = patterns + order[songpos] * NUM_ROWS * NUM_TRACKS + t * NUM_ROWS + row;
	    if (!out_count && *p) {
		track->note = (*p & 0x7f) % 12;
		track->octave = (*p & 0x7f) / 12;
		track->instr = *p & 0x80 ? 4 : 0;
		if (songpos >= 14) {
		    instruments[3].vol = TRACK_VOL(0.13f);
		}
	    }
	    struct instrument *instrument = instruments + t + track->instr;
	    if (!out_count && *p) {
		track->vol = instrument->vol;
		track->flt_co = instrument->flt_co.f_val;
	    }

	    float osc = 0.0f;
	    for (int o = 0; o < OSCS_PER_INSTR; o++) {
		int osc_out;
		oscillators[t * OSCS_PER_INSTR + o] += static_cast<int>(
                    (instrument->pitches[o] * static_cast<float>(notetable[track->note])) /
                    static_cast<float>(1 << track->octave));
		osc_out = oscillators[t * OSCS_PER_INSTR + o];
		if (instrument->square == 1) {
		    osc_out &= 0xc0000000;
		} else if (instrument->square == 2) {
#if defined(USE_LD)
                    boost::random::uniform_int_distribution<> distribution(-32768, 32767);
                    osc_out = distribution(g_mt_rand);
#else
                    union
                    {
                      int full_random_data;
                      int16_t partial_random_data;
                    } random_part;
                    random_part.full_random_data = dnload_random();
                    osc_out = random_part.partial_random_data;
#endif
		}
		osc += (static_cast<float>(osc_out) * track->vol);

	    }
	    track->vol *= instrument->decay;
	    track->flt_co *= instrument->flt_decay;

	    sum += filter(osc, instrument, track);
	}

	if (!((out_count++) % OVERSAMPLE_FACTOR)) {
	    *out = static_cast<int16_t>(sum);
	    ++out;
	    --count;
	    sum = 0;
	}

	if (out_count == ROWLEN) {
	    out_count = 0;
	    ++row;
	    if (row == NUM_ROWS) {
		row = 0;
		++songpos;
	    }
	}
    }
}


