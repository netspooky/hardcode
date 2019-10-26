/*
kartoonikum 4k
slack and waffle
*/
#ifdef SDL
#include <SDL/SDL.h>
#endif

#ifndef OS_X
#ifdef WIN32
#include <windows.h>
#ifndef SDL
#include <mmsystem.h>
#endif
#endif
#include <GL/glu.h>
#include <GL/gl.h>
#else
#include <OpenGL/glu.h>
#include <OpenGL/gl.h>
#endif
#include <math.h>
#include <stdlib.h>

#define PLAYLIST_LENGTH 43 
#define NUM_PATTERNS 13
#define NUM_TRACKS 7
#define NUM_ENVELOPES 6
#define NUM_INSTRUMENTS 4
#define NUM_RHYTHM_CHANNELS 1
#define NUM_CHANNELS 5
#define TRACK_LENGTH 12
#define NUM_VOICES 32 

#if defined(__X11__) && !defined(DEBUG)
typedef struct
{
	// libSDL
	//int	(*SDL_Init)(Uint32);
	void	(*SDL_Quit)(void);
	int	(*SDL_OpenAudio)(SDL_AudioSpec*, SDL_AudioSpec*);
	void	(*SDL_CloseAudio)(void);
	void	(*SDL_PauseAudio)(int);
	int	(*SDL_ShowCursor)(int);
	void*	(*SDL_SetVideoMode)(int, int, int, Uint32);
	int	(*SDL_GL_SwapBuffers)(void);
	int	(*SDL_PollEvent)(SDL_Event*);
	void	(*SDL_Delay)(int);
	unsigned int (*SDL_GetTicks)(void);

	// libm
	float	(*powf)(float, float);
	float	(*fmodf)(float, float);
	
	// libGLU
	GLUquadric* (*gluNewQuadric)(void);
	void (*gluCylinder)(GLUquadric* quad, GLdouble base, GLdouble top, GLdouble height, GLint slices, GLint stacks);
	void	(*gluPerspective)(GLdouble, GLdouble, GLdouble, GLdouble);

#ifndef ALTSUN
//	void	(*glScalef)(GLfloat, GLfloat, GLfloat);
#endif
	void	(*glRotatef)(GLfloat, GLfloat, GLfloat, GLfloat);
	void	(*glTranslatef)(GLfloat, GLfloat, GLfloat);
	void	(*glMatrixMode)(GLenum);
	void	(*glPushMatrix)(void);
	void	(*glPopMatrix)(void);
	void	(*glColor3ub)(GLubyte, GLubyte, GLubyte);
	void	(*glRectf)(GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2);
} FN_STRUCT;

#define SDL_Quit fn.SDL_Quit
#define SDL_OpenAudio fn.SDL_OpenAudio
#define SDL_CloseAudio fn.SDL_CloseAudio
#define SDL_PauseAudio fn.SDL_PauseAudio
#define SDL_ShowCursor fn.SDL_ShowCursor
#define SDL_SetVideoMode fn.SDL_SetVideoMode
#define SDL_GL_SwapBuffers fn.SDL_GL_SwapBuffers
#define SDL_PollEvent fn.SDL_PollEvent
#define SDL_Delay fn.SDL_Delay
#define SDL_GetTicks fn.SDL_GetTicks
#define gluNewQuadric fn.gluNewQuadric
#define gluCylinder fn.gluCylinder
#define gluPerspective fn.gluPerspective
#define glScalef fn.glScalef
#define glRotatef fn.glRotatef
#define glTranslatef fn.glTranslatef
#define glMatrixMode fn.glMatrixMode
#define glPushMatrix fn.glPushMatrix
#define glPopMatrix fn.glPopMatrix
#define glColor3ub fn.glColor3ub
#define glRectf fn.glRectf
#define powf fn.powf
#define fmodf fn.fmodf
#endif

#define BUFFER_SIZE 1024
#define SAMPLE_RATE 44100.0f
#define invSAMPLE_RATE 2.26497650146e-05f

#define FLOAT2INTCAST(x) (*((int*)(&x)))
#define FLOAT2UINTCAST(x) (*((unsigned int*)(&x)))

#define PI_X 0x40490FDB
#define DOSPI_X 0x40C90FDB
#define PI_2_X 0x3FC90FDB

#define PI 3.140625f
#define PI_samplerate 7.10487365723e-05f
#define DOSPI 6.28125f
#define DOSPI_samplerate 0.000142097473145f

typedef unsigned char U8;
typedef signed char S8;

typedef struct _Envelope
{
	U8 D, S, R; // In 1/100ths of a second except S which is vol*100 
	U8 sustain_time; // In 1/100ths of a second
} Envelope;

