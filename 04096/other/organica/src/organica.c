/** \file
 * For details, please see README.
 */

//############################################################################
// Portability stuff not of interest in compoversion #########################
//############################################################################

#ifndef DISCARD_LIBC

// Endianness.
#if defined(HAVE_ENDIAN_H)
# include <endian.h>
#elif defined(HAVE_MACHINE_ENDIAN_H)
# include <machine/endian.h>
#elif defined(HAVE_SYS_ENDIAN_H)
# include <sys/endian.h>
#endif

// Make endianness definition.
#if defined(_BYTE_ORDER)
# if(_BYTE_ORDER == _LITTLE_ENDIAN)
#  define ORGANICA_LITTLE_ENDIAN
# elif(_BYTE_ORDER == _BIG_ENDIAN)
#  define ORGANICA_BIG_ENDIAN
# else
#  error "_BYTE_ORDER defined but is not _LITTLE_ENDIAN or _BIG_ENDIAN."
# endif
#elif defined(__BYTE_ORDER)
# if (__BYTE_ORDER == __LITTLE_ENDIAN)
#  define ORGANICA_LITTLE_ENDIAN
# elif (__BYTE_ORDER == __BIG_ENDIAN)
#  define ORGANICA_BIG_ENDIAN
# else
#  error "__BYTE_ORDER defined but is not __LITTLE_ENDIAN or __BIG_ENDIAN."
# endif
#elif defined(__LITTLE_ENDIAN__) && !defined(__BIG_ENDIAN__)
# define ORGANICA_LITTLE_ENDIAN
#elif defined(__BIG_ENDIAN__) && !defined(__LITTLE_ENDIAN__)
# define ORGANICA_BIG_ENDIAN
#else
# error "Cannot determine endianness."
#endif

// Visual Studio doesn't use the M_PI definition by default
#ifdef WIN32
#define _USE_MATH_DEFINES
#endif

#endif

//############################################################################
// Include ###################################################################
//############################################################################

#include "math.h"

#include "limits.h"
#include "stdint.h" // MSVC2003, ohwell.

// SDL brings all the enum stuff and everything we need for operation.
#ifdef HAVE_SDL_SDL_H
#include "SDL/SDL.h"
#include "SDL/SDL_opengl.h"
#else
#include "SDL.h"
#include "SDL_opengl.h"
#endif

// glut definitions are not included in SDL definitions.
#if defined(WIN32) 
#include "glut.h"
#elif defined(__APPLE__)
#include "glut.h"
#else
#include "GL/glut.h"
#endif

//############################################################################
// Define ####################################################################
//############################################################################

#define SCREEN_W 800
#define SCREEN_H 600
#define SCREEN_B 32
#define SCREEN_F SDL_FULLSCREEN
#define SCREEN_ASPECT 1.33f

static const float M_2PI = 6.283185f;

/** Allow Text. Sadly, no room. */
//#define ALLOW_TEXT

//############################################################################
// Loader ####################################################################
//############################################################################

// Implement our own loader since we CAN!
#ifdef HAVE_DLFCN_H

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

#ifndef DISCARD_LIBC
	printf("Opened %s for %p\n", iter, handle);
#endif


	for(;;)
	{
		while(*iter++);

		if(!(*iter))
		{
			break;
		}

#ifndef DISCARD_LIBC
		printf("Loading symbol %s: ", iter);
#endif

		*symset = dlsym(handle, iter);

#ifndef DISCARD_LIBC
		printf("%p\n", *symset);
#endif

		++symset;
	}
}

#endif

#ifdef DNLOAD_LIBM

/** m symbol table. */
static void *msym[3];
#define dcosf ((float (*)(float))(msym[0]))
#define dsinf ((float (*)(float))(msym[1]))
#define dsqrtf ((float (*)(float))(msym[2]))

/** m symbol name table. */
static const char msymname[] =
"libm.so\0"
"cosf\0"
"sinf\0"
"sqrtf\0"
"\0";

#else

#define dcosf cosf
#define dsinf sinf
#define dsqrtf sqrtf

#endif

#ifdef DNLOAD_LIBGL

/** GL symbol table. */
static void *glsym[15];
#define dlBlendFunc ((void (*)(GLenum, GLenum))(glsym[0]))
#define dlClear ((void (*)(GLbitfield))(glsym[1]))
#define dlColor4ubv ((void (*)(const GLubyte*))(glsym[2]))
#define dlDisable ((void (*)(GLenum))(glsym[3]))
#define dlDrawArrays ((void (*)(GLenum, GLint, GLsizei))(glsym[4]))
#define dlEnable ((void (*)(GLenum))(glsym[5]))
#define dlInterleavedArrays ((void (*)(GLenum, GLsizei, const GLvoid *))(glsym[6]))
#define dlLightfv ((void (*)(GLenum, GLenum, const GLfloat*))(glsym[7]))
#define dlLightModelfv ((void (*)(GLenum, const GLfloat*))(glsym[8]))
#define dlLoadIdentity ((void (*)())(glsym[9]))
#define dlMatrixMode ((void (*)(GLenum))(glsym[10]))
#define dlPopMatrix ((void (*)())(glsym[11]))
#define dlPushMatrix ((void (*)())(glsym[12]))
#define dlRotatef ((void (*)(GLfloat, GLfloat, GLfloat, GLfloat))(glsym[13]))
#define dlTranslatef ((void (*)(GLfloat, GLfloat, GLfloat))(glsym[14]))

/** GL symbol name table. */
static const char glsymname[] =
"libGL.so\0"
"glBlendFunc\0"
"glClear\0"
"glColor4ubv\0"
"glDisable\0"
"glDrawArrays\0"
"glEnable\0"
"glInterleavedArrays\0"
"glLightfv\0"
"glLightModelfv\0"
"glLoadIdentity\0"
"glMatrixMode\0"
"glPopMatrix\0"
"glPushMatrix\0"
"glRotatef\0"
"glTranslatef\0"
"\0";

#else

#define dlBlendFunc glBlendFunc
#define dlClear glClear
#define dlColor4ubv glColor4ubv
#define dlDisable glDisable
#define dlDrawArrays glDrawArrays
#define dlEnable glEnable
#define dlInterleavedArrays glInterleavedArrays
#define dlLightfv glLightfv
#define dlLightModelfv glLightModelfv
#define dlLoadIdentity glLoadIdentity
#define dlMatrixMode glMatrixMode
#define dlPopMatrix glPopMatrix
#define dlPushMatrix glPushMatrix
#define dlRotatef glRotatef
#define dlTranslatef glTranslatef

#endif

#ifdef DNLOAD_LIBGLU

/** GLU symbol table. */
static void *glusym[2];
#define dluLookAt ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble))(glusym[0]))
#define dluPerspective ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble))(glusym[1]))

/** GLU symbol name table. */
static const char glusymname[] =
"libGLU.so\0"
"gluLookAt\0"
"gluPerspective\0"
"\0";

#else

#define dluLookAt gluLookAt
#define dluPerspective gluPerspective

#endif

#ifdef DNLOAD_LIBGLUT

/** glut symbol table. */
#ifdef USE_FREEGLUT
static void *glutsym[3];
#define dlutInit ((void (*)(int*, char**))(glutsym[2]))
#else
static void *glutsym[2];
#endif
#define dlutSolidCone ((void (*)(GLdouble, GLdouble, GLint, GLint))(glutsym[0]))
#define dlutSolidSphere ((void (*)(GLdouble, GLint, GLint))(glutsym[1]))

