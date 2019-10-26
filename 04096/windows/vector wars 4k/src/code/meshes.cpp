#include "stableheaders.hpp"

#include "meshes.hpp"

#include "shape.hpp"

//////////////////////////////////////////////////////////////////////////
// DATA
//////////////////////////////////////////////////////////////////////////
#pragma data_seg(".data_meshes")

unsigned __int8 g_shapeEmpty[] =
{
	0,
};

unsigned __int8 g_shapePlayer[] =
{
	2,
	SHAPE_PUSH(),
	
		SHAPE_FORWARD(2),
		SHAPE_RIGHT(7),

		SHAPE_PENDOWN(),
		SHAPE_FORWARD(4),
		SHAPE_RIGHT(7),
		SHAPE_FORWARD(2),
		SHAPE_FLUSH(),

	SHAPE_POP(),
	SHAPE_FLIP(0, 1),
	SHAPE_END(),
};

unsigned __int8 g_shapeCursor[] =
{
	4,
	SHAPE_PUSH(),
	
		SHAPE_PENDOWN(),

		SHAPE_ANIMROTATE(3, 0),
		SHAPE_FORWARD(2),
		SHAPE_RIGHT(6),
		SHAPE_FORWARD(3),
		SHAPE_FLUSH(),

	SHAPE_POP(),
	SHAPE_RIGHT(4),
	SHAPE_END(),
};

unsigned __int8 g_shapeShot[] =
{
	2,
	SHAPE_PUSH(),
	
		SHAPE_FORWARD(1),
		SHAPE_RIGHT(7),

		SHAPE_PENDOWN(),
		SHAPE_FORWARD(2),
		SHAPE_FLUSH(),

	SHAPE_POP(),
	SHAPE_FLIP(0, 1),
	SHAPE_END(),
};


unsigned __int8 g_shapeParticle[] =
{
	4,
	SHAPE_PUSH(),
	
		SHAPE_ANIMROTATE(3, 3),

		SHAPE_PENDOWN(),
		SHAPE_FORWARD(1),
		SHAPE_FLUSH(),

	SHAPE_POP(),
	SHAPE_RIGHT(4),
	SHAPE_SCALE(4),
	SHAPE_END(),
};

unsigned __int8 g_shapeSpawner[] =
{
	4,
	SHAPE_PUSH(),
	
		SHAPE_RIGHT(2),
		SHAPE_FORWARD(2),

		SHAPE_PUSH(),
		
			SHAPE_LEFT(6),
			SHAPE_PENDOWN(),
			SHAPE_FORWARD(1),
			SHAPE_FLUSH(),
			
		SHAPE_POP(),
		SHAPE_RIGHT(6),
		SHAPE_PENDOWN(),
		SHAPE_FORWARD(1),
		SHAPE_FLUSH(),

	SHAPE_POP(),
	SHAPE_RIGHT(4),
	SHAPE_END(),
};

unsigned __int8 g_shapeBouncer[] =
{
	5,
	SHAPE_PUSH(),
	
		SHAPE_ANIMSCALE(1, 2),
		SHAPE_FORWARD(2),
		
		SHAPE_PENDOWN(),
		SHAPE_PENUP(),
		
	SHAPE_POP(),
	SHAPE_RIGHT(4),
	SHAPE_END(),
};

unsigned __int8 g_shapeWanderer[] =
{
	8,
	SHAPE_PUSH(),
	
		SHAPE_ANIMROTATE(3, 0),
		SHAPE_FORWARD(2),
		SHAPE_RIGHT(4),

		SHAPE_PENDOWN(),
		SHAPE_FORWARD(2),
		SHAPE_FLUSH(),

	SHAPE_POP(),
	SHAPE_RIGHT(2),
	SHAPE_END(),
};

unsigned __int8 g_shapeBlob[] =
{
	8,
	SHAPE_PUSH(),

		SHAPE_PENDOWN(),
		SHAPE_FORWARD(2),
		SHAPE_LEFT(2),
		SHAPE_FORWARD(1),
		SHAPE_RIGHT(4),
		SHAPE_FORWARD(1),
		SHAPE_RIGHT(4),
		SHAPE_FORWARD(1),
		SHAPE_RIGHT(4),
		SHAPE_FORWARD(1),
		SHAPE_FLUSH(),

	SHAPE_POP(),
	SHAPE_RIGHT(2),
	SHAPE_END(),
};

unsigned __int8 g_shapeSpeeder[] =
{
	8,

	SHAPE_PUSH(),
	
		SHAPE_ANIMSCALE(1, 3),
		SHAPE_PENDOWN(),
		SHAPE_FORWARD(2),
		SHAPE_FLUSH(),
		
	SHAPE_POP(),
	
	SHAPE_RIGHT(2),
	SHAPE_END(),
};

unsigned __int8 g_shapeFloodling[] =
{
	4,
	SHAPE_PUSH(),
	
		SHAPE_ANIMROTATE(3, 2),
		SHAPE_PENDOWN(),
		SHAPE_FORWARD(1),
		SHAPE_SCALE(4),
		SHAPE_RIGHT(3),
		SHAPE_FORWARD(1),
		SHAPE_SCALE(4),
		SHAPE_RIGHT(3),
		SHAPE_FORWARD(1),
		
	SHAPE_POP(),

	SHAPE_RIGHT(4),
	SHAPE_END(),
};