typedef struct _Instrument
{
	// Filter
	S8 lfo_freq;
	U8 resonance; // in 1/100ths
	
	S8 square_detune_coarse; // in tones
	S8 square_detune_fine; // in cents
	S8 saw_detune_coarse;
	S8 saw_detune_fine;

	U8 square_vol;
	U8 saw_vol;
	U8 noise_vol;

	U8 vol_envelope;
	U8 pitch_envelope;

	float cutoff; // >0 LP; <0 HP
	float lfo_amp;
} Instrument;


typedef struct _Voice
{
	Instrument *ins;

	float pitch;
	float vol;

	float xn[3];
	float yn[3];

	int pos; // position in samples since the start
	U8 active; // { 0 ==> inactiva, (not 0) ==> activa }

} Voice;

typedef struct _Track
{
	/* A note is defined by a Uint8:
	 *
	 *   7   6    5   4   3   2   1   0
	 * -----------------------------------
	 * |  Vol. |       note number       |
	 * -----------------------------------
	 */

	Uint8 notes[TRACK_LENGTH];
	Uint8 instrument;
} Track;


typedef struct _Channel
{
	Uint8 pat[NUM_PATTERNS];
} Channel;

typedef struct _Song
{
	//float row_duration; // in seconds
	Uint8 playlist[PLAYLIST_LENGTH];

	Envelope envelopes[NUM_ENVELOPES];

	Uint8 rhythm_notes[NUM_RHYTHM_CHANNELS];
	Uint8 rhythm_insts[NUM_RHYTHM_CHANNELS];

	Uint16 rhythms[2*NUM_RHYTHM_CHANNELS];
	Channel chans[NUM_CHANNELS];

	Track tracks[NUM_TRACKS];

	Instrument insts[NUM_INSTRUMENTS];
} Song;

#define whitenoise() (fn_rand()/(float)RAND_MAX)

static Voice voices[NUM_RHYTHM_CHANNELS+NUM_VOICES]={{0}};
static float mix_buf[BUFFER_SIZE]={0};
static float global_vol=1.0f;
static float last_bombo;
static float last_hihat;
static float current_time=0;
static unsigned char current_time_char=0;

static unsigned int last_voice_used=0;
static int end;
static int cur_pos=0, cur_row=0;
static int rhythm_offset;
static int rows_played=0;

#if defined(WIN32) && !defined(SDL)
static Uint8 soundbuffer[sizeof(wave)+SAMPLECOUNT*2];
#endif

#ifdef SDL
//extern SDL_AudioSpec desired;
#else
typedef unsigned char Uint8;
typedef unsigned short Uint16;
typedef signed char Sint8;
typedef signed short Sint16;
#endif
#if defined(WIN32) && !defined(SDL)
//extern void initsound();

#define SAMPLECOUNT (120*44100)
static struct {
	char riff[4]; //identifikaatio
	unsigned int size; //filen koko
	char wave[4]; //wave-header
	char fmt[4]; //fmt-chunk
	unsigned int num; 
	unsigned short format; //
	unsigned short channels; //1 = mono, 2 = stereo
	unsigned int freq; //samplerate
	unsigned int abps; //average bytes per sec
	unsigned short blockalign; //tavuja per sample
	unsigned short bitdepth; //bittej� per sample
	char data[4];
	unsigned int datasize;
} wave = {
	{'R','I','F','F' },
	sizeof(wave) + SAMPLECOUNT*2,
	{'W','A','V','E'},
	{'f','m','t',' '},
	0x10,
	1,
	1,
	44100,
	88200,
	2,
	16,
	{ 'd', 'a', 't', 'a' },
	SAMPLECOUNT*2
};
static Uint8 soundbuffer[sizeof(wave)+SAMPLECOUNT*2];
#endif

#include "song.h"

#ifndef WIN32
#define sin(x) __builtin_sinf(x)
#define cos(x) __builtin_cosf(x)
#define sqrt(x) __builtin_sqrtf(x)
#endif


//different sun
#define ALTSUN

static unsigned long rand_next_seed = 1;
static int fn_rand(void)
{
	rand_next_seed = rand_next_seed * 1103515245 + 12345;
	return((unsigned)(rand_next_seed/65536) % 32768);
}

static GLUquadric *Q;
static float rotation=0.0f, rotation2=0.0f;
#define FLOWERS (20*3)
#define STARS (70*3)
#define BUILDINGS (16*3)
#define WINDOWS (10*10*10)
static float position[FLOWERS], buildingsPosition[BUILDINGS], starsPosition[STARS];
static int windows[WINDOWS];
static int i,j,k,x,y;


