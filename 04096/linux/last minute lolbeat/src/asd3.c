#include "SDL.h"
#include <math.h>
#include <GL/gl.h>

#define FREQ 44100
#define SAMPLES 256

#define SCREEN_W 1280
#define SCREEN_H 720

char notes[] = {3,1,3,4,5,3,5,6, 3,1,3,4,5,6,5,6};
//char notes[] = {3,4,3,4,6,3,5,6, 3,4,3,4,6,7,5,3};
//char notes[] = {6,3,4,5,6,3,4,5,6, 7,6,7,6,8,5,4,2};
const int NNOTES = sizeof(notes)/sizeof(notes[0]);
//#define NOTELEN 32
#define NOTETIME .2f
#define NOTESAMPLES ((int)(NOTETIME*FREQ))

#define NBUFS 16
short audioBufs[NBUFS][SAMPLES];
volatile int curAudioBuf=0;

#define BTIME (2*NOTETIME)
#define BSTIME .07f
//#define BSTIME 1.f
#define BSAMPLES ((int)(BTIME*FREQ))

char bnotes[] = {3,3,3,3,5,5,3,5};
const int NBNOTES = sizeof(bnotes)/sizeof(bnotes[0]);
int curBNote=0;

int curNote=0, curNotePlace=0;
float noteState = 0;
int bplace=0;
float bstate=0;

//char notes2[];

#define BEAT 1
#define BASS 2
#define SIN 4
int soundType = SIN;

void playSquare(Sint16* stream, int note, float baseh, int place, int nlen, float vol)
{
	if (note==-100) return;
	float perioid = FREQ/(baseh*exp2(note/12.f));
	int i;
	int limit = nlen*4/3;
	float silence = 1./limit;
	limit = nlen-limit;
	for(i=0; i<SAMPLES; ++i) {
		int k = place+i;
		float a = vol;
		if (fmod(k, perioid) < .5*perioid)
			a = -a;
		if (k > limit) {
			a *= 1-silence*(k-limit);
		}
		stream[i] += a;
	}
}

void callback(void* udata, Uint8* s, int len)
{
	(void)udata,(void)len;
	Sint16* stream = (Sint16*)s;
	int i=SAMPLES;
	do {
			stream[i] = 0;
	} while(--i);

	const int blimit = FREQ*(BTIME-BSTIME);
//	const float bsilence = 1/(FREQ*BSTIME);
	if (soundType & BEAT) {
		/* BEAT CODE */
		const float bsfreq = .105f;
		const float bslowdown = .0012f;
		for(i=0; i<SAMPLES; ++i) {
			int k = bplace+i;
			float a = 25000*sin(bsfreq*k/(1+k*bslowdown));
			if (k > blimit) {
//				a *= 1-bsilence*(k-blimit);
				if (k == (int)(BTIME*FREQ)) {
					curBNote = (curBNote+1)%NBNOTES;
					printf("note: %d\n", curBNote);
					bplace = 0;
					bstate = 1;
				}
			}
			stream[i] += a;
		}
	}
	if (soundType & BASS) {
		/* SQUARE WAVE */
/*		float perioid = FREQ/(60.f*exp2(bnotes[curBNote]/12.f));
		for(i=0; i<SAMPLES; ++i) {
			int k = bplace+i;
			float a = 6000;
			if (fmod(k, perioid) < .5*perioid)
				a = -a;
			if (k > blimit) {
				a *= 1-bsilence*(k-blimit);
				if (k > (int)(BTIME*FREQ)) {
					curBNote = (curBNote+1)%NBNOTES;
					bplace = 0;
					bstate = 1;
				}
			}
			stream[i] += a;
		}*/
		playSquare(stream, bnotes[curBNote], 55.f, bplace, BTIME*FREQ, 6000);
		
	}
	if (soundType & (BEAT|BASS)) {
		bplace += SAMPLES;
		if (bplace >= BSAMPLES) {bplace=0, bstate=1; curBNote=(curBNote+1)%NBNOTES;}
		bstate *= .95;
	}

	if (soundType & SIN) {
		// lol sin
		static int place=0;
/*		float len = (440.f*2*M_PI/FREQ)*exp2(notes[curNote]/12.f);
		for(i=0; i<SAMPLES; ++i) {
			int k = place+i;
			stream[i] += 10000*sin(len*k)/(1+.001f*k);
		}*/
		playSquare(stream, notes[curNote], 110.f, place, NOTESAMPLES, 6000);
		Sint16 buf[512] = {};
		playSquare(buf, notes[curNote], 165.f, place, NOTESAMPLES, 3000);
		for(i=0; i<SAMPLES; ++i)
			stream[i] += buf[i];

		place += SAMPLES;

		if (place > NOTESAMPLES) {
			place = 0;
			curNote = (curNote+1)%NNOTES;
		}

/*		if (++curNotePlace == NOTELEN) {
			curNotePlace = 0;
			++curNote;
			curNote %= NNOTES;
			place = 0;
//			printf("note: %d\n", curNote);
		}*/
	}
	
	short* buf=audioBufs[curAudioBuf];
	i=SAMPLES;
	do {
		buf[i] = stream[i];
	} while(--i);
	curAudioBuf = (curAudioBuf+1)%NBUFS;
}

#define LINE1 1
#define LINE2 2
#define CUBE1 4
#define CUBE2 8
#define BEATBG 16

#define BEATCUBE 1
#define ROTATE2 2

