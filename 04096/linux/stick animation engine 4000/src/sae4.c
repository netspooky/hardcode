/** \file
 * For details, please see README.
 */

//######################################
// Define ##############################
//######################################

/** Screen width. */
#define SCREEN_W 1280

/** Screen heigth. */
#define SCREEN_H 720

/** Required for perspective. This is the first time we're in widescreen! */
#define SCREEN_ASPECT ((double)SCREEN_W / (double)SCREEN_H)

/** Screen bytes per pixel. */
#define SCREEN_B 32

/** Fullscreen on or off. */
#define SCREEN_F 0//SDL_FULLSCREEN

/** Camera view area in X. */
#define CAMERA_VIEW 50.0

/** Delay between frames (milliseconds). */
#define FRAME_TICKS 16

// Only check for anim-frame-creator and shit if we're in GNU LD mode.
#if defined(SAE4_GNU_LD)
/** Use animation frame creator. */
//#define USE_ANIM_FRAME_CREATOR
/** Use Manual advance to test the intro better. */
//#define MANUAL_ADVANCE
#endif

//######################################
// Include #############################
//######################################

#define _USE_MATH_DEFINES
#include "math.h"

#include "limits.h"
#include "stdint.h" // MSVC2003, ohwell.
#include "sys/types.h"

// SDL brings all the enum stuff and everything we need for operation.
#if defined(__APPLE__)
#include <SDL/SDL.h>
#include <SDL/SDL_opengl.h>
#else
#include "SDL.h"
#include "SDL_opengl.h"
#endif

// glut definitions are not included in SDL definitions.
#if defined(WIN32) 
#include "glut.h"
#elif defined(__APPLE__)
#include "GLUT/glut.h"
#else
#include "GL/glut.h"
#endif

#ifdef USE_ANIM_FRAME_CREATOR
#include <fcntl.h>
#include <unistd.h>
#include <sys/socket.h>
#endif

//######################################
// Loader ##############################
//######################################

// Implement our own loader since we CAN!
#if !defined(SAE4_GNU_LD)

#include "dlfcn.h"

/** \brief Load a block of symbols.
 *
 * Open a library and dynamically load a set of symbols from it.
 *
 * @param lib Name of the library.
 * @param symset Symbol set.
 * @param nameset Name set.
 */
static void block_dnload(void **symset, const char *nameset)
{
	char *iter = (char*)nameset;
	void *handle = dlopen(iter, RTLD_LAZY);

#if defined(SAE4_DEBUG)
	printf("Opened %s for %p\n", iter, handle);
#endif

	for(;;)
	{
		while(*iter++);

		if(!(*iter))
		{
			break;
		}

		*symset = dlsym(handle, iter);

#if defined(SAE4_DEBUG)
		printf("  Loading symbol %s: %p\n", iter, *symset);
#endif

		++symset;
	}
}

/** Dnload of sinf might be more profitable than using inline. */
#if defined(DNLOAD_LIBM)

static void *msym[1];
#define dsinf ((float (*)(float))(msym[0]))

static const char msymname[] =
"libm.so\0"
"sinf\0";

#else

#define dsinf sinf

#endif

static void *glsym[11];
#define dlBlendFunc ((void (*)(GLenum, GLenum))(glsym[0]))
#define dlClear ((void (*)(GLbitfield))(glsym[1]))
#define dlColor4ubv ((void (*)(const GLubyte*))(glsym[2]))
#define dlEnable ((void (*)(GLenum))(glsym[3]))
#define dlLoadIdentity ((void (*)())(glsym[4]))
#define dlMatrixMode ((void (*)(GLenum))(glsym[5]))
#define dlPopMatrix ((void (*)())(glsym[6]))
#define dlPushMatrix ((void (*)())(glsym[7]))
#define dlRotatef ((void (*)(GLfloat, GLfloat, GLfloat, GLfloat))(glsym[8]))
#define dlScalef ((void (*)(GLfloat, GLfloat, GLfloat))(glsym[9]))
#define dlTranslatef ((void (*)(GLfloat, GLfloat, GLfloat))(glsym[10]))

static const char glsymname[] =
"libGL.so\0"
"glBlendFunc\0"
"glClear\0"
"glColor4ubv\0"
"glEnable\0"
"glLoadIdentity\0"
"glMatrixMode\0"
"glPopMatrix\0"
"glPushMatrix\0"
"glRotatef\0"
"glScalef\0"
"glTranslatef\0";

static void *glusym[2];
#define dluLookAt ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble))(glusym[0]))
#define dluPerspective ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble))(glusym[1]))

static const char glusymname[] =
"libGLU.so\0"
"gluLookAt\0"
"gluPerspective\0";

static void *glutsym[3];
#define dlutInit ((void (*)(int*, char **))(glutsym[0]))
#define dlutSolidCube ((void (*)(GLdouble))(glutsym[1]))
#define dlutWireCube ((void (*)(GLdouble))(glutsym[2]))

static const char glutsymname[] =
"libglut.so\0"
"glutInit\0"
"glutSolidCube\0"
"glutWireCube\0";

