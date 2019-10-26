#ifndef shape_hpp
#define shape_hpp

#include "helpers.hpp"

#define SHAPE_STEPSIZE	7.0f	// the number of pixels to move forward per single forward step
#define SHAPE_PENSIZE	7.0f	// the width of the pen to draw the shapes with (pixels)

// the shape commands
enum Shape
{
	S_FORWARD,		// step forward
	S_RIGHT,		// turn right
	S_FLIP,			// flip along x- and/or y-axis
	S_SCALE,		// set a new scale for the following commands
	S_PEN,			// lower / raise the pen to start / end drawing
	S_PUSH,			// push current shape matrix state to stack
	S_POP,			// pop topmost shape matrix state from stack
	S_FLUSH,		// draw all vertices queued in the vertex buffer
	S_ANIMROTATE,	// a time based rotation
	S_ANIMSCALE,	// a time based scaling

	S_MAX
};

// convenience macros to quickly assemble the 8 bit shape commands
#define SHAPE_COMMAND(COMMAND, VALUE)		(((COMMAND) << 4) | (VALUE))
#define SHAPE_FORWARD(_STEPS)				SHAPE_COMMAND(S_FORWARD, _STEPS)
#define SHAPE_RIGHT(_STEPS_22_5)			SHAPE_COMMAND(S_RIGHT, _STEPS_22_5)
#define SHAPE_LEFT(_STEPS_22_5)				SHAPE_COMMAND(S_RIGHT, 16 - (_STEPS_22_5))
#define SHAPE_FLIP(_FLIPX, _FLIPY)			SHAPE_COMMAND(S_FLIP, (_FLIPX) | ((_FLIPY) << 1))
#define SHAPE_SCALE(_SCALE_1_8TH)			SHAPE_COMMAND(S_SCALE, _SCALE_1_8TH)
#define SHAPE_PENDOWN()						SHAPE_COMMAND(S_PEN, 1)
#define SHAPE_PENUP()						SHAPE_COMMAND(S_PEN, 0)
#define SHAPE_PUSH()						SHAPE_COMMAND(S_PUSH, 0)
#define SHAPE_POP()							SHAPE_COMMAND(S_POP, 0)
#define SHAPE_FLUSH()						SHAPE_COMMAND(S_FLUSH, 0)
#define SHAPE_ANIMROTATE(_RANGE, _SPEED)	SHAPE_COMMAND(S_ANIMROTATE, (_RANGE) | ((_SPEED) << 2))
#define SHAPE_ANIMSCALE(_RANGE, _SPEED)		SHAPE_COMMAND(S_ANIMSCALE, (_RANGE) | ((_SPEED) << 2))
#define SHAPE_END()							SHAPE_COMMAND(S_MAX, 0)

// some shape rendering data combined into a struct so they can be cleared with a single MemClear()
struct ShapeData
{
	Vector2			g_zeroVertex;	// a vertex with the coordinates 0/0 which is needed to do some transformations
	unsigned		g_vertices;		// the number of vertices queued in the vertex buffer
	unsigned		g_shapePenDown;	// if 1 the pen is down and all commands add vertices to the buffer
};

extern ShapeData	g_shapeData;
extern unsigned		g_shapeCommandValue;
extern LPD3DXLINE	g_pD3DXLine;
extern float		g_shapePhase;

extern void (*g_pShapeFunctions[S_MAX])();

void Shape_AddVertex();
void Shape_Reset();
void Shape_Forward();
void Shape_Right();
void Shape_Flip();
void Shape_Scale();
void Shape_Pen();
void Shape_Flush();
void Shape_Push();
void Shape_Pop();
void Shape_AnimRotate();
void Shape_AnimScale();

#endif // #ifndef shape_hpp
