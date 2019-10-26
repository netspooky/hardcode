/** \file
 * For details, please see README.
 */

//######################################
// Config ##############################
//######################################

/** \cond */
#if defined(WIN32)
#define USE_LD
#define IFUNCTION static
#define IVARIABLE static
#define ICONST static const
#elif defined(USE_LD)
#define IFUNCTION static
#define IVARIABLE static
#define ICONST static const
#else
#define IFUNCTION static
#define IVARIABLE static
#define ICONST static
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

/** Framebuffer width */
#define FBO_TEX_W 448

/** Framebuffer height */
#define FBO_TEX_H 252

/** Noise volume height. */
#define VOLUME_W 128

/** Noise volume height. */
#define VOLUME_H 128

/** Noise volume height. */
#define VOLUME_D 128
/** Required for perspective. */
#define SCREEN_A ((double)SCREEN_W / (double)SCREEN_H)

/** Screen bytes per pixel. */
#define SCREEN_B 32

/** Fullscreen on or off. */
#define SCREEN_F 1

/** Delay between frames (milliseconds). */
#define FRAME_TICKS 16

// Only check for debugging if we're in GNU LD mode.
#if defined(USE_LD)
/** Manual advance in the intro timeline. */
#undef DEV_MODE
#endif

/** Intro length (seconds). */
#define INTRO_LENGTH (131 * 2 * 44100)

/** Intro start debug (if applicable) */
#define INTRO_START 0

//######################################
// Include #############################
//######################################

// Math defines for MSVC.
#define _USE_MATH_DEFINES
#include <float.h>
#include <math.h>

#if defined(WIN32)
#include <stdint.h> // requires a fairly new MSVS
#elif defined(HAVE_INTTYPES_H)
#include <inttypes.h>
#elif defined(HAVE_STDINT_H)
#include <stdint.h>
#else
#include <inttypes.h>
#endif

// Needed for function prototypes.
#if !defined(GL_GLEXT_PROTOTYPES)
#define GL_GLEXT_PROTOTYPES 1
#endif

#if defined(WIN32)
#include "windows.h"
#include "GL/glew.h"
#include "GL/gl.h"
#include "GL/glu.h"
//#include "GL/glext.h"
//#include "GL/wglext.h"
#include "SDL.h"
//#include "SDL_opengl.h"
#elif defined(__APPLE__)
#include <SDL/SDL.h>
#include <SDL/SDL_opengl.h>
#else
#include "SDL.h"
#include "GL/gl.h"
#include "GL/glext.h"
#endif

#if defined(USE_LD) && defined(HAVE_LIBPNG)
#include "record.h"
#endif

//######################################
// Dynamic loader ######################
//######################################

#if !defined(WIN32)
#include "dlfcn.h"
#endif

/** Dynamically loaded symbols in one segment. */
IVARIABLE char dnload_symbols[] =
"libc.so\0"
"rand\0"
"srand\0\0"
"libGL.so\0"
"glAttachShader\0"
"glBindFramebufferEXT\0"
"glBindTexture\0"
"glCompileShader\0"
"glCreateProgram\0"
"glCreateShader\0"
"glDisable\0"
"glEnable\0"
"glFramebufferTexture2DEXT\0"
"glGenFramebuffersEXT\0"
"glGenTextures\0"
"glLinkProgram\0"
"glRectf\0"
"glShaderSource\0"
"glTexImage2D\0"
"glTexImage3D\0"
"glTexParameteri\0"
"glUniform3fv\0"
"glUseProgram\0"
"glViewport\0\0"
"libSDL.so\0"
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

#define dlActiveTexture glActiveTexture
#define dlAttachShader glAttachShader
#define dlBindFramebufferEXT glBindFramebufferEXT
#define dlBindTexture glBindTexture
#define dlCompileShader glCompileShader
#define dlCreateProgram glCreateProgram
#define dlCreateShader glCreateShader
#define dlDisable glDisable
#define dlEnable glEnable
#define dlFramebufferTexture2DEXT glFramebufferTexture2DEXT
#define dlGenFramebuffersEXT glGenFramebuffersEXT
#define dlGenTextures glGenTextures
#define dlLinkProgram glLinkProgram
#define dlRectf glRectf
#define dlShaderSource glShaderSource
#define dlTexImage2D glTexImage2D
#define dlTexImage3D glTexImage3D
#define dlTexParameteri glTexParameteri
#define dlUseProgram glUseProgram
#define dlUniform1i glUniform1i
#define dlUniform3fv glUniform3fv
#define dlViewport glViewport

#define dluLookAt gluLookAt
#define dluPerspective gluPerspective

#define DDL_GL_SwapBuffers SDL_GL_SwapBuffers
#define DDL_Init SDL_Init
#define DDL_OpenAudio SDL_OpenAudio
#define DDL_PauseAudio SDL_PauseAudio
#define DDL_PollEvent SDL_PollEvent
#define DDL_SetVideoMode SDL_SetVideoMode
#define DDL_ShowCursor SDL_ShowCursor
#define DDL_Quit SDL_Quit

/** \brief Print function addresses (for debug)
 *
 * @param iter Function names.
 */
IFUNCTION void print_function_offsets(char *iter)
{
	char *start = iter;
	// This is a replica of the loader to determine function addresses.
	do {
		for(;;)
		{
			char *olditer = iter;

			while(*(iter++));
			if(!*(iter))
			{
				break;
			}

			printf("dlfcn symbol offset %s: %i\n", iter, (int)(olditer - start));
		}
	} while(*(++iter));
}
#else

/* To understand this, you need to realize that all function names are
 * actually at least 4 bytes long. Thus, we can store them in the exact same
 * location wherefrom the pointer is loaded from, thus saving space. */

#define dnload_pointer(offset) (*((void**)(dnload_symbols + offset)))

#define drand ((int (*)(void))dnload_pointer(0))
#define dsrand ((void (*)(unsigned int))dnload_pointer(8))

#define dlAttachShader ((void (*)(GLuint, GLuint))dnload_pointer(20))
#define dlBindFramebufferEXT ((void (*)(GLenum target, GLuint id))dnload_pointer(29))
#define dlBindTexture ((void (*)(GLenum, GLuint))dnload_pointer(44))
#define dlCompileShader ((void (*)(GLuint))dnload_pointer(65))
#define dlCreateProgram ((GLuint (*)(void))dnload_pointer(79))
#define dlCreateShader ((GLuint (*)(GLenum))dnload_pointer(95))
#define dlDisable ((void (*)(GLenum))dnload_pointer(111))
#define dlEnable ((void (*)(GLenum))dnload_pointer(126))
#define dlFramebufferTexture2DEXT ((void (*)(GLenum, GLenum, GLenum, GLuint, GLint))dnload_pointer(136))
#define dlGenFramebuffersEXT ((void (*)(GLsizei, GLuint*))dnload_pointer(145))
#define dlGenTextures ((void (*)(GLsizei, GLuint*))dnload_pointer(171))
#define dlLinkProgram ((void (*)(GLuint))dnload_pointer(192))
#define dlRectf ((void (*)(GLfloat, GLfloat, GLfloat, GLfloat))dnload_pointer(206))
#define dlShaderSource ((void (*)(GLuint, GLsizei, const GLchar**, const GLint*))dnload_pointer(220))
#define dlTexImage2D ((void (*)(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, const GLvoid*))dnload_pointer(228))
#define dlTexImage3D ((void (*)(GLenum, GLint, GLint, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum, const GLvoid*))dnload_pointer(243))
#define dlTexParameteri ((void (*)(GLenum, GLenum, GLint))dnload_pointer(256))
#define dlUniform3fv ((void (*)(GLint, GLsizei, GLfloat*))dnload_pointer(269))
#define dlUseProgram ((void (*)(GLuint))dnload_pointer(285))
#define dlViewport ((void (*)(GLint, GLint, GLsizei, GLsizei))dnload_pointer(298))

