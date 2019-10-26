/** \file
 * For details, please see README.
 */

//######################################
// Config ##############################
//######################################

/** \cond */
#if !defined(MODE_REL)
#include "config.h"
#define FUNCTION static
#define VARIABLE static
#define CONST static const
#else
#define FUNCTION __attribute__((regparm(3))) static
#define VARIABLE static
#define CONST static
#endif
/** \endcond */

//######################################
// Define ##############################
//######################################

/** Screen width. */
#define SCREEN_W 1280
//#define SCREEN_W 800

/** Screen heigth. */
#define SCREEN_H 720
//#define SCREEN_H 500

/** Required for perspective. This is the first time we're in widescreen! */
#define SCREEN_A ((double)SCREEN_W / (double)SCREEN_H)

/** Screen bytes per pixel. */
#define SCREEN_B 32

/** Fullscreen on or off. */
#define SCREEN_F

/** Delay between frames (milliseconds). */
#define FRAME_TICKS 16

// Only check for debugging if we're in GNU LD mode.
#if defined(USE_LD)
/** Manual advance in the intro timeline. */
//#define MANUAL_ADVANCE
#endif

/** Camera fade cycle. */
#define CAMERA_FADE 4096

/** Camera flash cycle. */
#define CAMERA_FLASH 512

/** Fall start. */
#define FALL_START 56000

/** Fall end / fade to black start. */
#define FALL_END 58000

/** Intro length (seconds). */
#define INTRO_LENGTH 65535

/** Intro start debug (if applicable) */
//#define INTRO_START 40000

//######################################
// Include #############################
//######################################

// Math defines for MSVC
#define _USE_MATH_DEFINES
#include <math.h>

#if defined(HAVE_INTTYPES_H)
#include <inttypes.h>
#elif defined(HAVE_STDINT_H)
#include <stdint.h>
#else // Fallback.
#include <inttypes.h>
#endif

// SDL brings all the enum stuff and everything we need for operation.
#if defined(__APPLE__)
#include <SDL/SDL.h>
#include <SDL/SDL_opengl.h>
#else
#include "SDL.h"
#include "SDL_opengl.h"
#endif

//######################################
// Dynamic loader ######################
//######################################

#include "dlfcn.h"

/** Dynamically loaded symbols in one segment. */
VARIABLE char dnload_symbols[] =
"libc.so\0"
"rand\0"
"srand\0\0"
"libGL.so\0"
"glAttachShader\0"
"glBlendFunc\0"
"glClear\0"
"glCompileShader\0"
"glCreateProgram\0"
"glCreateShader\0"
"glDepthMask\0"
"glDisable\0"
"glDrawElements\0"
"glEnable\0"
"glInterleavedArrays\0"
"glLinkProgram\0"
"glLoadIdentity\0"
"glMatrixMode\0"
"glShaderSource\0"
"glTexEnvi\0"
"glUseProgram\0\0"
"libGLU.so\0"
"gluLookAt\0"
"gluPerspective\0\0"
"libSDL.so\0"
"SDL_GetTicks\0"
"SDL_GL_SwapBuffers\0"
"SDL_Init\0"
"SDL_OpenAudio\0"
"SDL_PauseAudio\0"
"SDL_PollEvent\0"
"SDL_Quit\0"
"SDL_SetVideoMode\0"
"SDL_ShowCursor\0\0";

#define dsinf sinf

/** \cond */
#if defined(USE_LD)

#define dlAttachShader glAttachShader
#define dlBlendFunc glBlendFunc
#define dlClear glClear
#define dlCompileShader glCompileShader
#define dlCreateProgram glCreateProgram
#define dlCreateShader glCreateShader
#define dlDepthMask glDepthMask
#define dlDisable glDisable
#define dlDrawElements glDrawElements
#define dlEnable glEnable
#define dlInterleavedArrays glInterleavedArrays
#define dlLinkProgram	glLinkProgram
#define dlLoadIdentity glLoadIdentity
#define dlMatrixMode glMatrixMode
#define dlShaderSource glShaderSource
#define dlTexEnvi glTexEnvi
#define dlUseProgram glUseProgram

#define dluLookAt gluLookAt
#define dluPerspective gluPerspective

#define DDL_GetTicks SDL_GetTicks
#define DDL_GL_SwapBuffers SDL_GL_SwapBuffers
#define DDL_Init SDL_Init
#define DDL_OpenAudio SDL_OpenAudio
#define DDL_PauseAudio SDL_PauseAudio
#define DDL_PollEvent SDL_PollEvent
#define DDL_SetVideoMode SDL_SetVideoMode
#define DDL_ShowCursor SDL_ShowCursor
#define DDL_Quit SDL_Quit

#else

/* To understand this, you need to realize that all function names are
 * actually at least 4 bytes long. Thus, we can store them in the exact same
 * location wherefrom the pointer is loaded from, thus saving space. */

#define dnload_pointer(offset) (*((void**)(dnload_symbols + offset)))

#define drand ((int (*)(void))dnload_pointer(0))
#define dsrand ((void (*)(unsigned int))dnload_pointer(8))

