#ifndef _CLINKSTER_H_
#define _CLINKSTER_H_

struct sample {
	short left,right;
};

extern "C" {
	// Generate the whole music in to music buffer. When this function
	// returns, Clinkster_MusicBuffer will be filled with sound data,
	// and Clinkster_StartMusic can be called.
	void __stdcall Clinkster_GenerateMusic();

	// Play the music
	void __stdcall Clinkster_StartMusic();

	// Returns how much of the music has currently been played.
	// Use this function as the timer for the visuals in your intro.
	// Returned value is measured in music ticks (pattern rows).
	float __stdcall Clinkster_GetPosition();

	// Used for timing intro events to music notes.
	// Returns how long ago (in ticks) a note was last triggered in the
	// specified track, starting from the specified position (in ticks).
	// If the track contains no note before the specified position,
	// the position is returned back (as if there was a note at time 0).
	// Note that the track number refers to post-conversion track numbers.
	// Consult the text output from the conversion script to see at which
	// track each original track/instrument combination has ended up.
	float __stdcall Clinkster_GetInstrumentTrigger(int track, float position);

	// Buffer containing the music.
	extern struct sample Clinkster_MusicBuffer[];

	// The tick rate of the music.
	extern const float Clinkster_TicksPerSecond;

	// The length of the music in ticks.
	extern const unsigned int Clinkster_MusicLength;

	// The number of tracks in the music.
	extern const unsigned int Clinkster_NumTracks;

	// Timing data used by Clinkster_GetInstrumentTrigger.
	// Consists of NUMTRACKS blocks of (1 << LOGNUMTICKS) ints
	// (constants defined in music.asm) where index i for a track
	// holds the last tick (at or prior to i) where a note was
	// triggered in that track.
	extern unsigned int Clinkster_TimingData[];

	// Wav file header to use if you want to write the music to disk.
	// Write these 44 bytes followed by Clinkster_MusicBuffer with a
	// length of Clinkster_WavFileHeader[10].
	extern unsigned int Clinkster_WavFileHeader[11];
};

#endif