typedef struct State {
	int time;
	char effect;
	char sound;
	char param;
} State;
#define BT (1000*BTIME)
State intro[] = {
	{BT*16, LINE1, SIN,0},
	{BT*1, 0, BASS, 0},
	{BT*8, LINE2, BASS,0},
	{BT*4, LINE2, BASS|BEAT,0},
	{BT*8, LINE2|BEATBG, BASS|BEAT,0},
	{BT*16, CUBE1, BASS|BEAT,0},
	{BT*8, CUBE1, BASS|BEAT,0},
	{BT*8, CUBE1, BASS|BEAT, BEATCUBE},
	{BT*8, CUBE1|BEATBG, BASS|BEAT, BEATCUBE},
//	{BT*4, CUBE1|BEATBG, BASS|BEAT, BEATCUBE},
	{BT*4, CUBE1|LINE2, BASS, 0},
	{BT*2, LINE2, BEAT, 0},
	{BT*8, CUBE2, BASS, 0},
	{BT*16, CUBE2, BASS|BEAT, 0},
	{BT*16, CUBE2|LINE2|BEATBG, BASS|BEAT, BEATCUBE}
};
#undef BT
const int nStates = sizeof(intro)/sizeof(intro[0]);

#define GRAPH_LEN SAMPLES
void drawGraphs(float r, float g, float b)
{
	int k=NBUFS;
	do {
		short* graph = audioBufs[(k+curAudioBuf)%NBUFS];
//		glColor4f(r,g,b,k/NBUFS);
		glColor4f(r,g,b,2*k/NBUFS);
		glBegin(GL_LINE_STRIP);
		int i=GRAPH_LEN;
		do {
			glVertex2i(i, graph[i]);
		} while(--i);
		glEnd();
	} while(--k);
}

float cubeScaleY;
static void lineTo(float dy, float dz)
{
	glTranslatef(-1, dy, dz);
#if 1
//	const float scalex=2./GRAPH_LEN, scaley=1.f/10;
	const float scalex=2./GRAPH_LEN;//, scaley=.000012f;
	glScalef(scalex, cubeScaleY, 1);
	drawGraphs(0, 0, 1);
	glScalef(1/scalex, 1/cubeScaleY, 1);
#else
	glBegin(GL_LINES);
	glVertex3f(0, 0, 0);
	glVertex3f(2, 0, 0);
	glEnd();
#endif
	glTranslatef(1, -dy, -dz);
}

/*const signed char crotate[6][2] =
{
	{0, 0},{1,0},{-1,0},{2,0},{0,1},{0,-1}
};*/
const signed char clines[4][2] =
{
	{-1,-1},{1,-1},{1,1},{-1,1}
};
void drawCube()
{
	int i,j;
	for(i=0; i<3; ++i) {
		if (i==1) glRotatef(90, 0, 1, 0);
		else if (i==2) glRotatef(90, 0, 0, 1);
		for(j=0; j<4; ++j) {
			lineTo(clines[j][0], clines[j][1]);
		}
	}
}

SDL_Surface* screen;

SDL_AudioSpec spec = {
	FREQ, // freq
	AUDIO_S16, // format
	1, // channels
	0, // silence
	SAMPLES, // samples
	0, // padding
	0, // size
	callback, // callback
	0 // userdata
};

void resetMatrix()
{
	glLoadIdentity();
	glFrustum(-.1, .1, -.1, .1, .1, 100);
}

void _start()
//int main()
{
	SDL_Init(SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_TIMER);
	SDL_OpenAudio(&spec, 0);
	SDL_PauseAudio(0);
	
	screen = SDL_SetVideoMode(SCREEN_W, SCREEN_H, 0, SDL_OPENGL);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	int t;
	int curState = 0;
	int etime = intro[0].time;
	do {
		t = SDL_GetTicks();

		int eff = intro[curState].effect;
		int param = intro[curState].param;

		if (eff & BEATBG) {
//			float tmp = bstate - .1f;
//			if (tmp < 0) tmp += 1;
			float tmp = bstate;
			glClearColor(tmp,tmp,tmp,0);
		}

		glClear(GL_COLOR_BUFFER_BIT);
		
		if (eff & (LINE1 | LINE2)) {
			resetMatrix();
			if (eff&LINE1) {
				glTranslatef(-15, 0, t*.016f-100.f);
				glScalef(30.f/GRAPH_LEN, 4./30000, 1);
			} else {
				glTranslatef(-15, 0, -17);
				glScalef(30.f/GRAPH_LEN, 6./30000, 1);
			}
			drawGraphs(.8,.8,.0);
		}
		if (eff & (CUBE1 | CUBE2)) {
			float scales[2] = {.000012f, .1f};
			cubeScaleY = scales[(eff >> 3)&1];

			resetMatrix();
			glTranslatef(0, 0, -4);
			glRotatef(t*.1f, 1, 1, 0);
			glRotatef(t*.15f, 0, 1, 1);
			if (param & BEATCUBE) {
				float x = 1+bstate*.8f;
				glScalef(x,x,x);
			}
			drawCube();
		}
/*		glTranslatef(0, 0, -5);
		drawCube();*/

		SDL_GL_SwapBuffers();
		SDL_Event e;
		if (SDL_PollEvent(&e) && e.key.keysym.sym==SDLK_ESCAPE)
			break;

		if (t > etime) {
			++curState;
			etime += intro[curState].time;
			if (curState == nStates) break;
			printf("state: %d\n", curState);
			soundType = intro[curState].sound;
			curBNote = 0;
			glClearColor(0,0,0,0);
		}
	} while(1);

	SDL_Quit();
}