#define dlAttachShader ((void (*)(GLuint, GLuint))(dnload_pointer(20)))
#define dlBlendFunc ((void (*)(GLenum, GLenum))(dnload_pointer(29)))
#define dlClear ((void (*)(GLbitfield))(dnload_pointer(44)))
#define dlCompileShader ((void (*)(GLuint))(dnload_pointer(56)))
#define dlCreateProgram ((GLuint (*)(void))(dnload_pointer(64)))
#define dlCreateShader ((GLuint (*)(GLenum))(dnload_pointer(80)))
#define dlDepthMask ((void (*)(GLboolean))(dnload_pointer(96)))
#define dlDisable ((void (*)(GLenum))(dnload_pointer(111)))
#define dlDrawElements ((void (*)(GLenum, GLsizei, GLenum, const GLvoid*))(dnload_pointer(123)))
#define dlEnable ((void (*)(GLenum))(dnload_pointer(133)))
#define dlInterleavedArrays ((void (*)(GLenum, GLsizei, const GLvoid*))(dnload_pointer(148)))
#define dlLinkProgram ((void (*)(GLuint))(dnload_pointer(157)))
#define dlLoadIdentity ((void (*)(void))(dnload_pointer(177)))
#define dlMatrixMode ((void (*)(GLenum))(dnload_pointer(191)))
#define dlShaderSource ((void (*)(GLuint, GLsizei, const GLchar**, const GLint*))(dnload_pointer(206)))
#define dlTexEnvi ((void (*)(GLenum, GLenum, GLint))(dnload_pointer(219)))
#define dlUseProgram ((void (*)(GLuint))(dnload_pointer(234)))

#define dluLookAt ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble))(dnload_pointer(258)))
#define dluPerspective ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble))(dnload_pointer(268)))

#define DDL_GetTicks ((Uint32 (*)())(dnload_pointer(294)))
#define DDL_GL_SwapBuffers ((void (*)())(dnload_pointer(304)))
#define DDL_Init ((int (*)(Uint32))(dnload_pointer(317)))
#define DDL_OpenAudio ((int (*)(SDL_AudioSpec*, SDL_AudioSpec*))(dnload_pointer(336)))
#define DDL_PauseAudio ((void (*)(int))(dnload_pointer(345)))
#define DDL_PollEvent ((int (*)(SDL_Event*))(dnload_pointer(359)))
#define DDL_Quit ((void (*)())(dnload_pointer(374)))
#define DDL_SetVideoMode ((SDL_Surface* (*)(int, int, int, Uint32))(dnload_pointer(388)))
#define DDL_ShowCursor ((int (*)(int))(dnload_pointer(397)))

#endif
/** \endcond */

//######################################
// rand() ##############################
//######################################

#if defined(USE_LD)

#define drand bsd_rand
#define dsrand bsd_srand

/** BSD random var. */
static uint32_t bsd_rand_next = 1;

/** \brief BSD rand() implementation.
 *
 * The intro needs to include the rand() from FreeBSD 7.2, since it might need
 * to run on platforms with a different implementation and still look the
 * same.
 */
FUNCTION int bsd_rand(void)
{
/*
 * Compute x = (7^5 * x) mod (2^31 - 1)
 * wihout overflowing 31 bits:
 *      (2^31 - 1) = 127773 * (7^5) + 2836
 * From "Random number generators: good ones are hard to find",
 * Park and Miller, Communications of the ACM, vol. 31, no. 10,
 * October 1988, p. 1195.
 */
	long hi, lo, x;

	/* Can't be initialized with 0, so use another value. */
	if(bsd_rand_next == 0)
	{
		bsd_rand_next = 123459876;
	}
	hi = bsd_rand_next / 127773;
	lo = bsd_rand_next % 127773;
	x = 16807 * lo - 2836 * hi;
	if (x < 0)
		x += 0x7fffffff;
	return ((bsd_rand_next = x) % ((u_long)RAND_MAX + 1));
}

FUNCTION void bsd_srand(uint32_t seed)
{
	bsd_rand_next = seed;
}

#endif

/** Random number from 0 to 65536.
 *
 * This is the granularity of this intro.
 *
 * @return Random number [0, 65536[
 */
FUNCTION float rand16(void)
{
	return (float)(drand() & 0xFFFF);
}

/** Random number from 0 to this.
 *
 * @param op Max. number.
 * @return Random number [0, op]
 */
FUNCTION float frand(float op)
{
	return rand16() / 65535.0f * op;
}

/** Random number from -num to num.
 *
 * @param op Cap (in one direction)
 * @return Random number [-op, op]
 */
FUNCTION float frand2(float op)
{
	return frand(op) * 2.0f - op;
}

//######################################
// Music ###############################
//######################################

/** Audio buffer for output. */
VARIABLE int16_t audio_buffer[(int64_t)44100 * INTRO_LENGTH / 1000 + 44100];

/** Current audio position. */
VARIABLE int16_t *audio_position = audio_buffer;

// This is cheaper than multiple input files.
#include "synth.c"

/** \brief Update audio stream.
 *
 * @param userdata Not used.
 * @param stream Target stream.
 * @param len Number of bytes to write.
 */
static void audio_callback(void *userdata_not_in_use, uint8_t *stream, int len)
{
	do {
		*((int16_t*)stream) = *audio_position;
		stream += 2;
		++audio_position;
	} while(len -= 2);
}