//definitions
#define ROUNDNESS 40

//color definitions
#define FN_COLOR_BLACK() glColor3ub(0,0,0)
#define FN_COLOR_WHITE() glColor3ub(255,255,255)
#define FN_COLOR_YELLOW() glColor3ub(0xff,0xff,0x80)
#define FN_COLOR_SKY() glColor3ub(0xa5,0xc6,0xed)
#define FN_COLOR_FIELD() glColor3ub(0x60,0xff,0x60)
#define FN_COLOR_BUILDING() glColor3ub(100, 100, 100)
#define FN_COLOR_LIGHTS_OUT() glColor3ub(20,20,20)
static const unsigned char flowercolor[9] = { 0x20, 0x9b, 0xc8, 0xbe, 0x20, 0xc8, 0xc8, 0x20, 0x20 };

#ifdef __X11__
#include <dlfcn.h>
#include "names.h"

static FN_STRUCT fn;

__attribute__((always_inline)) static void dl_init(void)
{
	char *p=names;
	void **pfn=(void **)&fn;
	void *handle, *tmp;

	int i;
	for(i=0; i<NAMES_LENGTH; i++)
	{
		names[i] -= DELTA;
	}

	while(*p)
	{
		tmp = dlopen(p, RTLD_LAZY);
		if (tmp == NULL)
		{
			*pfn=dlsym(handle, p);
			#ifdef DEBUG2
			__builtin_printf("%s = %p\n", p, *pfn);
			#endif
			++pfn;
		}
		else
		{
			handle=tmp;
		}
		while(*p++); // Avanzamos p hasta la siguiente
	}
}
#endif

__attribute__((fastcall)) static float detune(int coarse, int fine)
{
	return powf(2.0f, (coarse+(fine/100.0f))/12.0f);
}

#if defined(WIN32) && !defined(SDL)
#define mfmodf(x,y) fmod(x,y)
#define msin(x) sin(x)
#define mcos(x) cos(x)
#else
#define mfmodf(x,y) fmodf(x,y)
#define msin(x) __builtin_sinf(x)
#define mcos(x) __builtin_cosf(x)
#endif

__attribute__((fastcall)) static float mtan(float x)
{
	float sin_x, cos_x;
	#ifdef X86_ASM
		__asm__("fsincos" : "=t" (cos_x), "=u" (sin_x) : "0" (x));
	#else
		sin_x=msin(x);
		cos_x=mcos(x);
	#endif

	return sin_x/cos_x;
}

__attribute__((fastcall)) static float getADSR(Envelope *e, float pos)
{
	float p=pos*100.0f;

	// Attacks are disabled
	//float A=e->A;
	if (p < 0)
		return 9.96589660645e-05f;

	float D=e->D;
	float S=e->S*0.00994873046875f;
	if (p <= D)
		return (1.0f-(p * (1.0f - S)) / D);

	p -= D;

	float sustain_time=e->sustain_time;
	if (p <= sustain_time)
		return S;

	p -= sustain_time;

	float R=e->R;
#ifndef SYNTH_HACKS
	if (p < R)
		return S - S * (p/R);
	return 0.0f;
#else
	return S - S * (p/R);
#endif
}