/** glut symbol name table. */
static const char glutsymname[] =
"libglut.so\0"
"glutSolidCone\0"
"glutSolidSphere\0"
#ifdef USE_FREEGLUT
"glutInit\0"
#endif
"\0";

#else

#define dlutInit glutInit
#define dlutSolidCone glutSolidCone
#define dlutSolidSphere glutSolidSphere

#endif

#ifdef DNLOAD_LIBSDL

/** SDL symbol table. */
static void *sdlsym[9];
#define DDL_GetTicks ((Uint32 (*)())(sdlsym[0]))
#define DDL_GL_SwapBuffers ((void (*)())(sdlsym[1]))
#define DDL_Init ((int (*)(Uint32))(sdlsym[2]))
#define DDL_OpenAudio ((int (*)(SDL_AudioSpec*, SDL_AudioSpec*))(sdlsym[3]))
#define DDL_PauseAudio ((void (*)(int))(sdlsym[4]))
#define DDL_PollEvent ((int (*)(SDL_Event*))(sdlsym[5]))
#define DDL_Quit ((void (*)())(sdlsym[6]))
#define DDL_SetVideoMode ((SDL_Surface* (*)(int, int, int, Uint32))(sdlsym[7]))
#define DDL_ShowCursor ((int (*)(int))(sdlsym[8]))

/** SDL symbol name table. */
static const char sdlsymname[] =
"libSDL.so\0"
"SDL_GetTicks\0"
"SDL_GL_SwapBuffers\0"
"SDL_Init\0"
"SDL_OpenAudio\0"
"SDL_PauseAudio\0"
"SDL_PollEvent\0"
"SDL_Quit\0"
"SDL_SetVideoMode\0"
"SDL_ShowCursor\0"
"\0";

#else

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

//############################################################################
// Screen clearing ###########################################################
//############################################################################

/** One drawable element to be fed to drawarrays as tables.
*/
typedef struct
{
	/** This union doubles as radius of spheres and color data. */
	union
	{
		/** Color data array. */
		uint8_t color_array[4];

		/** Color instance. */
		uint32_t color;
	};

	/** Location data. */
	float vertex[3];
} interleaved_array_t;

/** Clear table. */
static interleaved_array_t clear_array[4] =
{
	{
		{
			{
				0, 0, 0, 0
			}
		},
		{
			-2.0f, -1.0f, -1.0f
		}
	},
	{
		{
			{
				0, 0, 0, 0
			}
		},
		{
			2.0f, -1.0f, -1.0f
		}
	},
	{
		{
			{
				0, 0, 0, 0
			}
		},
		{
			2.0f, 1.0f, -1.0f
		}
	},
	{
		{
			{
				0, 0, 0, 0
			}
		},
		{
			-2.0f, 1.0f, -1.0f
		}
	}
};

/** \brief Set the clear color for successive screen wipes.
 *
 * @param col Wipe color.
 */
static void set_clear_color(uint32_t col)
{
	clear_array[0].color = col;
	clear_array[1].color = col;
	clear_array[2].color = col;
	clear_array[3].color = col;
}

//############################################################################
// Forward declarations (only when needed) ###################################
//############################################################################

/** Between 0.0 and 1.0, interpolation value. */
static float timeshare_pos;

/** Variable to pass to the func (time spent here). */
static uint32_t timeshare_ticks;

/** Used for the darkness value calculation. */
float darkness_float;

//############################################################################
// Floating point ############################################################
//############################################################################

/** \brief Get the sign of a floating point number.
 *
 * @param op Operand.
 * @return 1 if non-negative, -1 otherwise.
 */
static float fsignf(float op)
{
	return (op < 0.0f) ? -1.0f : 1.0f;
}

//############################################################################
// Random ####################################################################
//############################################################################

/** Random number multiplier value. */
#define RA 1257787

/** Random number addition value. */
#define RB 859433

/** The random number seed value. Only thing that needs to be set in order to
 * reinitialize the RNG. */
static uint32_t rnumber;

/** \brief Reinitialize RNG.
 *
 * @param op New integer.
 */
static inline void rseed(uint32_t op)
{
	rnumber = op;
}

/** \brief Get a new random number.
 *
 * @return New random unsigned integer.
 */
static uint32_t rinteger()
{
  return rnumber = rnumber * RA + RB; // modulo 2^32 automatic.
}

/** \brief Return a new floating point number between 0 and target.
 *
 * @param op Maximum value for float.
 */
static float rfloat_unsigned(float op)
{
	int rnint = (int32_t)(rinteger() & 0xFFFF);
	return ((float)rnint) / 65535.0f * op;
}

/** \brief Return a new floating point number between -target and target.
 *
 * @param op Maximum absolute value for float.
 */
static float rfloat_signed(float op)
{
	return rfloat_unsigned(op + op) - op;
}

/** \brief Symbolizes probability.
 *
 * @param op Probability fraction.
 * @return op / 65536 parts of the whole.
 */
#define RPROB(op) (UINT_MAX / 0xFFFF * (op))

//############################################################################
// GL helpers ################################################################
//############################################################################

/** Light construct
 */
typedef struct
{
	float color[4];
	float pos[4];
} light_t;

/** \brief Shorthand for OpenGL translation.
 *
 * @param src Source translation array.
 */
static void glTranslate3fv(const float *src)
{
	dlTranslatef(src[0], src[1], src[2]);
}

/** \brief Generate a sphere coordinate to target float array.
 *
 * @param dst Target float array.
 * @param dr Radians (circular).
 * @param dh Radians (latitude).
 * @param r Radius.
 */
static void generate_sphere_coordinates(float *dst, float dr, float dh,
		float r)
{
	float cr = dcosf(dr),
				sr = dsinf(dr),
				ch = dcosf(dh),
				sh = dsinf(dh);

	dst[0] = cr * ch * r;
	dst[1] = sh * r;
	dst[2] = sr * ch * r;
}

/** \brief Draw an array if data into the origo.
 *
 * @param tgt Target array.
 * @param type What to draw.
 * @param count Number of elements to process.
 */
static void gl_draw_array(interleaved_array_t *tgt, GLenum type, int count)
{
	dlInterleavedArrays(GL_C4UB_V3F, 0, tgt);
	dlDrawArrays(type, 0, count);
}

/** \brief Draw a sphere at given coordinates with given color and radius.
 *
 * @param pos Position.
 * @param col Color.
 * @param radius Radius.
 */
static void gl_sphere(const float *pos, const uint8_t *col, float radius)
{
	dlPushMatrix();

	glTranslate3fv(pos);
	dlColor4ubv(col);
	dlutSolidSphere(radius, 18, 12);

	dlPopMatrix();
}

/** \brief Set a light.
 *
 * @param idx Light index.
 * @param data Light data.
 */
static void gl_light(unsigned idx, const light_t *lit)
{
	static const float ambient[4] = { 0.09, 0.09f, 0.09f, 1.0f };
	
	dlEnable(GL_LIGHTING);
	dlLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient);

	idx += GL_LIGHT0;
	dlEnable(idx);

	dlLightfv(idx, GL_DIFFUSE, lit->color);
	dlLightfv(idx, GL_POSITION, lit->pos);
}

//############################################################################
// Molecule ##################################################################
//############################################################################

/** Shift time by this much before adding another segment. */
#define MOLECULE_ADD_SKIP 6

/** Base size of surrounding ball. */
#define MOLECULE_BALL_SIZE 20

/** Molecule strand count. */
#define MOLECULE_STRAND_COUNT 20

/** Base length of one strand segment. */
#define MOLECULE_STRAND_SIZE 0.8f

/** Speed the strands move per addition. */
#define MOLECULE_SPEED 0.7f