/** SDL audio specification struct. */
VARIABLE SDL_AudioSpec audio_spec =
{
	44100,
	AUDIO_S16SYS,
	1,
	0,
	1024,
	0,
	0,
	audio_callback,
	NULL
};

//######################################
// Shaders #############################
//######################################

#if defined(USE_LD)
#define GLSL_NEWLINE "\n"
#else
#define GLSL_NEWLINE ""
#endif

/** \brief Shader source fragments.
 *
 * Used for generating the shaders better. The variables are:
 *
 * c: External camera position.
 * l: External light position.
 * a: Original position.
 * b: Transformed position, carries color alpha in fourth element.
 * n: Normal vector.
 * r: Reflection vector.
 * v: Original vertex position.
 */
CONST char shader_vars[] =
"varying vec4 a;" GLSL_NEWLINE
"varying vec4 b;" GLSL_NEWLINE
#if !defined(USE_LD)
"varying vec4 c;" GLSL_NEWLINE
#endif
"varying vec4 d;" GLSL_NEWLINE
"varying vec3 e;" GLSL_NEWLINE
"varying vec3 l;" GLSL_NEWLINE
"varying vec3 n;" GLSL_NEWLINE
"varying vec3 m;" GLSL_NEWLINE
"varying vec3 r;" GLSL_NEWLINE
"vec3 f(float p,float q){" GLSL_NEWLINE
#if defined(USE_LD)
"vec4 c=gl_Color;" GLSL_NEWLINE
#endif
"";

#if defined(USE_LD)
/** Shader vars for fragment shader. */
CONST char shader_vars_fragment[] =
"varying vec4 a;" GLSL_NEWLINE
"varying vec4 b;" GLSL_NEWLINE
"varying vec4 d;" GLSL_NEWLINE
"varying vec3 e;" GLSL_NEWLINE
"varying vec3 l;" GLSL_NEWLINE
"varying vec3 n;" GLSL_NEWLINE
"varying vec3 m;" GLSL_NEWLINE
"varying vec3 r;" GLSL_NEWLINE;
#endif

/** Shader function for leaves. */
CONST char shader_func_leaf[] =
"p/=63.;" GLSL_NEWLINE
"q*=0.898;" GLSL_NEWLINE
//"e.y=p*6*(1+(sin(p*a.a*9)+cos(p*a.a*9))/66);" // Looked like shit.
"d=vec4(3.,6.,3.,10.)/10.0;" GLSL_NEWLINE
"return vec3(" GLSL_NEWLINE
"a.z+(cos(q)+sin(q/2.))*p*6.+sin(1.-p)*(5.*sin(a.z+c.a/999.)+9.)*e.x" GLSL_NEWLINE
"," GLSL_NEWLINE
"(1.-p)*(160.+30.*sin(a.a))-64." GLSL_NEWLINE
"," GLSL_NEWLINE
"a.a+sin(q)*p*6." GLSL_NEWLINE;

/** Shader function for water. */
CONST char shader_func_water[] =
"p=(p/127.0-0.5)*600.;" GLSL_NEWLINE
"q=(q/127.0-0.5)*600.;" GLSL_NEWLINE
"d=vec4(2.,3.,6.,5.)/10.;" GLSL_NEWLINE
"return vec3(p" GLSL_NEWLINE
"," GLSL_NEWLINE
"(sin((p+q)/14.+c.a/250.)+cos((-p*q)/20.+c.a/500.))/2." GLSL_NEWLINE
"," GLSL_NEWLINE
"q" GLSL_NEWLINE;

CONST char shader_func_fire[] =
"d=vec4(1.0,0.2,0.2,1.-a.w+floor(a.w));" GLSL_NEWLINE
"p+=(1.-d.a)*12.*e.x;" GLSL_NEWLINE
"q+=(1.-d.a)*(30.*e.x-3.);" GLSL_NEWLINE
"return vec3(p+p*e.y*2.,q-q*e.y*0.8,a.z+a.z*e.y*2." GLSL_NEWLINE;

/** Shader main func head. */
CONST char shader_main_head[] =
");}" GLSL_NEWLINE "void main(){" GLSL_NEWLINE;

#if defined(USE_LD)
/** Main head for fragment shader. */
CONST char shader_main_head_fragment[] =
"void main(){" GLSL_NEWLINE;
#endif

/** \brief Vertex shader.
 */