#define DDL_GL_SwapBuffers ((void (*)(void))dnload_pointer(323))
#define DDL_Init ((int (*)(Uint32))dnload_pointer(333))
#define DDL_OpenAudio ((int (*)(SDL_AudioSpec*, SDL_AudioSpec*))dnload_pointer(352))
#define DDL_PauseAudio ((void (*)(int))dnload_pointer(361))
#define DDL_PollEvent ((int (*)(SDL_Event*))dnload_pointer(375))
#define DDL_Quit ((void (*)(void))dnload_pointer(390))
#define DDL_SetVideoMode ((SDL_Surface* (*)(int, int, int, Uint32))dnload_pointer(404))
#define DDL_ShowCursor ((int (*)(int))dnload_pointer(413))

#endif
/** \endcond */

//######################################
// rand() ##############################
//######################################

#if defined(USE_LD)

#define drand bsd_rand
#define dsrand bsd_srand

#define BSD_RAND_MAX 0x7FFFFFFF

/** BSD random var. */
IVARIABLE unsigned long bsd_rand_next = 1;

/** \brief BSD rand() implementation.
 *
 * Random generator from BSD. If not using BSD, have to compile it in.
 * If not doing the rel thingy, why not compile it in.
 */
IFUNCTION int bsd_rand(void)
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
	return ((bsd_rand_next = x) % ((uint32_t)BSD_RAND_MAX + 1));
}

IFUNCTION void bsd_srand(uint32_t seed)
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
IFUNCTION float rand16(void)
{
	return (float)(drand() & 0xFFFF);
}

/** Random number from 0 to this.
 *
 * @param op Max. number.
 * @return Random number [0, op]
 */
IFUNCTION float frand(float op)
{
	return rand16() / 65535.0f * op;
}

/** Random number from -num to num.
 *
 * @param op Cap (in one direction)
 * @return Random number [-op, op]
 */
IFUNCTION float frand2(float op)
{
	return (rand16() / 32768) * op - op;
}

/** Random ara inside which to throw the camera. */
#define RANDOM_AREA 8.0f

/** Feed an position uniform based on pseudo-random seeds and interpolation state.
 *
 * @param uniform Uniform id.
 * @param seed1 First seed.
 * @param seed2 Second seed.
 */
IFUNCTION void feed_pseudo_position_uniform(GLint uniform, float interpolate,
		uint8_t seed1, uint8_t seed2)
{
	float pos[3];
	int ii;

	dsrand((unsigned int)seed1);

	pos[0] = frand2(RANDOM_AREA);
	pos[1] = frand2(RANDOM_AREA);
	pos[2] = frand2(RANDOM_AREA);

	dsrand((unsigned int)seed2);

	pos[0] = (frand2(RANDOM_AREA) - pos[0]) * interpolate + pos[0];
	pos[1] = (frand2(RANDOM_AREA) - pos[1]) * interpolate + pos[1];
	pos[2] = (frand2(RANDOM_AREA) - pos[2]) * interpolate + pos[2];

	dlUniform3fv(uniform, 1, pos);

	//printf("%1.2f, %1.2f, %1.2f\n",
	//		interpolate * (second[0] - first[0]) + first[0],
	//		interpolate * (second[1] - first[1]) + first[1],
	//		interpolate * (second[2] - first[2]) + first[2]);
}

IFUNCTION void feed_pseudo_color_uniform(GLint uniform,	uint8_t seed1)
{
	float pos[3];

	dsrand((unsigned int)seed1);

	pos[0] = frand(1.0f);
	pos[1] = frand(1.0f);
	pos[2] = frand(1.0f);
	
	dlUniform3fv(uniform, 1, pos);

	//printf("%1.2f, %1.2f, %1.2f\n",
	//		interpolate * (second[0] - first[0]) + first[0],
	//		interpolate * (second[1] - first[1]) + first[1],
	//		interpolate * (second[2] - first[2]) + first[2]);
}

//######################################
// Music ###############################
//######################################

/** Audio buffer for output. */
IVARIABLE int16_t audio_buffer[INTRO_LENGTH + 5 * 44100];

/** Current audio position. */
IVARIABLE int16_t *audio_position = audio_buffer
#if (INTRO_START > 0)
+ INTRO_START * 44100 * 2
#endif
;

#if defined USE_LD
/** Recording flag. */
IVARIABLE uint8_t flag_record = 0;
#endif

/** \brief Update audio stream.
 *
 * This function cannot have extra attributes due to needing to comply with
 * the system ABI.
 *
 * @param userdata Not used.
 * @param stream Target stream.
 * @param len Number of bytes to write.
 */
static void audio_callback(void *userdata, Uint8 *stream, int len)
{
	(void)userdata;

	do {
		*((int16_t*)stream) = *audio_position;
		stream += 2;
		++audio_position;
	} while(len -= 2);
}

//#ifndef WIN32
#include "syn_defs.h"
#include "synth2.c"
//#endif

/** SDL audio specification struct. */
IVARIABLE SDL_AudioSpec audio_spec =
{
	44100,
	AUDIO_S16SYS,
	2,
	0,
#if defined(USE_LD)
	4096,
#else
	256, // as low as we can go without coughing
#endif
	0,
	0,
	audio_callback,
	NULL
};

//######################################
// Usage ###############################
//######################################

#if defined(USE_LD)
IFUNCTION uint32_t usage(int argc, char **argv)
{
	int ii;
#if SCREEN_F
	uint32_t ret = SDL_OPENGL | SDL_FULLSCREEN;
#else
	uint32_t ret = SDL_OPENGL;
#endif
	for(ii = 1; (ii < argc); ++ii)
	{
		const char *cmp = (const char*)argv[ii];

		if((strcmp("-f", cmp) == 0) || (strcmp("--fullscreen", cmp) == 0))
		{
			ret |= SDL_FULLSCREEN;
		}
		else if((strcmp("-n", cmp) == 0) || (strcmp("--no-fullscreen", cmp) == 0))
		{
			ret ^= SDL_FULLSCREEN;
		}
		else if((strcmp("-w", cmp) == 0) || (strcmp("--windowed", cmp) == 0))
		{
			ret &= ~SDL_FULLSCREEN;
		}
#if defined(HAVE_LIBPNG)
		else if((strcmp("-r", cmp) == 0) || (strcmp("--record", cmp) == 0))
		{
			flag_record = 1;
		}
#endif
		else
		{
			printf("Unknown flag: %s\n", cmp);
			puts("Valid command line arguments:\n"
					"  -f, --fullscreen    Fullscreen mode.\n"
					"  -w, --windowed      Windowed mode."
#if defined(HAVE_LIBPNG)
					"\n"
					"  -r, --record        Do not run in realtime, produce png/wav output."
#endif
					"");
			exit(1);
		}
	}
	return ret;
}
#endif

