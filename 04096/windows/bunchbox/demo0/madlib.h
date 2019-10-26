// BUNCHBOX, Brad Smith 9/18/2009

#ifndef MADLIB_H
#define MADLIB_H

typedef unsigned int        uint32;
typedef signed int          sint32;
typedef unsigned short int  uint16;
typedef signed short int    sint16;
typedef unsigned char       uint8;
typedef signed char         sint8;

namespace Madlib
{
	// semi-internal constants
	// NUM_CHANNELS, NUM_INSTRUMENTS, and MAX_VOLUME are worth looking at maybe.
	// NOTE: there is not a lot of headspace for calculations, so changing
	//       the bit depth constants is not recommended without a thorough
	//       examination of the fixed-point calculations being done.

	const uint32 CHANNEL_SHIFT = 3;
	const uint32 NUM_CHANNELS  = 1 << CHANNEL_SHIFT;

	const uint32 SAMPLERATE = 44100;
	const uint32 FRAME_LEN = 512; // number of samples in a music clock
	//const uint32 FRAME_SIZE = FRAME_LEN * 2; // stereo
	const uint32 FRAME_SIZE = FRAME_LEN * 1; // mono

	// for pitch conversion
	inline float hz( float freq ) { return freq / float(SAMPLERATE); }

	// enumerations and structures

	struct Instrument
	{
		// modulator frequency is carrier frequency * n/d
		// d=0 means use scale[n] instead as absolute frequency
		float mod_pitch_n;
		float mod_pitch_d;
		float feedback;
		// envelopes (AR)
		float ar_vol[2][2]; // { attack, release(usually 0) }
		uint32 ar_len[2][2]; // { attack, release }
	};

	struct Track
	{
		uint32 speed;
		uint32 pattern_len;
		uint32 order_len;
		uint32 num_channels;
		const float * scale;
		const Instrument * instrument;
		const uint8 * order;
		const uint8 * const * pattern;
		// each pattern is a collection of num_channels uint8*s,
		// stored in series in the "pattern"
	};

	// low level interface
	void tick( sint16 * buffer, unsigned int samples ); // generates sound (stereo 16 bit)
	void setup( const Track * t );

	// animation sync interface
	struct Sync
	{
		uint8 note;
		float vol;
	};
	void get_sync( uint32 * frame, Sync * sync_out );
}

#endif // MADLIB_H