CONST char vshader[] = 
"a=gl_Vertex;" GLSL_NEWLINE
#if defined(USE_LD)
"vec4 c=gl_Color;" GLSL_NEWLINE
#else
"c=gl_Color;" GLSL_NEWLINE
#endif
"e=gl_Normal;" GLSL_NEWLINE
"l=vec3(8.+sin(c.a/2500.)*64.,32.+sin(c.a/9999.)*32.,sin(c.a/5000.)*128.-16.);" GLSL_NEWLINE
""
"r=f(a.x,a.y);" GLSL_NEWLINE
"vec3 s=normalize(f(a.x+1.,a.y)-r);" GLSL_NEWLINE
"vec3 t=normalize(f(a.x,a.y+1.)-r);" GLSL_NEWLINE
"vec3 u=normalize(f(a.x-1.,a.y)-r);" GLSL_NEWLINE
"vec3 v=normalize(f(a.x,a.y-1.)-r);" GLSL_NEWLINE
"n=normalize(cross(s,v)+cross(v,u)+cross(u,t)+cross(t,s));" GLSL_NEWLINE
""
"a=vec4(r,1.);" GLSL_NEWLINE
"b=gl_ModelViewProjectionMatrix*a;" GLSL_NEWLINE
""
"m=c.xyz-a.xyz;" GLSL_NEWLINE
"l-=a.xyz;" GLSL_NEWLINE
"r=normalize(l);" GLSL_NEWLINE
#if defined(USE_LD)
"r=2.0*n*dot(r,n)-r;" GLSL_NEWLINE
#else
"r=2.*n*dot(r,n)-r;" GLSL_NEWLINE
#endif
""
"e.x=sin(c.a/99.+a.y/3.)*clamp(a.y,-0.3,0.3);" GLSL_NEWLINE
"e.y=clamp(1.-c.y,0.0,1.0);" GLSL_NEWLINE
"d+=vec4(-0.3,-0.3,0.4,0.0)*e.y;" GLSL_NEWLINE
"if(c.y<1.){if(a.y>-2.)b.x+=e.x*e.y;}" GLSL_NEWLINE
"else if(a.y<-2.)b.x+=e.x;" GLSL_NEWLINE
""
"gl_Position=b;" GLSL_NEWLINE
"gl_TexCoord[0]=gl_MultiTexCoord0;" GLSL_NEWLINE
"gl_PointSize=(999.+5555.*e.z)/length(b.xyz);" GLSL_NEWLINE
"}";

/** \brief Fragment shader.
 */
CONST char fshader[] =
"vec4 g=d;" GLSL_NEWLINE
"g.a+=clamp(a.y/11.,-1.0,0.0);" GLSL_NEWLINE
"g.xy+=clamp(dot(normalize(n),normalize(l)),0.0,1.0);" GLSL_NEWLINE
""
"float h=clamp(dot(normalize(m),normalize(r)),0.0,1.0);" GLSL_NEWLINE
"g.xyz+=h*h*h*h;" GLSL_NEWLINE
"g.xyz*=1.-sqrt(b.z/200.);" GLSL_NEWLINE
"g.xyz+=e.z;" GLSL_NEWLINE
""
"vec2 t=gl_TexCoord[0].xy-vec2(0.5,0.5);" GLSL_NEWLINE
"g.a*=clamp(1.-length(t)*2.,0.0,1.0);" GLSL_NEWLINE
"gl_FragColor=g;" GLSL_NEWLINE
"}";

/** Shader part table. */
VARIABLE char *shader_parts[] =
{
	shader_vars,
	NULL,
	shader_main_head,
	NULL
};

#if defined(USE_LD)
/** GLSL program. */
VARIABLE unsigned program_leaf;

/** GLSL program. */
VARIABLE unsigned program_water;

/** GLSL program. */
VARIABLE unsigned program_fire;
#else
/** Pre-computed GLSL program id. */
#define program_leaf 3

/** Pre-computed GLSL program id. */
#define program_water 6

/** Pre-computed GLSL program id. */
#define program_fire 9
#endif

/** \brief Uniform vars for a program.
 *
 * These are actually manipulated by passing them to the interleaved array
 * construct instead of actually using the uniforms.
 */
VARIABLE float uniform[8];

/** \brief Create a shader.
 *
 * @param ss Shader source.
 * @param st Shader type.
 * @return Compiled shader.
 */
FUNCTION unsigned shader_create(const char *sf, const char *ss, GLenum st)
{
	unsigned ret = dlCreateShader(st);

	shader_parts[1] = (char*)sf;
	shader_parts[3] = (char*)ss;
#if defined(USE_LD)
	if(st == GL_FRAGMENT_SHADER)
	{
		shader_parts[0] = (char*)shader_vars_fragment;
		shader_parts[1] = (char*)"";
		shader_parts[2] = (char*)shader_main_head_fragment;
	}
	else
	{
		shader_parts[0] = (char*)shader_vars;
		shader_parts[2] = (char*)shader_main_head;
	}
#endif
	dlShaderSource(ret, 4, (const char**)shader_parts, NULL);
	dlCompileShader(ret);
#if defined(USE_LD)
	for(int ii = 0; (ii < 4); ++ii)
	{
		printf("%s", shader_parts[ii]);
	}
	puts("");
	{
		char slog[4096];
		GLint status;
		GLsizei len;

		glGetShaderInfoLog(ret, 4096, &len, slog);
		if(strlen(slog) > 0)
		{
			puts(slog);
		}

		glGetShaderiv(ret, GL_COMPILE_STATUS, &status);
		if(status != GL_TRUE)
		{
			DDL_Quit();
			exit(1);
		}
	}
#endif
	return ret;
}

/** \brief Create a program.
 *
 * Create a shader program using one vertex shader and one fragment shader.
 *
 * @param vs Vertex shader.
 * @param fs Fragement shader.
 * @return The compiled and linked program.
 */