static void *sdlsym[10];
#define DDL_Delay ((void (*)(uint32_t))(sdlsym[0]))
#define DDL_GetTicks ((Uint32 (*)())(sdlsym[1]))
#define DDL_GL_SwapBuffers ((void (*)())(sdlsym[2]))
#define DDL_Init ((int (*)(Uint32))(sdlsym[3]))
#define DDL_OpenAudio ((int (*)(SDL_AudioSpec*, SDL_AudioSpec*))(sdlsym[4]))
#define DDL_PauseAudio ((void (*)(int))(sdlsym[5]))
#define DDL_PollEvent ((int (*)(SDL_Event*))(sdlsym[6]))
#define DDL_Quit ((void (*)())(sdlsym[7]))
#define DDL_SetVideoMode ((SDL_Surface* (*)(int, int, int, Uint32))(sdlsym[8]))
#define DDL_ShowCursor ((int (*)(int))(sdlsym[9]))

/** SDL symbol name table. */
static const char sdlsymname[] =
"libSDL.so\0"
"SDL_Delay\0"
"SDL_GetTicks\0"
"SDL_GL_SwapBuffers\0"
"SDL_Init\0"
"SDL_OpenAudio\0"
"SDL_PauseAudio\0"
"SDL_PollEvent\0"
"SDL_Quit\0"
"SDL_SetVideoMode\0"
"SDL_ShowCursor\0";

#else

#define dsinf sinf

#define dlBlendFunc glBlendFunc
#define dlClear glClear
#define dlColor4ubv glColor4ubv
#define dlEnable glEnable
#define dlLoadIdentity glLoadIdentity
#define dlMatrixMode glMatrixMode
#define dlPopMatrix glPopMatrix
#define dlPushMatrix glPushMatrix
#define dlRotatef glRotatef
#define dlScalef glScalef
#define dlTranslatef glTranslatef

#define dluLookAt gluLookAt
#define dluPerspective gluPerspective

#define dlutInit glutInit
#define dlutSolidCube glutSolidCube
#define dlutWireCube glutWireCube

#define DDL_Delay SDL_Delay
#define DDL_GetTicks SDL_GetTicks
#define DDL_GL_SwapBuffers SDL_GL_SwapBuffers
#define DDL_Init SDL_Init
#define DDL_OpenAudio SDL_OpenAudio
#define DDL_PauseAudio SDL_PauseAudio
#define DDL_PollEvent SDL_PollEvent
#define DDL_SetVideoMode SDL_SetVideoMode
#define DDL_ShowCursor SDL_ShowCursor
#define DDL_Quit SDL_Quit

#endif

//######################################
// Data tables #########################
//######################################

/** \brief Animation block size.
 *
 * This determines the basic form. Animation frames are distinct. Note, that
 * since there's (by default) no distinctive directions at all, nothing can
 * be drawn without animation frames.
 *
 * The animation frames are just simply rotation entries from -128 to 127,
 * which specify the rotation direction the entry is facing to. Note, that
 * this means the animation will always happen through the SHORTER route.
 *
 * The directions are flat-out converted to radians or degrees, meaning 0 is
 * to the right and 64 is up, then so on.
 *
 * The format of actual objects is:
 * Origination coordinates (3)
 * Dimensions (3)
 * Color (4)
 * Recursion index
 * Recuresion count.
 *
 * Place vector, is in regard to the center of object OR previous entry
 * endpoint.
 *
 * In dimensions, first is width, then depth is towards the 'end' of cube.
 *
 * Depth value determines on which "plane" the cube is in.
 *
 * The next objects are always examined unless recursion index is 0, object
 * cannot loop unto itself,
 */
#define ANIM_SIZE 12

/** Number of cubes in the human model. */
#define HUMAN_CUBE_COUNT 11

/** Size of a floor cube model. */
#define FLOOR_CUBE_SIZE 8

/** Number of light pillars. */
#define PILLAR_COUNT 20

/** Human animation object.
 */
static const int8_t obj_human[HUMAN_CUBE_COUNT * ANIM_SIZE] =
{
	// Base everything
	0, 0, 0,
	0, 0, 0,
	0, 0, 0, 0,
	1, 3,
	// Human body.
	0, -7, 0,
	11, 20, 6,
	0x54, 0x86, 0x6b, 0xff,
	3, 3,
	// Human left leg.
	-3, -7, 0,
	5, 10, 5,
	0x98, 0x81, 0x51, 0xff,
	5, 1,
	// Human right leg.
	3, -7, 0,
	5, 10, 5,
	0x98, 0x81, 0x51, 0xff,
	5, 1,
	// Human head.
	0, 0, 0,
	7, 7, 7,
	0xfc, 0xdb, 0xca, 0xff,
	0, 0,
	// Human left arm.
	-6, 0, 0,
	4, 12, 4,
	0x54, 0x86, 0x6b, 0xff,
	4, 1,
	// Human right arm.
	6, 0, 0,
	4, 12, 4,
	0x54, 0x86, 0x6b, 0xff,
	4, 1,
	// Human left foot.
	0, 0, 0,
	5, 10, 5,
	0x98, 0x81, 0x51, 0xff,
	0, 0,
	// Human right foot.
	0, 0, 0,
	5, 10, 5,
	0x98, 0x81, 0x51, 0xff,
	0, 0,
	// Human left hand.
	0, 0, 0,
	4, 12, 4,
	0xfc, 0xdb, 0xca, 0xff,
	0, 0,
	// Human right hand.
	0, 0, 0,
	4, 12, 4,
	0xfc, 0xdb, 0xca, 0xff,
	0, 0
};