/** Turning rate per segment. */
static const float MOLECULE_TURN = M_PI * 2 / 900.0f;

/** Molecule duration (how long to precalc). */
#define MOLECULE_DURATION 80000

/** Molecule chunks (how many segment additions). */
#define MOLECULE_CHUNKS (MOLECULE_DURATION >> MOLECULE_ADD_SKIP)

/** Color of the surroundings. */
static const uint8_t molecule_color[4] = { 0xFF, 0x80, 0x40, 0x90 };

/** Color of the spikes. */
static const uint8_t spike_color[4] = { 0xFF, 0x20, 0x40, 0x30 };

/** Light data.
 * First element of position doubles as mush position.
 * First element of color doubles as molecule strand size.
 */
static const light_t molecule_light =
{
	{
		0.8f, 1.0f, 0.2f, 1.0f
	},
	{
		26.0f, 5.0f, -80.0f, 1.0f
	}
};

//############################################################################
// Orbit #####################################################################
//############################################################################

/** Maximum number of orbit points. */
#define ORBIT_COUNT 8192

/** Number of mush points. */
#define MUSH_COUNT 512

/** Minimum mush size. */
#define MUSH_BALL_SIZE 0.3f

/** The scale of pulsating in the mush. */
#define MUSH_BALL_RETRACT 0.04f

/** Mush color. */
#ifdef ORGANICA_BIG_ENDIAN
static const uint32_t mush_color = 0xE0FFE030;
#else
static const uint32_t mush_color = 0x30E0FFE0;
#endif

/** Mush light data 0. */
static const light_t mush_light0 =
{
	{
		0.2f, 0.4f, 0.2f, 1.0f
	},
	{
		-40.0f, -5.0f, -10.0f, 1.0f
	}
};

/** Mush light data 1.
 * First element of position doubles as mush scale.
 */
static const light_t mush_light1 =
{
	{
		0.4f, 0.3f, 0.2f, 1.0f
	},
	{
		-50.0f, 35.0f, -15.0f, 1.0f
	}
};

/** Table of the orbit cells themselves. */
static interleaved_array_t orbit_table[2][ORBIT_COUNT];

/** Table for orbit cells this round. */
static interleaved_array_t orbit_current[ORBIT_COUNT];

/** \brief Gingerbreadman.
 *
 * @param target Target table.
 * @param cnt Unit count.
 */
static void orbit_gingerbread(interleaved_array_t *target, unsigned cnt)
{
	float iterx = -0.1f,
				iterz = 0.0f;

	do {
		float nx = 1.0f - iterz + fabsf(iterx),
					nz = iterx;

		target->vertex[0] =	nx;
		target->vertex[1] =	0.0f;
		target->vertex[2] =	nz;

		iterx = nx;
		iterz = nz;

		++target;
	} while(--cnt);
}

/** \brief Hopalong.
 *
 * @param target Target table.
 * @param cnt Unit count.
 */
static void orbit_hopalong(interleaved_array_t *target, unsigned cnt)
{
	static const float
		a = -8.0f,
		b = 1.5f,
		c = -14.4f;
	float iterx = 0.0f,
				iterz = 0.0f;

	do {
		float nx = (iterz + fsignf(iterx) * dsqrtf(fabsf(b * iterx - c))),
					nz = a - iterx;

		target->vertex[0] =	nx;
		target->vertex[1] =	0.0f;
		target->vertex[2] =	nz;

		iterx = nx;
		iterz = nz;

		++target;
	} while(--cnt);
}

/** \brief Threeply.
 *
 * @param target Target table.
 * @param cnt Unit count.
 */
static void orbit_threeply(interleaved_array_t *target, unsigned cnt)
{
	static const float
		a = -35.0f,
		b = -1.0f,
		cb = 0.5403023f;
	float iterx = -0.1f,
			  iterz = 0.0f,
				c = -16.0f + (float)timeshare_ticks * 0.0005f,
				sabc = dsinf(a * b * c);

	do {
		float
			nx = iterz - fsignf(iterx) * fabsf(dsinf(iterx) * cb + c - iterx * sabc),
			nz = a - iterx;

		target->vertex[0] =	nx * 0.04f;
		target->vertex[1] = 0.0f;
		target->vertex[2] =	nz * 0.04f;

		iterx = nx;
		iterz = nz;

		++target;
	} while(--cnt);
}

/** \brief Martin.
 *
 * @param target Target table.
 * @param cnt Unit count.
 */
static void orbit_martin(interleaved_array_t *target, unsigned cnt)
{
	float iterx = 0.0f,
				iterz = 0.0f,
				a = M_PI - 0.000012f * (float)(timeshare_ticks / 58);

	do {
		float
			nx = iterz - dsinf(iterx),
			nz = a - iterx;

		target->vertex[0] =	nx;
		target->vertex[1] = 0.0f;
		target->vertex[2] =	nz;

		iterx = nx;
		iterz = nz;

		++target;
	} while(--cnt);
}

/** \brief Interleave between two arrays.
 *
 * Calculate the average of two interleaved array thingies, store in target.
 *
 * @param dst Target array.
 * @param src1 First source.
 * @param src2 Second source.
 * @param cnt interpolation count.
 * @param pos Position of interpolation.
 */
static void orbit_interpolate(interleaved_array_t *dst,
		interleaved_array_t *src1, interleaved_array_t *src2, unsigned cnt)
{
	float pos = timeshare_pos,
				invpos = 1.0f - pos;
	do {
		dst->color = 0xFFFFFFFF;

		dst->vertex[0] = invpos * src1->vertex[0] +	pos * src2->vertex[0];
		dst->vertex[1] = invpos * src1->vertex[1] +	pos * src2->vertex[1];
		dst->vertex[2] = invpos * src1->vertex[2] +	pos * src2->vertex[2];

		++dst;
		++src1;
		++src2;
	} while(--cnt);
}

//############################################################################
// Interference ##############################################################
//############################################################################

/** Number of interference lines. */
#define INTERFERENCE_COUNT 300

/** Interference weak color. */
#define INTERFERENCE_WEAK_COLOR 0x00000000

/** Audio value divisor. */
#define INTERFERENCE_DIVISOR 30

/** The clear table doubles as the interference table. */
static interleaved_array_t interference_array[INTERFERENCE_COUNT * 2 * 4];

//############################################################################
// Time sharing ##############################################################
//############################################################################

#define LEN_O1 46
#define LEN_M1 18
#define LEN_O2 46
#define LEN_O3 12
#define LEN_M2 13
#define LEN_O4 39
#define LEN_M3 46
#define LEN_O5 39
#define LEN_M4 60
#define LEN_M5 22
#define LEN_O6 39
#define LEN_O7 12

#define LEN_O12 (LEN_O1 + LEN_O2)
#define LEN_O123 (LEN_O12 + LEN_O3)
#define LEN_O1234 (LEN_O123 + LEN_O4)
#define LEN_O12345 (LEN_O1234 + LEN_O5)
#define LEN_O123456 (LEN_O12345 + LEN_O6)
#define LEN_M12 (LEN_M1 + LEN_M2)
#define LEN_M123 (LEN_M12 + LEN_M3)
#define LEN_M1234 (LEN_M123 + LEN_M4 + 20)

/** Time sequence block construct.
 */
typedef struct
{
	uint8_t duration;
	uint8_t cumulative;
	uint8_t camera_block;
} timeshare_block_t;

/** Function to execute. */
static void (*timeshare_func)(uint32_t);

