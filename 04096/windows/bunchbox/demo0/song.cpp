// BUNCHBOX, Brad Smith 9/18/2009

#include "song.h"
#include "madlib.h"
#include "sound.h"
#include "math.h"

using namespace Madlib;

static float scale[256];

Instrument inst[6] =
{
	{ // 0 = bass
		1,1, // mod pitch
		0.4f, // feedback
		{ { 0.4f, 0.1f }, { 1.0f, 0.0f } }, // AR volume
		{ { 1, 60 }, { 0, 30 } }
	},
	{ // 1 = kick
		4,1, // mod pitch
		0.2f, // feedback
		{ { 1.0f, 0.0f }, { 1.0f, 0.0f } }, // AR volume
		{ { 0, 4 }, { 0, 10 } }
	},
	{ // 2 = snare
		11,2, // mod pitch
		1.98f, // feedback
		{ { 2.0f, 1.0f }, { 0.5f, 0.0f } }, // AR volume
		{ { 1, 90 }, { 2, 30 } }
	},
	{ // 3 = hat
		7,2, // mod pitch
		0.2f, // feedback
		{ { 1.6f, 0.2f }, { 0.15f, 0.0f } }, // AR volume
		{ { 0, 3 }, { 1, 2 } }
	},
	{ // 4 = pad
		3,2, // mod pitch
		0.5f, // feedback
		{ { 0.6f, 0.0f }, { 0.1f, 0.0f } }, // AR volume
		{ { 8 * 28, 4 * 8 }, { 8 * 12, 8 * 20 } }
	}
};


const uint8 bass_cm[] = {
	 92, 2,
	104, 2,
	102, 2,
	104, 2,
	107, 2,
	114, 4,
	 92, 4,
	104, 2,
	102, 2,
	104, 2,
	107, 2,
	114, 2,
	113, 2,
	109, 2,
};

const uint8 bass_f[] = {
	 97, 2,
	104, 2,
	109, 2,
	102, 2,
	107, 2,
	111, 4,
	 97, 4,
	104, 2,
	116, 2,
	102, 2,
	107, 2,
	114, 2,
	113, 2,
	109, 2,
};

const uint8 bass_ab[] = {
	100, 2,
	107, 2,
	112, 2,
	107, 2,
	110, 2,
	116, 2,
	 95, 2,
	 98, 2,
	100, 2,
	110, 2,
	112, 2,
	107, 2,
	110, 2,
	112, 2,
	100, 2,
	101, 2,
};

const uint8 bass_bb[] = {
	102, 2,
	109, 2,
	114, 2,
	109, 2,
	112, 2,
	119, 2,
	102, 2,
	100, 2,
	102, 2,
	114, 2,
	103, 2,
	115, 2,
	104, 2,
	116, 2,
	105, 2,
	117, 2,
};

const uint8 bass_dfm[] = {
	 93, 2,
	100, 2,
	108, 2,
	110, 2,
	105, 2,
	100, 2,
	 96, 2,
	 95, 2,
	 93, 2,
	100, 2,
	108, 2,
	110, 2,
	112, 2,
	103, 2,
	 96, 2,
	 98, 2,
};

const uint8 bass_ef[] = {
	 95, 2,
	 99, 2,
	102, 2,
	104, 2,
	107, 2,
	102, 2,
	104, 2,
	 99, 2,
	 95, 2,
	 99, 2,
	102, 2,
	104, 2,
	107, 2,
	109, 2,
	111, 2,
	102, 2,
};

const uint8 pad0_cm[] = { 143, 32 };
const uint8 pad1_cm[] = { 0, 8,	150, 24 };

const uint8 pad0_f[] = { 145, 32 };
const uint8 pad1_f[] = { 0, 8, 149, 24 };

const uint8 pad0_ab[] = { 140, 32 };
const uint8 pad1_ab[] = { 0, 8, 148, 24 };

const uint8 pad0_bb[] = { 142, 32 };
const uint8 pad1_bb[] = { 0, 8, 150, 24 };

const uint8 pad0_dfm[] = { 141, 32 };
const uint8 pad1_dfm[] = { 0, 8, 148, 24 };

const uint8 pad0_ef[] = { 143, 32 };
const uint8 pad1_ef[] = { 0, 8, 147, 24 };

const uint8 kick0[] = {
	92, 10,
	92, 6,
	92, 10,
	92, 6,
};

const uint8 snare0[] = {
	0, 4,
	128, 8,
	128, 8,
	128, 8,
	128, 4,
};

// hat data filled out procedurally
uint8 hat_cm[ 32*2];
uint8 hat_f[  32*2];
uint8 hat_ab[ 32*2];
uint8 hat_bb[ 32*2];
uint8 hat_dfm[32*2];
uint8 hat_ef[ 32*2];

const uint8 order[] = {
	0, 0, 1, 1, 0, 0, 1, 1, 2, 3,
	4, 4, 5, 5, 4, 4, 5, 5,
};

const uint8 * const patterns[] = {
	pad0_cm,  pad1_cm,  bass_cm,  kick0, snare0, hat_cm,
	pad0_f,   pad1_f,   bass_f,   kick0, snare0, hat_f,
	pad0_ab,  pad1_ab,  bass_ab,  kick0, snare0, hat_ab,
	pad0_bb,  pad1_bb,  bass_bb,  kick0, snare0, hat_bb,
	pad0_dfm, pad1_dfm, bass_dfm, kick0, snare0, hat_dfm,
	pad0_ef,  pad1_ef,  bass_ef,  kick0, snare0, hat_ef,
};

Track song =
{
	8, // speed
	32, // pattern len
	sizeof(order), // order len
	6, // num channels
	scale,
	inst,
	order,
	patterns
};

// fill hi-hat patterns with random pitches related to the chord

uint8 rand_hat( int r )
{
	const int f[3] = { 0, 7, 12 };
	uint32 index = (rndi()>>12)%3;
	return r + (12*4) + f[index];
}

void generate_hats()
{
	int   hat_rand[6] = { bass_cm[0], bass_f[0], bass_ab[0], bass_bb[0], bass_dfm[0], bass_ef[0] };
	uint8 * hat_fill[6] = { hat_cm, hat_f, hat_ab, hat_bb, hat_dfm, hat_ef };

	for ( int i=0; i<32; ++i )
	{
		for ( int j=0; j < 6; ++j )
		{
			hat_fill[j][0] = rand_hat(hat_rand[j]);
			hat_fill[j][1] = 1;
			hat_fill[j] += 2;
		}
	}
}

void play_song()
{
	// generate equal tempered scale
	const float MIDDLE_C = 261.625f;
	const float HALF_STEP = 1.0594630943592952645618252949463; // 2 ^ 1/12
	float pitch_up = MIDDLE_C;
	float pitch_down = MIDDLE_C;
	for ( int i=0; i < 127; ++i )
	{
		scale[128+i] = hz(pitch_up);
		scale[128-i] = hz(pitch_down);

		pitch_up *= HALF_STEP;
		pitch_down /= HALF_STEP;
	}

	generate_hats();

	Madlib::setup(&song);
	Sound::sound_open( Madlib::tick );
}

