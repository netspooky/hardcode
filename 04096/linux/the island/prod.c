
/*
_____________________________________________________________________

			  	Flags
_____________________________________________________________________
*/

//#define TESTING

#ifndef CLEAN_BEHAVIOUR
	//#define CLEAN_BEHAVIOUR
#endif
//#define LIMIT_FRAMERATE
//#define FRAME_SLEEP  150

//#define GENERATE_NORMALS
//#define DROP_PATCH_EDGES

//#define CALL_SDL_INIT

#define SIMPLE_MUSIC

#define ENABLE_MUSIC

/*
_____________________________________________________________________

			  General constants
_____________________________________________________________________
*/

#define XRES 1024 //1280
#define YRES 768 //1024

#define OPTIMAL_FPS 20
#define OPTIMAL_DT (1.0/OPTIMAL_FPS)

//#define T_START 0 //50.0// time offset, handy
//#define SPEED_MULTIPLIER 4.0 // overall demo speed multiplier, handy

#define MAX_FFT_BLOCK (512*512)

#define ALLOC_SIZE (10*1024*1024)

#define AUDIO_SLOT_DURATION 0.10 // seconds
#define AUDIO_PATTERN_LENGTH 32 // slots
#define NUM_SOUND_SAMPLES 1
#define MASTER_VOLUME 1.0

#define REPEAT_EACH_PATTERN 3
#define SONG_LENGTH 13



#define AUDIO_CHANNELS NUM_SOUND_SAMPLES
#define AUDIO_FREQ 22050
#define AUDIO_BUF_SIZE 8192
#define AUDIO_FORMAT AUDIO_S16
#define AUDIO_SDL_CHANNELS 1

#define SOUND_SAMPLE_SIZE ((int)(AUDIO_FREQ*AUDIO_SLOT_DURATION))

/*
_____________________________________________________________________

			  Types
_____________________________________________________________________
*/

/* Includes for types (all included later again, though) */
#include<SDL/SDL.h>
#include<SDL/SDL_mixer.h>
#include<GL/gl.h>

typedef float fft_float;

typedef Sint16 sample_t;
#define SOUND_SAMPLE_MAX (1<<14)
typedef float pitch_t;
typedef unsigned char note_t;
typedef unsigned char pattern_t;

typedef struct
{
	unsigned ac_pos;
#ifdef ENABLE_MUSIC
	sample_t *sound_data;
#endif
} AudioInfo;

/*
_____________________________________________________________________

		   Demo parameters (defines)
_____________________________________________________________________
*/

#define NUM_CHAPTERS 5

/*
// New, slow values
*/
#define TEX_RES 256
#define DFT_SEED 30
#define PATCH_TEX_REPEAT 9

#define PATCH_H 600.0
#define PATCH_SMOOTHNESS 2.0
#define PATCH_BUMP 1.18
#define PATCH_SIZE 12.0
#define PATCH_ELEVATION 0.3
#define PATCH_MIN_ELEVATION -0.4
#define CAMERA_TARGET_ELEVATION 0.5
#define CAMERA_BASE_ELEVATION 1.1
#define CAMERA_BASE_DIST 7.2

#define CAMERA_X_OFFSET 1
#define CAMERA_Y_OFFSET 1

#define CAMERA_VELOCITY 0.055

// */


/*
// Original, fast values

#define TEX_RES 128
#define DFT_SEED 6
#define PATCH_TEX_REPEAT 9

#define PATCH_H 300.0
#define PATCH_SMOOTHNESS 1.9
#define PATCH_BUMP 1.5
#define PATCH_SIZE 15.0
#define PATCH_ELEVATION 0.2
#define PATCH_MIN_ELEVATION -0.6
#define CAMERA_TARGET_ELEVATION 1
#define CAMERA_BASE_ELEVATION 1.1
#define CAMERA_BASE_DIST 7.0

#define CAMERA_X_OFFSET 0
#define CAMERA_Y_OFFSET 0

#define CAMERA_VELOCITY 0.0855

// */


#define PATCH_D (PATCH_SIZE/TEX_RES)
#define GROUND_TEX_CONTRAST 50
#define GROUND_TEX_GRAIN 10


#define PATCH_EDGE_THRESHOLD 0.2
#define PATCH_EDGE_DROP 2.0
#define NORMAL_SMOOTHING 0.1 //0.2

#define CAMERA_NEAR 0.2
#define CAMERA_FAR 100
#define CAMERA_ZOOM 2
#define ASPECT ((float)XRES/YRES)

#define FOG_DENSITY 0.04
#define FOG_COL_R 0.8
#define FOG_COL_G 0.9
#define FOG_COL_B 1.0

#define SKYDIST 28
#define SKYSLOPE 5
#define SKYSIZE 100
#define SKYTEXMINX 0.1
#define SKYDEPTH 120

#define SKY_COL_R 0.4
#define SKY_COL_G 0.7
#define SKY_COL_B 0.8
#define SKY_COL_A 0.97

#define SEASIZE 1000
//#define SEADEPTH 2
#define SEATEXMAG 10

#define SEA_COL_R 0.3
#define SEA_COL_G 0.5
#define SEA_COL_B 0.7
#define SEA_COL_A 0.7

/*
_____________________________________________________________________

		   	Variables
_____________________________________________________________________
*/

/* t, current time (seconds) */
static float t =
	#ifdef START_T
	T_START
	#else
	0
	#endif
	; 

/* dt, current frame duration (seconds) */
static float dt = OPTIMAL_DT;

/* rt, relative chapter time and its complement */
static float rt = 0, rtc = 1.0; 

/* SDL event, polled to detect ESC */
static SDL_Event event; 

/* f,g,h, auxilary float variables */
static float f, g, h;

/* frame number */
static unsigned frame_no = 0;