/** Timeshare  data. */
static const timeshare_block_t timeshare_data[] =
{
	{
		LEN_O1,
		0,
		12
	},
	{
		LEN_M1,
		0,
		60
	},
	{
		LEN_O2,
		LEN_O1,
		18
	},
	{
		LEN_O3,
		LEN_O12,
		24
	},
	{
		LEN_M2,
		LEN_M1,
		66
	},
	{
		LEN_O4,
		LEN_O123,
		30
	},
	{
		LEN_M3,
		LEN_M12,
		72
	},
	{
		LEN_O5,
		LEN_O1234,
		36
	},
	{
		LEN_M4,
		LEN_M123,
		72
	},
	{
		LEN_O6,
		LEN_O12345,
		42
	},
	{
		LEN_O7,
		LEN_O123456,
		48
	},
	{
		LEN_M5,
		LEN_M1234,
		84
	},
	{
		0xFF,
		0,
		0
	}
};

/** Static data table of all effects in this intro and their camera paths.
*/
static const int8_t camera_data[] =
{
	// clear 0
	0, 0, 0,
	0, 0, -1,
	// 1
	0, 0, 0,
	0, 0, -1,
	// orbit 2
	0, 0, -16,
	0, 0, -17,
	// 3
	0, 0, -16,
	0, 0, -17,
	// 4
	4, 8, 0,
	2, 0, 0,
	// 5
	15, 60, 0,
	0, 0, 0,
	// 6
	-10, 35, 15,
	0, 0, 5,
	// 7
	-8, 25, 5,
	0, 0, 5,
	// 8
	4, 8, 5,
	2, 0, 0,
	// 9
	4, 8, 0,
	1, -4, 4,
	// molecule 10
	MOLECULE_BALL_SIZE * 3, MOLECULE_BALL_SIZE, MOLECULE_BALL_SIZE,
	0, 0, 0,
	// 11
	MOLECULE_BALL_SIZE, 0, -MOLECULE_BALL_SIZE * 2,
	0, 0, 0,
	// 12
	0, -MOLECULE_BALL_SIZE / 7, -MOLECULE_BALL_SIZE * 5 / 9,
	0, 0, 0,
	// 13
	MOLECULE_BALL_SIZE / 3, 0, MOLECULE_BALL_SIZE / 12,
	0, 0, 0,
	// 14
	MOLECULE_BALL_SIZE, -MOLECULE_BALL_SIZE * 2, MOLECULE_BALL_SIZE * 2,
	0, 0, 0,
	// 15
	MOLECULE_BALL_SIZE, -MOLECULE_BALL_SIZE * 2, MOLECULE_BALL_SIZE * 2,
	0, 0, 0
};

/** \brief Time sharing structure.
 *
 * Determines the 'position' in the continuity of the intro and stores it into
 * the following variables:
 * - Intrepolation step to next - positive.
 * - Camera block.
 * - Time spent in current effect.
 *
 * Camera block is returned from function instead of being saved into a memory
 * slot.
 *
 * @param ticks Real ticks used.
 * @return Next camera block in use.
 */
static unsigned timeshare_determine(uint32_t ticks)
{
	timeshare_block_t *block = (timeshare_block_t*)timeshare_data;
	float pos;
	int8_t *lookat1, *lookat2;
	unsigned start = 0,
					 camera_block;

	// Determine floating point position and correct block.
	for(;;)
	{
		unsigned duration = block->duration << 5,
						 end = start + duration;
		
		camera_block = block->camera_block;

		// Determine lookat data first, it is needed at function end.
		lookat1 = (int8_t*)camera_data + camera_block;
		lookat2 = lookat1 + 6;

		if((ticks >= start) && (ticks <= end))
		{
			// Start becomes to resemble the time left for "this" iteration.
			start = ticks - start;

			// Take important data.
			timeshare_pos = pos = (float)(start) / (float)duration;
			timeshare_ticks = start + (block->cumulative << 5);
			break;
		}

		start = end;
		++block;
	}

	// Now we're ready to roll with the camera.
	{
		static const int16_t
			fov = 90,
			depth = 500;
		double gludata[6];
		int ii = 6;

		do {
			unsigned idx = ii - 1;

			gludata[idx] = (1.0f - pos) * (double)lookat1[idx] +
				pos * (double)lookat2[idx];
		} while(--ii);

		dlMatrixMode(GL_PROJECTION);
		dlLoadIdentity();
		dluPerspective(fov, SCREEN_ASPECT, 0.1f, depth);
		dlMatrixMode(GL_MODELVIEW);
		dlLoadIdentity();
		dluLookAt(gludata[0], gludata[1], gludata[2], gludata[3], gludata[4],
				gludata[5], 0.0, 1.0, 0.0);
	}

	dlDisable(GL_LIGHTING);
	dlDisable(GL_LIGHT1);

	return camera_block;
}

//############################################################################
// Audio #####################################################################
//############################################################################

/** Audio data block size (samples) is equal to the length of the intro. */
#define AUDIO_LEN (((LEN_M1234 + LEN_M5 + LEN_O123456 + LEN_O7) << 8) * 44)

/** Audio data buffer. */
static uint8_t audio_data_buffer[AUDIO_LEN * 2 * 2];

/** Audio data position. */
static uint8_t *audio_position = audio_data_buffer;

/** Update audio stream.
 *
 * @param userdata Not used.
 * @param stream Target stream.
 * @param len Number of bytes to write.
 */
static void audio_callback(void *userdata, uint8_t *stream, int len)
{
	static const float
		darkness_mul = (1.0f / INTERFERENCE_COUNT / INTERFERENCE_DIVISOR);

	darkness_float = 0.0f;

	do {
		int16_t aval = *((int16_t*)audio_position);
#ifdef ORGANICA_BIG_ENDIAN
		*stream = *(audio_position + 1);
		*(stream + 1) = *audio_position;
#else
		*((int16_t*)stream) = aval;
#endif

		darkness_float += fabsf(aval) * darkness_mul;

		stream += 2;
		audio_position += 2;
	} while(len -= 2);
}

/** Audio specification. */
static SDL_AudioSpec audio_spec =
{
	44100,
  AUDIO_S16,
	1,
	0,
	1024,
	0,
	0,
	audio_callback,
	NULL
};

//############################################################################
// Text ######################################################################
//############################################################################

#ifdef ALLOW_TEXT

