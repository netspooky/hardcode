//#define DEV

#define RESX (640)
#define RESY (480)

#define PROG_WAVEMAP (0.f)
#define PROG_PLASMABLUR (1.f)
#define PROG_C64 (100.f)
#define PROG_CYBER (101.f)
#define PROG_ROTT (102.f)
#define PROG_3DDDA (103.f)
#define PROG_PBRENDER (104.f)
#define PROG_PBTRACE (105.f)
#define PROG_DIFFUSOR (106.f)

#define PROG_DIFFUTOWAVE (200.f)



#ifdef DEV
	#define FLAGS (SDL_OPENGL)
#else
	#define FLAGS (SDL_OPENGL  | SDL_FULLSCREEN)
#endif

#define GL_GLEXT_PROTOTYPES
#include <SDL/SDL.h>
//#include <SDL/SDL_opengl.h>
#include <GL/gl.h>
#include <GL/glext.h>

#include <pthread.h>
#include <unistd.h>
#include <sys/signal.h>
#include <math.h>

#include "castlefont.h"

/* include 4klang track header */
#include "4klang.inh"

/* synth defines & definitions */

//#include "shader.h"
#include "shadermini.h"

char gfxbuf[320*80];

#define SYNTH_CHANNELS 2 /* 4klang is stereo */
#define SYNTH_OUTPUT_SAMPLE_SIZE sizeof(short) /* we use 16 bit audio */
#define SYNTH_PLAY_BUFFER 4096

static SAMPLE_TYPE synthBuffer[MAX_SAMPLES * SYNTH_CHANNELS];

typedef void* (*threadfunc_t)(void*);

/* */
static volatile int64_t samplePosition = 0;

#ifdef INTEGER_16BIT
/* callback function for the music output - 16b audio - stereo */
static void synthCallback(void *udata, Uint8 *stream, int len) {
	/* the music is stereo - use 32 bit for left and right channel */
	static int32_t* sample = (int32_t*)synthBuffer;
	int32_t* ptr = (int32_t*) stream;

	udata += 0;
	int i;
	for (i = len / (SYNTH_OUTPUT_SAMPLE_SIZE * SYNTH_CHANNELS); i > 0 ; i--) {
		/* loop the track */
		if (samplePosition >= MAX_SAMPLES) {
			samplePosition = 0;
			sample = udata;
		}
		/* copy left and right channel at the same time */
		*ptr++ = *sample++;
		samplePosition++;
	}
}
#else
/* callback function for the music output - converts 32b float to 16b audio */
static void synthCallback(void *udata, Uint8 *stream, int len) {
	static float* sample = synthBuffer;
	int16_t* ptr = (int16_t*) stream;

	udata += 0;
	int i;
	for (i = len / (SYNTH_OUTPUT_SAMPLE_SIZE * SYNTH_CHANNELS); i > 0 ; i--) {
		/* loop the track */
		if (samplePosition >= MAX_SAMPLES) {
			samplePosition = 0;
			sample = udata;
		}
		*ptr++ = (int16_t)(INT16_MAX * *sample++);
		*ptr++ = (int16_t)(INT16_MAX * *sample++);
		samplePosition++;
	}
}
#endif

int main(int argc, char** argv) {
	/* -Wall -Werror -Wmercury */
	argc += 0; argv += 0;

	srand(666);

	/* initialize SDL */
	if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER)) {
		fprintf(stderr, "SDL_Init() failed\n");
		return EXIT_FAILURE;
	}
	SDL_GL_SetAttribute(SDL_GL_SWAP_CONTROL, 1);
	SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );

	SDL_SetVideoMode(RESX, RESY, 32, FLAGS);

	SDL_WM_SetCaption("Electro-Magnetic", NULL);

	SDL_ShowCursor(0);

	/* audio specification */
	SDL_AudioSpec audioSpec;
	audioSpec.freq = SAMPLE_RATE;
	audioSpec.format = AUDIO_S16SYS;
	audioSpec.channels = SYNTH_CHANNELS;
	audioSpec.silence = 0;
	audioSpec.samples = SYNTH_PLAY_BUFFER;
	audioSpec.size = 0;
	audioSpec.callback = synthCallback;
	audioSpec.userdata = synthBuffer;

	/* setup audio */
	if (SDL_OpenAudio(&audioSpec, NULL)) {
		fprintf(stderr, "SDL_OpenAudio() failed\n");
		SDL_Quit();
		return EXIT_FAILURE;
	}

	static pthread_t synthRenderThread;
		if (pthread_create(&synthRenderThread, NULL, (threadfunc_t)__4klang_render, synthBuffer)) {
			fprintf(stderr, "pthread_create() failed\n");
			SDL_Quit();
			return EXIT_FAILURE;
		}
		fprintf(stderr, "Using sound thread\n");

	PFNGLQUERYCOUNTERPROC glQueryCounter = (PFNGLQUERYCOUNTERPROC)SDL_GL_GetProcAddress((const GLubyte*)"glQueryCounter");
	PFNGLGETQUERYOBJECTI64VPROC glGetQueryObjecti64v = (PFNGLGETQUERYOBJECTI64VPROC)SDL_GL_GetProcAddress((const GLubyte*)"glGetQueryObjecti64v");


		int i, j;



	GLuint prog;
	prog = glCreateProgram();

	GLuint fs;

	fs = glCreateShader(GL_FRAGMENT_SHADER);
	static const char *fss[2] = {GLSLX_SOURCE_MAIN, NULL};

	glShaderSource(fs, 1, fss, NULL);
	glCompileShader(fs);

