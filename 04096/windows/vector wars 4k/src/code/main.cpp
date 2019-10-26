#include "stableheaders.hpp"

#include "audio.hpp"
#include "gameobjects.hpp"
#include "game.hpp"
#include "globals.hpp"
#include "helpers.hpp"
#include "hud.hpp"
#include "level.hpp"
#include "midi.hpp"
#include "templates.hpp"
#include "video.hpp"

//////////////////////////////////////////////////////////////////////////
// DATA
//////////////////////////////////////////////////////////////////////////
#pragma data_seg(".data_main")

#ifndef _DEBUG
extern "C" 
{
	int _fltused = 1; // the compiler needs this for floating point operations
}
#endif

//////////////////////////////////////////////////////////////////////////
// CODE
//////////////////////////////////////////////////////////////////////////
#pragma code_seg(".code_main")

// entry point for the executable
#ifndef _DEBUG
	void mainCRTStartup(void) // if crt is not used
#else
	void main() // if crt is used (debug only)
#endif
{
	#ifdef _DEBUG
		printf("DEBUG MODE!\n\n");
	#endif
	
	// INIT //////////////////////////////////////////////////////////////////////////
	Video_Init();
	HUD_Init();
	
	Midi_Init();
	
	Audio_Init();
	
	GameObject_Init();
	Game_Init();
	Level_Init();

	ShowCursor(false);
	
	g_timeMs = GetTickCount();

	// RUN //////////////////////////////////////////////////////////////////////////
	while(true)
	{
		g_timeDelta = (float) (GetTickCount() - g_timeMs) * 0.001f;
		g_timeMs = GetTickCount();
		
		Video_BeginScene();
		
		if (g_game.pRunCallback() == true)
			ExitProcess(0);
		
		Video_EndScene();
	}
	
	// QUIT //////////////////////////////////////////////////////////////////////////
	//ExitProcess(0);
}
