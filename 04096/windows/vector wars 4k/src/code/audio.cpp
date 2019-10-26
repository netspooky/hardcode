#include "stableheaders.hpp"

#include "audio.hpp"

#include "globals.hpp"
#include "helpers.hpp"

//////////////////////////////////////////////////////////////////////////
// BSS
//////////////////////////////////////////////////////////////////////////
#pragma bss_seg(".bss_audio")

LPDIRECTSOUND8			g_pDirectSound8;						// pointer to the direct sound 8 object
LPDIRECTSOUNDBUFFER8	g_pDirectSoundBuffer[NUM_SOUNDBUFFERS];	// pointer to all available direct sound buffers
__int16					g_rawBuffer[1024 * 1024];				// buffer of 1 meg of 16 bit samples to store raw data before copying it into a direct sound buffer

//////////////////////////////////////////////////////////////////////////
// DATA
//////////////////////////////////////////////////////////////////////////
#pragma data_seg(".data_audio")

// a global definition of the wave format used for all sound buffers
WAVEFORMATEX g_waveFormat =
{
	WAVE_FORMAT_PCM,												// standard pcm output format
	AUDIO_CHANNELS,													// the number of audio channels
	AUDIO_SAMPLE_RATE,												// samples per second
	AUDIO_SAMPLE_RATE * AUDIO_BYTES_PER_SAMPLE * AUDIO_CHANNELS,	// bytes per second data rate
	AUDIO_BYTES_PER_SAMPLE * AUDIO_CHANNELS,						// block alignment of a sample frame
	AUDIO_BITS_PER_SAMPLE,											// bits per sample
	0																// no extensions needed
};

// a global definition of the direct sound buffer descriptor that is used to create all sound buffers
DSBUFFERDESC g_soundDesc =
{
	36,
	DSBCAPS_GLOBALFOCUS | DSBCAPS_GETCURRENTPOSITION2 | DSBCAPS_CTRLVOLUME | DSBCAPS_CTRLFREQUENCY, 
	0, // size in bytes. set during runtime
	0,
	&g_waveFormat,
	GUID_NULL	
};

//////////////////////////////////////////////////////////////////////////
// CODE
//////////////////////////////////////////////////////////////////////////
#pragma code_seg(".code_audio")

////////////////////////////////////////////////////////////////////////////////
//
//	Audio_Init()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Sets up the DirectSound audio engine.

*/
void Audio_Init()
{
	// create an instance of direct sound itself
	D3D_VERIFY(DirectSoundCreate8(NULL, &g_pDirectSound8, NULL), "Sound DirectSoundCreate8 failed");
	
	// set the cooperative level to "priority" which allows the application to do more audio configuration if needed
	D3D_VERIFY(g_pDirectSound8->SetCooperativeLevel(screen_params.hDeviceWindow, DSSCL_PRIORITY), "Sound SetCooperativeLevel failed");
}

////////////////////////////////////////////////////////////////////////////////
//
//	Audio_CreateSound()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Creates a DirectSoundBuffer and copies _rawBufferFrames sample frames
		into the buffer.

	\param _rawBufferFrames

		The number of sample frames to copy into the DirectSoundBuffer.

	\param _id

		The id of the sound. Use the same id for Audio_PlaySound() to start
		the sound. [0..NUM_SOUNDBUFFERS - 1]

