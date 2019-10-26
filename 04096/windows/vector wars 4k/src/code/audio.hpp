#ifndef audio_hpp
#define audio_hpp

// sound effect flags
#define SF_SINE		(1 << 0) // use the sine oscillator (no supported in this game!)
#define SF_SAW		(1 << 1) // use the saw oscillator
#define SF_NOISE	(1 << 2) // use the noise oscillator

#define AUDIO_CHANNELS				1 // number of channel for all audio (1 = mono)

#define AUDIO_BITS_PER_SAMPLE		16 // bits per sample for the direct sound buffers
#define AUDIO_BYTES_PER_SAMPLE		(AUDIO_BITS_PER_SAMPLE / 8) // bytes per sample for sound buffers
#define AUDIO_BYTES_PER_FRAME		(AUDIO_BYTES_PER_SAMPLE * AUDIO_CHANNELS) // bytes per frame for sound buffers
#define AUDIO_SAMPLE_RATE			22050 // sample rate to use for all calculations. 22050 is the direct sound default value.
#define AUDIO_SAMPLE_RATE_F			22050.0f // sample as float

#define AUDIO_HZ_TO_FRAMES(_hz)		(AUDIO_SAMPLE_RATE_F / (float) (_hz)) // convert hertz to sample frames
#define AUDIO_HZ_TO_SPEED(_hz)		((float) (_hz) / AUDIO_SAMPLE_RATE_F) // convert hertz to playback speed
#define AUDIO_MS_TO_FRAMES(_ms)		((float) (_ms) / 1000.0f * AUDIO_SAMPLE_RATE_F) // convert milliseconds to sample frames

#define NUM_SOUNDBUFFERS			100 // maximum number of sound buffers that can be used

// ids for SfxData.values[]
enum SfxDataId
{
	SDI_OSCFREQ,		// oscillator frequency (hertz)
	SDI_OSCFREQSLIDE,	// oscillator frequency slide (hertz / frame)
	SDI_VOLUME,			// volume [0..1]
	SDI_VOLUMESLIDE,	// volume slide (delta / frame)
	SDI_FILTERFREQ,		// filter frequency [0..1] where 0.0 means 0 hz and 1.0 means 1/4 sample rate
	SDI_FILTERFREQSLIDE,// filter frequency slide (delta / frame)
	
	SDI_MAX
};

// sound effect parameter block
struct SfxData
{
	unsigned __int16	flags;				// see SF_... flags
	unsigned __int16	length;				// length of sound effect in sample frames
	float				values[SDI_MAX];	// see SfxDataId
};

void Audio_Init();
void Audio_CreateSound(const unsigned _rawBufferFrames, const unsigned _id);
void Audio_PlaySound(const unsigned _id);
void Audio_CreateSfx(SfxData* _pData, const unsigned _id);

extern __int16 g_rawBuffer[1024 * 1024];

#endif // #ifndef audio_hpp