static int8_t obj_floor[256 * 256 * ANIM_SIZE / FLOOR_CUBE_SIZE / FLOOR_CUBE_SIZE];
static int8_t anim_floor[256 * 256 / FLOOR_CUBE_SIZE / FLOOR_CUBE_SIZE];

#if defined(USE_ANIM_FRAME_CREATOR)
static int8_t anim_human_test[] =
{
  0, 0, 8, 8, 0, 73, -55, 0, 0, 15, 15
};
#endif

static const int8_t anim_human[] =
{
	// Stand. 
	//0, 0, 8, 8, 0, 73, -55, 0, 0, 15, 15,
	// Walk 1.
  //0, 0, 7, 10, 0, 57, -71, 15, 15, -33, 47,
	0, 0, 7, 10, 0, 57, 55, 15, 15, -33, 33,
	// Walk 2.
  //0, 0, 10, 7, 0, 89, -39, 15, 15, -33, 62,
	0, 0, 10, 7, 0, 89, 71, 15, 15, -33, 50,
	// Look left.
	//0, 16, 24, 8, 16, 89, -87, 0, 0, -33, 46,
	0, 16, 24, 8, 16, 89, 55, 0, 0, -33, 34,
	// Look right up.
	//0, -15, 8, -8, -15, 105, -87, 0, 0, -17, 77,
	0, -15, 8, -8, -15, 105, 55, 0, 0, -17, 66,
	// Clap back.
	//0, 0, 25, -7, 0, 26, -7, 15, 15, -68, 109,
	//0, 0, 25, -7, 0, 26, -23, 15, 15, -68, 109,
	0, 0, 25, -7, 0, 26, 87, 15, 15, -68, 68,
	// Clap front.
	//0, 0, 25, -7, 0, 10, -7, 15, 15, -67, 109,
	0, 0, 25, -7, 0, 10, 103, 15, 15, -67, 84,
	// Pose left.
	//0, 16, 41, -7, -15, 47, 22, 0, 15, -64, -83,
	//0, 16, 41, -7, -15, 47, -118, 0, 15, -64, -108,
	0, 16, 41, -7, -15, 63, 22, 0, 15, -64, 37,
	// Pose right.
	//0, -16, 26, -39, 16, 39, -34, 14, 0, 4, -128,
	//0, -16, 26, -39, 16, 7, -34, 14, 0, 123, -128,
	// Point front.
	//0, 15, 41, -23, 1, 13, 39, 15, 15, -64, -85,
	// Break backwards.
	19, 0, 43, -39, -1, 76, 67, 60, -19, -94, -49,
	// Break forwards.
	//-18, -1, 11, -67, 18, 28, 84, 15, 15, 66, -20,
	-18, -1, 11, -34, 18, 28, 84, 15, 15, 66, -20,
	// Handstand.
	7, 1, 25, -7, 1, 79, 65, 12, 14, -113, 15,
	// Landing.
	0, 15, 27, -4, 1, 75, 69, 10, 10, 81, 33,
	// Cartwheel start.
	16, 0, 42, 9, 0, 75, 65, 15, 47, 65, 65,
	// Cartwheel middle.
	-128, 0, 26, -23, 0, 95, 65, 27, 15, 17, 114,
	// Cartwheel end.
	-16, 16, 40, -38, -16, 58, 69, -17, 15, 82, 50,
	// Bow start.
	//0, 0, 8, 8, 1, 25, 70, 0, 0, 4, -128,
	0, 0, 8, 8, 0, 105, -37, 0, 0, -21, -128,
	// Bow end.
	//0, 13, 8, 8, 15, -7, 85, 0, 0, 51, 81,
	0, 13, 8, 8, 14, 26, -54, 0, 0, -37, 79,
	// Megaman kneel start.
	//0, 0, 44, -4, 1, 89, 38, 10, 10, 86, 54,
	0, 0, 28, -4, 2, 89, -103, 10, 10, -53, 26,
	// Megaman jump.
	//0, 0, 43, -7, 1, 48, 39, 11, 15, 64, 52,
	0, 0, 27, -7, 1, 64, -70, 10, 15, -112, 59,
	// Mosh up.
	//0, 0, 25, -7, 0, 105, 81, 15, 15, -20, 0,
	0, 0, 25, -23, -15, 105, 82, 15, 0, -20, 0,
	// Mosh down.
	0, 15, 25, -7, 14, 106, 80, 15, 15, -20, 0,
	// Retarded right.
	0, -16, 25, -7, 1, 106, 39, 0, 15, -20, 53,
	// Retarded left.
	0, 16, 25, -23, 15, 57, 23, 15, 0, -52, 52,
	// Back roll start.
	2, 0, 43, -5, 15, 122, 5, 15, 14, -20, 20,
	// Back roll middle.
	//8, 15, 29, -3, 13, 92, 52, 10, 10, -4, 19
	8, 15, 29, -3, 13, 92, 52, 10, 10, -1, 17,
	// Back roll end.
	15, 1, 27, -4, 1, 106, 38, 10, 11, -35, 52,
	// Bounce.
	5, 1, 26, -6, 15, 110, 34, 15, 15, -3, 19,
	// Pose front.
	0, -32, 41, -39, 32, 43, -7, 0, 0, -113, 1
};