/* x,y,z, coordinates :) */
static float x,y,z;

/* p, q, vectors, n normal vector */
static float px, py, pz, qx, qy, qz, nx, ny, nz;

/* len, vector length reciprocal */
static float lenr;

/* fa, GL float parameter array */
static GLfloat fa[4] = {0};

/* da, GL double parameter array */
static GLdouble da[4];

/* i,j,k, generic loop variables */
static int i,j,k;

/* a,b, auxilary integer variables */
static int a=0,b;

/* Current chapter number */
static char chapter_no = -1;

/* Next chapter change time */
static float next_chapter_t = 0;

/* Generic alpha var */
static float alpha = 1.0;

/* gl clear mode, fun */
static GLbitfield clear_mode = GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT;

/* texture ids */
static GLuint ground_texid, sky_texid, obj_texid;

static char second_pass;

#ifdef CLEAN_BEHAVIOUR
static void *my_memblock;
#endif
static void *memhandle;

/* generic "data" pointers */
static void *data;
static unsigned char *bdata;
static fft_float *fdata;

float sky_r = SKY_COL_R,
      sky_g = SKY_COL_G,
      sky_b = SKY_COL_B,
      fog_r = FOG_COL_R,
      fog_g = FOG_COL_G,
      fog_b = FOG_COL_B;

unsigned ac_pos = 0;

AudioInfo audio_info;

/*
_____________________________________________________________________

				Macros
_____________________________________________________________________
*/

#define SET_FA3(f0,f1,f2) fa[0] = f0; fa[1] = f1; fa[2]=f2
#define SET_FA4(f0,f1,f2,f3) fa[0] = f0; fa[1] = f1; fa[2]=f2; fa[3]=f3
#define SET_DA(f0,f1,f2,f3) da[0] = f0; da[1] = f1; da[2]=f2; da[3]=f3
#define SET_XYZ(X,Y,Z) x=X;y=Y;z=Z
#define SET_P(X,Y,Z) px=X;py=Y;pz=Z
#define SET_Q(X,Y,Z) qx=X;qy=Y;qz=Z
#define SET_N(X,Y,Z) nx=X;ny=Y;nz=Z

#define SQ(x) ((x)*(x))

#define NORMALIZE(v) 	lenr=1.0/sqrt(SQ(v##x)+SQ(v##y)+SQ(v##z));\
			v##x *= lenr; v##y *= lenr; v##z *= lenr

#define CROSS(a,b,r) 	r##x = a##y*b##z-a##z*b##y;\
			r##y = a##z*b##x-a##x*b##z;\
			r##z = a##x*b##y-b##x*a##y

#define RESERVEMEM(size) (memhandle+=(size))
#define FREEMEM(size) (memhandle-=(size))

#define ALLOC(ptr,size) ptr=memhandle;RESERVEMEM(size)

#define DRAND ((rand()%10000)/10000.0)

#define BASE_FREQ ((pitch_t)AUDIO_FREQ/SOUND_SAMPLE_SIZE)
#define Hz /(BASE_FREQ)

/*
_____________________________________________________________________

		More demo parameters (static consts)
_____________________________________________________________________
*/

/* Chapter durations */
static const float chapter_durations[] = {
	40.0,
	30.0,
	50.0,
	40.0,
	20.0
};

#define CHAPTER0_BEGIN 0
#define CHAPTER1_BEGIN (CHAPTER0_BEGIN+chapter_durations[0])
#define CHAPTER2_BEGIN (CHAPTER1_BEGIN+chapter_durations[1])
#define CHAPTER3_BEGIN (CHAPTER2_BEGIN+chapter_durations[2])
#define CHAPTER4_BEGIN (CHAPTER3_BEGIN+chapter_durations[3])

#ifdef ENABLE_MUSIC

#ifndef SIMPLE_MUSIC

/* Notes */
enum Notes
{
	S = 0, // Silence
	R, // sample played unmodified

	C4,
	Db4,
	D4,
	Eb4,
	E4,
	F4,
	Gb4,
	G4,
	Ab4,
	A4,
	Bb4,
	B4,
};

/* Note frequencies */
static const float pitch_map[] =
{
	1,
	262 Hz,		// C4
	277 Hz,		// C#4 / Db
	294 Hz,		// D4
	311 Hz,		// D#4 / Eb
	330 Hz,		// E4
	349 Hz,		// F4
	370 Hz,		// F#4 / Gb
	392 Hz,		// G4
	415 Hz,		// G#4 / Ab
	440 Hz,		// A4
	466 Hz,		// A#4 / Bb
	494 Hz		// B4
};

/* Samples */
enum Samples
{
	HIHAT,
	SNARE,
	KICK,
	SINE_WAVE,
	FOURIER_SAMPLE
};

static const float sample_volumes[] =
{
	1.0,
	1.0,
	4.0,
	0.0,
	0.0,
};
enum Patterns 
{
	SILENCE=0,
	B8, // Beat 4/4
	SN1,// Snare
	K1,// Kick
	K2,// Kick
	M1, // Meoldy 1
	M2
};

enum Patterns 
{
	SILENCE=0,
	B8, // Beat 4/4
	SN1,// Snare
	K1,// Kick
	K2,// Kick
	M1, // Meoldy 1
	M2
};

