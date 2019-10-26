#include "stableheaders.hpp"

#include "gameobjects.hpp"

#include "audio.hpp"
#include "game.hpp"
#include "globals.hpp"
#include "meshes.hpp"
#include "midi.hpp"
#include "shape.hpp"
#include "templates.hpp"
#include "video.hpp"


//////////////////////////////////////////////////////////////////////////
// BSS
//////////////////////////////////////////////////////////////////////////
#pragma bss_seg(".bss_gameobjects")

Player		g_player;									// the global player object
Cursor		g_cursor;									// the global cursor object
GameObject	g_firstGameObject;							// the first game object (head) of the list - unused
GameObject	g_lastGameObject;							// the last game object (tail) of the list - unused
GameObject*	g_pCurrentGameObject;						// pointer to the current game object to work with
GameObject*	g_pGameObjectStack[GAMEOBJECT_MAX_COUNT];	// stack of pointers that point to free memory reserved for game objects
unsigned	g_insertMode;								// the current insert mode. set to IM_FRONT (default) or IM_BACK.
float		g_splitTime;



//////////////////////////////////////////////////////////////////////////
// DATA
//////////////////////////////////////////////////////////////////////////
#pragma data_seg(".data_gameobjects")

unsigned	g_stackTop = GAMEOBJECT_MAX_COUNT - 1;		// the top index of the g_pGameObjectStack[]

// definition of all sound effects to be generated and used
SfxData g_sfxData[SB_MAX] =
{
	// SHOT //////////////////////////////////////////////////////////////////////////
	{
		SF_SAW,								// flags
		(int) AUDIO_MS_TO_FRAMES(50),		// length
		4000.0f,							// oscFreq
		-2000.0f / AUDIO_MS_TO_FRAMES(50),	// oscSlide
		1.0f,								// vol
		-0.5f / AUDIO_MS_TO_FRAMES(50),		// volSlide
		1.0f,								// filterFreq
		-1.0f / AUDIO_MS_TO_FRAMES(50),		// filterSlide
	},

	// HIT //////////////////////////////////////////////////////////////////////////
	{
		SF_NOISE,							// flags
		(int) AUDIO_MS_TO_FRAMES(50),		// length
		8000.0f,							// oscFreq
		0.0f,								// oscSlide
		0.5f								// vol
		-0.5f / AUDIO_MS_TO_FRAMES(50),		// volSlide
		0.3f,								// filterFreq
		0.0f,								// filterSlide
	},
	
	// EXPLOSION //////////////////////////////////////////////////////////////////////////
	{
		SF_NOISE,							// flags
		(int) AUDIO_MS_TO_FRAMES(800),		// length
		11000.0f,							// oscFreq
		-10000.0f / AUDIO_MS_TO_FRAMES(800),// oscSlide
		1.0f,								// vol
		-1.0f / AUDIO_MS_TO_FRAMES(800),	// volSlide
		0.8f,								// filterFreq
		-0.8f / AUDIO_MS_TO_FRAMES(800),	// filterSlide
	},

	// NEXT WAVE //////////////////////////////////////////////////////////////////////////
	{
		SF_SAW | SF_NOISE,					// flags
		(int) AUDIO_MS_TO_FRAMES(1000),		// length
		5000.0f,							// oscFreq
		-3000.0f / AUDIO_MS_TO_FRAMES(1000),// oscSlide
		0.25f,								// vol
		0.5f / AUDIO_MS_TO_FRAMES(1000),	// volSlide
		0.0f,								// filterFreq
		0.8f / AUDIO_MS_TO_FRAMES(1000),	// filterSlide
	},
};


//////////////////////////////////////////////////////////////////////////
// CODE
//////////////////////////////////////////////////////////////////////////
#pragma code_seg(".code_gameobjects")

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_Init()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Set up the game object handling.