//######################################
// Shaders #############################
//######################################

/** Shader main begin. */
ICONST char shader_main[] = ""
"void main()"
"{"
"";

/** \brief Normal vertex shader variables.
 */
ICONST char shader_vars[] = ""
"#define S sin\n"
"#define T cos\n"
"#define U vec2\n"
"#define V vec3\n"
"#define W vec4\n"
"#define u uniform\n" 
"#define v varying\n"
"#define g gl_Vertex\n"
"#define n normalize\n"
"#define t texture3D\n"
"u V A;" // position || noise
"u V B;" // lookat || shape_ambient
"u V C;" // up || shape diffuse
"u V D;" // bailout || background
"u V E;" // shape parameter
"u sampler3D F;" // volume
"u sampler2D G;" // texture
"v V H;" // starting position
"v V I;" // target direction
"v V J;" // light position
"v V K;" // texture coordinate
"";

/** Vertex shader end. */
ICONST char shader_vertex[] = ""
"V z=n(B);"
"V o=n(C);"
"V c=cross(z,o);"
"o=cross(c,z);"
"H=A;"
"I=n(g.x*c+g.y*o*0.625+z)*.01;"
"J=n(V(-6,4,-3));"
"K=(g.xyz+1)/2;"
"gl_Position=W(g.xy,0,1);"
"}"
"";

/** Bulb fragment function. */
ICONST char fragment_function_bulb[] = ""
"float f(V x)"
"{"
"V c=x+E;"
"float r,d,z,o,m=8,b=D.x,i=0;"
"for(i=0;i<2;i+=1)"
"{"
"r=sqrt(dot(x,x));"
"d=atan(sqrt(x.x*x.x+x.y*x.y),x.z);"
"z=atan(x.y,x.x);"
"x=pow(r,m)*V(T(d*m)*T(z*m),S(d*m)*S(z*m),T(d*m))+c;"
"o=dot(x,x);"
"if(o>b)break;"
"}"
"return o-b;"
"}"
"";

/** Growing Julia test. */
ICONST char fragment_function_julia[] = ""
"float f(V x)"
"{"
"V c=V(.9*T(.7*x.y),.9*T(x.y/2),.9*T(1.1*x.y))+E;"
"x=V(x.x+.75*T(.37*x.y)+.75*S(.49*x.y),0,x.z+.73*S(.7*x.y)+.75*T(1.01*x.y));"
"float r,d,z,o,m=5,b=D.x,i=0;"
"for(i=0;i<4;i+=1)"
"{"
"r=sqrt(dot(x,x));"
"d=atan(sqrt(dot(x.xy,x.xy)),x.z);"
"z=atan(x.y,x.x);"
"x=pow(r,m)*V(S(d*m)*T(z*m),S(d*m)*S(z*m),T(d*m))+c;"
"o=dot(x,x);"
"if(o>b)break;"
"}"
"return o-b;"
"}"
"";

#if 0
/** Spider fragment function. */
ICONST char fragment_function_spider[] = ""
"float f(V x)"
"{"
"float o,b = 4.0;"
"float zr,zc,cr,cc;"
"V c,z;"
"c=x + E.zxy;"
"z=x + E.yzx;"
"c.z=0;"
"z.z=0;"
"z.x=z.x+x.z;"
"for(int i=0; i<8; i++)"
"{"
"zr=z.x*z.x-z.y*z.y;"
"zc=2*z.x*z.y;"
"z.x = zr + c.x;"
"z.y = zc + c.y;"
"c.x = z.x/2 + c.x;"
"c.y = z.y/2 + c.y;"
"o = sqrt(dot(z,z));"
"if(o>b) break;"
"}"
"return o - b;"
"}"
"";
#endif

/** Normal fragment shader body. */
ICONST char fragment_body[] = ""
"V a=H,b,y;"
"float d=1,c=0,o=0,i=0,z=1e-2;"
#if defined(USE_LD)
"bool m=f(a)<0,r,x=false;"
#else
"bool m=f(a)<0,r,x=0;"
#endif
"for(;(i<555);i+=1)"
"{"
"d=i/555;"
"b=a+I;"
"if(c==0)"
"{"
"if(clamp(.0625*t(F,.25*b+E).x+.125*t(F,.125*b+E).x+.30*t(F,.0625*b+E).x+.30*t(F,.03125*b+E).x,0,1)>D.y)"
"{"
"c=1-d;"
"break;"
"}"
"}"
"r=f(b)<0;"
"if(m!=r)"
"{"
#if defined(USE_LD)
"x=true;"
#else
"x=1;"
#endif
"for(i=0;i<5;i+=1)"
"{"
"y=(a+b)/2;"
"o=f(y);"
"r=o<0;"
"if(m==r)"
"{"
"a=y;"
"}"
"else"
"{"
"b=y;"
"}"
"}"
"z=clamp(dot(n(V(f(y+V(z,0,0)),f(y+V(0,z,0)),f(y+V(0,0,z)))-o),J),0,1);"
"o=d;"
"break;"
"}"
"a=b;"
"}"
"if(!x)"
"{"
"z=0;"
"o=0;"
"}"
"gl_FragColor= W(z,o,c,d);"
"}"
"";

/** Noise shader. */
ICONST char shader_noise[] = ""
"float f(U s)"
"{"
"return fract(S(dot(s,U(12,78)))*A.z);"
"}"
"";

/** FBO fragment shader. */
ICONST char fragment_body_fbo[] = ""
"U z=U(f(K.xy+A.x));"
"U o=(z-.5)/U(128,64)*A.y;"
"W y=texture2D(G,K.xy+o);"
"V c=H+I*555*y.a;"
"c =D;" // TODO: something nicer.
"V d=mix(c,V(0,0,0),y.z);"
"if(y.y>0)"
"{"
"d=mix(mix(B,C,y.x),c,y.y);"
"}"
"gl_FragColor=W(d,1);"
"}"
"";

#if defined(USE_LD)
/* GLSL identifiers. */
IVARIABLE GLuint program_bulb;
IVARIABLE GLuint program_julia;
IVARIABLE GLuint program_fbo;
IVARIABLE GLint uniform_pos;
IVARIABLE GLint uniform_look;
IVARIABLE GLint uniform_up;
IVARIABLE GLint uniform_bailout;
IVARIABLE GLint uniform_fractal;
IVARIABLE GLint uniform_noise;
IVARIABLE GLint uniform_shape_ambient;
IVARIABLE GLint uniform_shape_diffuse;
IVARIABLE GLint uniform_background;
IVARIABLE GLint uniform_texture;
IVARIABLE GLint uniform_volume;
IVARIABLE GLuint framebuffer;
IVARIABLE GLuint texture;
IVARIABLE GLuint volume;
IVARIABLE GLuint current_program;
#else
/* Pre-computed GLSL identifiers. */
#define program_bulb 1
#define program_julia 5
#define program_fbo 7
#define uniform_pos 0
#define uniform_look 1
#define uniform_up 2
#define uniform_bailout 3
#define uniform_fractal 4
#define uniform_volume 5
#define uniform_noise 0
#define uniform_shape_ambient 1
#define uniform_shape_diffuse 2
#define uniform_background 3
#define uniform_texture 4
#define framebuffer 1
#define texture 1
#define volume 2
#endif