static const note_t pattern_data[] =
{
// AUDIO_PATTERN_LENGTH samples in a row, NUM_SOUND_SAMPLES rows
// item is a note
R,0,0,0,R,0,0,0,R,0,0,0,R,0,0,0,R,0,0,0,R,0,0,0,R,0,R,R,R,0,R,R,
0,0,0,0,0,0,0,0,R,R,0,0,0,0,0,0,0,0,R,0,0,0,0,0,R,R,0,0,0,0,0,0,
R,R,R,R,0,0,0,0,0,0,0,0,0,0,R,R,0,0,0,0,R,R,R,R,R,R,R,R,R,0,0,0,
R,R,R,R,R,R,0,0,0,0,0,0,0,0,R,R,0,0,0,0,R,0,0,0,0,0,0,0,0,0,0,0,
C4,0,Db4,0,E4,0,F4,0,G4,G4,0,G4,G4,0,0,0,A4,0,Gb4,0,E4,0,F4,0,A4,G4,0,G4,A4,0,0,0,
E4,A4,Db4,0,E4,0,G4,0,0,0,0,0,B4,0,0,0,Bb4,0,Gb4,0,E4,0,0,0,A4,0,0,0,A4,0,0,0,
};

#else
/* Notes */
enum Notes
{
	S = 0, // Silence
	R, // sample played unmodified
};

enum Patterns 
{
	SILENCE=0,
	B1, // Beat 4/4
	B2, // Beat 4/4
	B3, // Beat 4/4
	B4, // Beat 4/4
};

static const note_t pattern_data[] =
{
// AUDIO_PATTERN_LENGTH samples in a row, NUM_SOUND_SAMPLES rows
// item is a note
R,0,0,0,R,0,0,0,R,0,0,0,R,0,0,0,R,0,0,0,R,0,0,0,R,0,R,R,R,0,R,R,
R,0,0,0,R,0,0,0,R,0,0,0,R,0,0,0,R,0,0,0,R,0,0,0,R,0,0,0,R,0,0,0,
R,0,R,0,R,0,0,0,0,0,0,0,0,0,0,0,R,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
R,0,0,0,0,0,0,0,R,0,0,0,0,0,0,0,R,0,0,0,0,0,0,0,R,0,0,0,0,0,0,0,
};
#endif


/* Song */
static const pattern_t song_data[] =
{
// Each row represents one bar,
// it has a pattern index for each channel/instrument

// HH,	Snare,	Kick,	Sine,	Fourier
B1, B2, B3, B4, 0, 0, B1, B1, B2, B4, B4, B2, B2

};
#endif


/*
_____________________________________________________________________

		Imported functions (with generate.py)
_____________________________________________________________________
*/


/*BEGIN_LIBS
	stdlib.h libc.so
	srand
	rand
	malloc
# free is not necessary
	free

	SDL/SDL.h|SDL/SDL_video.h|SDL/SDL_mouse.h|SDL/SDL_timer.h|SDL/SDL_events.h|SDL/SDL_audio.h libSDL.so -lSDL
	IGNORE: DECLSPEC
	SDL_SetVideoMode
# hiding the cursor with SDL_ShowCursor is not necessary
	SDL_ShowCursor
	SDL_GL_SwapBuffers
	SDL_PollEvent
	SDL_Quit
# SDL init is not necessary
	SDL_Init
# remove next item when frame sleep is not used
	SDL_Delay
# SDL_GetTicks is not needed when we have an audio callback
	# SDL_GetTicks
# audio
	SDL_OpenAudio
	# SDL_CloseAudio
	SDL_PauseAudio
# not sure if these two are absolutely necessary
	# SDL_LockAudio
	# SDL_UnlockAudio
# get mouse state (for testing)
	#SDL_GetMouseState

	#SDL/SDL_mixer.h libSDL_mixer.so -lSDL_mixer
	#Mix_OpenAudio
	#Mix_CloseAudio
	#Mix_QuickLoad_RAW
	#(int (*)(int, Mix_Chunk *, int, int))Mix_PlayChannelTimed
	#
	GL/gl.h libGL.so -lGL
	IGNORE: GLAPI
	glMatrixMode
	glLoadIdentity
	glFrustum
	glViewport
	glEnable
	glDisable
	glBlendFunc
	glClear
	glLightfv
	glPushMatrix
	glRotatef
	glTranslatef
	glBegin
	glColor4f
	glVertex3i
	glVertex3f
	glNormal3f
	glScalef
	glEnd
	glPopMatrix
	glShadeModel
# texures
	glGenTextures
	glBindTexture
	glTexParameteri
	glTexImage2D
	glTexEnvf
	glTexCoord2i
	glTexCoord2f
	#glTexGeni
# fog
	glFogi
	glFogfv
	glFogf
# clipping
	glClipPlane

	GL/glu.h libGLU.so -lGLU
	IGNORE: GLAPI
	gluLookAt

	GL/freeglut_std.h libglut.so -lglut
	glutSolidCube
	# glutSolidTeapot -- now this would be lame
	# glutSolidDodecahedron
	glutInit

	math.h libm.so -lm
	(double(*)(double))sin
	(double(*)(double))cos
	(double(*)(double))sqrt
	(double(*)(double,double))pow

END_LIBS*/

/*
_____________________________________________________________________

			Function declarations
_____________________________________________________________________
*/

static void create_texture(GLuint *texid);

/* draws a box, dimensions read from vars x,y,z */
static void draw_box();

static void draw_patch();

/* Discrete Fourier Transform */
static void dft(const fft_float *src, fft_float *dest,
	 	unsigned n, unsigned imoffset, unsigned ptrdist, char inverse);

static void audio_callback(void *userdata, Uint8 *stream, int len);

/** ---------------- main */

#include "gen/prod_header.c"

/*
_____________________________________________________________________

			   Initialization
_____________________________________________________________________
*/

// Init glut and tell it to fuck off
glutInit(&a,NULL);

// Set up SDL and OpenGL
#ifdef CALL_SDL_INIT
SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
#endif

SDL_SetVideoMode(XRES,YRES,0,SDL_OPENGL);
SDL_ShowCursor(SDL_DISABLE);

