#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include "windows.h"
#include "mmsystem.h"
#include "mmreg.h"

// define this if you have a multicore cpu and can spare ~15 bytes for realtime playback
// undef for sound precalc
#define USE_SOUND_THREAD

////////////////////////////////////////////////
// sound
////////////////////////////////////////////////
#define SAMPLE_RATE 44100
#define MAX_SAMPLES	SAMPLE_RATE*2*60*4

#pragma bss_seg(".synthnothing")
static float		lpSoundBuffer[MAX_SAMPLES];
static HWAVEOUT	hWaveOut;

/////////////////////////////////////////////////////////////////////////////////
// initialized data
/////////////////////////////////////////////////////////////////////////////////

#pragma data_seg(".wavefmt")
WAVEFORMATEX WaveFMT =
{
	WAVE_FORMAT_IEEE_FLOAT,
	2, // channels
	SAMPLE_RATE, // samples per sec
	SAMPLE_RATE*4*2, // bytes per sec
	8, // block alignment;
	32, // bits per sample
	0 // extension not needed
};

#pragma data_seg(".wavehdr")
WAVEHDR WaveHDR = 
{
	(LPSTR)lpSoundBuffer, 
	MAX_SAMPLES*4, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0
};

#pragma data_seg(".mmtime")
MMTIME MMTime = 
{ 
	TIME_SAMPLES,
	0
};

// declaration of the external synth render function, you'll always need that
extern "C" void	_4klang_render(float*);
// declaration of the external envelope buffer. only include if you're song was exported with that option
extern "C" float _4klang_envelope_buffer;

/////////////////////////////////////////////////////////////////////////////////
// Initialization
/////////////////////////////////////////////////////////////////////////////////

#ifdef USE_SOUND_THREAD
#pragma code_seg(".sndthrd")
DWORD WINAPI SoundThread( LPVOID lpParam )
{
	_4klang_render(lpSoundBuffer);
	return 0;
}
#endif

#pragma code_seg(".initsnd")
extern "C" void InitSound()
{
#ifdef USE_SOUND_THREAD
	CreateThread(0, 0, SoundThread, 0, 0, 0);
#else
	_4klang_render(lpSoundBuffer);
#endif
	waveOutOpen			( &hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
	waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
	waveOutWrite		( hWaveOut, &WaveHDR, sizeof(WaveHDR) );	
}

#pragma code_seg(".envelope")
extern "C" float get_Envelope(int instrument)
{
	return (&_4klang_envelope_buffer)[((MMTime.u.sample >> 8) << 5) + 2*instrument];
}

#pragma code_seg(".time")
extern "C" float get_Time()
{
	waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
	return float(MMTime.u.sample) / SAMPLE_RATE;
}