/** Font for drawing. */
const uint8_t font[] =
{
	// A 0
	0x00, 0xFF, 0xFF, 0x00,
	0xFF, 0x00, 0x00, 0xFF,
	0xFF, 0xFF, 0xFF, 0x00,
	0xFF, 0x00, 0x00, 0xFF,
	// B 1
	0xFF, 0x00, 0x00, 0x00,
	0xFF, 0xFF, 0xFF, 0x00,
	0xFF, 0x00, 0x00, 0xFF,
	0xFF, 0xFF, 0xFF, 0x00,
	// D 2
	0xFF, 0xFF, 0xFF, 0x00,
	0xFF, 0x00, 0x00, 0xFF,
	0xFF, 0x00, 0x00, 0xFF,
	0xFF, 0xFF, 0xFF, 0x00,
	// E 3
	0x00, 0xFF, 0xFF, 0x00,
	0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0x00, 0x00, 0x00,
	0x00, 0xFF, 0xFF, 0x00,
	// F 4
	0x00, 0x00, 0xFF, 0xFF,
	0x00, 0xFF, 0x00, 0x00,
	0xFF, 0xFF, 0xFF, 0xFF,
	0x00, 0xFF, 0x00, 0x00,
	// L 5
	0xFF, 0x00, 0x00, 0x00,
	0xFF, 0x00, 0x00, 0x00,
	0xFF, 0x00, 0x00, 0x00,
	0xFF, 0xFF, 0xFF, 0xFF,
	// M 6
	0xFF, 0x00, 0x00, 0xFF,
	0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0x00, 0x00, 0xFF,
	0xFF, 0x00, 0x00, 0xFF,
  // O/0 7
	0x00, 0xFF, 0xFF, 0x00,
	0xFF, 0x00, 0x00, 0xFF,
	0xFF, 0x00, 0x00, 0xFF,
	0x00, 0xFF, 0xFF, 0x00,
  // R 8
	0xFF, 0xFF, 0xFF, 0x00,
	0xFF, 0x00, 0x00, 0xFF,
	0xFF, 0xFF, 0xFF, 0x00,
	0xFF, 0x00, 0x00, 0xFF,
	// S 9
	0x00, 0xFF, 0x00, 0x00,
	0xFF, 0x00, 0xFF, 0x00,
	0xFF, 0x00, 0x00, 0xFF,
	0xFF, 0x00, 0xFF, 0x00,
	// Y 10
	0xFF, 0x00, 0x00, 0xFF,
	0xFF, 0xFF, 0xFF, 0x00,
	0x00, 0xFF, 0x00, 0x00,
	0x00, 0xFF, 0x00, 0x00,
	// 2 11
	0xFF, 0xFF, 0xFF, 0xFF,
	0x00, 0x00, 0xFF, 0x00,
	0x00, 0xFF, 0x00, 0x00,
	0xFF, 0xFF, 0xFF, 0xFF,
	// 7 12
	0xFF, 0xFF, 0xFF, 0x00,
	0x00, 0x00, 0xFF, 0x00,
	0x00, 0xFF, 0xFF, 0xFF,
	0x00, 0x00, 0xFF, 0x00,
	// space, 13
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00
};

const uint8_t string_assembly[] =
{
 	0, 9, 9, 3, 6, 1, 5, 10, 13, 11, 7, 7, 12, 14
};
const uint8_t string_freebsd[] =
{
	4, 8, 3, 3, 1, 9, 2, 14
};

/** \brief Draw text to screen.
 *
 * @param x X position.
 * @param y Y position.
 * @param col Color.
 * @param csize Cube size.
 * @param str String to draw.
 */
void textout(float x, float y, uint32_t col, float csize, const uint8_t *str)
{
	uint8_t *striter = (uint8_t*)str;
	interleaved_array_t *iter = interference_array;
	unsigned drawcap = 0;

	while(1)
	{
		unsigned ch = *striter;
		++striter;

		if(ch > 13)
		{
			break;
		}

		{
			unsigned ii;
			for(ii = 0; (ii < 4); ++ii)
			{
				unsigned jj;
				for(jj = 0; (jj < 4); ++jj)
				{
					if(font[ch * 16 + jj * 4 + ii])
					{
						float x1 = x + ii * csize,
									x2 = x1 + csize,
									y1 = y - jj * csize,
									y2 = y1 - csize;

						printf("Legal mark at %f: %i %i\n", x, ii, jj);

						iter[0].color = col;
						iter[0].vertex[0] = x1;
						iter[0].vertex[1] = y1;
						iter[0].vertex[2] = -1.0f;
						iter[1].color = col;
						iter[1].vertex[0] = x1;
						iter[1].vertex[1] = y2;
						iter[1].vertex[2] = -1.0f;
						iter[2].color = col;
						iter[2].vertex[0] = x2;
						iter[2].vertex[1] = y2;
						iter[2].vertex[2] = -1.0f;
						iter[3].color = col;
						iter[3].vertex[0] = x2;
						iter[3].vertex[1] = y1;
						iter[3].vertex[2] = -1.0f;

						drawcap += 4;
						iter += 4;
					}
				}
			}
		}

		x += 5.0f * csize;
	}

	gl_draw_array(interference_array, GL_QUADS, drawcap);
}

#endif

//############################################################################
// Mega-effect ###############################################################
//############################################################################

/** Mega effect.
 *
 * @param camera_block The camera block to use.
 */