__attribute__((fastcall)) static int synth(Voice *v, int len, float *mix_buf)
{
	Instrument *ins=v->ins;
	//float pitch_sine  = v->pitch * ins->sine_detune;
	float pitch_square= v->pitch * detune(ins->square_detune_coarse, ins->square_detune_fine);
	float pitch_saw   = v->pitch * detune(ins->saw_detune_coarse, ins->saw_detune_fine); 
	float pitch_env, vol, res, t;
	int i;

	for (i=0; i<len; ++i)
	{
		t=(v->pos+i)*invSAMPLE_RATE;
		vol = getADSR(&song.envelopes[ins->vol_envelope], t);
		if(ins->pitch_envelope)
			pitch_env = getADSR(&song.envelopes[ins->pitch_envelope], t);
		else
			pitch_env = 1.0f;
		
		// Calc. and mix the oscillators 
		// Noise
		res = 0.00994873046875f*ins->noise_vol*(2.0f*whitenoise()-1.0f) ;

		// Sine
		//res += ins->sine_vol * msin(DOSPI*pitch_sine*pitch_env*t);

		// Square
		float sqvol=ins->square_vol*0.00994873046875f;
		if (mfmodf(t, 1.0f/(pitch_square*pitch_env)) > (0.5f/(pitch_square*pitch_env)))
			res += sqvol;
		else
			res -= sqvol;

		// Saw
		res += 0.00994873046875f*ins->saw_vol * (mfmodf(t*pitch_saw*pitch_env, 2.0f) - 1.0f);

		// Apply the ADSR
		res *= vol;

		// Calculamos el valor del cutoff aplicando LFO
		// TODO: Comprobar si vale la pena eliminar este if
		float cutoff, lfo_freq;
		if (ins->lfo_freq < 0)
		{
			lfo_freq=-ins->lfo_freq;
			t=current_time;
		}
		else
		{
			lfo_freq=ins->lfo_freq;
		}
		lfo_freq *= 0.099609375f;
		cutoff= ins->cutoff + ins->lfo_amp * mcos(DOSPI * lfo_freq * t);

		// TODO: Cambiar el factor de la resonancia para
		// ajustar el rango a valores mas utiles.
		// ahora mismo va de 0.0 a 2.55 con incrementos de 0.01 y
		// no parece que > 1.5 sea util
		t = ins->resonance*0.00994873046875f;

		// Filter coefficients	
		float c, c2,a1,a2,b1,b2;

		// This is common to high-pass and low-pass
		float param_tan = PI_samplerate * cutoff;

		if (cutoff > 0.0f) // Low-pass
		{
			c=1.0f / mtan(param_tan);
			c2 = c*c;

			a1 = 1.0f / ( 1.0f + t*c + c2);
			a2 = 2.0f * a1;
			b1 = 2.0f * ( 1.0f - c2) * a1;
		}

		else // High-pass
		{
			c = mtan(-param_tan);
			c2 = c*c;

			a1 = 1.0f / ( 1.0f + t*c + c2);
			a2 = -2.0f * a1;
			b1 = 2.0f * ( c2 - 1.0f) * a1;
		}

		b2 = ( 1.0f - t*c + c2) * a1;

		v->yn[0] = a1*res + a2*v->xn[1] + a1*v->xn[2] -
			b1*v->yn[1] - b2*v->yn[2];

		v->xn[2]=v->xn[1];
		v->xn[1]=res;
		v->yn[2]=v->yn[1];
		v->yn[1]=v->yn[0];

		mix_buf[i] += v->yn[0] * v->vol;
	}

	v->pos+=len;

	if (vol > 0.0f)
		return 1;
	return 0;
}

static float looneyTunesFadeOut=10.0f;

static void play(Song *s, Uint8 *stream, int len)
{
	unsigned int cur_ptn;
	unsigned int i, j;
	unsigned int trans;
        unsigned int num_samples=len>>1;

	Sint16 *buf=(Sint16 *)stream;

	Track *cur_trk;

	float tmp;

	current_time_char = current_time;

#ifdef X86_ASM
	__asm__("rep; stosl;"::"a"(0), "c"(BUFFER_SIZE), "D"(mix_buf));
#else
	__builtin_memset(mix_buf, 0, BUFFER_SIZE*sizeof(float));
#endif

	if ((current_time - rows_played * ROW_DURATION) > ROW_DURATION )
	{
		++rows_played;
		int buf_start = ((current_time - rows_played * ROW_DURATION)*SAMPLE_RATE)-num_samples;


		cur_ptn=song.playlist[cur_pos];
		
		for (i=0; i<NUM_RHYTHM_CHANNELS; ++i)
		{
			int steps;
			steps = song.rhythms[i];
			if (steps & (1<<(11-cur_row)))
			{
				voices[i].pitch = 440.0f*detune(song.rhythm_notes[i]-45,0);
				voices[i].pos = buf_start;

				voices[i].ins = &song.insts[song.rhythm_insts[i]];
				voices[i].vol = global_vol;
				voices[i].active = 1;
			}
		}

		for (i=0; i<NUM_CHANNELS; ++i)
		{
			unsigned int chanval=song.chans[i].pat[cur_ptn];
			unsigned int trknum=chanval & 0x0F;
			cur_trk = &song.tracks[trknum];
			trans = (chanval) >> 4;

			unsigned int note = (cur_trk->notes[cur_row] & 0x0F);
			float vol = ((cur_trk->notes[cur_row])>>4) * 0.0625f;
			if (chanval)
			{
				note+=trans;
				
				j = last_voice_used + NUM_RHYTHM_CHANNELS;
				//fprintf(stdout, "%d lvu = %d; (%d + 1) %% %d = %d\n", j, last_voice_used, last_voice_used, NUM_VOICES, (last_voice_used + 1) % NUM_VOICES); fflush(stdout);
				last_voice_used = (last_voice_used + 1) % NUM_VOICES;
				//fprintf(stdout, "%d lvu = %d; (%d + 1) %% %d = %d\n", j, last_voice_used, last_voice_used, NUM_VOICES, (last_voice_used + 1) % NUM_VOICES); fflush(stdout);
				voices[j].pitch = 440.0f*detune(note-45,0);
				voices[j].pos = buf_start;
				voices[j].ins = &song.insts[cur_trk->instrument];
				voices[j].vol = global_vol*0.19921875f*vol;
				voices[j].active = 1;
			}
		}

		++cur_row;
		if (cur_row == TRACK_LENGTH) // end of track
		{
			cur_row=0;
			++cur_pos;
#ifdef DEBUG2
			printf("pat=%d ROW_DURATION=%f\tcurrent_time=%f\n", cur_pos, ROW_DURATION,current_time);
#endif
		}


		if (song.playlist[cur_pos]==255) { // loop at end of song
			cur_pos=0;
#ifdef DEBUG2
			printf("LOOP!\n");
#endif
		}
	}
	// Ahora vamos sintetizando las voces
	for (i=0; i < NUM_VOICES + NUM_RHYTHM_CHANNELS; ++i)
	{
		if (voices[i].active)
		{
			voices[i].active=synth(&voices[i], num_samples, mix_buf);
		}
	}

	for (i=0; i<num_samples; ++i)
	{
		tmp = mix_buf[i];
		buf[i]=(Sint16)(tmp*looneyTunesFadeOut*2500.0f);
	}
}

