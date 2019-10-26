// BUNCHBOX, Brad Smith 9/18/2009

#include "sound.h"
#include <MMSystem.h>

namespace Sound {

bool sound_on = false;

//sint16 sound_buffer[2][ BUFFER_SIZE * 2 ];
sint16 sound_buffer[2][ BUFFER_SIZE ];
int sound_buffer_index = 0;
HWAVEOUT sound_hwo;
WAVEHDR  sound_whdr[2];
void (*sound_callback)( sint16 * buffer, unsigned int samples );
HANDLE mutex;

static void sound_advance()
{
	::WaitForSingleObject( mutex, INFINITE );
	if ( sound_on )
	{
		WAVEHDR & whdr  = sound_whdr[  sound_buffer_index];
		sint16 * buffer = sound_buffer[sound_buffer_index];

		// header shouldn't be prepared yet, but just in case
		if ( whdr.dwFlags & WHDR_PREPARED )
		{
			::waveOutUnprepareHeader( sound_hwo, &whdr, sizeof(WAVEHDR) );
		}

		// fill the next buffer
		sound_callback(buffer,BUFFER_SIZE);

		// prepare the buffer and send it
		whdr.lpData = (LPSTR)buffer;
		//whdr.dwBufferLength = BUFFER_SIZE * 2 * 2;
		whdr.dwBufferLength = BUFFER_SIZE * 1 * 2;
		::waveOutPrepareHeader( sound_hwo, &whdr, sizeof(WAVEHDR) );
		::waveOutWrite( sound_hwo, &whdr, sizeof(WAVEHDR) );

		// flip the double buffer
		sound_buffer_index ^= 1;
	}
	::ReleaseMutex( mutex );
}

static void CALLBACK sound_handler( HWAVEOUT hwo, UINT uMsg, DWORD dwInstance, DWORD dwParam1, DWORD dwParam2)
{
	if (WOM_DONE == uMsg)
	{
		sound_advance();
	}
}

bool sound_open( void (*callback)( sint16 * buffer, unsigned int samples ) )
{
	mutex = ::CreateMutex( NULL, false, "mutex" );

	WAVEFORMATEX wfx;
	wfx.wFormatTag =       1; // PCM
	//wfx.nChannels  =       2; // Stereo
	wfx.nChannels  =       1; // Mono
	wfx.nSamplesPerSec =   SOUND_SAMPLERATE;
	//wfx.nAvgBytesPerSec =  2 * 2 * SOUND_SAMPLERATE;
	//wfx.nBlockAlign =      2 * 2; // 2 * 16 bit
	wfx.nAvgBytesPerSec =  1 * 2 * SOUND_SAMPLERATE;
	wfx.nBlockAlign =      1 * 2; // 1 * 16 bit
	wfx.wBitsPerSample =   16;
	wfx.cbSize =           0; // no extra information

	MMRESULT errCode = ::waveOutOpen(
		&sound_hwo, WAVE_MAPPER, &wfx,
		(DWORD)sound_handler,
		(DWORD)NULL, // user data
		(DWORD)CALLBACK_FUNCTION );

	if (errCode == MMSYSERR_NOERROR)
	{
		::memset( sound_buffer, 0, sizeof(sound_buffer) );
		::memset( sound_whdr, 0, sizeof(sound_whdr) );
		sound_callback = callback;

		// start it up by filling the buffers
		sound_on = true;
		sound_advance();
		sound_advance();
	}

	return sound_on;
}
 
void sound_close()
{	if ( sound_on )
	{
		sound_on = false; // stops the callback from providing new buffers
		::waveOutReset(sound_hwo); // waits until all buffers emptied
		for ( int i=0; i < 2; ++i )
		{
			if ( sound_whdr[i].dwFlags & WHDR_PREPARED )
			{
				::waveOutUnprepareHeader(sound_hwo,&(sound_whdr[i]),sizeof(WAVEHDR));
			}
		}
		::waveOutClose(sound_hwo);
	}
}

unsigned int sound_pos()
{
	MMTIME mmt;
	mmt.wType = TIME_SAMPLES;
	::WaitForSingleObject( mutex, INFINITE );
	MMRESULT result = ::waveOutGetPosition(sound_hwo, &mmt, sizeof(mmt) );
	::ReleaseMutex(mutex);
	ASSERT( result == MMSYSERR_NOERROR );
	return mmt.u.sample;
}

} // namespace Sound