void effect(unsigned camera_block)
{
	float ticks_float = (float)timeshare_ticks;

	dlEnable(GL_DEPTH_TEST);

	if(camera_block >= 60)
	{
		dlEnable(GL_BLEND);

		gl_light(0, &molecule_light);

		// First.
		rseed(10);
		{
			unsigned ii = 600;

			do {
				float sph[3];
				generate_sphere_coordinates(sph,
						rfloat_unsigned(M_2PI), rfloat_unsigned(M_2PI),
						(float)MOLECULE_BALL_SIZE);
				gl_sphere(sph, molecule_color,
						(float)MOLECULE_BALL_SIZE *
						(.3f + 0.2f *
						 fabs(dsinf(ticks_float * 0.0006f + ii))));
			} while(--ii);
		}

		if(camera_block == 84)
		{
			dlDisable(GL_LIGHTING);
		}

		{
			unsigned ii = MOLECULE_STRAND_COUNT;
			rseed(8);

			do {
				unsigned cap = timeshare_ticks >> MOLECULE_ADD_SKIP;
				float dr = rfloat_unsigned(M_2PI),
							dh = rfloat_signed(M_PI_2),
							pos[3],
							dir_r,
							dir_h;

				// The initial place and direction.
				generate_sphere_coordinates(pos, dr, dh, (float)MOLECULE_BALL_SIZE);
				dir_r = dr - M_PI;
				dir_h = -dh;

				// We will turn this much every frame.
				dr = (rfloat_signed(MOLECULE_TURN) + 0.001f) *
					dsinf(ticks_float * (rfloat_unsigned(0.01f) + 0.001f));
				dh = (rfloat_signed(MOLECULE_TURN) + 0.001f) *
					dsinf(ticks_float * (rfloat_unsigned(0.01f) + 0.001f));

				{
					unsigned jj = 0;
					for(; (jj < cap); ++jj)
					{
						static const float
							ROT_MULT = (180.0f / M_PI),
							CONE_LEN = MOLECULE_SPEED * 5.0f;
						float sphereadd[3],
									sphere_div;

						// Orientation.
						dlPushMatrix();
						glTranslate3fv(pos);
						dlRotatef(dir_r * ROT_MULT + 90.0f, 0.0f, -1.0f, 0.0f);
						dlRotatef(dir_h * ROT_MULT + 180.0f, 1.0f, 0.0f, 0.0f);

						// Draw.
						dlColor4ubv(spike_color);
						sphere_div = 1.0f -
							(float)(jj << MOLECULE_ADD_SKIP) / ticks_float;
						dlutSolidCone(sphere_div * MOLECULE_STRAND_SIZE,
								CONE_LEN,
								16, 1);
						dlPopMatrix();

						// Advance.
						generate_sphere_coordinates(sphereadd, dir_r, dir_h,
								MOLECULE_SPEED);
						pos[0] += sphereadd[0];
						pos[1] += sphereadd[1];
						pos[2] += sphereadd[2];
						dir_r += dr;
						dir_h += dh;
					}
				}
			} while(--ii);
		}

#ifdef ORGANICA_BIG_ENDIAN
		set_clear_color(0x00000015);
#else
		set_clear_color(0x15000000);
#endif
	}
	else
	{
		void (*lissajous_1)(interleaved_array_t*, unsigned);
		void (*lissajous_2)(interleaved_array_t*, unsigned);

		// Do the mush first.
		dlDisable(GL_BLEND);

		gl_light(0, &mush_light0);
		gl_light(1, &mush_light1);

		{
			unsigned ii = MUSH_COUNT;

			do {
				float scale = dsinf(ticks_float * rfloat_signed(0.003f)),
							rscale = mush_light1.pos[0];
				float vertex[3] =
				{
					rfloat_signed(rscale) * scale,
					rfloat_signed(rscale) * scale,
					rfloat_signed(rscale) * scale - molecule_light.pos[0]
				};
				float	radius =
					(1.0f + MUSH_BALL_RETRACT * dsinf(ticks_float * 0.01f + ii)) *
					MUSH_BALL_SIZE;

				gl_sphere(vertex, (uint8_t*)(&mush_color), radius);
			} while(--ii);
		}

		// Mush is done, do the orbit.
		dlDisable(GL_DEPTH_TEST);
		dlDisable(GL_LIGHTING);
		dlEnable(GL_BLEND);

		if((camera_block >= 48) || (camera_block <= 12))
		{
			lissajous_1 = orbit_gingerbread;
			lissajous_2 = orbit_gingerbread;
		}
		else if(camera_block <= 18)
		{
			lissajous_1 = orbit_threeply;
			lissajous_2 = orbit_threeply;
		}
		else if(camera_block <= 24)
		{
			lissajous_1 = orbit_threeply;
			lissajous_2 = orbit_hopalong;
		}
		else if(camera_block <= 32)
		{
			lissajous_1 = orbit_hopalong;
			lissajous_2 = orbit_martin;
		}
		else if(camera_block <= 36)
		{
			lissajous_1 = orbit_martin;
			lissajous_2 = orbit_martin;
		}
		else
		{
			lissajous_1 = orbit_martin;
			lissajous_2 = orbit_gingerbread;
		}

		// Call precalculators.
		rseed(1);
		lissajous_1(orbit_table[0], ORBIT_COUNT);
		rseed(1);
		lissajous_2(orbit_table[1], ORBIT_COUNT);
		orbit_interpolate(orbit_current, orbit_table[0], orbit_table[1],
				ORBIT_COUNT);

		gl_draw_array(orbit_current, GL_POINTS, ORBIT_COUNT);

#ifdef ORGANICA_BIG_ENDIAN
		set_clear_color(0x312F1C60);
#else
		set_clear_color(0x601C2F31);
#endif
	}

	// Always draw.
	{
		unsigned ii = 512;
		interleaved_array_t *iter = interference_array + 4;
		uint32_t darkness = (uint32_t)darkness_float;

		rseed(1);
		timeshare_determine(0x3FFF);

		//darkness = 127 + (uint32_t)((dsinf(ticks_float * 0.03f) + 1.0f) * 64.0f);

#ifdef ORGANICA_BIG_ENDIAN
		darkness = (darkness << 24) | (darkness << 16);
#else
		darkness |= darkness << 8;
#endif

		// Different color for other effect.
		if(camera_block < 60)
		{
#ifdef ORGANICA_BIG_ENDIAN
			darkness = darkness >> 8;
#else
			darkness = darkness << 8;
#endif
		}
#ifdef ALLOW_TEXT
		else
		{
			textout(5.7f - ticks_float * 0.002f, -0.1f, 0x70E0C0A0, 0.08f,
					string_assembly);
			textout(-8.7f + ticks_float * 0.002f, 0.6f, 0x70A0C0E0, 0.08f,
					string_freebsd);
		}
#endif

#ifdef ORGANICA_BIG_ENDIAN
		darkness |= 64;
#else
		darkness |= 64 << 24;
#endif

		ii = INTERFERENCE_COUNT;
		do {
			float	pos = dsinf(rfloat_unsigned(4.0f * M_PI) +
					ticks_float * rfloat_unsigned(0.001f));
			float extent = rfloat_unsigned(SCREEN_ASPECT);

			iter[0].color = darkness;
			iter[0].vertex[0] = -SCREEN_ASPECT;
			iter[0].vertex[1] = pos;
			iter[0].vertex[2] = -1.0f;
			iter[1].color = INTERFERENCE_WEAK_COLOR;
			iter[1].vertex[0] = -extent;
			iter[1].vertex[1] = pos;
			iter[1].vertex[2] = -1.0f;

			iter[2].color = INTERFERENCE_WEAK_COLOR;
			iter[2].vertex[0] = extent;
			iter[2].vertex[1] = pos;
			iter[2].vertex[2] = -1.0f;
			iter[3].color = darkness;
			iter[3].vertex[0] = SCREEN_ASPECT;
			iter[3].vertex[1] = pos;
			iter[3].vertex[2] = -1.0f;

			iter += 4;
		} while(--ii);

		// Flush interfered pattern to the screen. Note that this is valid,
		// since depth buffer is cleared after the filling front rectangle.
		gl_draw_array(interference_array, GL_LINES, INTERFERENCE_COUNT * 2 * 2);
	}
}

//############################################################################
// Soft synth ################################################################
//############################################################################

#define c0 0
#define cs0 1
#define d0 2
#define ds0 3
#define e0 4
#define f0 5
#define fs0 6
#define g0 7
#define gs0 8
#define a0 9
#define as0 10
#define h0 11
#define c1 12
#define cs1 13
#define d1 14
#define ds1 15
#define e1 16
#define f1 17
#define fs1 18
#define g1 19
#define gs1 20
#define a1 21
#define as1 22
#define h1 23
#define c2 24
#define cs2 25
#define d2 26
#define ds2 27
#define e2 28
#define f2 29
#define fs2 30
#define g2 31
#define gs2 32
#define a2 33
#define as2 34
#define h2 35
#define c3 36
#define cs3 37
#define d3 38
#define ds3 39
#define e3 40
#define f3 41
#define fs3 42
#define g3 43
#define gs3 44
#define a3 45
#define as3 46
#define h3 47
#define c4 48
#define cs4 49
#define d4 50
#define ds4 51
#define e4 52
#define f4 53
#define fs4 54
#define g4 55
#define gs4 56
#define a4 57
#define as4 58
#define h4 59
#define c5 60
#define cs5 61
#define d5 62
#define ds5 63
#define e5 64
#define f5 65
#define fs5 66
#define g5 67
#define gs5 68
#define a5 69
#define as5 70
#define h5 71
#define c6 72
#define cs6 73
#define d6 74
#define ds6 75
#define e6 76
#define f6 77
#define fs6 78
#define g6 79
#define gs6 80
#define a6 81
#define as6 82
#define h6 83
#define c7 84
#define cs7 85
#define d7 86
#define ds7 87
#define e7 88
#define f7 89
#define fs7 90
#define g7 91
#define gs7 92
#define a7 93
#define as7 94
#define h7 95
#define pp 0
#define acc | 0x80
#define C1 | 0x00
#define C2 | 0x40
#define C3 | 0x80
#define C4 | 0xc0

static unsigned short freqtable[13] = {
4000,
4237,
4489,
4756,
5039,
5339,
5656,
5993,
6349,
6727,
7127,
7550,
0,};

#define SONGLEN 26
#define PATTLEN 16
#define TICKLEN 10259
#define DETUNE_AMT 30000

#define FILTER_LP 0
#define FILTER_HP 0x40
#define FILTER_BP 0x80
#define FILTER_BYPASS 0xc0

#define PITCH_SLIDE 0x20

#define SAW_DUAL 0x10
#define NOISE 0x08
#define SQUARE 0x04
#define SINE 0x02

typedef int16_t sample_t;
typedef unsigned char uint8_t;

#define VOICES_NORMAL 5
#define VOICES_CHORD 3

static const uint8_t chords[12] = {
    0, 3, 7, // min
    0, 4, 7, // maj
    0, 5, 8, // min joku
    0, 5, 9, // hmhmhhmm majjj
};

#define SONGSTART 0