/** \brief Location data block.
 *
 * This specifies the 'location', 'speed' and other things related to
 * animating the model.
 *
 * Format:
 * Speed until next block (3)
 * Animation index this block (1)
 * Animation speed (1)
 * Animation power (1)
 * Animation cycle count (1)
 *
 * Speed is actually divided to very small amounts.
 *
 * The animation speed is multiplied by 8 in actual animation terms.
 * Higher is slower, as it represents the divisor for tick. Negative value
 * means going 'backwards'.
 *
 * Animation power represents the power the sine is multiplied to before
 * applying. It should mostly be 1, but any number is valid in theory.
 *
 * The animation cycle count represents the number of cycles this animation
 * passes before we move onto the next block. This way, the animation frames
 * are cumulative and not tied to exact time steps but rather the number of
 * cycles in the distinct locators. Number of 1 means one pass from start to
 * finish, number 2 would be a pass back to the start again.
 */
#define LOCATION_SIZE 7

static const int8_t location_human[] =
{
	0, 0, -80, 0, 25, 1, 17, // Begin walk
	0, 0, 0, 1, 60, 1, 1,
	0, 0, 0, 2, 127, 1, 1,
	0, -5, 0, 3, 40, 1, 1,
	0, 0, 0, 4, 10, 1, 23, // Clapping
	0, 0, 0, 5, 60, 3, 1,
	0, 0, 0, 26, 40, 3, 1,
	0, 0, 0, 5, 20, 3, 1,
	0, 0, 0, 6, 40, 3, 1,
	0, 0, 0, 5, 20, 3, 1,
	0, 0, 0, 18, 20, 3, 19,
	0, 0, 0, 19, 40, 3, 1, // Retarded
	0, 0, 0, 20, 40, 3, 7,
	0, -44, 16, 21, 31, 0, 1, // Begin back roll
	0, 26, 18, 22, 20, 0, 1, 
	0, 12, 68, 23, 29, 0, 1, 
	0, -35, 30, 24, 22, 0, 1, 
	0, 16, 18, 22, 31, 0, 1, 
	0, 20, -15, 23, 27, 0, 1, 
	0, 7, -70, 25, 45, 0, 1, 
	0, 0, 0, 18, 26, 3, 13, // Mosh again
	0, 0, 0, 19, 20, 1, 1,
	0, 0, 0, 20, 26, 3, 13, // Retarded again
	0, -26, 0, 21, 45, 1, 1, // Begin drop
	0, 13, 33, 7, 30, 1, 1,
	0, 55, -48, 8, 30, 1, 1,
	0, -51, -33, 9, 35, 1, 1,
	0, 25, 0, 10, 30, 1, 1,
	-60, 32, 0, 11, 30, 1, 1,
	-60, -24, 0, 12, 30, 1, 1,
	0, 0, 0, 13, 40, 1, 1,
	0, 0, 0, 6, 20, 1, 1,
	60, 24, 0, 13, 30, 1, 1,
	60, -28, 0, 12, 30, 1, 1,
	0, 0, 0, 11, 40, 1, 1,
	0, 0, 0, 18, 60, 1, 1,
	0, 0, 0, 14, 90, 3, 1,
	0, -10, 0, 15, 80, 0, 1,
	0, 127, 0, 16, 20, 1, 1,
	0, 127, 0, 17, 127, 1, 1,
	0, 127, 0, 17, 127, 1, 1
};

/** \brief Size of the camera block.
 *
 * The format is simple. The first number tells how many tenths of seconds
 * to keep this camera position, the three following bytes tell the position
 * itself.
 */
#define CAMERA_SIZE 4

/** Camera positions. */
static const int8_t camera_position[] =
{
	94, -20, -12, 127, 
	127, 45, 20, -50, 
	41, -40, 30, -50, 
	96, 40, 30, -40, 
	40, 15, 30, -40, 
	40, -20, -28, -20, 
	122, 45, 20, -35, 
	115, -65, 20, -55, 
	30, -35, 25, -30, 
	127, 45, 20, -50,
	127, -10, -26, 5
};

#define INTROLEN 91

//######################################
// Random ##############################
//######################################

/** Random number multiplier value. */
#define RANDA 1257787

/** Random number addition value. */
#define RANDB 859433

/** \brief Return the next random number in sequence.
 *
 * @param seed Seed value to calculate from.
 */
static unsigned sae4_rand_next(unsigned seed)
{
  return seed * RANDA + RANDB; // modulo 2^32 automatic.
}

//######################################
// Drawing #############################
//######################################

/** Set to 1 to disable all color. */
static int sae4_shadow = 0;

/** Shadow color. */
static const uint8_t shadow_color[] = { 0x00, 0x00, 0x00, 0x88 };

/** \brief Color set wrapper.
 *
 * @param col Color to use.
 */
static void sae4_color(const uint8_t *col)
{
	dlColor4ubv(sae4_shadow ? shadow_color : col);
}

/** \brief Get inerpolation lol.
 *
 * @param frame_start Start frame.
 * @param frame_end End frame.
 * @param intermediate Interpolation variable.
 * @return Current value between start and end.
 */
static float interpolate_frame_angle(int8_t frame_start, int8_t frame_end,
		float intermediate)
{
	float rr0 = (float)(frame_start) * (360.0f / 16.0f),
				rr1 = (float)(frame_end) * (360.0f / 16.0f),
				drr = rr1 - rr0;
	if(drr > 180.0f)
	{
		drr -= 360.0f;
	}
	if(drr < -180.0f)
	{
		drr += 360.0f;
	}
	return drr * intermediate + rr0;
}