#if defined(USE_LD)
FUNCTION unsigned program_create(const char *vf)
#else
FUNCTION void program_create(const char *vf)
#endif
{
	unsigned vi = shader_create(vf, vshader, GL_VERTEX_SHADER),
					 fi = shader_create(vf, fshader, GL_FRAGMENT_SHADER);

	unsigned ret = dlCreateProgram();
	dlAttachShader(ret, vi);
	dlAttachShader(ret, fi);
	dlLinkProgram(ret);
#if defined(USE_LD)
	{
		char slog[4096];
		GLint status;
		GLsizei len;

		glGetProgramInfoLog(ret, 4096, &len, slog);
		if(strlen(slog) > 0)
		{
			puts(slog);
		}

		glGetProgramiv(ret, GL_LINK_STATUS, &status);
		if(status != GL_TRUE)
		{
			DDL_Quit();
			exit(1);
		}
	}
	printf("GLSL program with %p compiles to: %u\n", vf, ret);
	return ret;
#endif
}

//######################################
// Dragonfly ###########################
//######################################

/** \brief Dragonfly point data.
 *
 * Format:
 * x
 * y
 * z
 * y movement sin multiplier
 * y movement sin addition
 */
CONST int8_t dragonfly_data[] = 
{
	// Middle point
	3, 0, 0, 0, 0,
	// Head
	5, 6, 0, 0, 0,
	// Upper jaw
	5, 9, 0, 0, 0,
	2, 9, 0, 0, 0,
	// Lower jaw
	2, 8, 0, 0, 0,
	// Tail
	4, -11, 0, 0, 0,
	1, -28, 0, 0, 0,
	// Leg UL
	4, 5, 5, 1, 64,
	-2, 7, 2, 1, 64,
	// Leg UR
	4, 5, -5, 1, 0,
	-2, 7, -2, 1, 0,
	// Leg LL
	2, -5, 4, 1, 0,
	-2, -3, 2, 1, 0,
	// Leg LR
	2, -5, -4, 1, 64,
	-2, -3, -2, 1, 64,
	// Wing UL
	10, -3, 7, 0, 0,
	12, -16, 11, 0, 0,
	// Wing UR
	10, -3, -7, 0, 0,
	12, -16, -11, 0, 0
};

/** \brief Dragonfly index data.
 *
 * Format:
 * GL_LINES
 */
CONST uint8_t dragonfly_index[] =
{
	0, 1,
	1, 2,
	2, 3,
	1, 4,
	0, 5,
	5, 6,
	0, 7,
	7, 8,
	0, 9,
	9, 10,
	0, 11,
	11, 12,
	0, 13,
	13, 14,
	0, 15,
	15, 16,
	0, 17,
	17, 18
};

//######################################
// Generic drawing #####################
//######################################

/** \brief Interleaved array container.
 *
 * Should align correctly.
 */
typedef struct iarray_struct
{
	/** TexCoord (T2F). */
	float ts;

	/** TexCoord (T2F). */
	float tt;

	float tu;
	float tv;

	/** Color (C4F). */
	float cr;

	/** Color (C4F). */
	float cg;

	/** Color (C4F). */
	float cb;

	/** Color (C4F). */
	float ca;

	/** Normal (N3F). */
	float nx;

	/** Normal (N3F). */
	float ny;

	/** Normal (N3F). */
	float nz;

	/* Vertex (V3F). */
	float px;

	/* Vertex (V3F). */
	float py;

	/* Vertex (V3F). */
	float pz;

	float pw;
} iarray_t;

/** Drawing array size (should be enough). */
#define DRAW_ARRAY_SIZE 65536

/** \brief Drawing array block (should be enough). */
VARIABLE iarray_t draw_array[DRAW_ARRAY_SIZE];

/** \brief Face normal array. */
VARIABLE float draw_normal[DRAW_ARRAY_SIZE];

/** \brief Index array for draws. */
VARIABLE int draw_index[DRAW_ARRAY_SIZE * 4];

/** Model movement general multiplier. */
VARIABLE float model_movement_general_mul = 1.0f;

/** \brief Fill the iarray_t contents as uniform replacement.
 *
 * Extra parameters are mapped as follows:
 *
 * gl_Color.xyz Camera position.
 * gl_Color.a Milliseconds since intro start.
 * gl_Normal.x Extra parameter 1 (depends on the shader).
 * gl_Normal.y Extra parameter 2 (depends on the shader).
 * gl_Normal.z Camera flash multiplier.
 *
 * @param dst Destination array element.
 */
FUNCTION void uniform_fill(iarray_t *dst)
{
	for(int ii = 0; (ii < 7); ++ii)
	{
		((float*)dst)[ii + 4] = uniform[ii];
	}
}

/** \brief Issue one grid draw mapping command.
 *
 * @param icnt I parameter count.
 * @param jcnt J parameter count.
 * @param k K parameter.
 * @param l L parameter.
 */
FUNCTION void draw_mapped(int icnt, int jcnt, float k, float l)
{
	iarray_t *aiter = draw_array;
	int *iiter = draw_index;

	for(int ii = 0; (ii < icnt); ++ii)
	{
		for(int jj = 0; (jj < jcnt); ++jj)
		{
			int idx = (ii * jcnt) + jj;

			uniform_fill(aiter);

			aiter->ts = aiter->tt = 0.5f;
			aiter->px = (float)ii;
			aiter->py = (float)jj;
			aiter->pz = k;
			aiter->pw = l;
			++aiter;

			if((ii < icnt - 1) && (jj < jcnt - 1))
			{
				iiter[0] = idx;
				iiter[1] = idx + 1;
				iiter[2] = idx + jcnt + 1;
				iiter[3] = idx + jcnt;
				iiter += 4;
			}
		}
	}

	dlDrawElements(GL_QUADS, (icnt - 1) * (jcnt - 1) * 4, GL_UNSIGNED_INT, draw_index);
}