glMatrixMode(GL_PROJECTION);
glLoadIdentity();
glFrustum(	-ASPECT*CAMERA_NEAR/CAMERA_ZOOM,
		ASPECT*CAMERA_NEAR/CAMERA_ZOOM,
		-CAMERA_NEAR/CAMERA_ZOOM,
		CAMERA_NEAR/CAMERA_ZOOM,
		CAMERA_NEAR,CAMERA_FAR);

glMatrixMode(GL_MODELVIEW);
glEnable(GL_DEPTH_TEST);

glEnable(GL_LIGHTING);
glEnable(GL_LIGHT0);
glEnable(GL_LIGHT1);

glEnable(GL_BLEND); //Enable alpha blending
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); //Set the blend function

glEnable(GL_TEXTURE_2D); // Enable textures
glEnable(GL_COLOR_MATERIAL); //Enable color

#ifdef GENERATE_NORMALS
glShadeModel(GL_SMOOTH);
#endif
// Allocate some memory
memhandle = malloc(ALLOC_SIZE);
#ifdef CLEAN_BEHAVIOUR
my_memblock = memhandle;
#endif

// Open the audio device
((SDL_AudioSpec*)memhandle)->freq = AUDIO_FREQ;
((SDL_AudioSpec*)memhandle)->format = AUDIO_FORMAT;
((SDL_AudioSpec*)memhandle)->channels = AUDIO_SDL_CHANNELS;
((SDL_AudioSpec*)memhandle)->samples = AUDIO_BUF_SIZE;
((SDL_AudioSpec*)memhandle)->callback = &audio_callback;
((SDL_AudioSpec*)memhandle)->userdata = &audio_info;
SDL_OpenAudio(((SDL_AudioSpec*)memhandle), NULL);

/*
_____________________________________________________________________

			Data generation
_____________________________________________________________________
*/

glEnable(GL_FOG);
glFogi (GL_FOG_MODE, GL_EXP);
glFogf (GL_FOG_DENSITY, FOG_DENSITY);

srand(DFT_SEED);
ALLOC(fdata, SQ(TEX_RES)*4*sizeof(fft_float));

// Random noise
for(i=0; i<SQ(TEX_RES)*2;++i) fdata[i] = 0.5*DRAND-0.5;

// IDFT, x-direction
for(i=0;i<TEX_RES;++i)
	dft(fdata+i*TEX_RES,
	    fdata+i*TEX_RES+2*SQ(TEX_RES),
	    TEX_RES,SQ(TEX_RES),1,1);

// IDFT, y-direction
for(i=0;i<TEX_RES;++i)
	dft(fdata+i+2*SQ(TEX_RES),
	    fdata+i,
	    TEX_RES,SQ(TEX_RES),TEX_RES,1);

// Frequency distribution magic
for(i=0; i<TEX_RES; i++)
  for(j=0; j<TEX_RES; j++)
  {
	//f = 1.0 / (SQ(i-TEX_RES/2)+SQ(j-TEX_RES/2)+1)*100;
	g = i;
	h = j;

	if(g==0 && h==0) f=0;
	else f = pow(SQ(g)+SQ(h),-0.5*PATCH_SMOOTHNESS);
	fdata[i*TEX_RES+j+SQ(TEX_RES)] *= f;
	fdata[i*TEX_RES+j] *= f;
  }

// DFT, y-direction
for(i=0;i<TEX_RES;++i)
	dft(fdata+i,
	    fdata+i+2*SQ(TEX_RES),
	    TEX_RES,SQ(TEX_RES),TEX_RES,0);

// DFT, x-direction
for(i=0;i<TEX_RES;++i)
	dft(fdata+i*TEX_RES+2*SQ(TEX_RES),
	    fdata+i*TEX_RES,
	    TEX_RES,SQ(TEX_RES),1,0);

ALLOC(bdata,SQ(TEX_RES)*4);

for(i=0;i<SQ(TEX_RES);++i)
{
	f = (0.5+fdata[i]*GROUND_TEX_CONTRAST);
	g = (0.5+fdata[i+SQ(TEX_RES)]*100);
	if(f<0.0) f = 0;
	if(f>1.0) f = 1;
	if(g<0.0) g = 0;
	if(g>1.0) g = 1;
	bdata[i*4+1] = (int)(f*0x90)+rand()%GROUND_TEX_GRAIN;
	bdata[i*4] = bdata[i*4+1]/4+(int)(g*0x10);
	bdata[i*4+2] = bdata[i*4+1]/7+bdata[i*4]/5;
	bdata[i*4+3] = 0xFF;
}

create_texture(&ground_texid);

/*for(i=0;i<SQ(TEX_RES);++i)
{
	bdata[i*4+3] = 0x80+bdata[i*4+1]/2;
	bdata[i*4] = 0x70+rand()%20;
	bdata[i*4+1] = 0x70+rand()%10;
	bdata[i*4+2] = 0x70+rand()%40;
	if(i%(TEX_RES)%(TEX_RES-3)<3 || (i/TEX_RES)%(TEX_RES-3)<3) 
	{
		bdata[i*4] = bdata[i*4+1] = bdata[i*4+2] = 1;
	}
}
create_texture(&obj_texid);*/

//glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_REFLECTION_MAP);
//glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_REFLECTION_MAP);

#ifdef ENABLE_MUSIC
// render some sounds
ALLOC(audio_info.sound_data,SOUND_SAMPLE_SIZE*sizeof(sample_t)*NUM_SOUND_SAMPLES);