#ifdef DEV
GLint isCompiled = 0;
glGetShaderiv(fs, GL_COMPILE_STATUS, &isCompiled);
if(isCompiled == GL_FALSE)
{
	GLint maxLength = 0;
	glGetShaderiv(fs, GL_INFO_LOG_LENGTH, &maxLength);

	// The maxLength includes the NULL character
	char errorLog[maxLength];
	glGetShaderInfoLog(fs, maxLength, &maxLength, &errorLog[0]);

	printf("infolog: %s\n", errorLog);

	// Provide the infolog in whatever manor you deem best.
	// Exit with failure.
	glDeleteShader(fs); // Don't leak the shader.
	return 666;
}
#endif

	glAttachShader(prog, fs);

#if 0
	GLuint vs;
	vs = glCreateShader(GL_VERTEX_SHADER);
	char *vss[2] = { "void main() { gl_Position = ftransform(); }", NULL};
	glShaderSource(vs, 1, vss, NULL);
	glCompileShader(vs);
	glAttachShader(prog, vs);
#endif
	glLinkProgram(prog);
	glUseProgram(prog);


//	GLint unif_colo = glGetUniformLocation(prog, GLSLX_NAME_U_COLO);
	GLint unif_prog = glGetUniformLocation(prog, GLSLX_NAME_U_PROG);
	GLint unif_time = glGetUniformLocation(prog, GLSLX_NAME_U_TIME);
	GLint unif_lastwave = glGetUniformLocation(prog, GLSLX_NAME_U_LASTWAVE);
	GLint unif_noise = glGetUniformLocation(prog, GLSLX_NAME_U_NOISE);
	GLint unif_text = glGetUniformLocation(prog, GLSLX_NAME_U_TEXT);
	GLint unif_songpos = glGetUniformLocation(prog, GLSLX_NAME_U_SONGPOS);