/** \brief Draw a line graphics model.
 *
 * @param y Height position of object.
 */
FUNCTION void draw_dragonfly(float y, float currtick)
{
	float *fptr = draw_normal;
	currtick *= 0.001f; // SECONDS.

	for(int ii = 0; (ii < (int)(sizeof(dragonfly_data))); ii += 5)
	{
		const int8_t *ppnt = dragonfly_data + ii;

		fptr[2] = (float)(ppnt[2]);
		fptr[1] = (float)(ppnt[1]) + y +
			dsinf((float)(ppnt[3]) * currtick +
					(float)(ppnt[4]) * (M_PI / 64.0f)) *
			model_movement_general_mul;
		fptr[0] = (float)(ppnt[0]) +
			dsinf(currtick + fptr[1] * 0.5f) *
			model_movement_general_mul;

		fptr += 3;
	}

	iarray_t *aiter = draw_array;
	int *iiter = draw_index,
			dcnt = 0;

	for(unsigned ii = 0; (ii < sizeof(dragonfly_index)); ii += 2)
	{
		for(unsigned jj = 0; (jj < 384); ++jj)
		{
			int idx1 = dragonfly_index[ii],
					idx2 = dragonfly_index[ii + 1];
			float *fl1 = draw_normal + (idx1 * 3),
						*fl2 = draw_normal + (idx2 * 3);

			uniform_fill(aiter);

			float lenmul = frand(1.0f);
			aiter->px = (fl2[0] - fl1[0]) * lenmul + fl1[0] + frand2(1.0f);
			aiter->py = (fl2[1] - fl1[1]) * lenmul + fl1[1] + frand2(1.0f);
			aiter->pz = (fl2[2] - fl1[2]) * lenmul + fl1[2] + frand2(1.0f);
			aiter->pw = currtick + frand(1.0f);
			*(iiter) = dcnt;

			++aiter;
			++iiter;
			++dcnt;
		}
	}

	dlDrawElements(GL_POINTS, dcnt, GL_UNSIGNED_INT, draw_index);
}

//######################################
// Specific drawing ####################
//######################################

/** Number of leaf loops. */
#define LEAF_LOOPS 5

/** Thickness of one leaf. */
#define LEAF_THICKNESS 2.5f

/** Leaf detail level. */
#define LEAF_DETAIL_U 64

/** Leaf detail level. */
#define LEAF_DETAIL_V 8

/** Height of one leaf. */
#define LEAF_HEIGHT 128.0f

/** Starting y position of a leaf. */
#define LEAF_BOTTOM -64.0f

/** Height randomization of a leaf. */
#define LEAF_RANDOM 64.0f

/** Width of one leaf. */
#define LEAF_WIDTH 6.0f

/** Leaf span. */
#define LEAF_SPAN 300.0f

/** Leaf frequency. */
#define LEAF_FREQ 0.001f

/** Water detail level. */
#define WATER_DETAIL 128

/** Wave span. */
#define WAVE_SPAN (1.0f / LEAF_SPAN * 20.0f)

/** Water frequency. */
#define WAVE_FREQ 0.004f

//######################################
// Recording ###########################
//######################################

#if defined(HAVE_LIBPNG)
#include "record.h"

/** Recording flag. */
VARIABLE uint8_t flag_record = 0;
#endif

//######################################
// Draw loop ###########################
//######################################

/** Camera plane span. */
#define CAMERA_SPAN 64.0f

/** Camera move speed. */
#define CAMERA_MOVE 0.004f

/** Dragonfly starting depth. */
#define DRAGONFLY_START -60.0f

/** Dragonfly ending height. */
#define DRAGONFLY_END 32.0f

/** Fire event start. */
#define FIRE_EVENT_START 53000

/** Fire event end. */
#define FIRE_EVENT_END (CAMERA_BEAT * 8)

CONST uint16_t camera_switch_table[] =
{
	1,
	10798,
	18496,
	27926,
	30200,
	35000,
	39500,
	46601,
	51309,
	56500,
	65535
};

/** \brief Perform drawing.
 *
 * @param currtick Milliseconds since program start.
 */