for(i=0; i<SOUND_SAMPLE_SIZE; ++i)
{
#define S_DATA(s,i) audio_info.sound_data[i+SOUND_SAMPLE_SIZE*s]
#ifndef SIMPLE_MUSIC
   // sine wave
   S_DATA(SINE_WAVE,i) = cos(2*M_PI*i/SOUND_SAMPLE_SIZE)*SOUND_SAMPLE_MAX;
   // fourier sample
   S_DATA(FOURIER_SAMPLE,i) =
	(sample_t)(SOUND_SAMPLE_MAX * fdata[i*TEX_RES/SOUND_SAMPLE_SIZE]*3000);

   // white noise
   if(i<SOUND_SAMPLE_SIZE/8)
   	S_DATA(HIHAT,i) = ((*(sample_t*)&fdata[i])%SOUND_SAMPLE_MAX);
   else
   	S_DATA(HIHAT,i) = 0;

   S_DATA(SNARE,i) = ((*(sample_t*)&fdata[i])%SOUND_SAMPLE_MAX);

   //f = ((float)i/SOUND_SAMPLE_MAX);//-0.1)/0.9;
   S_DATA(KICK,i) = /*(1.0-f*f)**/-SOUND_SAMPLE_MAX;
#else
	// white noise
   if(i<SOUND_SAMPLE_SIZE/8)
   	S_DATA(0,i) = ((*(sample_t*)&fdata[i])%SOUND_SAMPLE_MAX);
   else
   	S_DATA(0,i) = 0;

#endif
}
#endif

// generate terrain
for(i=0; i<TEX_RES; i++)
  for(j=0; j<TEX_RES; j++)
  {
	a = i*TEX_RES+j;
	g = (i-TEX_RES/2)*2/(float)TEX_RES;
	h = (j-TEX_RES/2)*2/(float)TEX_RES;

	fdata[a] =
	  fdata[a]*PATCH_H-(SQ(g)+SQ(h))*PATCH_BUMP+PATCH_ELEVATION;

#ifdef DROP_PATCH_EDGES
	if(g<-1.0+PATCH_EDGE_THRESHOLD)
	  fdata[a] -= (PATCH_EDGE_THRESHOLD-(g+1.0))*PATCH_EDGE_DROP/PATCH_EDGE_THRESHOLD;
	if(g>1.0-PATCH_EDGE_THRESHOLD)
	  fdata[a] -= (g-1.0+PATCH_EDGE_THRESHOLD)*PATCH_EDGE_DROP/PATCH_EDGE_THRESHOLD;
	if(h<-1.0+PATCH_EDGE_THRESHOLD)
	  fdata[a] -= (PATCH_EDGE_THRESHOLD-(h+1.0))*PATCH_EDGE_DROP/PATCH_EDGE_THRESHOLD;
	if(h>1.0-PATCH_EDGE_THRESHOLD)
	  fdata[a] -= (h-1.0+PATCH_EDGE_THRESHOLD)*PATCH_EDGE_DROP/PATCH_EDGE_THRESHOLD;
#endif

  }


#ifdef GENERATE_NORMALS
// generate normals
for(i=1; i<TEX_RES-1; i++)
  for(j=1; j<TEX_RES-1; j++)
  {
	//f = 1.0 / (SQ(i-TEX_RES/2)+SQ(j-TEX_RES/2)+1)*100;

	g = fdata[i*TEX_RES+j+1]-fdata[i*TEX_RES+j-1];
	h = fdata[(i+1)*TEX_RES+j]-fdata[(i-1)*TEX_RES+j];

	SET_P(2*PATCH_D,0,g);
	SET_Q(0,2*PATCH_D,h);
	CROSS(p,q,n);
	nz += NORMAL_SMOOTHING*PATCH_D;
	NORMALIZE(n);

	fdata[i*TEX_RES+j+SQ(TEX_RES)] = nx;
	fdata[i*TEX_RES+j+SQ(TEX_RES)*2] = ny;
	fdata[i*TEX_RES+j+SQ(TEX_RES)*3] = nz;
  }
#endif

// Start audio
SDL_PauseAudio(0);

/*
_____________________________________________________________________

			Frame loop
_____________________________________________________________________
*/