#ifdef SDL
static SDL_AudioSpec desired={(int)SAMPLE_RATE,
			AUDIO_S16SYS,
			1,
			0,
			BUFFER_SIZE,
			0,
			0,
			(void (*)(void *, Uint8 *, int)) play,
			0};
#endif

#if defined(WIN32) && !defined(SDL)
static void initsound()
{
	int i;
	int j;
	int baseoffset = sizeof(wave);
	int kohta;
	float noise;
	float volumeramp;

	memcpy(soundbuffer, &wave, sizeof(wave));

	for(int i = 0; i < 5167; i++)
	{
		play(&song, &soundbuffer[sizeof(wave)+i*2048], 2048);
	}
}
#endif

__attribute__((fastcall)) static void flower(void)
{
	int s;

	for(s = 0; s < 5; s++)
	{
		glPushMatrix();
		glRotatef((360.0f/5.0f)*s, 0.0f,0.0f,1.0f);
		glTranslatef(1.0f,0.0f,0.0f);
		gluCylinder(Q, 0.7, 0.0, 0.0, ROUNDNESS, 1);
		glPopMatrix();
	}

	FN_COLOR_WHITE();
	gluCylinder(Q, 0.55, 0.0, 0.0, ROUNDNESS, 1);
}

#if defined(WIN32) && !defined(SDL)
static HWND hwnd = NULL;
static HDC hdc = NULL;
static HINSTANCE hinstance = NULL;
#endif

