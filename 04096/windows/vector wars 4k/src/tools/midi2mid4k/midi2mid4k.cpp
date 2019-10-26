#include "stdafx.h"

#include "..\..\code\midi.hpp"

void Error(const char* _pMessage)
{
	printf("Error: %s\n", _pMessage);
	exit(1);
}

void Midi_LoadSong(const _TCHAR* _pSourceName, const _TCHAR* _pDestName)
{
	FILE* pFile;
	int lastTick = 0;
	int tokensFound;
	int tick;
	int channel;
	int note;
	int velocity;
	int program;
	int fileType;
	int tracks;
	int ticksPerBeat;
	int microsecondsPerBeat;
	unsigned __int8 song[65536];
	Mid4kHeader* pHeader = (Mid4kHeader *) song;
	unsigned __int8* pSongPointer = song + sizeof(Mid4kHeader);
	char buffer[1024];
	errno_t err;
	
	// PREPARE HEADER //////////////////////////////////////////////////////////////////////////
	memset(pHeader, 0, sizeof(*pHeader));

	// LOAD TXT //////////////////////////////////////////////////////////////////////////
	err = _tfopen_s(&pFile, _pSourceName, L"rt");

	while (feof(pFile) == 0)
	{
		fgets(buffer, sizeof(buffer), pFile);
		
		// check for file header ------------------------
		tokensFound = sscanf_s(buffer, "MFile %i %i %i\n", &fileType, &tracks, &ticksPerBeat);
		
		if (tokensFound == 3)
		{
			if (fileType != 0)
				Error("Only 'Type 0' midi files allowed!");
				
			if (tracks != 1)
				Error("Only single track midi files allowed (Type 0)!");
				
			if (ticksPerBeat != 48)
				Error("Ticks per beat must be 48!");
		}
		
		// check for tempo meta event ------------------------
		tokensFound = sscanf_s(buffer, "%i Tempo %i", &tick, &microsecondsPerBeat);
		
		if (tokensFound == 2)
		{
			pHeader->msPerTick = microsecondsPerBeat / 1000 / 48;
		}
		
		// check program changes ------------------------
		tokensFound = sscanf_s(buffer, "%i PrCh ch=%i p=%i\n", &tick, &channel, &program);
		
		if (tokensFound == 3)
		{
			if ((channel < 7) || (channel > 10))
				Error("Used a channel other than 7, 8, 9 for program change!");
				
			pHeader->program[channel - 7] = program;
		}

		// check notes ------------------------
		tokensFound = sscanf_s(buffer, "%i On ch=%i n=%i v=%i\n", &tick, &channel, &note, &velocity);

		if (tokensFound == 4)
		{
			if (tick != lastTick)
			{
				while (tick - lastTick > 127)
				{
					*pSongPointer++ = MID4K_WAIT(127);
					lastTick += 127;
				}
				
				*pSongPointer++ = MID4K_WAIT(tick - lastTick);
				lastTick = tick;
			}

			if (velocity > 0)
			{
				if ((channel < 7) || (channel > 10))
					Error("Used a channel other than 7, 8, 9, 10 for note-on!");
					
				if (note - MID4K_ROOTNOTE < 0)
					Error("Used a note below MID4K_ROOTNODE!");
					
				if (note - MID4K_ROOTNOTE > 31)
					Error("Used a note above MID4K_ROOTNODE + 31!");

				*pSongPointer++ = MID4K_NOTE(channel - 7, note - MID4K_ROOTNOTE);
			}

		}
	}

	*pSongPointer++ = MID4K_LOOP();

	fclose(pFile);

	// SAVE BIN //////////////////////////////////////////////////////////////////////////
	err = _tfopen_s(&pFile, _pDestName, L"wb");
	fwrite(song, 1, (pSongPointer - song) * sizeof(song[0]), pFile);
	fclose(pFile);
}


int _tmain(int argc, _TCHAR* argv[])
{
	Midi_LoadSong(argv[1], argv[2]);

	return 0;
}