/** Huge blob of data for the volume. */
IVARIABLE int8_t volume_data[VOLUME_W * VOLUME_H * VOLUME_D];

#if defined(USE_LD)

/** \brief Prints an indent.
 *
 * @param indent Number of characters to draw.
 */
static void print_indent(unsigned indent)
{
	unsigned ii;
	for(ii = 0; (ii < indent); ++ii)
	{
		putc(' ', stdout);
	}
}

/** \brief Print a shader and make the output neater.
 *
 * @param shader Shader to print.
 */
static unsigned print_shader(const char *shader, unsigned indent)
{
	char *iter = (char*)shader;
	char cc = *iter;

	while(cc)
	{		
		switch(cc)
		{
			case ';':
				{
					puts(";");
					print_indent(indent);
				}
				break;

			case '{':
				putc('\n', stdout);
				print_indent(indent);
				puts("{");
				indent += 2;
				print_indent(indent);
				break;

			case '}':
				putc('\r', stdout);
				indent -= 2;
				print_indent(indent);
				puts("}");
				print_indent(indent);
				break;

			default:
				putc(cc, stdout);
				break;
		}

		++iter;
		cc = *iter;
	}

	return indent;
}			

#endif

/** \brief Create a shader.
 *
 * @param sh Shader content.
 * @param st Shader type.
 * @return Compiled shader.
 */