*/
void GameObject_Init()
{
	unsigned n;
	
	// allocate memory for the maximum number of game objects
	for (n = 0; n < GAMEOBJECT_MAX_COUNT; n++)
		g_pGameObjectStack[n] = (GameObject*) LocalAlloc(LMEM_FIXED, GAMEOBJECT_MAX_SIZE);
	
	// generate all needed sound effects
	for (n = 0; n < SB_MAX; n++)
		Audio_CreateSfx(&g_sfxData[n], n);
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_InsertFront()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Insert the given game object at the beginning of the linked list.

	\param _pObject

		Pointer to the object to link in.

	\remarks

		The g_firstGameObject and the g_lastGameObject are just head and tail
		objects which make the code for insertion and removal easier as there
		are no special cases for lists with 0 or 1 entry or removal of the
		first or last object.

*/
void GameObject_InsertFront(GameObject* _pObject)
{
	_pObject->pPrev = &g_firstGameObject;
	_pObject->pNext = g_firstGameObject.pNext;
	g_firstGameObject.pNext->pPrev = _pObject;
	g_firstGameObject.pNext = _pObject;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_InsertBack()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Insert the given game object at the end of the linked list.

	\param _pObject

		Pointer to the object to link in.

	\remarks

		See GameObject_InsertFront().

*/
void GameObject_InsertBack(GameObject* _pObject)
{
	_pObject->pPrev = g_lastGameObject.pPrev;
	_pObject->pNext = &g_lastGameObject;
	g_lastGameObject.pPrev->pNext = _pObject;
	g_lastGameObject.pPrev = _pObject;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_Remove()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Remove the current game object from the linked list.

	\remarks

		See GameObject_InsertFront().

*/
void GameObject_Remove()
{
	g_pCurrentGameObject->pPrev->pNext = g_pCurrentGameObject->pNext;
	g_pCurrentGameObject->pNext->pPrev = g_pCurrentGameObject->pPrev;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_Move()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Moves the game object with its internal speed.
*/
void GameObject_Move()
{
	// calculate the actual movement
	float movement = g_pCurrentGameObject->movementSpeed * g_timeDelta;
	
	// into the direction given by rot
	g_pCurrentGameObject->pos.x += SinF(g_pCurrentGameObject->rot) * movement;
	g_pCurrentGameObject->pos.y -= CosF(g_pCurrentGameObject->rot) * movement;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_SetDefaults()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Set the default values of the given game object based on the given
		template.

	\param _pObject

		Pointer to the game object to set default values.

	\param _template

		Template to read the default values from.

	\remarks

		A few parameters are not copied from the template but set to default
		values.
		
		The game object is also inserted into the global linked list.

*/
void GameObject_SetDefaults(GameObject* _pObject, const GameObjectTemplate& _template)
{
	// make sure the game object is in a defined state
	MemClear(_pObject, GAMEOBJECT_MAX_SIZE);
	MemCopy(_pObject, &_template, sizeof(GameObjectTemplate));
	
	// set default values that are not stored within a template
	_pObject->scale = 1.0f;
	_pObject->rot = GetRandomFloat() * 2.0f * PI;

	// should the object be inserted at the beginning of the list?
	if (g_insertMode == IM_FRONT)
		// yes!
		GameObject_InsertFront(_pObject);
	else
		// no! so insert it at the back
		GameObject_InsertBack(_pObject);
	
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_Allocate()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Allocates free memory for a game object and initialize it.

	\param _template

		The template to use for initialization.

	\return

		The pointer to the new and initialized game object.

*/
GameObject* GameObject_Allocate(const GameObjectTemplate& _template)
{
	GameObject* pObject;
	
	// get a pointer to a free memory block from the top of the stack
	pObject = g_pGameObjectStack[g_stackTop--];
	
	// set the default values
	GameObject_SetDefaults(pObject,_template);
	
	// return the pointer to the new and initialized object
	return pObject;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_FreeAllTerminated()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Frees all game objects that have been terminated since the last call to
		this function.

	\remarks

		The game object will be removed from the list and the pointer to its
		memory will be put on the top of the stack.

*/
void GameObject_FreeAllTerminated()
{
	GameObject* pNext;

	// start with the first real game object. the one just after the head of the list
	g_pCurrentGameObject = g_firstGameObject.pNext;
	
	// are there still objects to check?
	while (g_pCurrentGameObject != &g_lastGameObject)
	{
		// yes! so store the pointer to the next object
		pNext = g_pCurrentGameObject->pNext;

		// has the current object been terminated?
		if (g_pCurrentGameObject->hitPoints <= 0)
		{
			// yes! so remove it from the list
			GameObject_Remove();
			
			// is it an object that should free its memory?
			if (!(g_pCurrentGameObject->flags & GOF_DONTFREE))
				// yes! put the pointer to its memory back onto the stack
				g_pGameObjectStack[++g_stackTop] = g_pCurrentGameObject;
		}

		// go on with the next object in the list
		g_pCurrentGameObject = pNext;
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_TerminateIfOutOfLevel()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Terminates the object if its position is outside of the battle arena.
*/
void GameObject_TerminateIfOutOfLevel()
{
	if
	(
		(g_pCurrentGameObject->pos.x < 0)
		|| (g_pCurrentGameObject->pos.x > SCREEN_WIDTH)
		|| (g_pCurrentGameObject->pos.y < 0)
		|| (g_pCurrentGameObject->pos.y > SCREEN_HEIGHT)
	)
	{
		g_pCurrentGameObject->hitPoints = 0;
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_BounceIfOutOfLevel()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Bounces an object off the battle arena's walls.

	\remarks

		It does not really reflect the object but bounce it off in a random
		angle.
		
		An interesting side note from trying to minimize code: I took the
		invariant term "GetRandomFloat() * PI" out of the four if-statements
		and calculated it once before any of the if-statement. I used the
		pre-calculated angle within the four if-statements and figured I would
		save some bytes because I removed three unnecessary jumps. But after
		packing it with Crinkler the executable increased in size, so I
		reverted the change. Strange...

*/
void GameObject_BounceIfOutOfLevel()
{
	if (g_pCurrentGameObject->pos.x < 0)
		g_pCurrentGameObject->rot = GetRandomFloat() * PI;
	
	if (g_pCurrentGameObject->pos.x > (float) SCREEN_WIDTH)
		g_pCurrentGameObject->rot = GetRandomFloat() * PI + PI;
	
	if (g_pCurrentGameObject->pos.y < 0)
		g_pCurrentGameObject->rot = GetRandomFloat() * PI + PI * 0.5f;
	
	if (g_pCurrentGameObject->pos.y > (float) SCREEN_HEIGHT)
		g_pCurrentGameObject->rot = GetRandomFloat() * PI - PI * 0.5f;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_ClipToLevel()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Keeps the game object within the battle arena.

*/
void GameObject_ClipToLevel()
{
	if (g_pCurrentGameObject->pos.x < 0)
		g_pCurrentGameObject->pos.x = 0;

	if (g_pCurrentGameObject->pos.x > (float) SCREEN_WIDTH)
		g_pCurrentGameObject->pos.x = (float) SCREEN_WIDTH;

	if (g_pCurrentGameObject->pos.y < 0)
		g_pCurrentGameObject->pos.y = 0;

	if (g_pCurrentGameObject->pos.y > (float) SCREEN_HEIGHT)
		g_pCurrentGameObject->pos.y = (float) SCREEN_HEIGHT;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_EpidemicSplit()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Splits the object in two if enough time has passed.

*/
void GameObject_EpidemicSplit()
{
	// update split time
	g_splitTime -= g_timeDelta;
	
	// enough time passed?
	if (g_splitTime <= 0.0f)
	{
		GameObject* pObject = GameObject_Allocate(*g_pCurrentGameObject);

		GameObject_SetNearbyPosition(pObject, 50.0f);
		
		g_splitTime += GAMEOBJECT_SPLITTIME;
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_CreateSpawner()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Creates a spawner object which spawns the actual object after some time.

	\param _template

		The template for the object to spawn.

	\return

		Returns a pointer to the new and initialized spawner.

*/
GameObject* GameObject_CreateSpawner(const GameObjectTemplate& _template)
{
	// allocate the game object
	Spawner* pSpawner = (Spawner *) GameObject_Allocate(g_templateSpawner);
	
	// store a pointer to the template
	pSpawner->pTemplate = &_template;
	
	// put the spawner at a random position inside the battle arena
	pSpawner->pos.x = GetRandomFloat() * SCREEN_WIDTH;
	pSpawner->pos.y = GetRandomFloat() * SCREEN_HEIGHT;
	
	// set the initial scale
	pSpawner->scale = 5.0f;
	
	// use the same color as the object to be spawned
	pSpawner->color = pSpawner->pTemplate->color;
	
	// return the pointer to the new and initialized spawner
	return pSpawner;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_TurnTo()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Turn the current game object towards the given object.

	\param _pDest

		Pointer to the object to turn to.

*/
void GameObject_TurnTo(GameObject* _pDest)
{
	float destRot;
	float diffOfAngles;
	
	// get the angle pointing directly towards the other game object
	destRot = GetAngle(_pDest->pos.x - g_pCurrentGameObject->pos.x, _pDest->pos.y - g_pCurrentGameObject->pos.y);
	
	// calculate the difference between the current rotation and the rotation that points towards the other object
	diffOfAngles = GetDiffOfAngles(g_pCurrentGameObject->rot, destRot);
	
	// interpolate between the two angles using the turning speed of the current game object
	ApproxLinear(&g_pCurrentGameObject->rot, g_pCurrentGameObject->rot + diffOfAngles, g_pCurrentGameObject->rotationSpeed, g_timeDelta);
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_SetNearbyPosition()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Sets the position of the given object within the given range of the
		current game object.

	\param _pObject

		Pointer to the object to position nearby the current game object.

	\param _randomPosRange

		The random range along the x and y axis.

*/
void GameObject_SetNearbyPosition(GameObject* _pObject, const float _randomPosRange)
{
	// add random offset
	_pObject->pos.x = g_pCurrentGameObject->pos.x - _randomPosRange * 0.5f + GetRandomFloat() * _randomPosRange;
	_pObject->pos.y = g_pCurrentGameObject->pos.y - _randomPosRange * 0.5f + GetRandomFloat() * _randomPosRange;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_RunDefaultBehaviours()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Applies default behaviors if the matching game object flags are set.

*/
void GameObject_RunDefaultBehaviors()
{
	// terminate the object if it is outside the battle arena?
	if (g_pCurrentGameObject->flags & GOF_TERMINATEIFOUT)
		// yes!
		GameObject_TerminateIfOutOfLevel();

	// bounce the object off the walls?
	if (g_pCurrentGameObject->flags & GOF_BOUNCEIFOUT)
		// yes!
		GameObject_BounceIfOutOfLevel();

	// split the object after some time?
	if (g_pCurrentGameObject->flags & GOF_EPIDEMIC)
		// yes!
		GameObject_EpidemicSplit();
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_Render()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Render the current game object.

*/
void GameObject_Render()
{
	float			scale;

	// start with the scale stored in the object data
	scale = g_pCurrentGameObject->scale;

	// should the object be scaled according to its hitpoints?
	if (g_pCurrentGameObject->flags & GOF_SCALEBYHITPOINTS)
	{
		// yes! so scale it
		scale = (float) g_pCurrentGameObject->hitPoints * 0.5f;
		
		// and do not forget to adjust the radius for collision checks
		g_pCurrentGameObject->radiusSqr = (scale * 20.0f) * (scale * 20.0f);
	}

	// start the shape rendering process at the current position with the current rotation and scaling
	g_pMatrixStack->LoadIdentity();
	g_pMatrixStack->Scale(scale, scale, scale);
	g_pMatrixStack->RotateYawPitchRoll(0, 0, g_pCurrentGameObject->rot);
	g_pMatrixStack->Translate(g_pCurrentGameObject->pos.x, g_pCurrentGameObject->pos.y, 0);

	// retrieve the number of iterations the shape should be rendered
	__int8 numIterations = *g_pCurrentGameObject->pShape;
	__int8 iteration;
	
	// set the shape phase for animated shapes
	g_shapePhase = (float) (g_timeMs * (1 << (g_shapeCommandValue >> 2)) & 4095) / 4095.0f * PI;


	// reset the shape
	Shape_Reset();

	for (iteration = 0; iteration < numIterations; iteration++)
	{
		// start with the first shape data
		unsigned __int8* pShapeData = g_pCurrentGameObject->pShape + 1;
		unsigned __int8	command;

		// any more data?
		while ((command = *pShapeData++) != SHAPE_END())
		{
			// yes! so extract the "value" from the data
			g_shapeCommandValue = command & 0x0F;
			
			// now extract and execute the "command"
			g_pShapeFunctions[command >> 4]();

			// if the pen is down, then add a vertex after any command
			if (g_shapeData.g_shapePenDown)
				Shape_AddVertex();
		}
	}

	// finally draw whatever vertices are left in the vertex buffer
	Shape_Flush();
	
	#ifdef GAMEOBJECT_DRAWCOLLISIONCIRCLE
	
		unsigned n;
		
		Shape_Reset();
		
		for (n = 0; n < 13; n++)
		{
			g_pMatrixStack->LoadIdentity();
			g_pMatrixStack->Translate(0, SqrtF(g_pCurrentGameObject->radiusSqr), 0);
			g_pMatrixStack->RotateYawPitchRoll(0, 0, (float) n / 12.0f * 2.0f * PI);
			g_pMatrixStack->Translate(g_pCurrentGameObject->pos.x, g_pCurrentGameObject->pos.y, 0);
			Shape_AddVertex();
		}
		
		Shape_Flush();
		
	#endif
}

////////////////////////////////////////////////////////////////////////////////
//
//	Player_Init()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Sets up the player object.

*/
void Player_Init()
{
	// default values for the cursor and the player (spaceship) are needed
	GameObject_SetDefaults(&g_cursor, g_templateCursor);

	GameObject_SetDefaults(&g_player, g_templatePlayer);
	g_player.pos.x = (float) SCREEN_WIDTH / 2.0f;
	g_player.pos.y = (float) SCREEN_HEIGHT / 2.0f;
}

////////////////////////////////////////////////////////////////////////////////
//
//	Player_RunMove()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		State handler for the player's "move" state.

*/
void Player_RunMove()
{
	// ROTATION //////////////////////////////////////////////////////////////////////////
	GameObject_TurnTo(&g_cursor);
	
	// MOVEMENT //////////////////////////////////////////////////////////////////////////
	float movement;
	
	// calculate the movement for this frame according to speed and time delta
	movement = g_timeDelta * g_player.movementSpeed;
	
	// user pressed "left"?
	if (GetAsyncKeyState(VK_LEFT))
		// yes! so move left
		g_player.pos.x -= movement;

	// user pressed "right"?
	if (GetAsyncKeyState(VK_RIGHT))
		// yes! so move right
		g_player.pos.x += movement;

	// user pressed "up"?
	if (GetAsyncKeyState(VK_UP))
		// yes! so move up
		g_player.pos.y -= movement;

	// user pressed "down"
	if (GetAsyncKeyState(VK_DOWN))
		// yes! so move down
		g_player.pos.y += movement;
		
	// make sure the player object stays within the battle arena
	GameObject_ClipToLevel();
	
	// SHOT //////////////////////////////////////////////////////////////////////////
	
	// update reload time
	g_player.reloadTime -= g_timeDelta;
	
	// user pressed "fire" and reload time has passed?
	if (GetAsyncKeyState(VK_LBUTTON) && g_player.reloadTime <= 0.0f)
	{
		// yes! so fire projectiles
		GameObject* pObject;
		unsigned n;
		
		// determine angle of the first projectile. it depends on the upgrade level
		// and thus the number of projectiles fired.
		float rot = g_player.rot - (float) g_player.upgradeLevel * PLAYER_SHOT_STEP * 0.5f;
		
		// fire all projectiles
		for (n = 0; n <= g_player.upgradeLevel; n++)
		{
			// allocate a new game object
			pObject = GameObject_Allocate(g_templateShot);
			
			// set its starting position to where the player is located
			pObject->pos = g_player.pos;
			
			// set its angle
			pObject->rot = rot;
			
			// set angle for next projectile
			rot += PLAYER_SHOT_STEP;
		}
		
		// after firing a projectile there is a reload time
		g_player.reloadTime = PLAYER_MAX_RELOADTIME;

		// play a sound effect
		Audio_PlaySound(SB_SHOT);
	}
	
	// COLLISION //////////////////////////////////////////////////////////////////////////
	
	// determine if the player hit anything
	int collision = GameObject_ExplodeIfHit();
	
	// any collision at all?
	if (collision)
	{
		// yes! so downgrade if there are any upgrades yet
		if (g_player.upgradeLevel)
		{
			g_player.upgradeLevel--;
			g_player.combo = 0;
		}
	}

	// did the player die due to the collision?
	if (collision == -1)
	{
		// yes! but the player object should not be removed!
		g_player.hitPoints++;
		
		// instead set the "die" state to keep the current battle scene running for a few seconds
		g_player.pRunCallback = Player_RunDie;
		g_player.dieTimeLeft = PLAYER_DIE_TIME;
	}
	
	// adjust the player's color to reflect the current hitpoint reserve
	unsigned hitPointBrightness = (PLAYER_INIT_HITPOINTS - g_player.hitPoints) * (255 / PLAYER_INIT_HITPOINTS);
	g_player.color = MAKE_RGBA(hitPointBrightness, 0, 0, 128);

	// UPGRADE //////////////////////////////////////////////////////////////////////////
	
	// enough combo kills? not yet upgraded to the max?
	if ((g_player.combo >= PLAYER_MIN_COMBO_PER_UPGRADE * (1 << g_player.upgradeLevel)) && (g_player.upgradeLevel < PLAYER_MAX_UPGRADES - 1))
	{
		// yes! so reset the combo counter and upgrade the ship
		g_player.combo = 0;
		g_player.upgradeLevel++;
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	Player_RunDie()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		State handler for the player's "die" state.

*/
void Player_RunDie()
{
	// update "die" time
	g_player.dieTimeLeft -= g_timeDelta;
	
	// still some "die" time left?
	if (g_player.dieTimeLeft <= 0)
		// no! so the player is now "dead" and the game should end
		g_player.pRunCallback = Player_RunDead;
}

////////////////////////////////////////////////////////////////////////////////
//
//	Player_RunDead()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		State handler for the player's "dead" state.

*/
void Player_RunDead()
{
	// nothing to do here...
}

////////////////////////////////////////////////////////////////////////////////
//
//	Cursor_Run()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		State handler for the single "default" state of the cursor.

*/
void Cursor_Run()
{
	POINT cursorPos;
	
	// get the windows mouse position
	GetCursorPos(&cursorPos);
	
	// use them as game object position
	g_cursor.pos.x = (float) cursorPos.x;
	g_cursor.pos.y = (float) cursorPos.y;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_SpawnParticles()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Spawn a number of particles.

	\param _numParticles

		The number of particles to spawn.

*/
void GameObject_SpawnParticles(const unsigned _numParticles)
{
	// insert them at the end! this is needed for the optimization of the collision detection
	g_insertMode = IM_BACK;
	
	// use the more general function to create the particles
	GameObject_SpawnObjects(_numParticles, g_templateParticle, 0x00808080, 20.0f);
	
	// restore standard insertion mode
	g_insertMode = IM_FRONT;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_SpawnObjects()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Spawn a number of game objects.

	\param _numObjects

		The number of objects to spawn.

	\param _template

		The template to use for the new objects.

	\param _colorOr

		A color value that gets ORed with the current game object's color to become
		the final color for the new objects.

	\param _randomPosRange

		The position of the new objects will be the current game object's position
		plus a random offset within the given range.

*/
void GameObject_SpawnObjects(const unsigned _numObjects, const GameObjectTemplate& _template, const D3DCOLOR _colorOr, const float _randomPosRange)
{
	unsigned	n;
	
	for (n = 0; n < _numObjects; n++)
	{
		GameObject* pObject;
		
		// allocate a new object
		pObject = GameObject_Allocate(_template);
		
		// set a nearby position within the given range
		GameObject_SetNearbyPosition(pObject,_randomPosRange);
		
		// set a somewhat random movement speed
		pObject->movementSpeed += GetRandomFloat() * pObject->movementSpeed;
		
		// apply the new color
		pObject->color = g_pCurrentGameObject->color | _colorOr;
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	GameObject_ExplodeIfHit()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Does a collision check for the current game object against those objects
		determined by the GOF_XON... flags.

	\return

		0 = no collision; 1 = collision but HP left; -1 collision and no HP left

	\remarks

		A small speed optimization is that all particles (which can be a lot) are
		put at the end of the linked list of game objects. This means as soon as
		a particle is found, the collision detection can be exited.

*/
int GameObject_ExplodeIfHit()
{
	GameObject* pCurrent;
	
	// check out all gameobjects
	pCurrent = g_firstGameObject.pNext;
	
	while (pCurrent->pNext != &g_lastGameObject)
	{
		// bail out if the first particle is encountered (they are all stacked at the end of the list)
		if (pCurrent->flags & GOF_PARTICLE)
			break;
			
		// does it fit any of the filtered flags?
		if (pCurrent->flags & ((g_pCurrentGameObject->flags >> GOF_XON_SHIFT) & GOF_XON_MASK))
		{
			Vector2 delta;
			
			// yes! so what is the distance between the two?
			delta.x = pCurrent->pos.x - g_pCurrentGameObject->pos.x;
			delta.y = pCurrent->pos.y - g_pCurrentGameObject->pos.y;
			
			// is it close enough?
			if (delta.x * delta.x + delta.y * delta.y < g_pCurrentGameObject->radiusSqr + pCurrent->radiusSqr)
			{
				// yes! so they hit each other!
				GameObject_SpawnParticles(GAMEOBJECT_MAX_HIT_PARTICLES);

				// play a hit sound effect
				Audio_PlaySound(SB_HIT);
				
				// no hitpoints for other object!
				pCurrent->hitPoints = 0;
					
				// no hitpoints left?
				if (--g_pCurrentGameObject->hitPoints <= 0)
				{
					// if it is an enemy that is destroyed, the player gets some score
					if (g_pCurrentGameObject->flags & GOF_ENEMY)
					{
						g_player.score += g_pCurrentGameObject->points;
						g_player.combo++;
					}
					
					// set an empty shape. this is actually only needed for the player since
					// all other objects will get frees at the end of the frame anyways
					g_pCurrentGameObject->pShape = g_shapeEmpty;
					
					// also spawn a few particles
					GameObject_SpawnParticles(GAMEOBJECT_MAX_EXPLODE_PARTICLES);
					
					// is it an infected object?
					if (g_pCurrentGameObject->flags & GOF_INFECTED)
						// yes! so spawn a few floodlings
						GameObject_SpawnObjects(3 + (GetRandomInt16() & 0x0007), g_templateFloodling, 0x00000000, 50.0f);

					// play an explosion sound effect
					Audio_PlaySound(SB_EXPLOSION);
					
					// return that the object has been destroyed
					return -1;
				}
				
				// return that the object has been hit
				return 1;
			}
		}

		// check against the next object in the linked list
		pCurrent = pCurrent->pNext;
	}
	
	// no hit
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
//	Spawner_Run()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		State handler for the spawner's "default" state.

*/
void Spawner_Run()
{
	// keep the spawner inside the battle arena
	GameObject_ClipToLevel();

	// scale the spawner over time
	g_pCurrentGameObject->scale -= g_timeDelta * SPAWNER_SCALEDOWN_SPEED;
	
	// has the spawner been "minimized"?
	if (g_pCurrentGameObject->scale <= 0)
	{
		// yes! so convert it to the actual game object
		MemCopy(g_pCurrentGameObject, ((Spawner *) g_pCurrentGameObject)->pTemplate, sizeof(GameObjectTemplate));
		
		// and reset the scale
		g_pCurrentGameObject->scale = 1.0f;
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	AllInOne_Run()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		The default state handler for most game objects.

	\remarks

		Most game objects have been parameterized so they can use a single
		state handler and a few flags.

*/
void AllInOne_Run()
{
	// turn the object towards the player (if turning speed is 0, it will obviously not turn - such as the bouncer)
	GameObject_TurnTo(&g_player);
	
	// move the object
	GameObject_Move();
	
	// check collisions
	GameObject_ExplodeIfHit();
}
