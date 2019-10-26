#ifndef midi_hpp
#define midi_hpp

void Midi_Init();
DWORD WINAPI Midi_Run(LPVOID _param);

void Midi_SendMessage(const DWORD _midiMessage);
void Midi_StartSong(const unsigned __int8* _pSongHeader);

// the header for the mid4k files
#pragma pack (push, 1)
struct Mid4kHeader
{
	unsigned __int16	msPerTick;	// the number of milliseconds to wait per internal tick
	unsigned __int8		program[3]; // midi program for channel 7 to 9
};
#pragma pack (pop)

// midi message helpers
#define MIDI_NOTEON(_CHANNEL, _NOTE, _VELOCITY) (0x90 | (_CHANNEL) | ((_NOTE) << 8) | ((_VELOCITY) << 16))
#define MIDI_CONTROLLERCHANGE(_CHANNEL, _CONTROLLER, _VALUE) (0xB0 | (_CHANNEL) | ((_CONTROLLER) << 8) | ((_VALUE) << 16))
#define MIDI_PROGRAMCHANGE(_CHANNEL, _PROGRAM) (0xC0 | (_CHANNEL) | ((_PROGRAM) << 8))
#define MIDI_START() 0xFA
#define MIDI_MONOMODE(_CHANNEL) (0xB0 | (_CHANNEL) | (126 << 8) | (1 << 16))

// compressed format helpers
#define MID4K_WAIT(_MS) (0x80 | (_MS))
#define MID4K_NOTE(_CHANNEL, _NOTE) (0x00 | ((_CHANNEL) << 5) | (_NOTE))
#define MID4K_LOOP() MID4K_WAIT(0)

// misc defines
#define MID4K_ROOTNOTE	60	// the root note. the note from the MID4K_NOTE command is added to get the actual midi note to play
#define MID4K_MSSLEEP	10	// the number of milliseconds to sleep per process loop. needs to be this high since Sleep() does not work correctly with low value unless timeBeginPeriod() has been called - which we do not do

#endif // #ifndef midi_hpp