IFUNCTION unsigned shader_create(const char *pt1, const char* pt2,
		const char* pt3, const char *pt4, GLenum st)
{
	const char *shader_parts[] = { pt1, pt2, pt3, pt4 };
	unsigned ret = dlCreateShader(st), ii, indent;

	dlShaderSource(ret, 4, (const char**)shader_parts, NULL);
	dlCompileShader(ret);
#if defined(USE_LD)
	{
		char slog[4096];
		GLsizei len;
		GLint status;
		for(ii = 0, indent = 0; (ii < 4); ++ii)
		{
			indent = print_shader(shader_parts[ii], indent);
		}

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
IFUNCTION
#if defined(USE_LD)
unsigned
#else
void
#endif
program_create(const char *vpt1, const char *vpt2, const char *fpt1, const char *fpt2, const char* fpt3)
{
	unsigned ret = dlCreateProgram();

	dlAttachShader(ret, shader_create(vpt1, shader_main, vpt2, "", GL_VERTEX_SHADER));
	dlAttachShader(ret, shader_create(fpt1, fpt2, shader_main, fpt3, GL_FRAGMENT_SHADER));
	dlLinkProgram(ret);
#if defined(USE_LD)
	{
		char slog[4096];
		GLsizei len;
		GLint status;
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
		printf("GLSL program with compiles to: %u\n", ret);
		return ret;
	}
#endif
}

//######################################
// Draw ################################
//######################################

#if defined(USE_LD)
/** Uniform values for control. */
float uni[] =
{
	0.0f, 0.0f, -5.0f,
	0.0f, 0.0f, 1.0f,
	0.0f, 1.0f, 0.0f,
	0.0f, 0.0f, 0.0f,
	0.0f
};

/** Snap position. */
int closest_pos_x = 0;
int closest_pos_y = 0;
int closest_pos_z = 0;
/** Snap lookat. */
uint8_t closest_look = 0;
/** Snap up. */
uint8_t closest_up = 0;
/** Use closest look. */
uint8_t examine_closest = 0;
#endif

/** Animate world. */
#define FLAG_ANIMATE_EVERYTHING 1
/** Fractal inactive. */
#define FLAG_FRACTAL_INACTIVE 2
/** Fractal fade-in (if inactive). */
#define FLAG_FRACTAL_FADE_IN 4
/** Smog inactive. */
#define FLAG_SMOG_INACTIVE 8
/** Fade smog out. */
#define FLAG_SMOG_FADE_OUT 16
/** Animation goes from zero point. */
#define FLAG_NEUTRAL_ANIMATE 32
/** Break fractals - use a higher animator. */
#define FLAG_BREAK 64

/** Control structure.
 *
 * Every 16 values of this structure are one scene. They go as:
 *
 * -- once --
 * shape ambient color (uniform_shape_ambient)
 * shape diffuse color (uniform_shape_diffuse)
 * background color (uniform_background)
 * scene
 * length
 * flags
 * -- twice --
 * x, y, z (uniform_pos)
 * lookat (uniform_look)
 * up (uniform_up)
 * ----
 *
 * There is no continuous paths. Every camera run is two sets or 10 bytes.
 * However, after 10 bytes the scene lenght and scene are mentioned.
 *
 * Length is audio samples multiplied by beat. Scene itself is just the index
 * of the GLSL program. It also determines raytrace step and step count.
 *
 * Beat is 3950 samples or 15800 bytes.
 *
 * Color reminder:
 * 9 - dark amber
 * 3 - light amber
 * 180 - deep blue
 * 191 - gray-white
 * 193 - something
 * 197 - dark yellow
 * 200 - dark red
 * 206 - deep yellow
 * 209 - crimson
 * 227 - dark blue
 */
ICONST uint8_t control[] =
{
	112, 1, 9, 3, 180, FLAG_FRACTAL_INACTIVE, // intro
	71, 13, 174, 116, 204,
	92, 241, 13, 146, 246,

	78, 1, 9, 3, 180, FLAG_FRACTAL_INACTIVE + FLAG_SMOG_INACTIVE + FLAG_SMOG_FADE_OUT, // close on ball
	250, 0, 157, 37, 217,
	25, 14, 217, 71, 26,

	66, 1, 9, 3, 180, FLAG_FRACTAL_INACTIVE + FLAG_FRACTAL_FADE_IN + FLAG_SMOG_INACTIVE, // explosion
	25, 14, 217, 71, 26,
	25, 14, 217, 71, 26,

	132, 1, 200, 206, 193, FLAG_ANIMATE_EVERYTHING + FLAG_BREAK, // broken bulb 1
	226, 253, 6, 11, 29,
	10, 28, 242, 87, 194,

	124, 4, 191, 206, 209, FLAG_ANIMATE_EVERYTHING + FLAG_SMOG_INACTIVE + FLAG_SMOG_FADE_OUT, // julia morph
	248, 12, 242, 220, 3,
	248, 12, 242, 220, 3,

	156, 4, 191, 206, 209, FLAG_ANIMATE_EVERYTHING + FLAG_SMOG_INACTIVE + FLAG_SMOG_FADE_OUT, // julia run 1
	11, 187, 237, 41, 11,
	250, 30, 203, 189, 241,

	132, 1, 200, 206, 227, FLAG_ANIMATE_EVERYTHING, // bulb volcano
	234, 243, 9, 230, 173,
	10, 29, 18, 126, 202,

	8, 1, 200, 206, 215, FLAG_ANIMATE_EVERYTHING + FLAG_NEUTRAL_ANIMATE, // inside the bulb
	2, 252, 6, 47, 178,
	2, 252, 6, 47, 178,

	25, 1, 200, 206, 227, FLAG_ANIMATE_EVERYTHING, // bulb volcano
	10, 29, 18, 126, 202,
	10, 29, 18, 126, 202,

	131, 1, 200, 206, 215, FLAG_ANIMATE_EVERYTHING + FLAG_NEUTRAL_ANIMATE, // inside the bulb
	2, 252, 6, 47, 178,
	2, 253, 251, 117, 230,

	254, 4, 191, 206, 209, FLAG_ANIMATE_EVERYTHING + FLAG_NEUTRAL_ANIMATE + FLAG_FRACTAL_INACTIVE + FLAG_FRACTAL_FADE_IN, // julia fade in
	236, 47, 230, 201, 54,
	7, 110, 241, 87, 171,

	127, 1, 200, 206, 227, FLAG_ANIMATE_EVERYTHING | FLAG_NEUTRAL_ANIMATE | FLAG_BREAK | FLAG_FRACTAL_FADE_IN, // bulb in full glory
	13, 22, 250, 87, 68,
	233, 22, 11, 187, 118,

	129, 1, 200, 227, 227, FLAG_FRACTAL_INACTIVE | FLAG_FRACTAL_FADE_IN, // passing
	255, 0, 190, 37, 217,
	80, 0, 231, 63, 217,

};

/** Length of one visual beat. */
#define BEAT_LENGTH (15800 * 8)

/** Visual beat tracker.
 *
 * MSB is true for distortion, false for noise.
 *
 * Rest is time till next beat.
 *
 * All beats take the same amount of time. New beat can be launched before the
 * previous one has ended.
 */
ICONST uint8_t beat_control[] =
{
	72,
	16,
	31,
	112, // noisee!
	8,
	8,
	8,
	8,
	21, // bulb pyörimis biittii
	16,
	16,
	16,
	16,
	16,
	16,
	79, // julia morf biittii
	16,
	16,
	16,
	16,
	16,
	16,
	16,
	16,
	16,
	16,
	16,
	16,
	16,
	140, // härö
	34, // inside biittii
	96,
	32,
	24, // uliuliuli
	24,
	16,
	24,
	8,
	62,
	64,
	32,
	32,
	32,
	32,
	32,
	255 // safety value.
};

/** \brief Draw the world.
 *
 * @param ms Milliseconds.
 */
IFUNCTION void draw(int ticks)
{
	uint8_t *iter = (uint8_t*)control;
	float interpolation;
	int beat_ticks = ticks;
	uint8_t flags;

#if defined(DEV_MODE)
	dlUseProgram(current_program);
#else
	for(;;)
	{
		int val = (*iter) * 15800;
		ticks -= val;
		if(ticks < 0)
		{
			interpolation = 1.0f + ((float)ticks / val);
			break;
		}
		iter += 16;
	}
	flags = iter[5];

#if defined(USE_LD)
	if(iter[1] == 1)
	{
		dlUseProgram(program_bulb);
	}
	else
	{
		dlUseProgram(program_julia);
	}
#else
	dlUseProgram(iter[1]);
#endif
#endif

	dlViewport(0, 0, FBO_TEX_W, FBO_TEX_H);
	dlBindFramebufferEXT(GL_FRAMEBUFFER_EXT, framebuffer);
	
#if defined(DEV_MODE)
	if(examine_closest != 0)
	{
		glUniform3f(uniform_pos,
				(closest_pos_x / 128.0f) * RANDOM_AREA,
				(closest_pos_y / 128.0f) * RANDOM_AREA,
				(closest_pos_z / 128.0f) * RANDOM_AREA);
		feed_pseudo_position_uniform(uniform_look, 0.0f, closest_look, closest_look);
		feed_pseudo_position_uniform(uniform_up, 0.0f, closest_up, closest_up);
	}
	else
	{
		dlUniform3fv(uniform_pos, 1, uni + 0);
		dlUniform3fv(uniform_look, 1, uni + 3);
		dlUniform3fv(uniform_up, 1, uni + 6);
	}
	dlUniform3fv(uniform_fractal, 1, uni + 9);
	//dlUniform3f(uniform_bailout, cos(ms * 0.001) * 5.0f, 1.0f, -0.5f);
#else
	{
		float pos[3];
		int ii;

		for(ii = 0; (ii < 3); ++ii)
		{
			float to = ((int8_t*)iter)[11 + ii];
			float from = ((int8_t*)iter)[6 + ii];
			pos[ii] = ((to - from) * interpolation + from) / 128.0f * RANDOM_AREA;
		}
		dlUniform3fv(uniform_pos, 1, pos);
		feed_pseudo_position_uniform(uniform_look, interpolation, iter[9], iter[14]);
		feed_pseudo_position_uniform(uniform_up, interpolation, iter[10], iter[15]);
	}
	{
		float pos[3] = { 0.0f, 0.0f, 0.0f }; // Magic number mini-party.
		float mul = 1.0f;
		float animmul = 0.000001f;

		if(flags & FLAG_BREAK)
		{
			if(flags & FLAG_FRACTAL_FADE_IN)
			{
				animmul = 0.000004f;
				mul = 0.4f;
			}
			else
			{
				pos[0] += 0.4f;
				pos[1] -= 0.4f;
				pos[2] += 0.4f;
			}
		}
		if(flags & FLAG_NEUTRAL_ANIMATE)
		{
			mul *= 0.4f;
		}
		if(flags & FLAG_ANIMATE_EVERYTHING)
		{
			pos[0] += dsinf(-ticks * animmul + 0.4f) * mul; 
			pos[1] += dsinf(ticks * animmul) * mul;
			pos[2] += dsinf(-ticks * animmul + 0.4f) * mul;
		}
		dlUniform3fv(uniform_fractal, 1, pos);
	}
#endif
	{
		float pos[3] = { 4.0f, 0.6f, 0.0f }; // Magic number superparty!

		if(flags & FLAG_FRACTAL_INACTIVE)
		{
			pos[0] *= 0.0625f + ((flags & FLAG_FRACTAL_FADE_IN) ? (interpolation * 0.4f) : 0.0f);
		}
		if(flags & FLAG_SMOG_INACTIVE)
		{
			pos[1] += (flags & FLAG_SMOG_FADE_OUT) ? (interpolation * 0.1f) : 0.12f;
		}
		dlUniform3fv(uniform_bailout, 1, pos);
	}

#if defined(USE_LD)
	dlActiveTexture(GL_TEXTURE0);
	dlBindTexture(GL_TEXTURE_2D, 0);
	dlUniform1i(uniform_volume, 0);
	dlBindTexture(GL_TEXTURE_3D, volume);
#endif

	// I first did this with GL_TRIANGLE_STRIP, did not remember rect
	dlRectf(-1.0f, -1.0f, 1.0f, 1.0f);

	dlUseProgram(program_fbo);

	dlViewport(0, 0, SCREEN_W, SCREEN_H);
	dlBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

#if defined(DEV_MODE)
	if(uni[12] != 0.0f)
	{
		float fms = ticks * 0.000001f;
  	glUniform3f(uniform_noise, fms, dsinf(1.4* fms), uni[12]);
	}
	else
	{
  	glUniform3f(uniform_noise, 0.0f, 0.0f, 0.0f);
	}
	feed_pseudo_color_uniform(uniform_shape_ambient, 209); // 209
	feed_pseudo_color_uniform(uniform_shape_diffuse, 227);
	feed_pseudo_color_uniform(uniform_background, 227);
#else
	{
		uint8_t *beat = (uint8_t*)beat_control;
		float beat_strength = 0.0f;
		float pos[3];

		for(;;)
		{
			beat_ticks -= *beat * 15800;
			if(beat_ticks < 0)
			{
				if(beat_ticks > -BEAT_LENGTH)
				{
#ifdef WIN32
					beat_strength = max((float)beat_ticks / -BEAT_LENGTH, 0.0f);
#else
					beat_strength = fmaxf((float)beat_ticks / -BEAT_LENGTH, 0.0f);
#endif

				}
				break;
			}
			++beat;
		}

		//float fms = ticks * 0.000001f;
		//glUniform3f(uniform_noise, fms, dsinf(1.4f* fms), 0.4f);

		dsrand((unsigned int)beat);

		pos[0] = beat_strength;
		pos[1] = dsinf(beat_strength) * 12.0f;
		pos[2] = frand(8.0);

		dlUniform3fv(uniform_noise, 1, pos);
	}
	feed_pseudo_color_uniform(uniform_shape_ambient, iter[2]);
	feed_pseudo_color_uniform(uniform_shape_diffuse, iter[3]);
	feed_pseudo_color_uniform(uniform_background, iter[4]);
#endif

#if defined(USE_LD)
	dlActiveTexture(GL_TEXTURE0);
	dlBindTexture(GL_TEXTURE_3D, 0);
	dlUniform1i(uniform_texture, 0);
	dlBindTexture(GL_TEXTURE_2D, texture);
#endif

	dlRectf(-1.0f, -1.0f, 1.0f, 1.0f);
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
	GLenum err;
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
#if defined(USE_LD)
	uint32_t starttick;
#endif
	SDL_Event event;

#if !defined(USE_LD)
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

	// Graphics init.
	DDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
	{
#if defined(USE_LD)
		uint32_t sdl_flags = usage(argc, argv);
#else
#if SCREEN_F
#define sdl_flags (SDL_OPENGL | SDL_FULLSCREEN)
#else
#define sdl_flags SDL_OPENGL
#endif
#endif
		DDL_SetVideoMode(SCREEN_W, SCREEN_H, SCREEN_B, sdl_flags);
	}
	DDL_ShowCursor(0);
#if defined(WIN32)
	if(glewInit() != GLEW_OK)
	{
		return 1;
	}
#endif

#if defined(USE_LD)
	print_function_offsets(dnload_symbols);
#endif

	// Drawing rules.
	dlEnable(GL_BLEND);
	dlEnable(GL_TEXTURE_2D);
	dlDisable(GL_DEPTH_TEST);
	dlDisable(GL_CULL_FACE);

	// Draw data.
#if defined(USE_LD)
	program_bulb = program_create(shader_vars, shader_vertex, shader_vars, fragment_function_bulb, fragment_body);
	program_julia = program_create(shader_vars, shader_vertex, shader_vars, fragment_function_julia, fragment_body);
	program_fbo = program_create(shader_vars, shader_vertex, shader_vars, shader_noise, fragment_body_fbo);
	uniform_pos = glGetUniformLocation(program_bulb, "A");
	uniform_look = glGetUniformLocation(program_bulb, "B");
	uniform_up = glGetUniformLocation(program_bulb, "C");
	uniform_bailout = glGetUniformLocation(program_bulb, "D");
	uniform_fractal = glGetUniformLocation(program_bulb, "E");
	uniform_volume = glGetUniformLocation(program_bulb, "F");
  uniform_noise = glGetUniformLocation(program_fbo, "A");
  uniform_shape_ambient = glGetUniformLocation(program_fbo, "B");
  uniform_shape_diffuse = glGetUniformLocation(program_fbo, "C");
  uniform_background = glGetUniformLocation(program_fbo, "D");
	uniform_texture = glGetUniformLocation(program_fbo, "G");
	current_program = program_bulb;

	dlGenTextures(1, &texture);
	dlBindTexture(GL_TEXTURE_2D, texture);
	glTexImage2D(GL_TEXTURE_2D, 0, 4, FBO_TEX_W, FBO_TEX_H, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);

	{
		int ii;

		for(ii = 0; (ii < VOLUME_W * VOLUME_H * VOLUME_D); ++ii)
		{
			volume_data[ii] = drand();
		}

		dlGenTextures(1, &volume);
		dlBindTexture(GL_TEXTURE_3D, volume);
		dlTexImage3D(GL_TEXTURE_3D, 0, 1, VOLUME_W, VOLUME_H, VOLUME_D, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, volume_data);
		//glGenerateMipmap(GL_TEXTURE_3D);
	}

	dlTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	dlTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	//dlTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	//dlTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	dlGenFramebuffersEXT(1, &framebuffer);
	dlBindFramebufferEXT(GL_FRAMEBUFFER_EXT, framebuffer);
	dlFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, texture, 0);
	{
		GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
		if(GL_FRAMEBUFFER_COMPLETE_EXT != status)
		{
			printf("FRAMEBUFFER ERROR (%x)", status);
		}
	}

	printf("Programs: %d (normal), %d (fbo)\nPos: %i\nFw: %i\nUp: %i\nBailout: %i\nFractal: %i\nNoise: %i\nShape ambient: %i\nShape diffuse: %i\nBackground: %i\nTexture: %i (texid: %i, fboid: %i)\nVolume: %i (texid: %i)\n",
			program_bulb, program_fbo, uniform_pos, uniform_look, uniform_up, uniform_bailout, uniform_fractal, uniform_noise, uniform_shape_ambient, uniform_shape_diffuse, uniform_background, uniform_texture, texture, framebuffer, uniform_volume, volume);
	err = glGetError();
	if(GL_INVALID_VALUE == err)
	{
		puts("GL_INVALID_VALUE");
	}
	else if(GL_INVALID_OPERATION == err)
	{
		puts("GL_INVALID_OPERATION");
	}
#else
	{
		GLuint useless;

		program_create(shader_vars, shader_vertex, shader_vars, fragment_function_bulb, fragment_body);
		program_create(shader_vars, shader_vertex, shader_vars, fragment_function_julia, fragment_body);
		program_create(shader_vars, shader_vertex, shader_vars, shader_noise, fragment_body_fbo);

		dlGenTextures(1, &useless);
		dlBindTexture(GL_TEXTURE_2D, texture);
		dlTexImage2D(GL_TEXTURE_2D, 0, 4, FBO_TEX_W, FBO_TEX_H, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);

		for(useless = 0; (useless < VOLUME_W * VOLUME_H * VOLUME_D); ++useless)
		{
			volume_data[useless] = drand();
		}

		dlGenTextures(1, &useless);
		dlBindTexture(GL_TEXTURE_3D, volume);
		dlTexImage3D(GL_TEXTURE_3D, 0, 1, VOLUME_W, VOLUME_H, VOLUME_D, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, volume_data);

		dlTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		dlTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

		dlGenFramebuffersEXT(1, &useless);
		dlBindFramebufferEXT(GL_FRAMEBUFFER_EXT, framebuffer);
		dlFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, texture, 0);
	}
#endif

	// Prepare audio.
	writeaudio();
	DDL_OpenAudio(&audio_spec, NULL);
#if !defined(DEV_MODE)
#if defined(USE_LD) && defined(HAVE_LIBPNG)
	DDL_PauseAudio((int)flag_record);
#else
	DDL_PauseAudio(0);
#endif
#endif

#if defined(USE_LD) && defined(HAVE_LIBPNG)
	if(flag_record)
	{
		//SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 0);
		int frame_idx = 0;
		char filename[] = "dirty_garden_0000.png";
		FILE *fptr = fopen("dirty_garden_audio.raw", "w");
		fwrite(audio_buffer,
				sizeof(int16_t),
				(unsigned)(44100.0 * (double)INTRO_LENGTH / 1000.0),
				fptr);
		fclose(fptr);
		for(;;)
		{
			int ticks = (int)((float)frame_idx / 15.0f * 44100.0f + 0.5f);
			if(ticks > INTRO_LENGTH)
			{
				break;
			}
			if(DDL_PollEvent(&event) && (event.type == SDL_KEYDOWN) && (event.key.keysym.sym == SDLK_ESCAPE))
			{
				break;
			}
			draw(ticks);
			sprintf(filename, "dirty_garden_%04u.png", frame_idx);
			write_opengl_viewport(filename);
			DDL_GL_SwapBuffers();
			++frame_idx;
		}
		DDL_Quit();
		return 0;
	}
#endif

#if defined(USE_LD)
	starttick = SDL_GetTicks();	
#endif

	for(;;)
	{
#if defined(DEV_MODE)
		int currtick = (int)(SDL_GetTicks() - starttick) + INTRO_START;
		static int tick_cumulative = 0;

		if(tick_cumulative > currtick)
		{
			SDL_Delay(1);
		}
		else
		{
			static int turn_x = 0;
			static int turn_y = 0;
			static int turn_z = 0;
			static int move_x = 0;
			static int move_y = 0;
			static int move_z = 0;
			static int animate = 0;
			static float animation_state = 0.0f;
			unsigned frameskip = 0;

			tick_cumulative += FRAME_TICKS;

			while(tick_cumulative <= currtick)
			{
				tick_cumulative += FRAME_TICKS;
				++frameskip;
			}

			if((frameskip > 0) && (tick_cumulative > 1000))
			{
				printf("\rframeskip %d", frameskip);
        fflush(stdout);
			}

			draw((uint8_t*)audio_position - (uint8_t*)audio_buffer);
			DDL_GL_SwapBuffers();

			// Abort on any keypress.
			if(DDL_PollEvent(&event))
			{
				int key_multiplier = (event.type == SDL_KEYDOWN) ? 1 : -1;
				switch(event.key.keysym.sym)
				{
					case SDLK_TAB:
						if(key_multiplier > 0)
						{
							if(current_program == program_bulb)
							{
								current_program = program_julia;
							}
							else
							{
								current_program = program_bulb;
							}
						}
						break;

					case SDLK_KP1:
						turn_y += key_multiplier;
						break;

					case SDLK_KP3:
						turn_y -= key_multiplier;
						break;

					case SDLK_KP4:
						turn_z += key_multiplier;
						break;

					case SDLK_KP6:
						turn_z -= key_multiplier;
						break;

					case SDLK_KP2:
						turn_x += key_multiplier;
						break;

					case SDLK_KP5:
						turn_x -= key_multiplier;
						break;

					case SDLK_a:
						move_x -= key_multiplier;
						break;

					case SDLK_d:
						move_x += key_multiplier;
						break;

					case SDLK_q:
						move_y -= key_multiplier;
						break;

					case SDLK_e:
						move_y += key_multiplier;
						break;

					case SDLK_w:
						move_z += key_multiplier;
						break;

					case SDLK_s:
						move_z -= key_multiplier;
						break;

					case SDLK_c:
						{
							if(key_multiplier == 1)
							{
								float smallest_look = FLT_MAX;
								float smallest_up = FLT_MAX;
								int i;

								closest_pos_x = (int)(uni[0] / RANDOM_AREA * 128.0f);
								closest_pos_y = (int)(uni[1] / RANDOM_AREA * 128.0f);
								closest_pos_z = (int)(uni[2] / RANDOM_AREA * 128.0f);

								printf("Pos: %d,%d,%d -> %f, %f, %f\n",
										((uint8_t*)&closest_pos_x)[0],
										((uint8_t*)&closest_pos_y)[0],
										((uint8_t*)&closest_pos_z)[0],
										(float)closest_pos_x / 128.0 * RANDOM_AREA,
										(float)closest_pos_y / 128.0 * RANDOM_AREA,
										(float)closest_pos_z / 128.0 * RANDOM_AREA);

								for(i = 0; i < 255; ++i)
								{
									float look[3], up[3], len_look, len_up;

									dsrand((unsigned int)i);
									look[0] = frand2(RANDOM_AREA);
									look[1] = frand2(RANDOM_AREA);
									look[2] = frand2(RANDOM_AREA);

									//printf("Look(%i): %1.2f, %1.2f, %1.2f", i, look[0], look[1], look[2]);

									len_look = sqrtf(look[0] * look[0] + look[1] * look[1] + look[2] * look[2]);

									look[0] = look[0] / len_look - uni[3];
									look[1] = look[1] / len_look - uni[4];
									look[2] = look[2] / len_look - uni[5];

									len_look = sqrtf(look[0] * look[0] + look[1] * look[1] + look[2] * look[2]);
									//printf(" -> %1.2f\n", len_look);

									dsrand((unsigned int)i);
									up[0] = frand2(RANDOM_AREA);
									up[1] = frand2(RANDOM_AREA);
									up[2] = frand2(RANDOM_AREA);

									//printf("Up(%i): %1.2f, %1.2f, %1.2f", i, up[0], up[1], up[2]);

									len_up = sqrtf(up[0] * up[0] + up[1] * up[1] + up[2] * up[2]);

									up[0] = up[0] / len_up - uni[6];
									up[1] = up[1] / len_up - uni[7];
									up[2] = up[2] / len_up - uni[8];

									len_up = sqrtf(up[0] * up[0] + up[1] * up[1] + up[2] * up[2]);
									//printf(" -> %1.2f\n", len_up);

									if(len_look < smallest_look)
									{
										smallest_look = len_look;
										closest_look = (uint8_t)i;
									}
									if(len_up < smallest_up)
									{
										smallest_up = len_up;
										closest_up = (uint8_t)i;
									}
								}

								{
									float new_look[3];
									float look_len;

									dsrand((unsigned int)closest_look);

									new_look[0] = frand2(RANDOM_AREA);
									new_look[1] = frand2(RANDOM_AREA);
									new_look[2] = frand2(RANDOM_AREA);

									look_len = sqrtf(new_look[0] * new_look[0] + new_look[1] * new_look[1] + new_look[2] * new_look[2]);

									new_look[0] /= look_len;
									new_look[1] /= look_len;
									new_look[2] /= look_len;

									printf("\rLookat(%i): %1.2f, %1.2f, %1.2f -> %1.2f, %1.2f, %1.2f\n", closest_look,
											uni[3], uni[4], uni[5],
											new_look[0], new_look[1], new_look[2]);
								}

								{
									float new_up[3];
									float up_len;

									dsrand((unsigned int)closest_up);

									new_up[0] = frand2(RANDOM_AREA);
									new_up[1] = frand2(RANDOM_AREA);
									new_up[2] = frand2(RANDOM_AREA);

									up_len = sqrtf(new_up[0] * new_up[0] + new_up[1] * new_up[1] + new_up[2] * new_up[2]);

									new_up[0] /= up_len;
									new_up[1] /= up_len;
									new_up[2] /= up_len;

									printf("Up(%i): %1.2f, %1.2f, %1.2f -> %1.2f, %1.2f, %1.2f\n", closest_up,
											uni[6], uni[7], uni[8],
											new_up[0], new_up[1], new_up[2]);
								}								
							}
						}
						break;

					case SDLK_v:
						examine_closest = (key_multiplier > 0) ? 1 : 0;
						printf("examine %s\n", examine_closest ? "on" : "off");
						break;

					case SDLK_PAGEUP:
						animate -= key_multiplier;
						break;

					case SDLK_PAGEDOWN:
						animate += key_multiplier;
						break;

					case SDLK_INSERT:
						if(key_multiplier > 0)
						{
							uni[12] = frand(1.2f);
						}
						else
						{
							uni[12] = 0.0f;
						}
						break;

					case SDLK_DELETE:
						if(key_multiplier > 0)
						{
							uni[12] = 77.77f;
						}
						else
						{
							uni[12] = 0.0f;
						}
						break;

					default:
						break;
				}
			}
			if(SDLK_ESCAPE == event.key.keysym.sym)
			{
				break;
			}
			if(examine_closest == 0)
			{
				const float MOVEMENT = 0.0125f;
				const float TURN = 0.02f;
				const float ANIMATION = 0.009f;

				float pos_x = uni[0];
				float pos_y = uni[1];
				float pos_z = uni[2];

				float fw_x = uni[3];
				float fw_y = uni[4];
				float fw_z = uni[5];
				float fw_len = sqrtf(fw_x * fw_x + fw_y * fw_y + fw_z * fw_z);

				float rt_x = fw_y * uni[8] - fw_z * uni[7];
				float rt_y = fw_z * uni[6] - fw_x * uni[8];
				float rt_z = fw_x * uni[7] - fw_y * uni[6];
				float rt_len = sqrtf(rt_x * rt_x + rt_y * rt_y + rt_z * rt_z);

				float up_x = rt_y * fw_z - rt_z * fw_y;
				float up_y = rt_z * fw_x - rt_x * fw_z;
				float up_z = rt_x * fw_y - rt_y * fw_x;
				float up_len = sqrtf(up_x * up_x + up_y * up_y + up_z * up_z);

				float cos_x = cosf((float)turn_x * TURN);
				float sin_x = sinf((float)turn_x * TURN);
				float cos_y = cosf((float)turn_y * TURN);
				float sin_y = sinf((float)turn_y * TURN);
				float cos_z = cosf((float)turn_z * TURN);
				float sin_z = sinf((float)turn_z * TURN);

				float new_pos_x;
				float new_pos_y;
				float new_pos_z;

				float new_fw_x;
				float new_fw_y;
				float new_fw_z;

				float new_up_x;
				float new_up_y;
				float new_up_z;

				fw_x /= fw_len;
				fw_y /= fw_len;
				fw_z /= fw_len;
				rt_x /= rt_len;
				rt_y /= rt_len;
				rt_z /= rt_len;
				up_x /= up_len;
				up_y /= up_len;
				up_z /= up_len;

				//printf("fw: (%1.2f, %1.2f, %1.2f)", fw_x, fw_y, fw_z);
				//printf(" rt: (%1.2f, %1.2f, %1.2f)", rt_x, rt_y, rt_z);
				//printf(" up: (%1.2f, %1.2f, %1.2f)\n", up_x, up_y, up_z);

				new_fw_x = ((cos_x * fw_x + sin_x * up_x) + (cos_y * fw_x - sin_y * rt_x)) * 0.5f;
				new_fw_y = ((cos_x * fw_y + sin_x * up_y) + (cos_y * fw_y - sin_y * rt_y)) * 0.5f;
				new_fw_z = ((cos_x * fw_z + sin_x * up_z) + (cos_y * fw_z - sin_y * rt_z)) * 0.5f;

				new_up_x = ((cos_x * up_x - sin_x * fw_x) + (cos_z * up_x - sin_z * rt_x)) * 0.5f;
				new_up_y = ((cos_x * up_y - sin_x * fw_y) + (cos_z * up_y - sin_z * rt_y)) * 0.5f;
				new_up_z = ((cos_x * up_z - sin_x * fw_z) + (cos_z * up_z - sin_z * rt_z)) * 0.5f;

				new_pos_x = pos_x + ((float)move_x * rt_x + (float)move_y * up_x + (float)move_z * fw_x) * MOVEMENT;
				new_pos_y = pos_y + ((float)move_x * rt_y + (float)move_y * up_y + (float)move_z * fw_y) * MOVEMENT;
				new_pos_z = pos_z + ((float)move_x * rt_z + (float)move_y * up_z + (float)move_z * fw_z) * MOVEMENT;

				animation_state += (float)animate * ANIMATION;

				uni[0] = new_pos_x;
				uni[1] = new_pos_y;
				uni[2] = new_pos_z;
				uni[3] = new_fw_x;
				uni[4] = new_fw_y;
				uni[5] = new_fw_z;
				uni[6] = new_up_x;
				uni[7] = new_up_y;
				uni[8] = new_up_z;
				uni[9] = dsinf(animation_state * 1.27f) * 0.2f;
				uni[10] = dsinf(animation_state * 0.873f) * 0.2f;
				uni[11] = dsinf(animation_state * 0.981f) * cosf(animation_state * 1.19f) * 0.2;

				//printf("Pos: %1.2f, %1.2f, %1.2f\nLook: %1.2f, %1.2f, %1.2f\nUp: %1.2f, %1.2f, %1.2f\n",
				//		uni[0], uni[1], uni[2], uni[3], uni[4], uni[5], uni[6], uni[7], uni[8]);
			}
		}
#else
		int currtick;
#if defined(USE_LD)
		currtick = (int)(((SDL_GetTicks() - starttick) / 1000.0f + (float)INTRO_START) * 4.0f * 44100.0f + 0.5f);
#else
		currtick = (uint8_t*)audio_position - (uint8_t*)audio_buffer;
#endif
		if(currtick >= INTRO_LENGTH * 2)
		{
			break;
		}
		DDL_GL_SwapBuffers();
		draw(currtick);

		// Abort on any keypress.
		if(DDL_PollEvent(&event))
		{
			if(event.type == SDL_KEYDOWN)
			{
				break;
			}
		}
#endif
		//fprintf(stderr, "looping %d\n", currtick);
	}

	DDL_Quit();
#if !defined(USE_LD)
end:
	asm("movl $1,%eax\nxor %ebx,%ebx\nint $128\n");
#else
	return 0;
#endif
}

//######################################
// End #################################
//######################################