for(;;)
{
	glClear(clear_mode);

	glLoadIdentity();

	// Chapter changing
	if(t >= next_chapter_t)
	{
		++chapter_no;
		if(chapter_no < NUM_CHAPTERS)
		{
		  next_chapter_t += chapter_durations[chapter_no];
		  /*switch(chapter_no) <<< no switchs >>>
		  {
		  case 0:
			clear_mode = GL_DEPTH_BUFFER_BIT;

			//break;

		  default:
			clear_mode = GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT;
			break;
		  }*/
		}
		else break;
	}

	rtc = (next_chapter_t-t)/chapter_durations[chapter_no];
	rt = 1.0-rtc;

	if(chapter_no==0)
	{
		fog_r = rt;
		fog_b = 0;
		fog_g = 0.5*rt;
		sky_b = rtc;
		sky_r = sky_g = 0;
	}
	if(chapter_no==1)
	{
		sky_r = rt*SKY_COL_R;//SKY_COL_R+rt*(1.0-SKY_COL_R);
		sky_g = rt*SKY_COL_G;//SKY_COL_G+rt*(1.0-SKY_COL_G);
		sky_b = rt*SKY_COL_B;
		fog_r = rt*FOG_COL_R+rtc*(1.0);
		fog_g = rt*FOG_COL_G+rtc*(0.5);
		fog_b = rt*FOG_COL_B;
	}
	if(chapter_no==2)
	{
		sky_r = rtc*SKY_COL_R;
		sky_g = rtc*SKY_COL_G;
		sky_b = rtc*SKY_COL_B;
	}
	if(chapter_no==3)
	{
		sky_r = rt;
		sky_g = rt;
		fog_g = rtc*FOG_COL_G+rt*0.5;
		fog_b = rtc*FOG_COL_B+rt*0.2;
	}
	if(chapter_no==4)
	{
		sky_b = rt;
		sky_g = rtc;
		sky_r = rtc;
		fog_r = rtc*FOG_COL_R;
		fog_g = rtc*0.5;
		fog_b = rtc*0.2;
	}

	SET_FA4(fog_r,fog_g,fog_b,1.0);
	glFogfv (GL_FOG_COLOR, fa);

	second_pass = 0;

RENDER_AGAIN:
	glLoadIdentity();

	g = CAMERA_BASE_DIST;
	f = t*CAMERA_VELOCITY;

	SET_XYZ(cos(f)*g+CAMERA_X_OFFSET, sin(f*0.7)*g+CAMERA_Y_OFFSET, cos(f*1.0)+CAMERA_BASE_ELEVATION);

	if(second_pass)
	{
		glViewport(0,0,XRES,YRES);
		glDisable(GL_CLIP_PLANE0);
	}
	if(second_pass)
	{
		glBindTexture( GL_TEXTURE_2D, 0 );	

		glColor4f(sky_r,sky_g,sky_b,SKY_COL_A);

		glDisable(GL_LIGHTING);

		glBegin(GL_QUADS);
		//glTexCoord2f(0,1);
		glVertex3i(-SKYSIZE,SKYSIZE,-SKYDIST/3);
		//glTexCoord2f(SKYTEXMINX,1);
		glVertex3i(SKYSIZE,SKYSIZE,-SKYDIST/3);
		//glTexCoord2f(SKYTEXMINX,0);
		glVertex3i(SKYSIZE,-SKYDEPTH,-SKYDIST*SKYSLOPE);
		//glTexCoord2f(0,0);
		glVertex3i(-SKYSIZE,-SKYDEPTH,-SKYDIST*SKYSLOPE);
		glEnd();

		glColor4f(1,1,1,1);

		glEnable(GL_LIGHTING);
	}

	f = CAMERA_TARGET_ELEVATION;

	if(!second_pass)
	{
		z = -z;
		f = -f;
		glScalef(-1,1,1);
	}

	gluLookAt(x,y,z, CAMERA_X_OFFSET,CAMERA_Y_OFFSET,f, 0,0,second_pass?1:-1);

	// Set light 0 position
	SET_FA3(2,4,7);
	glLightfv(GL_LIGHT0,GL_POSITION,fa);

	//glBindTexture( GL_TEXTURE_2D, ground_texid );

	//glEnable(GL_TEXTURE_GEN_S);
	//glEnable(GL_TEXTURE_GEN_T);

	if(second_pass)
	{
		glColor4f(SEA_COL_R,SEA_COL_G,SEA_COL_B,SEA_COL_A);

		glBegin(GL_QUADS);
		glNormal3f(0,0,1);
		//glTexCoord2i(0,SEATEXMAG);
		glVertex3i(-SEASIZE,SEASIZE,0);
		//glTexCoord2i(SEATEXMAG,SEATEXMAG);
		glVertex3i(SEASIZE,SEASIZE,0);
		//glTexCoord2i(SEATEXMAG,0);
		glVertex3i(SEASIZE,-SEASIZE,0);
		//glTexCoord2i(0,0);
		glVertex3i(-SEASIZE,-SEASIZE,0);
		glEnd();

		glColor4f(1,1,1,1);
		glBindTexture( GL_TEXTURE_2D, 0 );
	}

	SET_DA(0,0,1,0);
	glClipPlane(GL_CLIP_PLANE0, da);

	//glDisable(GL_TEXTURE_GEN_S);
	//glDisable(GL_TEXTURE_GEN_T);


	glBindTexture( GL_TEXTURE_2D, ground_texid );

	glEnable(GL_CLIP_PLANE0);

	glPushMatrix();
	if(chapter_no==0)
	   glTranslatef(0,0,(PATCH_MIN_ELEVATION-PATCH_ELEVATION)*(1.0-rt));

	draw_patch();

	glPopMatrix();
	glBindTexture( GL_TEXTURE_2D, 0 );

	//glBindTexture( GL_TEXTURE_2D, obj_texid );

	if(t > 10)
	{
		srand(125);

		b = (int)((t-10)*1.1);

		//glTranslatef(0,0,-1);
		//glScalef(0.3,0.3,0.4);

		//SET_XYZ(1,1,1);

		for(i=0; i<=b; i++)
		{
			f = rand()%100;
			if(chapter_no>1) f += (t-CHAPTER2_BEGIN)*0.1;
			glRotatef(f,1,2,3);
			glScalef(0.92,0.92,0.92);
			glPushMatrix();

			/*if(b==i) alpha = rt*50-b;
			else alpha = 1.0;*/

			//glColor4f(0.5+DRAND*0.2,0.5+DRAND*0.2,0.5+DRAND*0.2,alpha);

			x = rand()%1000 - 500;
			y = rand()%1000 - 500;
			z = rand()%1000 - 500;
			glTranslatef(x,y,z);

			f = (t-CHAPTER3_BEGIN)*10;
			if(chapter_no>2)
				glRotatef(f,1,2,3);
		

			/*x = DRAND*0.05+0.03;
			y = x;
			z = DRAND+rt*5;

			a = (rand()%3)+1;
			if(z>a) z = a;*/

			//glutSolidTeapot(10);
			//glutSolidDodecahedron();
			glutSolidCube(10);

			glPopMatrix();
		}

		//glColor4f(1,1,1,1);
	}

	if(!second_pass)
	{
		second_pass = 1;
		goto RENDER_AGAIN;
	}


	SDL_GL_SwapBuffers();

	f = t;
	t = (float)(audio_info.ac_pos) / AUDIO_FREQ
		#ifdef SPEED_MULTIPLIER
		* SPEED_MULTIPLIER
		#endif
		#ifdef START_T
		+ T_START
		#endif
		;
	dt = t-f;

  #ifdef LIMIT_FRAMERATE
	if(dt < OPTIMAL_DT)
	{
		SDL_Delay((int)((OPTIMAL_DT-dt)*1000));
		t += OPTIMAL_DT-dt;
		dt = OPTIMAL_DT;
	}
  #endif

  #ifdef FRAME_SLEEP
	SDL_Delay(FRAME_SLEEP);
  #endif

	++frame_no;

	// Check for end
	while(SDL_PollEvent(&event))
	if(event.type==SDL_KEYDOWN) goto END_DEMO;
} 