#define FBOSIZEX (512)
#define FBOSIZEY (512)
#define NUM_FBO (4)
GLuint fbotex[NUM_FBO];
GLuint fboid[NUM_FBO];

	uint32_t texdata[FBOSIZEX * FBOSIZEY];
	for (i = 0; i < FBOSIZEX*FBOSIZEY; i++)
	{
		texdata[i] = rand();
	}


	glGenTextures(NUM_FBO, fbotex);
	glGenFramebuffers(NUM_FBO, fboid);
	for (i = 0; i < NUM_FBO; i++)
	{
		glBindTexture(GL_TEXTURE_2D, fbotex[i]);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

		GLint texmode = GL_RGBA32F;
		char *data = NULL;
		if (i == 2)
		{
			texmode = GL_RGBA; 
			data = texdata;
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		}
		else if (i == 3)
		{
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			glTexImage2D(GL_TEXTURE_2D, 0, texmode, FBOSIZEX, FBOSIZEY, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
		}

		if (i <= 2)
		{
			glTexImage2D(GL_TEXTURE_2D, 0, texmode, FBOSIZEX, FBOSIZEY, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		//glBindTexture(GL_TEXTURE_2D, 0);

		glBindFramebuffer(GL_FRAMEBUFFER, fboid[i]);

		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fbotex[i], 0);
#ifdef DEV
		GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		if(status != GL_FRAMEBUFFER_COMPLETE)
		{
			printf("fbo creation problem %i\n", i);
			return 667; 
		}
		#endif
		}
	}
	glBindFramebuffer(GL_FRAMEBUFFER, 0);


		glBindTexture(GL_TEXTURE_2D, fbotex[i]);


 
	glDisable(GL_DEPTH_TEST);



#ifdef DEV
// perf counting

const int qbuflen = 16;
GLuint queries[qbuflen];
glGenQueries(qbuflen, queries);
int ptr_w = 0;
int ptr_r = 0;
const int deltalen = 32;
float deltaavgarr[deltalen];
int deltaavgptr = 0;
#endif




	/* minimalistic mainloop - will exit on keydown event*/
	SDL_Event event;
	while (1) {
		while (SDL_PollEvent(&event)) {
//			if (event.type == SDL_KEYDOWN) goto _exit;
		}



#ifdef DEV
glQueryCounter(queries[ptr_w], GL_TIMESTAMP);
ptr_w = (ptr_w + 1) % qbuflen;

if (ptr_r != ptr_w)
{
		GLint done;
		glGetQueryObjectiv(queries[ptr_r], GL_QUERY_RESULT_AVAILABLE, &done);
		if (done == 1)
		{
				GLuint64 value;
				glGetQueryObjecti64v(queries[ptr_r], GL_QUERY_RESULT, &value);
				static float last_milval = 0.f;
				float milval = value / 1000000.f;
				float delta = milval - last_milval;
				//printf("r/w: %i/%i: %f (delta %f)\n", ptr_r, ptr_w, milval, delta);
				last_milval = milval;
				ptr_r = (ptr_r + 1) % qbuflen;

				deltaavgarr[deltaavgptr] = delta;
				deltaavgptr = (deltaavgptr + 1) % deltalen;
		}
}

float deltaavg = 0.f;
for (j = 0; j < deltalen; j++)
{
		deltaavg += deltaavgarr[j];
}
deltaavg /= (float)deltalen;
printf("deltaavg: %.2f, inv %.2f\n", deltaavg, 1000.f / deltaavg);

#endif

		float tim = SDL_GetTicks() / 1000.f;
		glUniform1f(unif_time, tim);


//		glUniform3f(unif_colo, 0.0f, 0.0f, 0.0f);
//		glRectf(-0.92f, -0.92f, 0.92f, 0.92f);

		static float bus = 1.f;
		bus = -bus;
		float bus2 = 0.2 + bus * 0.1f;
		static int cur_wave_fbo = 0;

		SDL_LockAudio();
		float songpos = (float)(samplePosition - SYNTH_PLAY_BUFFER / 4);
		if (songpos < 0.0f)
			songpos = 0.0f;
		songpos /= (float)(SAMPLES_PER_TICK * PATTERN_SIZE);
			SDL_UnlockAudio();

		if (songpos > 70.f)
			break;

		glUniform1f(unif_songpos, songpos);

		#ifdef DEV
		printf("time %f songpos %f, %lu\n", tim, songpos, samplePosition);
		#endif


		int clearcount;
		int mainprog;
		int clearprog;

#if 0
			mainprog = PROG_DIFFUSOR;
			clearprog = PROG_PLASMABLUR;
			clearcount = 0;
#else

		if (songpos < 4.0f)
		{
			mainprog = PROG_C64;
			clearprog = PROG_WAVEMAP;
			clearcount = 5;
		}
		else if (songpos < 8.0f)
		{
			mainprog = PROG_ROTT;
			clearcount = 0;
		}
		else if (songpos < 16.0f)
		{
			mainprog = PROG_3DDDA;
			clearcount = 0;
		}
		else if (songpos < 24.0f)
		{
			mainprog = PROG_C64;
			clearprog = PROG_WAVEMAP;
			clearcount = 5;
		}
		else if (songpos < 32.0f)
		{
			mainprog = PROG_CYBER;
			clearcount = 0;
		}
		else if (songpos < 36.0f)
		{
			mainprog = PROG_DIFFUSOR;
			clearcount = 0;
		}
		else if (songpos < 40.0f)
		{
			mainprog = PROG_DIFFUTOWAVE;
			clearprog = PROG_WAVEMAP;
			clearcount = 1;
		}
		else if (songpos < 40.0f) // NEVER??
		{
			mainprog = PROG_C64;
			clearprog = PROG_WAVEMAP;
			clearcount = 1;
		}
		else if (songpos < 48.0f)
		{
			mainprog = PROG_3DDDA;
			clearcount = 0;
		}
		else if (songpos < 56.0f)
		{
			mainprog = PROG_PBTRACE;
			clearprog = PROG_PLASMABLUR;
			clearcount = 1;
		}
		else if (songpos < 64.0f)
		{
			mainprog = PROG_PBTRACE;
			clearprog = PROG_PLASMABLUR;
			clearcount = 2;
		}

#endif

			glUniform1i(unif_noise, 1);
			glActiveTexture(GL_TEXTURE0 + 1);
			glBindTexture(GL_TEXTURE_2D, fbotex[2]);

			glUniform1i(unif_text, 3);
			glActiveTexture(GL_TEXTURE0 + 3);
			glBindTexture(GL_TEXTURE_2D, fbotex[3]);
			for (i = 0; i < 320*80; i++)
			{
				gfxbuf[i] = 0;
			}

			const char *fontmap = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,!?:'abcdefghijklmnopqrstuvwxyz      0123456789";

			const char *rivi1 = "...and man said,\n\'Let there be light\'";
			const char *rivi2 = "And he was blessed\nby light, heat,\nmagnetism, gravity,\n******and all the energies\nof the universe.";

			const char *rivi3 = "Electro\'Magnetic\n\n Program: Ash Checksum\n Song:    Van Damme";
			const char *rivi4 = "HACKERS\n  Computer Graphics\n  Research Division\n\nat\n    Simulaatio 2016";

			static float writerbegintime = 100000.0;
			static int ws = 0;
			static char *rivi = NULL;
			if (ws == 0 && songpos > 24.0f)
			{
				ws = 1;
				writerbegintime = 24.0f;
				rivi = rivi1;
			}
			if (ws == 1 && songpos > 25.8f)
			{
				ws = 2;
				writerbegintime = 25.8f;
				rivi = NULL;
			}
			else if (ws == 2 && songpos > 26.0f)
		{
				ws = 3;
				writerbegintime = 26.0f;
				rivi = rivi2;
			}
			else if (ws == 3 && songpos > 32.0f)
			{
				rivi = NULL;
				ws = 4;
			}
			else if (ws == 4 && songpos > 60.0f)
			{
				ws = 5;
				writerbegintime = 60.0f;
				rivi = rivi3;
			}
			else if (ws == 5 && songpos > 63.0f)
			{
				ws = 6;
				writerbegintime = 63.0f;
				rivi = rivi4;
			}

			#ifdef DEV
			printf("ws %i wbt %.2f rivi %p\n", ws, writerbegintime, rivi);
			#endif

			if ( rivi )
			{
				float sincebegin = (songpos - writerbegintime);
				int maxchar = sincebegin * 32.0f;
				int x,y;
				int wpx = 0, wpy = 0;
				for (i = 0; i < strlen(rivi); i++)
				{
					maxchar--;
					if (maxchar < 0)
						break;
					int curchar = rivi[i];
					int chi;

					if (curchar == '\n')
					{
						wpx = 0;
						wpy += 9;
						continue;
					}
					else if (curchar == '*')
						continue;

					for (chi = 0; chi < strlen(fontmap); chi++)
					{
						if (fontmap[chi] == curchar)
							break;
					}
					int charruoffs = chi;
					int rivioffs = (chi/16);
					charruoffs += rivioffs * 16 * 7;
					for (y = 0; y < 8; y++)
					{
						int line = castle_raw[charruoffs + y*16];
						for (x = 0; x < 8; x++)
						{
							gfxbuf[(wpx*9+x)+(y+wpy)*320] = ((line & 128)>>7) * 255;
							line <<= 1;
						}
					}

					wpx++;

				}
			}


			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 320, 80, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, gfxbuf);


		if (clearcount > 0)
		{
			glUniform1f(unif_prog, clearprog);

			glViewport(0,0,FBOSIZEX, FBOSIZEY);
		}




		for (j = 0; j < clearcount; j++)
		{
			//if (scrx == 0)
				cur_wave_fbo ^= 1;

			glUniform1i(unif_lastwave, 0);
			glActiveTexture(GL_TEXTURE0 + 0);
			glBindTexture(GL_TEXTURE_2D, fbotex[cur_wave_fbo^1]);


			glBindFramebuffer(GL_FRAMEBUFFER, fboid[cur_wave_fbo]);
			glUniform3f(glGetUniformLocation(prog, "colo"), bus2, bus2, bus2);
			glRectf(-1.f, -1.f, 1.f, 1.f);
		}

		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glViewport(0,0,RESX, RESY);
		glClearColor(0.2f, 0.1f, 0.4f, 1.0f);
		glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);

			glUniform1f(unif_prog, mainprog);

//			glRectf(-1.f, -1.f, 1.f, 1.f);
			glRectf(-1.f, -1.f, 1.f, 1.f);
//		glRectf(-0.9f, -0.9f, 0.9f, 0.9f);


		SDL_GL_SwapBuffers();
//		glFinish();
	/* start the music */

const Uint8* keystates = SDL_GetKeyState( NULL );

	if (keystates[SDLK_SPACE])
		SDL_PauseAudio(1);
	else
		SDL_PauseAudio(0);

	if (keystates[SDLK_q])
		goto _exit;

	}

		pthread_kill(synthRenderThread, SIGKILL);


_exit:
	SDL_Quit();
	return EXIT_SUCCESS;
}
