#include "SDL/SDL.h"
#include "SDL/SDL_opengl.h"
#include "math.h"

/* * * * * * * * * * * * * *
		tejeez of tvt: Audio
		
		tzaeru of ---: gfx
* * * * * * * * * * * * * */



#define PII 3.14f

/* Some possible values include: 160, 320, 416, 480. The value HAS to divide evenly by 32 */
#define pallo_koko 416

#define pallo_size1 1.0f
#define pallo_size2 1.0f
static float sini(float kukko)
{
	return sinf(kukko);
}

int flagi = 4;

static int abc = 4;

float pii;
float pallo_size = pallo_size1;
float pallo_data[pallo_koko*pallo_koko*2*3];

int aika;

int i,j, yy, xx;

GLuint pallo;

float haam = 0;

float hassu1 = 1, hassu2 = 1, hassu3 = 0, hassu4 = 0;

#define MUSA1 /* kokotestailua helpottamaan */
#define MUSA2


#define OSCN 3
#define SAMPLERATE 48000
#ifdef MUSA1
#ifdef MUSA2
float osc_phs[OSCN] = { 0 };
float osc_freq[OSCN];
float lpfs[8] = { 0 };
static float filtfreq=0, filt2freq=0, filtresn, filt2resn=0;
static long int muslc = 0;
static short int musl = 0-1;
static short int rndm = 0;
#define NN -0x7F
const char bassla[] = {
  0, NN, 12,  0, NN,  3, 12,  0,-12,  0, 12,  7,  0, NN, 12,  7,
  0, NN, 12,  0, NN,  4, 12,  0,-12,  0, 12,  7,  4, NN, 12,  7,
  0, NN, 12, NN,  3, NN, 12, NN,-12,-12,  0,  0,-12,-12,  0,  0,
  0,  0, 12,  4, NN, NN, 12, NN,-12,-12,  0,  0,-12,-12,  0,  0,

  0, 12,  0, 12,  0, 12,  0,  3,  0, 12,  0, 12,  0, 12,  0,  7,
  0, 12,  0, 12,  0, 12,  0,  4,  0, 12,  0, 12,  0, 12,  0,  7,
};
const char basslb[] = {   25-2,25-2,25+5,25-4,25+3,25-6,25+1,25-4,
                          25-2,25-2,25+5,25+6,25+3,25+8,25+1,25-4 };
const char basslc[] = {      0,   0,   0,  16,   0,  16,  16,   8
                          };

const unsigned char noisff[] = {

                                  5,  60, 130,   6,  50, 100, 130, 160,

                                  5,  60, 130,   6,  50, 100, 130,   5,
                                 20,  60,   4, 200,  50, 100, 130, 160, 
				 

				  5,  60,   4, 200,   3,  60,  5,    1,
				  };
const unsigned char noisfr[] = {

                                 40,   4,   0,  40,  12,   6,   0,   8,

                                 40,   4,   0,  40,  12,   6,   0,  40,
                                  8,   4,  40,   1,  12,   6,   0,   8, 
				  

				 40,   3,  40,   4,  40,   8,  40,   40,
				  };

