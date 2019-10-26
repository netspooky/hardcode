#include "stableheaders.hpp"

#include "midi.hpp"

#include "globals.hpp"

//////////////////////////////////////////////////////////////////////////
// BSS
//////////////////////////////////////////////////////////////////////////
#pragma bss_seg(".bss_midi")

HMIDIOUT				g_midiDevice;	// handle of the midi output device
int						g_midiWaitMs;	// the number of milliseconds to wait until the next event should be processed
const unsigned __int8*	g_pSongData;	// pointer to the beginning of the actual song data (skipped header)
const unsigned __int8*	g_pSongPointer;	// pointer to the next song event
unsigned				g_msPerTick;	// multiplier to convert mid4k ticks into milliseconds

//////////////////////////////////////////////////////////////////////////
// CODE
//////////////////////////////////////////////////////////////////////////
#pragma code_seg(".code_midi")

////////////////////////////////////////////////////////////////////////////////
//
//	Midi_Init()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Sets up midi handling.

*/
void Midi_Init()
{
	// open the default midi mapper device. this should be the microsoft gm synthesizer
	midiOutOpen(&g_midiDevice, -1, 0, 0, CALLBACK_NULL);
	
	// put the instrument channels 1-9 into mono mode
	unsigned n;
	
	for (n = 0; n < 9; n++)
		Midi_SendMessage(MIDI_MONOMODE(n));
	
	// start the actual midi processing loop in another thread to minimize timing issues
	CreateThread
	( 
		NULL,		// default security attributes
		0,			// use default stack size  
		Midi_Run,	// thread function 
		NULL,		// argument to thread function 
		0,			// use default creation flags 
		NULL		// returns the thread identifier 
	);   
}

////////////////////////////////////////////////////////////////////////////////
//
//	Midi_Run()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		The actual MIDI sequencer.

	\param _param

		Thread parameter (not used)

	\remarks

		Strange enough: I do not return anything but the compiler does neither
		issue a warning nor an error!?! Not that I would really care in this
		case because the thread will never exit by itself.

*/
DWORD WINAPI Midi_Run(LPVOID _param)
{
	while (true)
	{
		// is there a song?
		if (g_pSongData)
		{
			// yes! so run the sequencer
			g_midiWaitMs -= MID4K_MSSLEEP;
			
			// wait any longer before next event?
			while (g_midiWaitMs <= 0)
			{
				// no! so process next event
				unsigned __int8 message;
				
				message = *g_pSongPointer++;
				
				// loop the song?
				if (message == MID4K_LOOP())
					// yes! so reset the song pointer to the first event
					g_pSongPointer = g_pSongData;
				// wait?
				else if (message & 0x80)
					// yes! calculate wait time in ms
					g_midiWaitMs += (message & 0x7F) * g_msPerTick;
				// else it must be a note!
				else
					// extract channel and note and send a midi note on command
					Midi_SendMessage(MIDI_NOTEON((message >> 5) + 6, (message & 0x1F) + MID4K_ROOTNOTE, 100));
			}
		}
		
		// sleep
		Sleep(MID4K_MSSLEEP);
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	Midi_SendMessage()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Send a single MIDI command to the output device.

	\param _midiMessage

		The MIDI message.

	\remarks

		The MIDI_... macros can be used to easily assemble the messages.

*/
void Midi_SendMessage(const DWORD _midiMessage)
{
	#ifndef SOUND_MUTE
		midiOutShortMsg(g_midiDevice, _midiMessage);
	#endif
}

////////////////////////////////////////////////////////////////////////////////
//
//	Midi_StartSong()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Start playback of a new song.

	\param _pSongData

		Pointer to the beginning of the song data.

	\remarks

		The sequencer is running in another thread so there is a chance that
		starting a new song interferes with the processing of the current song.
		Currently there is nothing that can be done about it since this would
		increase code size too much.

*/
void Midi_StartSong(const unsigned __int8* _pSongHeader)
{
	unsigned n;

	// prepare the new playback speed
	g_msPerTick = *((unsigned __int16 *) _pSongHeader);
	_pSongHeader += 2;
	
	// set the new midi programs
	for (n = 6; n <= 8; n++)
		Midi_SendMessage(MIDI_PROGRAMCHANGE(n, *_pSongHeader++));
	
	// start playback
	g_pSongData = g_pSongPointer = _pSongHeader;

	g_midiWaitMs = MID4K_MSSLEEP;
	
}