static const uint8_t song[SONGLEN * (VOICES_NORMAL + 1)] = {
    // sointu
    8, 8, 8, 8, 8, 8, 8, 8,
    7, 9, 7, 9, 7, 9, 7, 9,
    8, 8, 8, 8, 7, 9, 7, 9,
    7, 13,
    // diu
    8, 8, 8, 8, 4, 4, 4, 3,
    8, 8, 8, 8, 4, 4, 4, 3,
    10, 14, 10, 3, 4, 14, 10, 3,
    8, 8,
    // bas
    0, 1, 0, 1, 0, 1, 0, 1,
    0, 1, 0, 1, 0, 1, 0, 1,
    0, 1, 0, 1, 0, 1, 0, 1,
    8, 16,
    // bd
    8, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2,
    2, 15,
    // hh
    5, 5, 5, 5, 5, 5, 5, 5,
    5, 5, 5, 5, 5, 5, 5, 5,
    5, 5, 5, 5, 5, 5, 5, 5,
    5, 12,
    // sd
    8, 8, 6, 6, 6, 6, 6, 6,
    6, 6, 6, 6, 6, 6, 6, 6,
    6, 6, 6, 6, 6, 6, 6, 6,
    6, 11,
};

#define NUM_PATTERNS 17

static const uint8_t patterns[NUM_PATTERNS * PATTLEN] = {
    // Bass patterns
    // 0
    c2 acc, c2, c3, c2, pp, c2, c3 acc, ds2,
    f2 acc, f2, f3, f2, pp, f2 acc, f3, f3,

    // 1
    gs1 acc, gs1, gs2, as1, as1, as2 acc, ds2, pp,
    pp, ds2 acc, ds1, ds2, g2, g2 acc, g3, g3,

    // bd
    // 2
    c2 acc, pp, c4 acc, pp, pp, pp, c2 acc, pp,
    c2 acc, pp, c4 acc, pp, pp, pp, c2 acc, pp,

    // hp diung 2
    // free
    c4 acc, pp, c4, d4, f5 acc, g5, g4, ds5 acc,
    f4, f5 acc, g5, pp, c4, pp, c4, pp,

    // hp diung
    // 4
    c4 acc, pp, c4, d4, ds4, c4 acc, g4, f4 acc,
    f4, f4, c4, pp, c4, pp, c4, pp,

    // sd
    // 5
    c4, c5, d5, d5, c4, g5, c7, c4,
    c4, c6, c1, c2, c4, c5, h7, c5,

    // sd nyt jo
    // 6
    pp, pp, c2 acc, pp, pp, pp, c2 acc, g6,
    pp, pp, c2 acc, pp, pp, pp, c2 acc, g7,

    // sointua
    // 7
    c1 C1, g0 C3, pp, pp, pp, pp, c1 C1, pp,
    c1 C3, gs0 C2, pp, pp, pp, pp, c1 C3, pp,

    // hilj.
    // 8
    pp, pp, pp, pp, pp, pp, pp, pp,
    pp, pp, pp, pp, pp, pp, pp, pp,

    // sointu2
    c1 C3, c1 C1, as0 C2, gs0 C2, pp, as0 C2, pp, c1 C1,
    pp, as0 C4, pp, as0 C2, as0 C2, pp, gs0 C2, as0 C2,

    // diu 3
    c4 acc, ds5 acc, gs5, d4, g5 acc, c4 acc, gs5 acc, c6 acc,
    f4, f4 acc, gs5 acc, gs5, c4, g5, gs5 acc, g5,

    // sd end
    // 11
    pp, pp, c2 acc, pp, pp, pp, c2 acc, pp,
    c1 acc, pp, pp, pp, pp, pp, pp, pp,

    // hh end
    // 12
    c4, c5, d5, d5, c4, g5, c7, c4,
    c4, c6, pp, pp, pp, pp, pp, pp,

    // sointu2
    c1 C3, c1 C1, c1 C3, pp, pp, as0 C2, pp, c1 C1,
    c1 C1, pp, pp, pp, pp, pp, pp, pp,

    // diu 4
    c4 acc, pp, c4, d4, gs5 acc, as5, g4, g5 acc,
    f4, f5, as4 acc, pp, c4, pp, c4 acc, c4,

    // bd end
    // 15
    c2 acc, pp, c4 acc, pp, pp, pp, c2 acc, pp,
    c2 acc, pp, pp, pp, pp, pp, pp, pp,

    // bass fianl
    pp, pp, pp, pp, pp, pp, pp, pp,
    c2 acc, c2, c2, c2, c2, c2, c2,
};

#define INSTR_LEN 6
// flags, vol, vol slide, pitch slide, Q, F
static const signed short instruments[(VOICES_NORMAL + 1) * INSTR_LEN] = {
    // sointu
    FILTER_HP | SAW_DUAL,            19500, 0, 0, 12000, 3000,
    // dii
    FILTER_BP | SAW_DUAL,                 21000,0, 0, 700, 28000,
    // bääs
    FILTER_LP | SAW_DUAL,          18000, 0, 50, 7000, 18000,
    // bd
    FILTER_LP | SINE | PITCH_SLIDE, 17000, 1, 170, 30000, 30000,
    // sd
    FILTER_HP | NOISE,                    32600, 20, 0, 4000, 5000,
    // sd joo
    FILTER_HP | NOISE,                    22000, 2, 0, 10000, 1000,
};

//############################################################################
// Main ######################################################################
//############################################################################

