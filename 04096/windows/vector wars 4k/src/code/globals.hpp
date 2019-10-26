#ifndef globals_hpp
#define globals_hpp

#include "helpers.hpp"

#ifdef _DEBUG
// 	#define FULLSCREEN						// if defined the game will run in full screen mode
	#define GAME_CHEATS							// if defined the game will be easier
// 	#define AUDIO_DUMPSFX						// if defined the game will dump the audio effects to disk
// 	#define GAMEOBJECT_DRAWCOLLISIONCIRCLE		// if defined the game will draw collision circles around the objects
#else
	#define FULLSCREEN
// 	#define GAME_CHEATS
//	#define AUDIO_DUMPSFX
//	#define GAMEOBJECT_DRAWCOLLISIONCIRCLE
#endif

#define COLOR_ALPHA 160							// the default alpha value for all game objects
#define COLOR_CLEAR MAKE_RGBA(255, 255, 255, 0)	// the clear color for the background
#define COLOR_FONT	MAKE_RGBA(0, 0, 0, 128)		// the font color

#ifdef FULLSCREEN
	#define SCREEN_WIDTH g_desktopRect.right	// the screen width (should be the desktop resolution)
	#define SCREEN_HEIGHT g_desktopRect.bottom	// the screen height (should be the desktop resolution)
#else
// 	// for testing purposes a 2:1 aspect ratio :-)
//  	#define SCREEN_WIDTH 800
//  	#define SCREEN_HEIGHT 400
 	#define SCREEN_WIDTH 1024
 	#define SCREEN_HEIGHT 768
#endif

//#define SOUND_MUTE							// if defined the game will be silent

extern D3DPRESENT_PARAMETERS screen_params;

extern DWORD g_timeMs;
extern float g_timeDelta;



#endif // #ifndef globals_hpp