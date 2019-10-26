// BUNCHBOX, Brad Smith 9/18/2009

#ifndef SOUND_H
#define SOUND_H

typedef signed short int sint16;

namespace Sound
{
	const unsigned int SOUND_SAMPLERATE = 44100;
	const unsigned int BUFFER_SIZE = 4096;

	// opens stereo sound and executes the callback every time a buffer is finished reading
	bool sound_open( void (*callback)( sint16 * buffer, unsigned int samples ) );
	void sound_close();

	// gets the current sound playback position (samples into the second last filled buffer)
	unsigned int sound_pos();
}

#endif