FUNCTION void draw(int currtick)
{
	float ftick = (float)currtick;

	dlMatrixMode(GL_MODELVIEW);
	dlLoadIdentity();
	dlClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	int cslot = 0;
	unsigned csrand;
	for(;;++cslot)
	{
		csrand = camera_switch_table[cslot];
		if(currtick < camera_switch_table[cslot + 1])
		{
			break;
		}
	}
	int cleft = currtick - (int)csrand;
	float fcleft = (float)cleft;
	dsrand(csrand);
	uniform[0] = frand2(CAMERA_SPAN) + frand2(CAMERA_MOVE) * fcleft;
	uniform[1] = frand2(CAMERA_SPAN) + frand2(CAMERA_MOVE) * fcleft;
	uniform[2] = frand2(CAMERA_SPAN) + frand2(CAMERA_MOVE) * fcleft;
	if(cslot > 8)
	{
		uniform[0] = -16.0f;
		uniform[1] = 90.0f;
		uniform[2] = -4.0f;
	}
	dluLookAt(uniform[0], uniform[1], uniform[2],
			0.0, frand(CAMERA_SPAN) + frand2(CAMERA_MOVE) + (((cslot == 0) || (cslot == 2) || (cslot == 3) || (cslot == 5)) ? -16.0f : 0.0f), 0.0,
			0.0, 1.0, 0.0);
	//dluLookAt(0.0, 30.0, 50.0, 0.0, 25.0, 0.0, 0.0, 1.0, 0.0);
	uniform[3] = ftick;
	// Beat color.
	uniform[5] = uniform[6] = 0.0f;
	if(cleft < CAMERA_FLASH)
	{
		uniform[6] = 1.0f - fcleft / (float)CAMERA_FLASH;
	}
	if(currtick < CAMERA_FADE)
	{
		uniform[6] = fcleft / (float)(CAMERA_FADE) - 1.0f;
	}
	if(currtick > FALL_START - CAMERA_FADE)
	{
		uniform[6] = (float)(currtick - (FALL_START - CAMERA_FADE)) / (float)CAMERA_FADE;
	}
	if(currtick > FALL_START)
	{
		uniform[5] = (float)(currtick - FALL_START) / (float)(FALL_END - FALL_START);
		uniform[6] = 1.0f - uniform[5];
	}
	if(currtick > FALL_END)
	{
		uniform[6] = 1.0f - (float)(currtick - FALL_END) / (float)((INTRO_LENGTH - FALL_END) / 2);
	}

	dsrand(8);
	dlUseProgram(program_leaf);
	dlEnable(GL_CULL_FACE);
	uniform[4] = 1.0f;
	for(int ii = 0; (ii < 256); ++ii)
	{
		float x = frand2(LEAF_SPAN),
					z = frand2(LEAF_SPAN);
		draw_mapped(LEAF_DETAIL_U, LEAF_DETAIL_V, x, z);
	}
	uniform[4] = 0.1f;
	draw_mapped(LEAF_DETAIL_U, LEAF_DETAIL_V, -3.0f, 0.0f);
	dlDisable(GL_CULL_FACE);

	dlDepthMask(GL_FALSE);

	dlUseProgram(program_water);
	draw_mapped(WATER_DETAIL, WATER_DETAIL, 0.0f, 0.0f);

	dlBlendFunc(GL_SRC_ALPHA, GL_ONE);

	dlUseProgram(program_fire);
	uniform[4] = (currtick > FALL_START - CAMERA_FADE) ? uniform[6] : 0.0f;
	draw_dragonfly(DRAGONFLY_START + ftick * ((DRAGONFLY_END - DRAGONFLY_START) / FIRE_EVENT_START),
			ftick);

	dlBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	dlDepthMask(GL_TRUE);
}

//######################################
// Main ################################
//######################################

#if defined(__APPLE__)
#define MAINPROG SDL_main
#else
#define MAINPROG main
#endif

#if defined(USE_LD)
/** \brief GNU main function.
 *
 * @param argc Not used.
 * @param argv Not used.
 */
int MAINPROG(int argc, char *argv[])
{
#else
/** Required ELF symbol. */
void *environ;
/** Required ELF symbol. */
void *__progname;
/** \brief Object file starting point.
 */
void _start()
{
#endif

#if !defined(WIN32)
#if defined(USE_LD)
	// This is a replica of the loader to determine function addresses.
	{
		char *iter = (char*)dnload_symbols;
		do {
			for(;;)
			{
				void **olditer = (void**)iter;
				while(*(iter++));
				if(!*(iter))
				{
					break;
				}
				printf("dlfcn symbol offset %s: %i\n", iter, (int)(((char*)olditer) - dnload_symbols));
			}
		} while(*(++iter));
	}
#else
	// Load some symbols.
	{
		char *iter = (char*)dnload_symbols;
		do {
			void *handle = dlopen(iter, RTLD_LAZY);

			for(;;)
			{
				void **olditer = (void**)iter;

				while(*(iter++));
				if(!*(iter))
				{
					break;
				}

				*olditer = dlsym(handle, iter);			
			}
		} while(*(++iter));
	}
#endif
#endif

	// Graphics init.
	DDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER);
	{
#if defined(USE_LD)
#if defined(SCREEN_F)
		uint32_t sdl_flags = SDL_OPENGL | SDL_FULLSCREEN;
#else
		uint32_t sdl_flags = SDL_OPENGL;
#endif
		for(int ii = 1; (ii < argc); ++ii)
		{
			const char *cmp = (const char*)argv[ii];

			if((strcmp("-f", cmp) == 0) || (strcmp("--fullscreen", cmp) == 0))
			{
				sdl_flags |= SDL_FULLSCREEN;
			}
			else if((strcmp("-w", cmp) == 0) || (strcmp("--windowed", cmp) == 0))
			{
				sdl_flags &= ~SDL_FULLSCREEN;
			}
			else if((strcmp("-r", cmp) == 0) || (strcmp("--record", cmp) == 0))
			{
				flag_record = 1;
			}
			else
			{
				printf("Unknown flag: %s\n", cmp);
				puts("Valid command line arguments:\n"
						"  -f, --fullscreen    Fullscreen mode.\n"
						"  -w, --windowed      Windowed mode.\n"
						"  -r, --record        Do not run in realtime, produce png/wav output.");
				return -1;
			}
		}
#else
#if defined(SCREEN_F)
#define sdl_flags (SDL_OPENGL | SDL_FULLSCREEN)
#else
#define sdl_flags SDL_OPENGL;
#endif
#endif
		DDL_SetVideoMode(SCREEN_W, SCREEN_H, SCREEN_B, sdl_flags);
	}
	DDL_ShowCursor(0);

	// Drawing rules.
	//dlEnable(GL_AUTO_NORMAL);
  dlEnable(GL_BLEND);
	dlEnable(GL_DEPTH_TEST);
	dlEnable(GL_POINT_SPRITE);
	dlEnable(GL_VERTEX_PROGRAM_POINT_SIZE);
#if defined(USE_LD)
	//dlEnable(GL_TEXTURE_2D);
	//GLuint tex;
	//glGenTextures(1, &tex);
	//glBindTexture(GL_TEXTURE_2D, tex);
	//gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, 16, 16, GL_RGBA,
	//		GL_FLOAT, draw_array);
#endif
	dlTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);
	dlMatrixMode(GL_PROJECTION);
	dlLoadIdentity();
	dluPerspective(1.0 / SCREEN_A * 90.0, SCREEN_A, 1.0, LEAF_SPAN);

	// Draw data.