#endif
void shitaudio(void *userdata, Uint8 *stream, int len) {
	#ifdef MUSA2
	float *ass;
	float sawout;

	int i;
	Sint16 *penis = (Sint16*)stream;
	for(; len > 0; len -= 2) {
		muslc -= (int)(0x1000000 * 6.25 / SAMPLERATE);
		filtfreq *= .9999f;
		filt2freq *= .9996f;
		if(muslc < 0) {
			int blao = 0, homoste;
			float kgg = (55.0f / SAMPLERATE / 4);
			musl++;
			if(musl >= 0x180) blao = 0x20;
			if(musl >= 0x300) blao = 0x40;
			if(musl < 0x3E0 && ( homoste =
			    bassla[(0xF & musl) + basslc[7 & musl >> 4] + blao] ) != NN) {


				for(i = homoste + basslb[0xF & musl >> 4]; --i; ) {
					kgg *= 1.05946309f;
				}
				osc_freq[0] = kgg * (musl < 0x300 && (musl & 0x101) == 0x101 ?4 :1);

				osc_freq[1] = kgg * 1.012f;
				osc_freq[2] = kgg * 0.9923456f * ((musl & 0x1C5) == 0x140 ?8 :1);

				if(musl < 0x240) filtfreq = .4f - .0028f * (0x7F & (0x80 & musl ?~musl :musl));
				else filtfreq = .3f - .004f * (0x3b & (0x41 & musl ?~musl :musl));

			}

			filtresn = 3.0f;
			if(1 & 0xB1111111 >> (musl & 0x1F)) filtresn = 0.6f;

			if((1 & 0x02101200 >> (musl & 0x1F)) && musl > 0x3A0) filtresn = 8.0f;

			if(musl >= 0x40 && musl < 0x400) {
				int kikkeli, p_and = 0x7, p_add = 0;
				if(musl >= 0xC0 && musl < 0x2C0) p_and = 0xF;
				if(musl >= 0x1C0) p_add = 0x8;
				if(musl >= 0x2F0) p_add = 0x18;
				filt2freq = .005f * noisff[(kikkeli = (p_and & musl) + p_add)];
				filt2resn = noisfr[kikkeli];
				if(musl >= 0xF8 && musl < 0x180) filt2resn = 2;
			}
			muslc += 0x1000000;
		}

		sawout = -0.5f * OSCN;
		for(i = 0; i < OSCN; i++) {
			ass = osc_phs + i;
			if((*ass += osc_freq[i]) >= 1) *ass -= 1;
			sawout += *ass;
		}
		lpfs[0] = sawout - filtresn * lpfs[3];
		ass = lpfs;
		while(ass < lpfs+3) {
			ass++;

			*ass = (1-filtfreq) * ass[0] + filtfreq * ass[-1];
		}
		lpfs[4] = (0x3FFF & (rndm = (13*rndm) ^ 0x6969)) - 0x2000 - filt2resn * lpfs[7];
		while(ass < lpfs+7) { /* oli pienempi n?in */
			ass++;
			if((*ass = (1-filt2freq) * ass[0] + filt2freq * ass[-1]) < -2*9000)
				*ass = -2*9000;
		}
		{
			int bclean = 2*7500;
			float bdrive = 0;
			if(musl >= 666 && (musl & 0x10) != 0) {
				bclean = 0;
				bdrive = 10;
			}
			if(musl >= 624 && musl < 666) {
				bdrive = (100.0f/(666-624)) * (musl - 640);
			}
					
			/**(penis++) = (12000 * lpfs[3]/3-5000 * cos(16*lpfs[3])/3 + 0.8f*lpfs[7]);*/
			/**(penis++) = (10000 * lpfs[3] + 0*1000 * sin(12*lpfs[3]) + 0.8f*lpfs[7]);*/
			/**(penis++) = (6000 * sin(100*lpfs[3]) + 0.8f*lpfs[7]);*/
			*(penis++) = bclean * lpfs[3] - 2*2000 * sini(bdrive * lpfs[3]) + lpfs[7];
		}
	}
	#endif
}
#endif



static int lol2()
{
	return j+((yy*pallo_koko)+xx)*3;
}

static float cosi(float kukko)
{
	return cosf(kukko);
}

static void create_pallo(int jako)
{		
	pii = PII;
	i = 0;
	j = pallo_koko*(pallo_koko/jako)*3;
	
	for (xx = 0; xx < pallo_koko; xx++)
	{
		float lol1 = (xx/(float)pallo_koko)*pii*2;
		for (yy = 0; yy < pallo_koko/jako; yy++)
		{
			float hassu = (yy/(float)pallo_koko)*pii*2;
			float lol = sini(hassu)*pallo_size;
			pallo_data[i] = lol * cosi(lol1);
			pallo_data[i+1] = cosi(hassu) * pallo_size;
 			pallo_data[i+2] = sini(lol1) * lol;
			pallo_data[lol2()]=pallo_data[i];
			pallo_data[j+i+1]= pallo_data[(xx*3)+1];
			pallo_data[lol2()+2]= pallo_data[i+2];
			i+=3;
		}
		if (xx%5 == 0)
		{	
		pii *= hassu1;
		pallo_size *= hassu2;
		}
	}

	glBufferDataARB( GL_ARRAY_BUFFER_ARB, pallo_koko*pallo_koko*sizeof(GLfloat)*3*2, pallo_data, GL_STREAM_DRAW_ARB );
	pallo_size = pallo_size1;
	
	
	glLoadIdentity();
}


static void hassu_optimointi()
{
}

static void scenario1()
{	
	
	/*
	pii = sini(aika/3000.0f)/75.0f;
	hassu1 = 1 + pii;
	hassu2 = 1 - pii;
	*/
	pii = sini(aika/3000.0f)/1500.0f;
	hassu1 += pii;
	hassu2 -= pii;
	
	glTranslatef(0.0f, 0.0f, 0.5f);
	glRotatef(180, 0.0f, 0.5f, 0.5f);
	do {
		glColor4f(0.1f+(xx/1024.0f),0.1f,0.9f-(xx/64.0f),0.1f*(2.0/((aika >> 8)%5+2.0f)));
		glVertexPointer(3, GL_FLOAT, 0, 0);
		glDrawArrays( 4, 0, pallo_koko*pallo_koko*2);
		glRotatef(0.2f, 0.0f, 0.5f, 0.5f);
	} while (xx-=32);
	create_pallo(1);
}

