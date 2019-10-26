#include "stableheaders.hpp"

#include "level.hpp"

#include "audio.hpp"
#include "game.hpp"
#include "gameobjects.hpp"
#include "shape.hpp"
#include "templates.hpp"
#include "video.hpp"

//////////////////////////////////////////////////////////////////////////
// DATA
//////////////////////////////////////////////////////////////////////////
#pragma data_seg(".data_level")

// the enemy templates determine the order of appearance of the enemies
GameObjectTemplate* g_enemyTemplates[] =
{
	&g_templateBouncer,
	&g_templateWanderer,
	&g_templateBlob,
	&g_templateSpeeder,
	&g_templateBouncerInfected,
	&g_templateWandererInfected,
	&g_templateBlobInfected,
	&g_templateBouncerEpidemic,
	&g_templateSpeederEpidemic,
};

//////////////////////////////////////////////////////////////////////////
// CODE
//////////////////////////////////////////////////////////////////////////
#pragma code_seg(".code_level")

////////////////////////////////////////////////////////////////////////////////
//
//	Level_Init()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Sets up the level.

*/
void Level_Init()
{
	// setup game structure
	g_game.waveId = GAME_START_WAVE;
	g_game.waveTime = 0.0f;

	// remove all enemies that may still be active from the last game
	g_pCurrentGameObject = g_firstGameObject.pNext;

	while (g_pCurrentGameObject != &g_lastGameObject)
	{
		g_pCurrentGameObject->hitPoints = 0;
		g_pCurrentGameObject = g_pCurrentGameObject->pNext;
	}

	GameObject_FreeAllTerminated();

	// set up the random seed. unfortunately the random seed is also used for
	// visual effects which means the levels will be different everytime the
	// game is played
	g_randSeed = 987654321;
}

////////////////////////////////////////////////////////////////////////////////
//
//	Level_SpawnEnemies()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Spawns new enemies if the round time has elapsed.

*/
void Level_SpawnEnemies()
{
	unsigned	n;
	GameObject*	pObject;

	// update the wave time left
	g_game.waveTime -= g_timeDelta;
	
	// some functions need the p_pCurrentGameObject set!
	g_pCurrentGameObject = &g_player; 

	// time for a new wave?
	if (g_game.waveTime <= 0)
	{
		// yup! standard wave!
		for (n = 0; n < g_game.waveId + GAME_BASE_ENEMIES; n++)
		{
			unsigned type = 0;

			// 50% chance of random type (else stay with 0)
			if (GetRandomInt16() < 32768 / 2)
			{
				type = GetRandomInt16() % ((g_game.waveId / GAME_WAVES_PER_TYPE) + 1);
				type %= GET_ARRAY_SIZE(g_enemyTemplates);
			}

			// create a spawner for the new object
			pObject = GameObject_CreateSpawner(*g_enemyTemplates[type]);

			// to prevent corner-camping position the first 3 enemies nearby the player!
			if (n < 3)
				GameObject_SetNearbyPosition(pObject, 200.0f);
		}

		// reset wave time
		g_game.waveTime = GAME_INIT_MAXWAVETIME;
		
		// next wave
		g_game.waveId++;
		
		// play the sound effect
		Audio_PlaySound(SB_NEXTWAVE);
	}	
}

////////////////////////////////////////////////////////////////////////////////
//
//	Level_RunAndRender()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Calls all state handlers and renders all game objects.

*/
void Level_RunAndRender()
{
	g_pCurrentGameObject = g_firstGameObject.pNext;

	// any more game objects?
	while (g_pCurrentGameObject != &g_lastGameObject)
	{
		// yes! so run the state handler
		g_pCurrentGameObject->pRunCallback();

		// run default behaviors
		GameObject_RunDefaultBehaviors();
		
		// render the object
		GameObject_Render();

		// next object in list
		g_pCurrentGameObject = g_pCurrentGameObject->pNext;
	}

	// all objects that have been killed this frame need to be removed
	GameObject_FreeAllTerminated();
}