#if defined(USE_LD)
	program_leaf = program_create(shader_func_leaf);
	program_water = program_create(shader_func_water);
	program_fire = program_create(shader_func_fire);
#else
	program_create(shader_func_leaf);
	program_create(shader_func_water);
	program_create(shader_func_fire);
#endif
	dlInterleavedArrays(GL_T4F_C4F_N3F_V4F, 0, draw_array);

	// Prepare audio.
	writeaudio();
#if defined(INTRO_START)
	audio_position += (uint64_t)INTRO_START * 44100 / 1000;
#endif
	DDL_OpenAudio(&audio_spec, NULL);
#if !defined(MANUAL_ADVANCE)
#if defined(USE_LD)
	DDL_PauseAudio((int)flag_record);
#else
	DDL_PauseAudio(0);
#endif
#endif

	//SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 0);
	uint32_t starttick = DDL_GetTicks();	

#if defined(USE_LD)
	if(flag_record)
	{
		FILE *fptr = fopen("swamp_fly_audio.raw", "w");
		fwrite(audio_buffer,
				sizeof(int16_t),
				(unsigned)(44100.0 * (double)INTRO_LENGTH / 1000.0),
				fptr);
		fclose(fptr);
		int frame_idx = 0;
		for(;;)
		{
			int ms = lrintf((float)frame_idx / 60.0f * 1000.0f);
			if(ms > INTRO_LENGTH)
			{
				break;
			}
			SDL_Event event;
			if(DDL_PollEvent(&event) && (event.type == SDL_KEYDOWN) && (event.key.keysym.sym == SDLK_ESCAPE))
			{
				break;
			}
			draw(ms);
			char filename[] = "swamp_fly_0000.png";
			sprintf(filename, "swamp_fly_%04u.png", frame_idx);
			write_opengl_viewport(filename);
			DDL_GL_SwapBuffers();
			++frame_idx;
		}
		DDL_Quit();
		return 0;
	}
#endif

	for(;;)
	{
		// Perform drawing.
#if defined(MANUAL_ADVANCE)
		static uint32_t currtick = 0,
										currtickmul = 1;
		draw(currtick);
#else
		int currtick = (int)(DDL_GetTicks() - starttick);
#if defined(INTRO_START)
		currtick += INTRO_START;
#endif
#endif

		// Synchro.
#if defined(USE_LD) && !defined(MANUAL_ADVANCE)
		static int tick_cumulative = 0;

		if(tick_cumulative > currtick)
		{
			SDL_Delay((unsigned)(tick_cumulative - currtick));
		}
		else if((currtick > FRAME_TICKS) &&
				(tick_cumulative < currtick - FRAME_TICKS))
		{
			printf("\rframeskip: %u     ", currtick - tick_cumulative);
			fflush(stdout);
			while(tick_cumulative < currtick - FRAME_TICKS)
			{
				tick_cumulative += FRAME_TICKS;
			}
		}
#endif

		// Draw process.
		if(currtick >= INTRO_LENGTH)
		{
			break;
		}
		draw(currtick);
		DDL_GL_SwapBuffers();

#if defined(USE_LD) && !defined(MANUAL_ADVANCE)
		tick_cumulative += FRAME_TICKS;
#endif

		// Abort on any keypress.
		SDL_Event event;
		if(DDL_PollEvent(&event) && (event.type == SDL_KEYDOWN))
		{
#if defined(USE_LD)
			switch(event.key.keysym.sym)
			{
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
				case SDLK_SPACE:
					printf("Ticks: %u\n", currtick);
				default:
					break;
			}
			if(event.key.keysym.sym == SDLK_ESCAPE)
			{
				break;
			}
#else
			break;
#endif
		}
	}

	DDL_Quit();
#if !defined(USE_LD)
	asm("movl $1,%eax\nxor %ebx,%ebx\nint $128\n");
#else
	return 0;
#endif
}

//######################################
// End #################################
//######################################