static void scenario2()
{
	glTranslatef(0,0,(40960-aika)*0.00028f);
	scenario1();
}

static void scenario3()
{
	if (aika>92400)
		pii = 650.0f;
	else if (aika>81500)
		pii = 200.0f;
	else
	{
		scenario2();
		pii = 600.0f;
	}
	glTranslatef(0.0f, 0.0f, -3.0f);
	glRotatef((aika-61440)/pii, sini((aika-61440)/(pii*100)), 1.0f, 1.0f);
	do {
		glColor4f(0.08f, 0.6f*(xx/128.0), 0.2f*(32.0f/xx), (15/pii)*(2.0/((aika >> 8)%10+1.3f)));
		glRotatef(8, 0.0f, cosi(aika/1000.0f), sini(aika/1000.0f));
		glVertexPointer(3, GL_FLOAT, 0, 0);
		glDrawArrays( GL_QUADS, 0, pallo_koko*pallo_koko*2);
	} while(xx-=16);
	create_pallo(1);
}



static void scenario4()
{
	glTranslatef(0.6f+hassu3, 0.0f, -2.0f);
	glColor4f(0.08f-hassu4*7, 0.09f, 0.7f+hassu4*7, 0.1f);
	glRotatef(aika/20.0f, 0.5f, 1.0f, 1.0f);
	abc = 3;
	do {
		glVertexPointer(3, GL_FLOAT, 0, 0);
		glDrawArrays( abc, 0, pallo_koko*pallo_koko*2);
		glRotatef(180, 1.0f, 1.0f, 1.0f);
		glColor4f(0.08f, 0.8f, 0.1f, 0.1f+hassu4);
		abc = 4;
	}
	while (xx-=pallo_koko/2);
	create_pallo(1);
}


static void scenario4_i()
{
	glTranslatef(0.0f, 0.0f, (106496-aika)/100.0f);
	scenario4();
}

static void scenario4_l()
{
	glTranslatef(0,0,(aika-143360)/10000.0f);
	hassu3=(122880-aika)/34133.0;
	hassu4-=0.000001f;
	scenario4();
	
	hassu1=1;
	hassu2=1;
	
	pii = sini((aika-143360)/3000.0f)/150.0f;
	hassu1 =  1 +fabs(pii);
	hassu2 =  1 -fabs(pii);
}

static void scenario5()
{
	abc = GL_QUADS;
	scenario1();
}


void _start()
{
	int alkuaika;

	#ifdef MUSA1
	SDL_AudioSpec as_d = {
		48000,		
		AUDIO_S16,	
		1,		
		0,		
		0x1000,		
		0,		
		0,		
		shitaudio,	
		NULL		
	};
	SDL_OpenAudio(&as_d, NULL);
	#endif
	

	SDL_Event e;
	SDL_SetVideoMode(1280,1024,32, SDL_OPENGL);
	glMatrixMode(GL_PROJECTION);
	SDL_ShowCursor(0);

	gluPerspective(45.0f,1280/1024.0f,0.1f,5.0f);
	glMatrixMode(GL_MODELVIEW);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE);
	glGenBuffersARB(2, &pallo);
	glEnableClientState(GL_VERTEX_ARRAY);
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, pallo);
	hassu1 = 1.005f;
	hassu2 = 0.97f;
	create_pallo(1);

	
	const static void (*scenario[])() = { scenario1, scenario2, scenario3, scenario4_i, scenario4, scenario4_l, scenario5};
	SDL_Delay(1500);
	SDL_PauseAudio(0);
	alkuaika = SDL_GetTicks();
	const unsigned char skenes[] ={39,59,99,103,119,139,165};
	do
	{
		aika=SDL_GetTicks() - alkuaika;
		SDL_Delay(15);
		if (aika<140000 || aika%2)
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
		
		if (aika>>10 > 160)
			break;
		int skoo = -1;
		while (aika>>10>skenes[++skoo]) {};
		scenario[skoo]();
		
		SDL_PollEvent(&e);
		SDL_GL_SwapBuffers();

  	} while (e.type!=SDL_KEYDOWN);
  	SDL_Quit();
  	asm ( \
  	"movl $1,%eax\n" \
  	"xor %ebx,%ebx\n" \
 	 "int $128\n" \
 	 );
}