*/
void Audio_CreateSound(const unsigned _rawBufferFrames, const unsigned _id)
{
	__int16*			pLockedData;		// pointer to the locked data buffer of the direct sound buffer
	DWORD				size;				// size of the locked data buffer
	LPDIRECTSOUNDBUFFER	pDirectSoundBuffer;	// pointer to the IDirectSoundBuffer (not the IDirectSoundBuffer8)

	// set up the global sound buffer descriptor
	g_soundDesc.dwBufferBytes = _rawBufferFrames * AUDIO_BYTES_PER_FRAME;

	// create an IDirectSoundBuffer
	D3D_VERIFY(g_pDirectSound8->CreateSoundBuffer(&g_soundDesc, &pDirectSoundBuffer, 0), "Sound CreateSoundBuffer failed");
	
	// get an interface for the actual IDirectSoundBuffer8
	D3D_VERIFY(pDirectSoundBuffer->QueryInterface( IID_IDirectSoundBuffer8, (LPVOID *) &g_pDirectSoundBuffer[_id]), "Sound QueryInterface failed");

	// lock the direct sound buffer and copy the raw data into it
	D3D_VERIFY(g_pDirectSoundBuffer[_id]->Lock(0, 0, (LPVOID*)(&pLockedData), &size, 0, 0, DSBLOCK_ENTIREBUFFER), "Sound Lock failed");
	MemCopy(pLockedData, g_rawBuffer, g_soundDesc.dwBufferBytes);
	D3D_VERIFY(g_pDirectSoundBuffer[_id]->Unlock(pLockedData, size, 0, 0), "Sound Unlock failed");	
}

////////////////////////////////////////////////////////////////////////////////
//
//	Audio_PlaySound()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Starts playback of a given sound buffer.

	\param _id

		The id of the sound buffer to start.

	\remarks

		One sound buffer cannot be played back multiple times simultaneously,
		so it will be restarted.

*/
void Audio_PlaySound(const unsigned _id)
{
	#ifndef SOUND_MUTE
		g_pDirectSoundBuffer[_id]->SetCurrentPosition(0);
		g_pDirectSoundBuffer[_id]->Play(0, 0, 0);
	#endif
}

////////////////////////////////////////////////////////////////////////////////
//
//	Audio_CreateSfx()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Creates a sound effect with the given parameters.

	\param _pData

		The sound effect parameters.

	\param _id

		The id of the sound. Use the same id for Audio_PlaySound() to start
		the sound. [0..NUM_SOUNDBUFFERS - 1]

	\remarks

		A sound effect can only be created only since its source data will also
		be used as working data while rendering the effect.

*/
void Audio_CreateSfx(SfxData* _pData, const unsigned _id)
{
	__int16*	pRaw = g_rawBuffer;				// pointer to the next 16 bit sample to write
	float		sample;							// the current float sample value
	float		phase = 0.0f;					// the current phase of the oscillator [0..2 * PI]
	float		low = 0.0f;						// the current low pass filter result
	float		high;							// the current high pass filter result
	float		band = 0.0f;					// the current band pass filter result
	unsigned	samplesLeft = _pData->length;	// the number of samples that are left to render
	unsigned	n;
	
	// still samples to render?
	while (samplesLeft)
	{
		// yes! so start with a "fresh" sample
		sample = 0.0f;
				
		// use the saw oscillator?
		if (_pData->flags & SF_SAW)
			// yes! so add a saw signal
			sample += SawF(phase);
			
		// use the noise oscillator?
		if (_pData->flags & SF_NOISE)
			// yes! so add a noise signal
			sample += -1.0f + GetRandomFloat() * 2.0f;
			
 		// apply state variable filter
		low += _pData->values[SDI_FILTERFREQ] * band;
		high = sample - low - band;
		band += _pData->values[SDI_FILTERFREQ] * high;
		
		// only use the low pass filter in this game
		sample = low;

		// apply volume
 		sample *= _pData->values[SDI_VOLUME];
		
		// convert to s16 data format
		*pRaw++ = F2IFloor(sample * 32767.0f);
		
		// next sample
		phase += _pData->values[SDI_OSCFREQ] / AUDIO_SAMPLE_RATE_F * PI;
		samplesLeft--;
		
		// calculate all linear slides
		for (n = 0; n < SDI_MAX; n += 2)
			_pData->values[n] += _pData->values[n + 1];
	}
	
	#ifdef AUDIO_DUMPSFX

		FILE* pFile;
		char buffer[256];
		sprintf_s(buffer, sizeof(buffer), "sfx_%x.raw", _pData);
		errno_t err = fopen_s(&pFile, buffer, "wb");
		
		fwrite(g_rawBuffer, 1, (int) pRaw - (int) g_rawBuffer, pFile);
		
		fclose(pFile);

	#endif
	
	// finally create a direct sound buffer
	Audio_CreateSound(pRaw - g_rawBuffer, _id);
}