/*
_____________________________________________________________________

			Cleanup (yeah, right)
_____________________________________________________________________
*/


END_DEMO:

SDL_PauseAudio(1);
#ifdef CLEAN_BEHAVIOUR
SDL_CloseAudio();
free(my_memblock);
#endif

SDL_Quit();

#include "gen/prod_footer.c"

/*
_____________________________________________________________________

			Function bodies
_____________________________________________________________________
*/

static void create_texture(GLuint *texid)
{
	// generate test texture
	glGenTextures(1,texid);

	glBindTexture( GL_TEXTURE_2D, *texid );

	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT); // GL_CLAMP

	glTexImage2D(GL_TEXTURE_2D, 0, 4, TEX_RES, TEX_RES, 0,
		     GL_RGBA, GL_UNSIGNED_BYTE, bdata);
}

/*static void draw_box()
{
	glBegin(GL_QUADS);
	glNormal3f(0,-1,0);
	glTexCoord2i(1, 1); glVertex3f(-x, -y, -z);
	glTexCoord2i(0, 1); glVertex3f( x, -y, -z);
	glTexCoord2i(0, 0); glVertex3f( x, -y,  z);
	glTexCoord2i(1, 0); glVertex3f(-x, -y,  z);
	glNormal3f(0,0,1);
	glTexCoord2i(0, 0); glVertex3f(-x, -y,  z);
	glTexCoord2i(1, 0); glVertex3f( x, -y,  z);
	glTexCoord2i(1, 1); glVertex3f( x,  y,  z);
	glTexCoord2i(0, 1); glVertex3f(-x,  y,  z);
	glNormal3f(0,0,-1);
	glTexCoord2i(1, 0); glVertex3f(-x, -y, -z);
	glTexCoord2i(1, 1); glVertex3f(-x,  y, -z);
	glTexCoord2i(0, 1); glVertex3f( x,  y, -z);
	glTexCoord2i(0, 0); glVertex3f( x, -y, -z);
	glNormal3f(1,0,0);
	glTexCoord2i(1, 0); glVertex3f( x, -y, -z);
	glTexCoord2i(1, 1); glVertex3f( x,  y, -z);
	glTexCoord2i(0, 1); glVertex3f( x,  y,  z);
	glTexCoord2i(0, 0); glVertex3f( x, -y,  z);
	glNormal3f(-1,0,0);
	glTexCoord2i(0, 0); glVertex3f(-x, -y, -z);
	glTexCoord2i(1, 0); glVertex3f(-x, -y,  z);
	glTexCoord2i(1, 1); glVertex3f(-x,  y,  z);
	glTexCoord2i(0, 1); glVertex3f(-x,  y, -z);
	glNormal3f(0,1,0);
	glTexCoord2i(0, 1); glVertex3f(-x,  y, -z);
	glTexCoord2i(0, 0); glVertex3f(-x,  y,  z);
	glTexCoord2i(1, 0); glVertex3f( x,  y,  z);
	glTexCoord2i(1, 1); glVertex3f( x,  y, -z);
	glEnd();
}*/

static void draw_patch()
{
	for(i=1;i<TEX_RES-2;i++)
	{
	   glBegin(GL_TRIANGLE_STRIP);
#ifndef GENERATE_NORMALS
	   glNormal3f(0,0,1);
#endif

	   for(j=1; j<TEX_RES-1; j++)
	   {
#ifdef GENERATE_NORMALS
		glNormal3f(fdata[i*TEX_RES+j+SQ(TEX_RES)],
			   fdata[i*TEX_RES+j+SQ(TEX_RES)*2],
			   fdata[i*TEX_RES+j+SQ(TEX_RES)*3]);
#endif
		glTexCoord2f(j/(float)TEX_RES*PATCH_TEX_REPEAT,
			     i/(float)TEX_RES*PATCH_TEX_REPEAT);
		glVertex3f(j*PATCH_D-PATCH_SIZE/2,
			   i*PATCH_D-PATCH_SIZE/2,
			   fdata[i*TEX_RES+j]);
#ifdef GENERATE_NORMALS
		glNormal3f(fdata[(i+1)*TEX_RES+j+SQ(TEX_RES)],
			   fdata[(i+1)*TEX_RES+j+SQ(TEX_RES)*2],
			   fdata[(i+1)*TEX_RES+j+SQ(TEX_RES)*3]);
#endif
		glTexCoord2f(j/(float)TEX_RES*PATCH_TEX_REPEAT,
			     (i+1)/(float)TEX_RES*PATCH_TEX_REPEAT);
		glVertex3f(j*PATCH_D-PATCH_SIZE/2,
			   (i+1)*PATCH_D-PATCH_SIZE/2,
			   fdata[(i+1)*TEX_RES+j]);
	   }
	   glEnd();
	}
}

#ifndef M_2_PI
	#define M_2_PI 6.283185307179586476925286766559
#endif

static fft_float real0, imaginary0, r1, i1, br, bi, tmpvar, dft_lenr;
static const fft_float * dft_src_i;
static fft_float * dft_dest_i;
static unsigned dft_handle_i,dft_handle_j,dft_block_size;

/**
 * The not-so-fast (aka. discrete) Fourier transform
 */