/** This makes everything drawn smaller or bigger. */
static float anim_scale_factor = 1.0f;

/** \brief Draw an array if data into the screen.
 *
 * The object size specifies the number of objects to draw from position
 * ZERO, recursion recurses forever if necessary.
 *
 * @param obj Object to draw.
 * @param osize Object size.
 * @param frame_start Starting frame.
 * @param frame_end Ending frame.
 * @param intermediate Intermediate point.
 * @param xtrans X translation.
 * @param ytrans Y translation.
 */
static void draw_cube_object(int8_t *obj, unsigned osize,
		int8_t *frame_start, int8_t *frame_end, float intermediate)
{
	do {
		float xx = (float)(obj[0]),
					yy = (float)(obj[1]),
					zz = (float)(obj[2]),
					ww = (float)(obj[3]),
					hh = (float)(obj[4]),
					dd = (float)(obj[5]);

		int8_t fs = *frame_start,
					 fe = *frame_end;

		float rx =
			interpolate_frame_angle(fs & 15, fe & 15, intermediate);
		float ry =
			interpolate_frame_angle((fs >> 4), (fe >> 4), intermediate);


		//printf("Rotation: %f, %f\n", rx, ry);

		dlPushMatrix();
		dlTranslatef(xx, yy, zz);

		// The base human rotates differently than the children.
		if(obj == obj_human)
		{
			dlRotatef(ry, 0.0f, 0.0f, 1.0f);
			//dlRotatef(ry, 0.0f, 1.0f, 0.0f);
		}
		else
		{
			dlRotatef(ry, 0.0f, 1.0f, 0.0f);
			//dlRotatef(ry, 0.0f, 0.0f, 1.0f);
		}

		dlRotatef(rx, 1.0f, 0.0f, 0.0f);
		dlTranslatef(0.0f, hh * 0.5f, 0.0f);

		// Scaling is for the cube only.
		dlPushMatrix();
		dlScalef(ww * anim_scale_factor,
				hh * anim_scale_factor,
				dd * anim_scale_factor);

		// Set color just before drawing.
		sae4_color(obj + 6);
		dlutSolidCube(1.0);
		sae4_color(shadow_color);
		dlutWireCube(1.0);

		dlPopMatrix();

		dlTranslatef(0.0f, hh * 0.5f, 0.0f);

		// Recurse on request.
		int idx = obj[10];

		if(idx)
		{
			draw_cube_object(obj + idx * ANIM_SIZE,
					obj[11],
					frame_start + idx,
					frame_end + idx,
					intermediate);
		}

		dlPopMatrix();

		// Advance.
		obj += ANIM_SIZE;
		++frame_start;
		++frame_end;
	} while(--osize);
}


/** \brief Draw the whole scene.
 *
 * Does not modify intro state, run when you want.
 *
 * @param prmtick Parameter tick, time in milliseconds at this intro state.
 */
