#ifndef gameobjects_hpp
#define gameobjects_hpp

#include "helpers.hpp"

#include "globals.hpp"

#define GOF_NONE				0

#define GOF_PLAYER				(1 << 0)	// the object type is player
#define GOF_PLAYER_SHOT			(1 << 1)	// the object type is player's projectile
#define GOF_ENEMY				(1 << 2)	// the object type is enemy
#define GOF_PARTICLE			(1 << 3)	// the object type is particle

#define GOF_XONPLAYER			(1 << 4)	// the object explodes if it hits a player object
#define GOF_XONPLAYER_SHOT		(1 << 5)	// the object explodes it it hits a player's projectile
#define GOF_XONENEMY			(1 << 6)	// the object explodes if it hits an enemy
#define GOF_XON_SHIFT			4			// the shift value to map the XON-flags onto the object type flags
#define GOF_XON_MASK			(GOF_PLAYER | GOF_PLAYER_SHOT | GOF_ENEMY) // the "and" mask to extract only the type-flags

#define GOF_DONTFREE			(1 << 7)	// do not free the objects memory even if it is terminated
#define GOF_SCALEBYHITPOINTS	(1 << 8)	// scale the object according to its hitpoints
#define GOF_TERMINATEIFOUT		(1 << 9)	// terminate the object if it leaves the battle arena
#define GOF_BOUNCEIFOUT			(1 << 10)	// bounce off the walls of the battle arena
#define GOF_INFECTED			(1 << 11)	// the object is infected and will spawn floodlings after being destroyed
#define GOF_EPIDEMIC			(1 << 12)	// the object is epidemic and will clone itself every once in a while

#define GAMEOBJECT_MAX_COUNT				10000	// reserve bss memory for 10000 objects
#define GAMEOBJECT_MAX_SIZE					128		// the number of bytes reserved for a game object
#define GAMEOBJECT_MAX_EXPLODE_PARTICLES	47		// the number of particles spawned if an object explodes
#define GAMEOBJECT_MAX_HIT_PARTICLES		3		// the number of particles spawned if an object is hit
#define GAMEOBJECT_SPLITTIME				3.0f	// the time it takes until an infected object gets split in two

#define SPAWNER_SCALEDOWN_SPEED				5.0f	// speed of the size change of a spawner

#define PLAYER_INIT_HITPOINTS				3		// the initial hit points of the player
#define PLAYER_DIE_TIME						3.0f	// the time the die state lasts (seconds)
#define PLAYER_MAX_UPGRADES					5		// the maximum upgrade level for the player's ship weapons
#define PLAYER_SHOT_STEP					(PI * 0.03f)	// the spread of the player's projectiles (rad)

#ifndef GAME_CHEATS
	#define	PLAYER_MIN_COMBO_PER_UPGRADE	20		// the number of consecutive kills without being killed until the first weapon upgrade is granted
#else
	#define	PLAYER_MIN_COMBO_PER_UPGRADE	3
#endif

#define PLAYER_MAX_RELOADTIME				0.1f	// the reload time until the next projectile can be fired (seconds)

#define IM_FRONT							0		// insert mode "front" - insert the game object at the front of the list
#define IM_BACK								1		// insert mode "back" - insert the game object at the back of the list

typedef void GameObjectRunCallback();				// callback type for game objects state handlers

enum SoundBufferId
{
	SB_SHOT,		// effect id to be used if a projectile as been fired
	SB_HIT,			// effect id to be used if an object is hit by another, most likely a projectile
	SB_EXPLOSION,	// effect id to be used if an object explodes
	SB_NEXTWAVE,	// effect id to be used if the next wave of enemies is spawned

	SB_MAX
};

// the basic data of a game object. this forms a template that is copied if an instance of the game object is created
struct GameObjectTemplate
{
	GameObjectRunCallback*	pRunCallback;			// pointer to the current state handler
	unsigned __int8*		pShape;					// pointer to the shape to draw
	float					radiusSqr;				// the squared radius of the object
	D3DCOLOR				color;					// the color of the object
	unsigned __int32		flags;					// a combination of game object flags (GOF_...)
	int						hitPoints;				// the hitpoints of the object
	unsigned				points;					// the points rewarded for killing this object
	float					rotationSpeed;			// the maximum rotation speed of the object (rad / second)
	float					movementSpeed;			// the maximum movement speed of the object (pixels / second)
};

// the basic instance of a game object. it holds the copied game object template data and some common runtime variables
struct GameObject : GameObjectTemplate
{
	GameObject*				pPrev;					// pointer to the previous game object in the global linked list
	GameObject*				pNext;					// pointer to the next game object in the global linked list
	Vector2					pos;					// the current position of the object (pixels)
	float					rot;					// the current rotation of the object (rad)
	float					scale;					// the current scaling of the object
};

// the player holds all data of a game object and some only used by the player object
struct Player : GameObject
{
	float		reloadTime;							// the time left until the reload is done and another projectile can be fired
	unsigned	score;								// the current score
	unsigned	combo;								// the current consecutive number of kills without being killed
	unsigned	upgradeLevel;						// the current upgrade level
	float		dieTimeLeft;						// the time left until the die state has finished
	__int8		buffer[GAMEOBJECT_MAX_SIZE];		// all objects on stack or in data segment need a buffer as GameObject_SetDefaults() clears at least GAMEOBJECT_MAX_SIZE bytes
};

// the cursor does not really need extra data but its instance is a global variable we need to add a safety buffer to the game objects data
struct Cursor : GameObject
{
	__int8		buffer[GAMEOBJECT_MAX_SIZE];		// all objects on stack or in data segment need a buffer as GameObject_SetDefaults() clears at least GAMEOBJECT_MAX_SIZE bytes
};

// the spawner holds all data of a game object some only used by the spawner object
struct Spawner : GameObject
{
	const GameObjectTemplate*	pTemplate;			// pointer to the template of the object to spawn
};

void		GameObject_Init();
void 		GameObject_InsertFront(GameObject* _pObject);
void 		GameObject_Remove();
void		GameObject_Move();
void		GameObject_SetDefaults(GameObject* _pObject, const GameObjectTemplate& _template);
GameObject* GameObject_Allocate(const GameObjectTemplate& _template);
void		GameObject_FreeAllTerminated();
void		GameObject_TerminateIfOutOfLevel();
void		GameObject_BounceIfOutOfLevel();
void		GameObject_ClipToLevel();
void		GameObject_EpidemicSplit();
void		GameObject_SpawnParticles(const unsigned _numParticles);
void		GameObject_SpawnObjects(const unsigned _numObjects, const GameObjectTemplate& _template, const D3DCOLOR _colorOr, const float _randomPosRange);
int 		GameObject_ExplodeIfHit();
GameObject* GameObject_CreateSpawner(const GameObjectTemplate& _template);
void		GameObject_TurnTo(GameObject* _pDest, const float _speed);
void		GameObject_SetNearbyPosition(GameObject* _pObject, const float _randomPosRange);
void		GameObject_RunDefaultBehaviors();
void		GameObject_Render();

void 		Player_Init();
void 		Player_RunMove();
void		Player_RunDie();
void		Player_RunDead();
void 		Cursor_Run();
void		Spawner_Run();
void		AllInOne_Run();

extern GameObject	g_firstGameObject;
extern GameObject	g_lastGameObject;
extern GameObject*	g_pCurrentGameObject;
extern Player		g_player;

#endif // #ifndef gameobjects_hpp