#ifdef DISCARD_LIBC
void *environ, *__progname;
/** Small main function.
*/
void _start()
{
#ifdef USE_FREEGLUT
	int argc = 0;
	char *argv[] = { "i" };
#endif
#else
/** Main function.
 * @param argc Not used.
 * @param argv Not used.
 */
int main(int argc, char *argv[])
{
#endif
	uint32_t start_time, last_tick;

#ifdef HAVE_DLFCN_H
	// Dynamic loader before doing anything else.
#ifdef DNLOAD_LIBM
	block_dnload(msym, msymname);
#endif
#ifdef DNLOAD_LIBGL
	block_dnload(glsym, glsymname);
#endif
#ifdef DNLOAD_LIBGLU
	block_dnload(glusym, glusymname);
#endif
#ifdef DNLOAD_LIBGLUT
	block_dnload(glutsym, glutsymname);
#endif
#ifdef DNLOAD_LIBSDL
	block_dnload(sdlsym, sdlsymname);
#endif
#endif // HAVE_DLFCN_H

#ifdef USE_FREEGLUT
	dlutInit(&argc, argv);
#endif
	DDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER);

	// Do not take the screen with you since it is not needed.
	//SDL_Surface *screen =
	DDL_SetVideoMode(SCREEN_W, SCREEN_H, SCREEN_B, SDL_OPENGL | SCREEN_F);
	DDL_ShowCursor(0);

	dlEnable(GL_CULL_FACE);
	dlEnable(GL_COLOR_MATERIAL);
	dlBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// Open audio device and start playing.
	{
		/*unsigned ii;
			for(ii = 0; (ii < AUDIO_LEN); ++ii)
			{
			int16_t *audio_data = (int16_t*)audio_data_buffer;
			audio_data[ii * 2] = dsinf(ii * 0.02f) * 20000.0f;
			audio_data[ii * 2 + 1] = dsinf(ii * 0.02f) * 20000.0f;
			}*/
		int v, i, row, s;
		int osc1 = 0;
		int osc2 = 0;
		int sin = 0;
		int cos = 10000;
		// filter state
		int lp = 0;
		int hp = 0;
		int bp = 0;
		int d_2 = 0;

		for (v = 0; v < (VOICES_NORMAL + VOICES_CHORD); v++) {
			sample_t *op = audio_data_buffer;

			for (i = SONGSTART; i < SONGLEN; i++) {
				signed short *instr;
				uint8_t *pattern;
				int q, f;
				int filtertype;
				int cflag = (v < VOICES_CHORD);

				if (cflag) {
					instr = instruments;
					pattern = patterns + PATTLEN * song[i];
				} else {
					int a = v - (VOICES_CHORD - 1);
					instr = instruments + (a * INSTR_LEN);
					pattern = patterns + PATTLEN * song[i + SONGLEN * a];
				}

				// instrument params
				q = instr[4];
				f = instr[5];
				filtertype = instr[0] & 0xc0;

				for (row = 0; row < PATTLEN; row++) {
					int extra = 0;
					uint8_t note = *pattern;
					uint8_t n = note & 0x7f;
					int vol = instr[1];

					if (cflag && note != pp) {
						n += chords[(v + (3 * (note >> 6)))];
						n &= 0x3f;
						n += 48;
					} else if (note & 0x80) {
						// accent
						f = 10000;
						if (instr[0] & PITCH_SLIDE) {
							extra = 220000;
						}
					}

					for (s = 0; s < TICKLEN; s++) {
						int a = freqtable[n % 12];
						int add = 0;

						if (note) {
							add = ((a + extra) << (n / 12)) << 8;
						}

						// cutoff slide
						if (f > 4000 && ((int)op & 4)) {
							f--;
						}

						// pitch slide
						if (extra > 0) {
							extra -= instr[3];
						}

						// update oscillators
						osc1 += add + extra;
						osc2 += add + extra + DETUNE_AMT;

						if (instr[0] & NOISE) {
							osc1 *= osc2;
						}
						int in = osc1 >> 20;
						if (instr[0] & SQUARE) {
							in &= (-(1 << 32 - 1) >> 19);
						} else {
							in + osc2 >> 20;
						}
						if (instr[0] & SINE) {
							sin += ((add >> 16) * cos) >> 16;
							cos -= ((add >> 16) * sin) >> 16;
							in = sin;
						}

						if (vol > 100) {
							vol -= instr[2];
						}

						// volume
						in = (in * vol) >> 15;

						// filter
						lp = lp + ((f * bp) >> 15);
						hp = in - ((bp * q) >> 15) - lp;
						bp = ((f * hp) >> 15) + bp;

						if (note != pp) {
							switch (filtertype) {
								case FILTER_LP:
									*(op) += lp;
									break;
								case FILTER_HP:
									*(op) += hp;
									break;
								case FILTER_BP:
									*(op) += bp;
									break;
									/*
										 case FILTER_BYPASS:
									 *(op++) += in;
									 break;
									 */
							};
						}

						if (v < 2) {
							*op -= (*(op - TICKLEN * 3)) >> 4;
						}

						op++;
					}
					pattern++;
				}
			}
		}
	}
	DDL_OpenAudio(&audio_spec, NULL);
	DDL_PauseAudio(0);	

	// Start NAO PLX.
	start_time = DDL_GetTicks();
	last_tick = start_time;

	//SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 0);
	
	while(1)
	{
		// C89.
		uint32_t tick_pos;

		// Abort on any keypress.
		SDL_Event event;
		if(DDL_PollEvent(&event) && (event.type == SDL_KEYDOWN))
		{
			break;
		}

		// Get tick pos and act accordingly. The value is shifted right by 4, that
		// means we get a maximum of 125 frames per second. It is more than
		// enough.
		tick_pos = (DDL_GetTicks() - start_time) >> 3;

		// Clear the screen.
		if(tick_pos == last_tick)
		{
			continue;
		}
		last_tick = tick_pos;

		timeshare_determine(0x3FFF);
		gl_draw_array(clear_array, GL_QUADS, 4);
		dlClear(GL_DEPTH_BUFFER_BIT);

		{
			unsigned camera_block = timeshare_determine(tick_pos);
			if(!camera_block)
			{
				break;
			}
			effect(camera_block);
		}

		//effect_interference(tick_pos);
		DDL_GL_SwapBuffers();
	}

	DDL_Quit();

#ifdef DISCARD_LIBC
	asm("movl $1,%eax\nxor %ebx,%ebx\nint $128\n");
#else
	return 0;
#endif
}

//############################################################################
// Obsolete and unused #######################################################
//############################################################################

#if 0

#ifdef DNLOAD_LIBC

/** c symbol table */
static void *csym[2];
#define drand ((int (*)())(csym[0]))
#define dsrand ((void (*)(unsigned))(csym[1]))

/** c symbol name table. */
static const char csymname[] =
{
	5, 'r', 'a', 'n', 'd', 0,
	6, 's', 'r', 'a', 'n', 'd', 0,
	0
};

#else

#define drand rand
#define dsrand srand

#endif

#ifdef DNLOAD_LIBC
	block_dnload("libc.so", csym, csymname);
#endif

/** \brief DNA strand form effect.
 *
 * @param target Target table.
 * @param cnt Unit count.
 * @param ticks Tick count.
 */
static void orbit_dna(interleaved_array_t *target, unsigned cnt,
		uint32_t ticks)
{
	static const float DNA_SIZE = 20.0f;

	cnt /= 2;

	do {
		float sinepos = ticks * 0.005f + cnt * 0.1f;

		target->vertex[0] = dsinf(sinepos) * DNA_SIZE;
		target->vertex[1] = cnt * 0.7f - DNA_SIZE;
		target->vertex[2] = dcosf(sinepos) * DNA_SIZE;

		++target;

		target->vertex[0] = dsinf(sinepos + M_PI) * DNA_SIZE;
		target->vertex[1] = cnt * 0.7f - DNA_SIZE;
		target->vertex[2] = dcosf(sinepos + M_PI) * DNA_SIZE;

		++target;
	} while(--cnt);
}

			unsigned ii = INTERFERENCE_COUNT;
			interleaved_array_t *iter = interference_array + 4;
			uint32_t darkness;

			//dlLoadIdentity();
			rseed(1);

			do {
				int16_t audio_inst = ((int16_t*)audio_position)[ii];
				float
					ypos = (float)ii * (2.0f / INTERFERENCE_COUNT) - 1.0f,
							 extent = (float)audio_inst / AUDIO_DIVISOR;

				extent *= extent;

				darkness = ((uint32_t)(127 + extent * 64.0f) << 24) | 0x00FFFF00;

				extent = (1.0f - extent) * 2.0f;

				iter[0].color = darkness;
				iter[0].vertex[0] = -INTERFERENCE_START;
				iter[0].vertex[1] = ypos;
				iter[0].vertex[2] = -1.0f;
				iter[1].color = INTERFERENCE_WEAK_COLOR;
				iter[1].vertex[0] = -extent;
				iter[1].vertex[1] = ypos;
				iter[1].vertex[2] = -1.0f;

				iter[2].color = INTERFERENCE_WEAK_COLOR;
				iter[2].vertex[0] = extent;
				iter[2].vertex[1] = ypos;
				iter[2].vertex[2] = -1.0f;
				iter[3].color = darkness;
				iter[3].vertex[0] = INTERFERENCE_START;
				iter[3].vertex[1] = ypos;
				iter[3].vertex[2] = -1.0f;

				iter += 4;
			} while(--ii);

			// Flush interfered pattern to the screen. Note that this is valid,
			// since depth buffer is cleared after the filling front rectangle.
			dlLoadIdentity();
			gl_draw_array(interference_array, GL_LINES, INTERFERENCE_COUNT * 2 * 2);

#endif

//############################################################################
// End #######################################################################
//############################################################################