static void draw(unsigned prmtick)
{
#if defined(USE_ANIM_FRAME_CREATOR)
	static const unsigned FREEZE_TIME = 10000;
#endif

	// Empty everything.
	//dlClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	dlClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);

	// Position the camera.
#if !defined(USE_ANIM_FRAME_CREATOR)
	{
		unsigned tick = prmtick / 100;
		int8_t *citer = (int8_t*)camera_position;

		while(tick > *citer)
		{
			tick -= *citer;
			citer += CAMERA_SIZE;
		}

		dlMatrixMode(GL_MODELVIEW);
		dlLoadIdentity();
		dluLookAt(citer[1], citer[2], citer[3],
				0.0, 0.0, 0.0,
				0.0, 1.0, 0.0);
	}
#endif

	// Draw the inehmo and its shadow.
#if defined(USE_ANIM_FRAME_CREATOR)
	dlPushMatrix();

	dlTranslatef(0.0f, 0.0f, 0.0f);
	draw_cube_object((int8_t*)obj_human,
			1,
			(int8_t*)anim_human_test,
			(int8_t*)anim_human_test,
			0.5);

	dlPopMatrix();
#else
	{
		unsigned tick = prmtick;
#if defined(USE_ANIM_FRAME_CREATOR)
		tick = FREEZE_TIME;
#endif
		float hpos[] = { 0, 0, 440.0f };
		int8_t *hiter = (int8_t*)location_human;
		for(;;)
		{
			float speed[3] =
			{
				((float)(hiter[0])) / 2048.0f,
				((float)(hiter[1])) / 2048.0f,
				((float)(hiter[2])) / 2048.0f
			},
				animspeed = 1.0f / (((float)(hiter[4])) * 8.0f),
				animtotal = M_PI / animspeed * hiter[6];

			//printf("animspeed = %f, animtotal = %f\n", animspeed, animtotal);

			float tcnt = (tick > animtotal) ? animtotal : tick;
			hpos[0] += speed[0] * tcnt;
			hpos[1] += speed[1] * tcnt;
			hpos[2] += speed[2] * tcnt;

			// Advance.
			if(tick > animtotal)
			{
				tick -= animtotal;
				hiter += LOCATION_SIZE;
				continue;
			}

			unsigned power = hiter[5];
			float animpos;

			if(power)
			{
				float animtmp = dsinf(-M_PI / 2.0f + animspeed * tick),
							animmul = 1.0f - fabsf(animtmp);
				unsigned ii = 0;
				animpos = 1.0f;
				while(ii < hiter[5])
				{
					animpos *= animmul;
					++ii;
				}
				animpos = 1.0f - animpos;
				animpos *= (animtmp >= 0.0f) ? 1.0f : -1.0f;
				animpos = animpos * 0.5f + 0.5f;
			}
			else
			{
				animpos = (float)tick / animtotal;
			}

			dlPushMatrix();
			dlTranslatef(hpos[0], -27.5f, hpos[2]);
			dlScalef(1.0f, 0.0f, 1.0f);
			anim_scale_factor = 1.2f;
			sae4_shadow = 1;
			draw_cube_object((int8_t*)obj_human,
					1,
					(int8_t*)anim_human + HUMAN_CUBE_COUNT * hiter[3],
					(int8_t*)anim_human + HUMAN_CUBE_COUNT * hiter[3 + LOCATION_SIZE],
					animpos);
			sae4_shadow = 0;
			anim_scale_factor = 1.0f;
			dlPopMatrix();

			dlPushMatrix();
			dlTranslatef(hpos[0], hpos[1], hpos[2]);
			draw_cube_object((int8_t*)obj_human,
					1,
					(int8_t*)anim_human + HUMAN_CUBE_COUNT * hiter[3],
					(int8_t*)anim_human + HUMAN_CUBE_COUNT * hiter[3 + LOCATION_SIZE],
					animpos);
			dlPopMatrix();
			break;
		}
	}
#endif
	{
		// The floor.
		int tick = prmtick / 1000,
				ii,
				jj;
		int8_t *objiter = obj_floor,
					 *animiter = anim_floor;
		for(ii = -128; (ii <= 127); ii += FLOOR_CUBE_SIZE)
		{
			tick *= RANDA;
			for(jj = -128; (jj <= 127); jj += FLOOR_CUBE_SIZE)
			{
				objiter[0] = ii;
				objiter[1] = -28 - FLOOR_CUBE_SIZE;
				objiter[2] = jj;
				objiter[3] = FLOOR_CUBE_SIZE;
				objiter[4] = FLOOR_CUBE_SIZE;
				objiter[5] = FLOOR_CUBE_SIZE;
				objiter[6] = 0x80;
				objiter[7] = 0x80;
				objiter[8] = 0x80;
#if !defined(USE_ANIM_FRAME_CREATOR)
				if(prmtick > 25000)
				{
					tick *= RANDA;
					objiter[6] += tick & 0x7F;
					tick *= RANDA;
					objiter[7] += tick & 0x7F;
					tick *= RANDA;
					objiter[8] += tick & 0x7F;
				}
#endif
				objiter[9] = 0xFF;
				objiter[10] = 0;
				objiter[11] = 0;
				*animiter = 0;

				objiter += ANIM_SIZE;
				++animiter;
			}
		}
		draw_cube_object(obj_floor,
				(256 / FLOOR_CUBE_SIZE) * (256 / FLOOR_CUBE_SIZE),
				anim_floor,
				anim_floor,
				0.0f);

		//printf("Drawn!\n");
	}
#if !defined(USE_ANIM_FRAME_CREATOR)
	if(prmtick > 32000)
	{
		// The lights.
		int tick = prmtick / 3000,
				ii;
		int8_t *objiter = obj_floor,
					 *animiter = anim_floor;
		for(ii = 0; ii < PILLAR_COUNT; ++ii)
		{
			tick = sae4_rand_next(tick);
			objiter[0] = tick & 0xFF;
			objiter[1] = 80;
			tick = sae4_rand_next(tick);
			objiter[2] = tick & 0xFF;
			objiter[3] = FLOOR_CUBE_SIZE * 3 / 2;
			objiter[4] = 127;
			objiter[5] = FLOOR_CUBE_SIZE * 3 / 2;
			int jj = sae4_rand_next(ii);
			objiter[6] = 0xC0 + (jj & 63);
			jj = sae4_rand_next(jj);
			objiter[7] = 0xC0 + (jj & 63);
			jj = sae4_rand_next(jj);
			objiter[8] = 0xC0 + (jj & 63);
			objiter[9] = 0x80;
			objiter[10] = 0;
			objiter[11] = 0;
			tick = sae4_rand_next(tick);
			*animiter = tick;
			tick = sae4_rand_next(tick);
			*(animiter + PILLAR_COUNT) = tick;

			objiter += ANIM_SIZE;
			++animiter;
		}

		draw_cube_object(obj_floor,
				PILLAR_COUNT,
				anim_floor,
				anim_floor + PILLAR_COUNT,
				dsinf(prmtick * 0.002f) * 0.5f + 0.5f);
	}
#endif
}

//######################################
// Audio ###############################
//######################################

// For easier modification.
#include "synth.c"

/** Audio buffer for audio output. */
int16_t audio_buffer[44100 * 2 * INTROLEN];

/** Update audio stream.
 *
 * @param userdata Not used.
 * @param stream Target stream.
 * @param len Number of bytes to write.
 */
static void audio_callback(void *userdata, uint8_t *stream, int len)
{
	static int16_t *audio_position = audio_buffer;

	do {
		int16_t aval = *audio_position;
#ifdef ORGANICA_BIG_ENDIAN
		*stream = *(audio_position + 1);
		*(stream + 1) = *audio_position;
#else
		*((int16_t*)stream) = aval;
#endif

		stream += 2;
		++audio_position;
	} while(len -= 2);
}

