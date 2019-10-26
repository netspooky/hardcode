#include "stableheaders.hpp"

#include "templates.hpp"

#include "globals.hpp"
#include "meshes.hpp"

//////////////////////////////////////////////////////////////////////////
// DATA
//////////////////////////////////////////////////////////////////////////
#pragma data_seg(".data_templates")

//////////////////////////////////////////////////////////////////////////
GameObjectTemplate g_templatePlayer =
{
	Player_RunMove,
	g_shapePlayer,
	22.0f * 22.0f,
	MAKE_RGBA(0, 0, 0, COLOR_ALPHA),
	GOF_PLAYER | GOF_XONENEMY | GOF_DONTFREE,
	PLAYER_INIT_HITPOINTS,
	0,
	1000.0f, // rotation speed / rad per second (ASAP :-)
	400.0f , // movement speed / pixel per second
};

GameObjectTemplate g_templateCursor =
{
	Cursor_Run,
	g_shapeCursor,
	0,
	MAKE_RGBA(128, 128, 128, COLOR_ALPHA),
	GOF_NONE | GOF_DONTFREE,
	1,
	0,
	0, // rotation speed / rad per second
	0, // movement speed / pixel per second
};

GameObjectTemplate g_templateShot =
{
	AllInOne_Run,
	g_shapeShot,
	45.0f * 45.0f,
	MAKE_RGBA(0, 0, 0, COLOR_ALPHA),
	GOF_PLAYER_SHOT | GOF_TERMINATEIFOUT,
	1,
	0,
	0, // rotation speed / rad per second
	1500.0f, // movement speed / pixel per second
};


//////////////////////////////////////////////////////////////////////////
GameObjectTemplate g_templateParticle =
{
	AllInOne_Run,
	g_shapeParticle,
	0,
	0, // color is set by program
	GOF_PARTICLE | GOF_TERMINATEIFOUT,
	1,
	0,
	0, // rotation speed / rad per second
	400.0f, // movement speed / pixel per second (set in spawn method)
};

GameObjectTemplate g_templateSpawner =
{
	Spawner_Run,
	g_shapeSpawner,
	0,
	0, // color is set by program
	GOF_NONE,
	1,
	0,
	0, // rotation speed / rad per second
	0, // movement speed / pixel per second
};

//////////////////////////////////////////////////////////////////////////
GameObjectTemplate g_templateBouncer =
{
	AllInOne_Run,
	g_shapeBouncer,
	15.0f * 15.0f, // radius * radius
 	MAKE_RGBA(0, 127, 127, COLOR_ALPHA),
	GOF_ENEMY | GOF_XONPLAYER_SHOT | GOF_BOUNCEIFOUT,
	1, // hitpoints
	30, // points
	0.0f, // rotation speed / rad per second
	125.0f, // movement speed / pixel per second
};

GameObjectTemplate g_templateBouncerInfected =
{
	AllInOne_Run,
	g_shapeBouncer,
	15.0f * 15.0f, // radius * radius
	MAKE_RGBA(127, 0, 0, COLOR_ALPHA),
	GOF_ENEMY | GOF_XONPLAYER_SHOT | GOF_BOUNCEIFOUT | GOF_INFECTED,
	2, // hitpoints
	2 * 30, // points
	0.0f, // rotation speed / rad per second
	125.0f, // movement speed / pixel per second
};

GameObjectTemplate g_templateBouncerEpidemic =
{
	AllInOne_Run,
	g_shapeBouncer,
	15.0f * 15.0f, // radius * radius
	MAKE_RGBA(127, 0, 127, COLOR_ALPHA),
	GOF_ENEMY | GOF_XONPLAYER_SHOT | GOF_BOUNCEIFOUT | GOF_EPIDEMIC,
	3, // hitpoints
	3 * 30, // points
	0.0f, // rotation speed / rad per second
	125.0f, // movement speed / pixel per second
};

GameObjectTemplate g_templateWanderer =
{
	AllInOne_Run,
	g_shapeWanderer,
	15.0f * 15.0f,
	MAKE_RGBA(0, 127, 0, COLOR_ALPHA),
	GOF_ENEMY | GOF_XONPLAYER_SHOT,
	2,
	50,
	2.5f, // rotation speed / rad per second
	125.0f, // movement speed / pixel per second
};

GameObjectTemplate g_templateWandererInfected =
{
	AllInOne_Run,
	g_shapeWanderer,
	15.0f * 15.0f,
	MAKE_RGBA(127, 0, 0, COLOR_ALPHA),
	GOF_ENEMY | GOF_XONPLAYER_SHOT | GOF_INFECTED,
	2 * 2,
	2 * 50,
	1.2f * 2.5f, // rotation speed / rad per second
	1.2f * 125.0f, // movement speed / pixel per second
};

GameObjectTemplate g_templateBlob =
{
	AllInOne_Run,
	g_shapeBlob,
	30.0f * 30.0f,
	MAKE_RGBA(127, 127, 0, COLOR_ALPHA),
	GOF_ENEMY | GOF_XONPLAYER_SHOT | GOF_SCALEBYHITPOINTS,
	10,
	150,
	7.5f, // rotation speed / rad per second
	60.0f, // movement speed / pixel per second
};

GameObjectTemplate g_templateBlobInfected =
{
	AllInOne_Run,
	g_shapeBlob,
	30.0f * 30.0f,
	MAKE_RGBA(127, 0, 0, COLOR_ALPHA),
	GOF_ENEMY | GOF_XONPLAYER_SHOT | GOF_SCALEBYHITPOINTS | GOF_INFECTED,
	10,
	2 * 150,
	7.5f, // rotation speed / rad per second
	60.0f, // movement speed / pixel per second
};

GameObjectTemplate g_templateSpeeder =
{
	AllInOne_Run,
	g_shapeSpeeder,
	15.0f * 15.0f,
	MAKE_RGBA(0, 0, 127, COLOR_ALPHA),
	GOF_ENEMY | GOF_XONPLAYER_SHOT,
	1,
	100,
	5.0f, // rotation speed / rad per second
	350.0f, // movement speed / pixel per second
};

GameObjectTemplate g_templateSpeederEpidemic =
{
	AllInOne_Run,
	g_shapeSpeeder,
	15.0f * 15.0f,
	MAKE_RGBA(127, 0, 127, COLOR_ALPHA),
	GOF_ENEMY | GOF_XONPLAYER_SHOT | GOF_EPIDEMIC,
	2 * 1,
	2 * 100,
	5.0f, // rotation speed / rad per second
	350.0f, // movement speed / pixel per second
};

GameObjectTemplate g_templateFloodling =
{
	AllInOne_Run,
	g_shapeFloodling,
	5.0f * 5.0f, // radius * radius
	0, // color is set by program
	GOF_ENEMY | GOF_XONPLAYER_SHOT,
	1, // hitpoints
	30, // points
	5.0f, // rotation speed / rad per second
	150.0f, // movement speed / pixel per second
};