static void dft(const fft_float *src, fft_float *dest,
	unsigned len, unsigned imoffset, unsigned ptrdist, char inverse)
{
	dft_src_i = src+imoffset;
	dft_dest_i = dest+imoffset;

	dft_block_size = len*ptrdist;

	real0 = cos(M_PI*2 / (fft_float)(len));
	imaginary0 = sin(M_PI*2 / (fft_float)(len));

	if(inverse) {
		imaginary0 = -imaginary0;
		dft_lenr = 1.0/len;
	}

	br = 1;
	bi = 0;
	
	for(dft_handle_i=0; dft_handle_i<dft_block_size; dft_handle_i+=ptrdist)
	{
		r1 = 1;
		i1 = 0;
		dest[dft_handle_i] = dft_dest_i[dft_handle_i] = 0;

		for(dft_handle_j=0; dft_handle_j<dft_block_size; dft_handle_j+=ptrdist)
		{
			dest[dft_handle_i] += src[dft_handle_j]*r1-dft_src_i[dft_handle_j]*i1;
			dft_dest_i[dft_handle_i] += src[dft_handle_j]*i1+dft_src_i[dft_handle_j]*r1;
			tmpvar = r1;
			r1 = r1*br-i1*bi;
			i1 = tmpvar*bi+i1*br;
		}
		tmpvar = br;
		br = br*real0 - bi*imaginary0;
		bi = tmpvar*imaginary0 + bi*real0;
	
		if(inverse)
		{
			dest[dft_handle_i] *= dft_lenr;
			dft_dest_i[dft_handle_i] *= dft_lenr;
		}
		
	}

}

#ifdef ENABLE_MUSIC	
static int ac_iter, ac_chan_iter, ac_sample_no, ac_note_no, ac_mixlen, ac_first_chan;
static unsigned ac_cur_offs, ac_bar_no, ac_cur_pat;
//static const note_t *ac_patterns[AUDIO_CHANNELS] = { NULL };
static unsigned ac_offsets[AUDIO_CHANNELS] = { 0 };
static note_t cur_note;
static pitch_t cur_pitch;
#endif

#define STREAM ((sample_t *)stream)
#define AUDIOINFO ((AudioInfo*)userdata)
#define PATTERN(n) (pattern_data+(n)*AUDIO_PATTERN_LENGTH)
#define SOUND_SAMPLE(n) (AUDIOINFO->sound_data+(n)*SOUND_SAMPLE_SIZE)
#define PITCH(n) (pitch_map[(n)-1])
#define BAR(n) ((n)*AUDIO_PATTERN_LENGTH)

static void audio_callback(void *userdata, Uint8 *stream, int len)
{
#ifdef ENABLE_MUSIC	
	ac_sample_no = AUDIOINFO->ac_pos / SOUND_SAMPLE_SIZE;
	ac_mixlen = (SOUND_SAMPLE_SIZE-(AUDIOINFO->ac_pos % SOUND_SAMPLE_SIZE)-1);
#endif

	len /= sizeof(sample_t);

	AUDIOINFO->ac_pos += len;
#ifdef ENABLE_MUSIC
	while(len)
	{
		if(ac_mixlen > len) ac_mixlen = len;

		ac_note_no = ac_sample_no % AUDIO_PATTERN_LENGTH;
		ac_bar_no = ac_sample_no / AUDIO_PATTERN_LENGTH
				#ifdef REPEAT_EACH_PATTERN
				/ REPEAT_EACH_PATTERN
				#endif
				#ifdef SONG_LENGTH
				% SONG_LENGTH
				#endif
				;

#ifdef SIMPLE_MUSIC

		if((ac_cur_pat = song_data[ac_bar_no*NUM_SOUND_SAMPLES])!=0 && (cur_note=PATTERN(ac_cur_pat-1)[ac_note_no])!=0)
		{
			for(ac_iter = 0; ac_iter < ac_mixlen; ac_iter++)
			{
				ac_cur_offs = ((int)(ac_offsets[0]+ac_iter)) % SOUND_SAMPLE_SIZE;
				STREAM[ac_iter] = SOUND_SAMPLE(0)[ac_cur_offs]*MASTER_VOLUME;
			}
			ac_offsets[0] += (int)(ac_iter);
		}
		else ac_offsets[0] = 0;

#else
		ac_first_chan = 1;
		for(ac_chan_iter=0; ac_chan_iter < AUDIO_CHANNELS; ++ac_chan_iter)
		{
		  //if(ac_patterns[ac_chan_iter]!=NULL && (cur_note=ac_patterns[ac_chan_iter][ac_note_no]))
		  //if((cur_note=song_data[ac_bar_no*NUM_SOUND_SAMPLES+ac_chan_iter])!=0)
		  if((ac_cur_pat = song_data[ac_bar_no*NUM_SOUND_SAMPLES+ac_chan_iter])!=0 && (cur_note=PATTERN(ac_cur_pat-1)[ac_note_no])!=0)
		  {
		    cur_pitch = PITCH(cur_note);
		    for(ac_iter = 0; ac_iter < ac_mixlen; ac_iter++)
		    {
			if(ac_first_chan) STREAM[ac_iter] = 0;
			ac_cur_offs = ((int)(ac_offsets[ac_chan_iter]+ac_iter*cur_pitch)) % SOUND_SAMPLE_SIZE;
			STREAM[ac_iter] += SOUND_SAMPLE(ac_chan_iter)[ac_cur_offs]*sample_volumes[ac_chan_iter]*MASTER_VOLUME/AUDIO_CHANNELS;

		    }
		    ac_first_chan = 0;
		    ac_offsets[ac_chan_iter] += (int)(ac_iter*cur_pitch);
		  }
		  else ac_offsets[ac_chan_iter] = 0;
		}
#endif

		len -= ac_mixlen;
		ac_sample_no++;
		stream += ac_mixlen*sizeof(sample_t);
		ac_mixlen = SOUND_SAMPLE_SIZE;
	}
#endif
}