#if (defined(DEBUG) || (defined(WIN32) && defined(SDL)))
int main(int argc, char **argv)
#else
#ifdef WIN32
int WINAPI WinMainCRTStartup()
#else
void _start(void)
#endif
#endif
{
#if defined(WIN32) && !defined(SDL)
	HDC hdc;
	HGLRC hrc;
	MSG msg;

	PIXELFORMATDESCRIPTOR pfd;
#ifdef FULLSCREEN
	DEVMODE dmScreenSettings;
#endif
	pfd.nSize=sizeof(PIXELFORMATDESCRIPTOR);
	pfd.nVersion=1;
	pfd.dwFlags=PFD_DRAW_TO_WINDOW|PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER;
	pfd.iPixelType=PFD_TYPE_RGBA;
	pfd.cColorBits=32;
	pfd.cDepthBits=16;
	pfd.iLayerType=PFD_MAIN_PLANE;

#ifdef FULLSCREEN

	dmScreenSettings.dmSize=sizeof(dmScreenSettings);
	dmScreenSettings.dmPelsWidth    = 1024;
	dmScreenSettings.dmPelsHeight   = 576;
	dmScreenSettings.dmBitsPerPel   = 32;
	dmScreenSettings.dmFields=DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;

	ChangeDisplaySettings(&dmScreenSettings, CDS_FULLSCREEN);
#endif
	
	hwnd = CreateWindowEx( WS_EX_TOOLWINDOW,
						   "STATIC",
						   "",
						   WS_POPUP | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
						   0,
						   0,
						   1024,
						   576,
						   0,
						   0,
						   NULL,
						   0 );

	hdc = GetDC(hwnd);
	hrc = wglCreateContext(hdc);

	SetPixelFormat(GetDC(hwnd), ChoosePixelFormat(GetDC(hwnd),
              &pfd), &pfd);
	wglMakeCurrent(GetDC(hwnd), wglCreateContext(GetDC(hwnd)));
	
	ShowWindow(hwnd, SW_SHOW);		
	SetForegroundWindow(hwnd);	
	SetFocus(hwnd);
	
    ShowCursor(FALSE);

	initsound();
	sndPlaySound((LPCSTR)soundbuffer, SND_NODEFAULT | SND_ASYNC | SND_MEMORY);

#endif

#if defined(__X11__) && !defined(DEBUG)
	dl_init();
#endif

	const float w = 1024.0f, h = 576.0f;
#if !defined(__X11__) && defined(SDL)
	SDL_Init(SDL_INIT_AUDIO|SDL_INIT_VIDEO); //not necessary in Linux
#endif
#ifdef SDL
	SDL_SetVideoMode(w, h, 0, SDL_OPENGL|SDL_FULLSCREEN);
#endif

#ifndef OS_X
	Q = gluNewQuadric();
#endif

	//initialization here before the audio init because rand() is not thread safe
	for(i = 0; i < FLOWERS; i+=3)
	{
		position[i] = (fn_rand()%500)/10.0f+60;
		position[i+1] = (fn_rand()%150)/10.0f-5.0f;
		position[i+2] = -(fn_rand()%15)-15;
	}

	for(i = 0; i < BUILDINGS; i+=3)
	{
		buildingsPosition[i] = (fn_rand()%3)+1; //building width
		buildingsPosition[i+1] = (fn_rand()%4); //building height
		buildingsPosition[i+2] = (fn_rand()%3)/1.5 + ((i > 0) ? buildingsPosition[i-1]+buildingsPosition[i]*2 : 0);
	}
	buildingsPosition[(BUILDINGS-1)] += 10.0f;

	for(i = 0; i < STARS; i+=3)
	{
		starsPosition[i] = (fn_rand()%500)/10.0f-25;
		starsPosition[i+1] = (fn_rand()%300)/10.0f-15.0f;
		starsPosition[i+2] = -(fn_rand()%15)-15;
	}

	for(i = 0; i < WINDOWS; i++)
	{
		windows[i] = (fn_rand()%10);
	}

#ifdef OUTFILE
	fout = fopen(OUTFILE, "wb");
#endif
#if !defined(__X11__) && defined(SDL)
//	SDL_Init(SDL_INIT_AUDIO|SDL_INIT_VIDEO); //not necessary in Linux
#endif

#ifdef SDL
	SDL_OpenAudio(&desired, NULL);
	SDL_PauseAudio(0);
	unsigned int startTicks = SDL_GetTicks();
#ifdef OUTFILE
	//getchar();
#endif

	SDL_ShowCursor(0);
#endif
#ifdef OS_X
	Q = gluNewQuadric();
#endif

	
	//16:9 projection
	glMatrixMode(GL_PROJECTION);
	gluPerspective(45.0f, w/h, 0.01f, 1024.0f);
	glMatrixMode(GL_MODELVIEW);

	while (1)
	{
#ifdef SDL
		current_time = (SDL_GetTicks()-startTicks)/1000.0f;
#endif
		glPushMatrix();
		glTranslatef(
			0.0f,
			0.0f,
			current_time_char<10 ? -current_time : -10.0f
		);

		//intro timelines
		#define moonFadeTime bgFadeTime
		float bgFadeTime = 1.0f;
		float grassFadeTime = 1.0f;
		float flowerFadeTime = 1.0f;
		float flowerToStarFadeTime = 0.0f;
		float sunFadeOutTime = 0.0f;
		#define PIVOT_FADE 42.0f

		if (current_time_char >= 42)
		{
			if (current_time_char < (10+42))
			{
				bgFadeTime = (10-(current_time-42))/10.0f;
				sunFadeOutTime = -(current_time-42)*3;
			}
			else
			{
				bgFadeTime = 0.0f;
				sunFadeOutTime = -30.0f;
				if (current_time_char >= (42+60))
				{
					bgFadeTime = (current_time-(42+60))/10.0f;
					sunFadeOutTime = ((10-(current_time-(42+60)))/10.0f)*-30.0f;
					if(bgFadeTime > 1.0f)
					{
						bgFadeTime = 1.0f;
						sunFadeOutTime = 0.0f;
					}
				}
			}
		
			grassFadeTime = current_time_char<=(15+42) ? (15-(current_time-42))/15.0f : 0.0f;
			flowerFadeTime = (18-(current_time-42))/18.0f;
		}
		sunFadeOutTime += sin(current_time*0.7)*0.5-0.5;

		flowerToStarFadeTime =
			(current_time_char >= (42+12) && current_time_char<(42+20))
			? (current_time-(42+12))/8.0f : 0.0f;

		float starsFadeInTime = 0.0f;

		if (current_time_char >= (42+60))
		{
			starsFadeInTime =
				(current_time_char<(42+65))
				? (5-(current_time-(42+60)))/5.0f : 0.0f;
		}
		else if (current_time_char >= (42+12))
		{
			starsFadeInTime =
				(current_time_char<=(42+19))
				? (current_time-(42+12))/8.0f : 1.0f;
		}

		float buildingsTransitionTime = -8.0f;
		if (current_time_char >= (42+18))
		{
			buildingsTransitionTime =
				(current_time_char<(42+23))
				? -8.0f*(5-(current_time-(42+18)))/5.0f : 0.0f;
		}

		//clear screen
		glColor3ub(0xa5*bgFadeTime,0xc6*bgFadeTime,0xed*bgFadeTime);
		glRectf(-10.0f, -10.0f, 10.0f, 10.0f);

		//draw stars
		for(i = 0; i < STARS*starsFadeInTime-15; i += 3)
		{
			glPushMatrix();
			glTranslatef(starsPosition[i],starsPosition[i+1],starsPosition[i+2]);
			FN_COLOR_WHITE();
			gluCylinder(Q, 0.05, 0.0, 0.0, ROUNDNESS, 1);
			glPopMatrix();
		}

		//draw sun
		glPushMatrix();

		glTranslatef(0.0f, sunFadeOutTime, 0.0f);

		glTranslatef(16.0f,7.0f,-15.0f);

		FN_COLOR_BLACK();
#ifdef ALTSUN
		gluCylinder(Q, 2.5, 0.0, 0.0, 25, 1);
		for(i=0;i<8;i++)
		{
			glPushMatrix();
			glRotatef(360/8.0f*i, 0,0,1);
			glTranslatef(-5.5,-0.5,0);
			glRectf(0, 0, 2.5,0.7);
			glPopMatrix();
		}
#else
		//alternative sun
		for(i=0;i<2;i++)
		{
			glRotatef(45.0f,0.0f,0.0f,1.0f);
			glPushMatrix();
			glScalef(5.0f,1.0f,1.0f);
			gluCylinder(Q, 1.0, 0.0, 0.0, 4, 1);
			glScalef(0.2,5.0f,1.0f);
			gluCylinder(Q, 1.0, 0.0, 0.0, 4, 1);
			glPopMatrix();
		}
#endif
		glTranslatef(0.2f,-0.1f,0.0f);


		FN_COLOR_YELLOW();

#ifdef ALTSUN
		gluCylinder(Q, 2.5, 0.0, 0.0, 25, 1);
		for(i=0;i<8;i++)
		{
			glPushMatrix();
			glRotatef(360/8.0f*i, 0,0,1);
			glTranslatef(-5.5,-0.5,0);
			glRectf(0, 0, 2.5,0.7);
			glPopMatrix();
		}
#else
		//alternative sun
		for(i=0;i<2;i++)
		{
			glRotatef(45,0,0,1);
			glPushMatrix();
			glScalef(5,1,1);
			gluCylinder(Q, 1.0, 0.0, 0.0, 4, 1);
			glScalef(0.2,5,1);
			gluCylinder(Q, 1.0, 0.0, 0.0, 4, 1);
			glPopMatrix();
		}
#endif
		//draw moon
		glTranslatef(0.0f, 30.0f, 0.0f);
		FN_COLOR_YELLOW();
		gluCylinder(Q, 2.0, 0.0, 0.0, ROUNDNESS, 1);
		glTranslatef(-0.8f, 0.0f, 0.0f);
		glColor3ub(0xa5*moonFadeTime,0xc6*moonFadeTime,0xed*moonFadeTime);
		gluCylinder(Q, 2.0, 0.0, 0.0, ROUNDNESS, 1);

		glPopMatrix();

		rotation += 0.03f;
		if (grassFadeTime > 0.0f)
		{
			for(i=0;i<800;i++)
			{
				//size optimize by replacing with gluCylinder?
				FN_COLOR_BLACK();
				glRectf(i/50.0-8, -5, (i+1)/50.0-8, sin((i+1)/200.0f+rotation)*1+0.05);
	
				glColor3ub(0x60*grassFadeTime,0xff*grassFadeTime,0x60*grassFadeTime);
				glRectf(i/50.0-8, -5, (i+1)/50.0-8, sin((i+1)/200.0f+rotation)*1);
	
				FN_COLOR_BLACK();
				glRectf(i/50.0-8, -5, (i+1)/50.0-8, sin((i+1)/100.0f+rotation)*1-0.95);
	
				glColor3ub(0x60*grassFadeTime,0xff*grassFadeTime,0x60*grassFadeTime);
				glRectf(i/50.0-8, -5, (i+1)/50.0-8, sin((i+1)/100.0f+rotation)*1-1);
			}
		}

		//draw buildings
		for(i = 0, k = 0; i < BUILDINGS; i+=3)
		{
			if (current_time_char >= (42+25))
			{
				float dipshit = 1.0f;
				if (current_time_char >= (42+58))
				{
					dipshit = (10-(current_time-(42+58)))/10.0f;
					if (dipshit < 0.0f) { dipshit = 0.0f; }
				}

				buildingsPosition[i+2]-=0.06f*dipshit;
			}
			glPushMatrix();

			glTranslatef(buildingsPosition[i+2], buildingsTransitionTime,0);

			float collapse = 0.0f;

			if (current_time_char >= (42+72))
			{
				collapse = (current_time-(42+72))/3.0f*90;
				if (collapse > 90.0f)
				{
					collapse = 90.0f;
					looneyTunesFadeOut = 10.0f*(10-(current_time-(42+77)))/10.0f;
					//end the intro
					if (looneyTunesFadeOut < 0.1f)
					{
						goto end;
					}
				}
			}

			//the end building collapse
			glTranslatef(3.,-4.15,0);
			glRotatef(collapse,0,0,-1);
			glTranslatef(-3.,4.15,0);

			//int w=buildingsPosition[i]; int h=buildingsPosition[i+1];
			#define w buildingsPosition[i]
			#define h buildingsPosition[i+1]
			FN_COLOR_BLACK();
			glRectf(-0.30f,h+0.05f, w+0.05f,-4.15f);
		
			FN_COLOR_BUILDING();
			glRectf(-0.25f,h, w,-4.15f);

			//draw windows
			for(x = 0; x < w*2; x++, k++)
			{
				for(y = -4; y < h+h+4; y++, k++)
				{
					FN_COLOR_LIGHTS_OUT();
					if (windows[k])
					{
						FN_COLOR_YELLOW();
					}

					glRectf(x/2.0f, y/2.0f-2, x/2.0f+1/4.0f,y/2.0f+1/5.0f-2);
				}
			}

			glPopMatrix();

			//the end fade out
			FN_COLOR_BLACK();
			gluCylinder(Q, 10.0f, looneyTunesFadeOut, 0.0f, ROUNDNESS, 1);
		}

		//draw flowers
		rotation2=current_time*80.0f;
		//0.0f == probably better compression but might give some potential graphics bug
		if (flowerFadeTime > -0.1f)
		{
			for(i = 0, j = 0; i < FLOWERS; i+=3)
			{
				position[i] -= 0.06f-flowerToStarFadeTime;
	
				if (position[i] < -6.0f+position[i+2])
				{
					position[i] = 6.0f-position[i+2];
				}
	
				glPushMatrix();
				glTranslatef(0,0,flowerToStarFadeTime);

				glPushMatrix();
				glTranslatef(position[i]-0.1,position[i+1],position[i+2]+5);
				glPushMatrix();
				glRotatef(rotation2,0,0,1);
				FN_COLOR_BLACK();
				flower();
				glPopMatrix();

				glTranslatef(0.1f,0.0f,0.0f);
				glRotatef(rotation2,0,0,1);

				char *fcol = &flowercolor[i%9];
				glColor3ub(fcol[0], fcol[1], fcol[2]);

				flower();
				glPopMatrix();

				glPopMatrix();
			}
		}

		glPopMatrix();
#ifdef SDL
		SDL_GL_SwapBuffers();
		SDL_Delay(25);

		SDL_Event event;
		SDL_PollEvent(&event);
		if (event.key.keysym.sym == SDLK_ESCAPE)
		{
			end:
			break;
		}
#endif
#if defined(WIN32) && !defined(SDL)
		glFlush();
		SwapBuffers(hdc);
		if (GetAsyncKeyState(VK_ESCAPE))
		{
			break;
		}
#endif
	}

#ifdef SDL
	SDL_Quit();
#endif

#ifdef OUTFILE
	fclose(fout);
#endif

	
#if 1 && __X11__
	__asm__("xorl %eax, %eax\n\t"
	    "incl %eax\n\t"
	    "int $0x80\n\t");

#else
#ifdef SDL
	exit(0);
#endif
#endif
}