/** Audio specification. */
static SDL_AudioSpec audio_spec =
{
	44100,
  AUDIO_S16MSB,
	1,
	0,
	1024,
	0,
	0,
	audio_callback,
	NULL
};

//######################################
// Development thingies ################
//######################################

#if defined(SAE4_GNU_LD)
static void inc_lower(int8_t *op)
{
	int8_t ss = *op;

	*op = (ss & 240) | (((ss & 15) + 1) & 15);
}
static void dec_lower(int8_t *op)
{
	int8_t ss = *op;

	*op = (ss & 240) | (((ss & 15) - 1) & 15);
}
static void inc_upper(int8_t *op)
{
	int8_t ss = *op;

	*op = (((ss & 240) + 16) & 240) | (ss & 15);
}
static void dec_upper(int8_t *op)
{
	int8_t ss = *op;

	*op = (((ss & 240) - 16) & 240) | (ss & 15);
}
#endif

//######################################
// Main ################################
//######################################

#if defined(__APPLE__)
#define MAINPROG SDL_main
#else
#define MAINPROG main
#endif

#if defined(SAE4_GNU_LD)
/** \brief GNU main function.
 *
 * @param argc Not used.
 * @param argv Not used.
 */
int MAINPROG(int argc, char *argv[])
{
#else
void *environ, *__progname;
/** \brief ELF starting point.
*/
void _start()
{
#endif

#if !defined(SAE4_GNU_LD)
#if defined(DNLOAD_LIBM)
	block_dnload(msym, msymname);
#endif
	block_dnload(glsym, glsymname);
	block_dnload(glutsym, glutsymname);
	block_dnload(sdlsym, sdlsymname);
	block_dnload(glusym, glusymname);
#endif

#if defined(SAE4_FREEGLUT)
#if !defined(SAE4_GNU_LD)
	int argc = 0;
	char **argv = NULL;
#endif
	dlutInit(&argc, argv);
#endif
	DDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER);

	// Do not take the screen with you since it is not needed.
	DDL_SetVideoMode(SCREEN_W, SCREEN_H, SCREEN_B, SDL_OPENGL | SCREEN_F);
	DDL_ShowCursor(0);

	dlEnable(GL_DEPTH_TEST);
	//dlDisable(GL_CULL_FACE);
	//dlEnable(GL_CULL_FACE);
  dlEnable(GL_BLEND);
	//glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
	dlBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// Prepare audio.
	writeaudio(audio_buffer);

	DDL_OpenAudio(&audio_spec, NULL);
	DDL_PauseAudio(0);	

	//SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 0);
	
	// Camera will never move, it's perfectly safe to lock it into a certain
	// position.
	dlMatrixMode(GL_PROJECTION);
	dlLoadIdentity();
	dluPerspective(1.0 / SCREEN_ASPECT * 90.0, SCREEN_ASPECT, 1.0, 500.0);
	/*dluOrtho2D(-CAMERA_VIEW,
			CAMERA_VIEW,
			-CAMERA_VIEW * (double)(SCREEN_H) / (double)(SCREEN_W),
			CAMERA_VIEW * (double)(SCREEN_H) / (double)(SCREEN_W));*/
#if defined(USE_ANIM_FRAME_CREATOR)
		dlMatrixMode(GL_MODELVIEW);
		dlLoadIdentity();
		dluLookAt(45.0, 20.0, -50.0,
				0.0f, 0.0f, 0.0f,
				0.0f, 1.0f, 0.0f);
#endif
	
#if defined(SAE4_GNU_LD)
	unsigned cont = 1;
	while(cont)
#else
	for(;;)
#endif
	{
		// Perform drawing.
#if defined(MANUAL_ADVANCE)
		static uint32_t currtick = 0,
										currtickmul = 1;
		draw(currtick);
#else
		uint32_t currtick = DDL_GetTicks();
		if(currtick >= INTROLEN * 1000)
		{
			break;
		}
		draw(DDL_GetTicks());
#endif
		DDL_GL_SwapBuffers();

		// Small delay. Will probably sleep more in reality.
		DDL_Delay(FRAME_TICKS / 2);

		// Abort on any keypress.
		SDL_Event event;
		if(DDL_PollEvent(&event) && (event.type == SDL_KEYDOWN))
		{
#if defined(SAE4_GNU_LD)
			switch(event.key.keysym.sym)
			{
#if defined(USE_ANIM_FRAME_CREATOR)
				case SDLK_1:
					inc_lower(anim_human_test + 0);
					break;
				case SDLK_q:
					dec_lower(anim_human_test + 0);
					break;
				case SDLK_2:
					inc_upper(anim_human_test + 0);
					break;
				case SDLK_w:
					dec_upper(anim_human_test + 0);
					break;
				case SDLK_3:
					inc_lower(anim_human_test + 1);
					break;
				case SDLK_e:
					dec_lower(anim_human_test + 1);
					break;
				case SDLK_4:
					inc_upper(anim_human_test + 1);
					break;
				case SDLK_r:
					dec_upper(anim_human_test + 1);
					break;
				case SDLK_5:
					inc_lower(anim_human_test + 2);
					break;
				case SDLK_t:
					dec_lower(anim_human_test + 2);
					break;
				case SDLK_6:
					inc_upper(anim_human_test + 2);
					break;
				case SDLK_y:
					dec_upper(anim_human_test + 2);
					break;
				case SDLK_7:
					inc_lower(anim_human_test + 3);
					break;
				case SDLK_u:
					dec_lower(anim_human_test + 3);
					break;
				case SDLK_8:
					inc_upper(anim_human_test + 3);
					break;
				case SDLK_i:
					dec_upper(anim_human_test + 3);
					break;
				case SDLK_9:
					inc_lower(anim_human_test + 4);
					break;
				case SDLK_o:
					dec_lower(anim_human_test + 4);
					break;
				case SDLK_0:
					inc_upper(anim_human_test + 4);
					break;
				case SDLK_p:
					dec_upper(anim_human_test + 4);
					break;
				case SDLK_a:
					inc_lower(anim_human_test + 5);
					break;
				case SDLK_z:
					dec_lower(anim_human_test + 5);
					break;
				case SDLK_s:
					inc_upper(anim_human_test + 5);
					break;
				case SDLK_x:
					dec_upper(anim_human_test + 5);
					break;
				case SDLK_d:
					inc_lower(anim_human_test + 6);
					break;
				case SDLK_c:
					dec_lower(anim_human_test + 6);
					break;
				case SDLK_f:
					inc_upper(anim_human_test + 6);
					break;
				case SDLK_v:
					dec_upper(anim_human_test + 6);
					break;
				case SDLK_g:
					inc_lower(anim_human_test + 7);
					break;
				case SDLK_b:
					dec_lower(anim_human_test + 7);
					break;
				case SDLK_h:
					inc_upper(anim_human_test + 7);
					break;
				case SDLK_n:
					dec_upper(anim_human_test + 7);
					break;
				case SDLK_INSERT:
					inc_lower(anim_human_test + 8);
					break;
				case SDLK_DELETE:
					dec_lower(anim_human_test + 8);
					break;
				case SDLK_PAGEUP:
					inc_upper(anim_human_test + 8);
					break;
				case SDLK_PAGEDOWN:
					dec_upper(anim_human_test + 8);
					break;
				case SDLK_LEFT:
					inc_lower(anim_human_test + 9);
					break;
				case SDLK_RIGHT:
					dec_lower(anim_human_test + 9);
					break;
				case SDLK_UP:
					inc_upper(anim_human_test + 9);
					break;
				case SDLK_DOWN:
					dec_upper(anim_human_test + 9);
					break;
				case SDLK_KP7:
					inc_lower(anim_human_test + 10);
					break;
				case SDLK_KP4:
					dec_lower(anim_human_test + 10);
					break;
				case SDLK_KP8:
					inc_upper(anim_human_test + 10);
					break;
				case SDLK_KP5:
					dec_upper(anim_human_test + 10);
					break;
				case SDLK_KP1:
					glLoadIdentity();
					dluLookAt(45.0f, 20.0f, -50.0, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
					break;
				case SDLK_KP3:
					glLoadIdentity();
					dluLookAt(-45.0f, 20.0f, -50.0, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
					break;
				case SDLK_SPACE:
					printf("{ %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i }\n",
							anim_human_test[0],
							anim_human_test[1],
							anim_human_test[2],
							anim_human_test[3],
							anim_human_test[4],
							anim_human_test[5],
							anim_human_test[6],
							anim_human_test[7],
							anim_human_test[8],
							anim_human_test[9],
							anim_human_test[10]);
					break;
#endif
#if defined(MANUAL_ADVANCE)
				case SDLK_RSHIFT:
					currtickmul = 100;
					break;
				case SDLK_LSHIFT:
					currtickmul = 1;
					break;
				case SDLK_PERIOD:
					currtick += 20 * currtickmul;
					break;
				case SDLK_COMMA:
					currtick -= 20 * currtickmul;
					break;
#endif
				case SDLK_ESCAPE:
					cont = 0;
					break;
				default:
					break;
			}
#else
			break;
#endif
		}
#if defined(USE_ANIM_FRAME_CREATOR)
		{
			static char inputstr[8192];
			static unsigned inputlen = 0;
			static const char *delims = " \t\n,";

			int stdinfs = fileno(stdin);
			fd_set rdfs;
			FD_ZERO(&rdfs);
			FD_SET(stdinfs, &rdfs);

			struct timeval tv = { 0, 0 };
			if(select(stdinfs + 1, &rdfs, NULL, NULL, &tv) == 1)
			{
				read(stdinfs, inputstr + inputlen, sizeof(char));
				if(inputstr[inputlen] == '\n')
				{
					int8_t anim_temp[10];
					inputstr[inputlen] = 0;
					char *tok = strtok(inputstr, delims);
					unsigned assign = 0;

					while((assign < HUMAN_CUBE_COUNT) && tok)
					{
						anim_temp[assign] = atoi(tok);
						tok = strtok(NULL, delims);
						++assign;
					}

					unsigned ii;
					for(ii = 0; (ii < HUMAN_CUBE_COUNT); ++ii)
					{
						anim_human_test[ii] = anim_temp[ii];
						printf("%s%i", ((ii == 0) ? "" : ", "), anim_human_test[ii]);
					}
					puts("");
					inputlen = 0;
				}
				else
				{
					++inputlen;
				}
			}
		}
#endif

	}

	DDL_Quit();
#if !defined(SAE4_GNU_LD)
	asm("movl $1,%eax\nxor %ebx,%ebx\nint $128\n");
#else
	return 0;
#endif
}

//######################################
// End #################################
//######################################

