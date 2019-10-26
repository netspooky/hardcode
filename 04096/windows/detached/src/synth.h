#pragma once
#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include "windows.h"
#include "mmsystem.h"
#include "mmreg.h"
#include "4klang.h"

#define USE_SOUND_THREAD

#pragma bss_seg(".synthnothing")
static float lpSoundBuffer[MAX_SAMPLES * 2];
static HWAVEOUT	hWaveOut;

#pragma data_seg(".wavefmt")
WAVEFORMATEX WaveFMT =
{
#ifdef FLOAT_32BIT	
	WAVE_FORMAT_IEEE_FLOAT,
#else
	WAVE_FORMAT_PCM,
#endif		
	2, // channels
	SAMPLE_RATE, // samples per sec
	SAMPLE_RATE*sizeof(SAMPLE_TYPE)* 2, // bytes per sec
	sizeof(SAMPLE_TYPE)* 2, // block alignment;
	sizeof(SAMPLE_TYPE)* 8, // bits per sample
	0 // extension not needed
};

#pragma data_seg(".wavehdr")
WAVEHDR WaveHDR =
{
	(LPSTR)lpSoundBuffer,
	MAX_SAMPLES*sizeof(SAMPLE_TYPE)* 2,			// MAX_SAMPLES*sizeof(float)*2(stereo)
	0,
	0,
#ifdef WAVHDR_PREPARE_HACK
	WHDR_PREPARED,
#else
	0,
#endif
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

#ifndef _DEBUG
#pragma code_seg(".initsnd")
#endif
__forceinline void InitSound()
{
#ifdef USE_SOUND_THREAD
	::CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0);
#else
	_4klang_render(lpSoundBuffer);
#endif
}

#ifndef _DEBUG
#pragma code_seg(".playsnd")
#endif
__forceinline void PlaySound()
{
	waveOutOpen(&hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL);
#ifndef	WAVHDR_PREPARE_HACK
	waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
#endif
	waveOutWrite(hWaveOut, &WaveHDR, sizeof(WaveHDR));
}

#ifndef _DEBUG
#pragma code_seg(".sample")
#endif
__forceinline void get_Sample()
{
	waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
}
