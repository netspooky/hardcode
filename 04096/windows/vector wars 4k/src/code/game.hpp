#ifndef game_hpp
#define game_hpp

#include "globals.hpp"

#define GAME_INIT_MAXWAVETIME		6.0f	// time a wave lasts (seconds)

#ifndef GAME_CHEATS
	#define GAME_WAVES_PER_TYPE		6		// number of waves until a new enemy type is spawned
	#define GAME_START_WAVE			4		// start wave so it will not take 6 rounds until a new enemy type appears
#else
	#define GAME_WAVES_PER_TYPE		2
	#define GAME_START_WAVE			1
#endif

#define GAME_MIN_ENEMIES			5		// spawn at least this many enemies
#define GAME_BASE_ENEMIES			(GAME_MIN_ENEMIES - GAME_START_WAVE) // spawn this many enemies more than the actual wave id

typedef bool GameRunCallback(); // callback type for game state handlers

// data the game functions need to work
struct Game
{
	GameRunCallback*	pRunCallback;	// pointer to the current game state handler
	unsigned			waveId;			// current wave id
	float				waveTime;		// time left in the current wave
};

void Game_Init();
bool Game_Run();
bool Game_RunIngame();
bool Game_RunMenu();
void Game_SwitchToIngame();
void Game_SwitchToMenu();

extern Game g_game;

#endif // #ifndef game_hpp
