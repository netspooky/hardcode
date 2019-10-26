#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <dsound.h>
#include <math.h>

//#define __PREGENERATE_TRACK__ // Pregenerate the whole track, fucks up the sync
//#define __REORDERED_PATTERNS__ // Reordered patterns test
#define __FULLSCREEN__ // Fullscreen or not, this is the question
#define w_screen 640
#define h_screen 480

#ifdef __PREGENERATE_TRACK__
	#include "data.h"
#endif

#include "synth.h"
#include "play.h"

#define NUM_VOICES 24
#define MAX_PARTICLES 3000

#include "song.h"

#define	DXREPLAY_RATE				44100
#define	DXREPLAY_BUFFERLEN			(1024*8)
typedef void (*DXUSER_CALLBACK) (void *pBuffer,long bufferLen);

#ifndef _DEBUG
extern "C" int _fltused = 1;
#endif

// Structs for sound init
DSBUFFERDESC		bufferDesc={sizeof(DSBUFFERDESC), DSBCAPS_PRIMARYBUFFER};
WAVEFORMATEX		format={WAVE_FORMAT_PCM, 1, 44100, 44100*2, 2, 16};

// Pixel Format
PIXELFORMATDESCRIPTOR pfd = {
			sizeof(PIXELFORMATDESCRIPTOR),
			1,
			PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,
			PFD_TYPE_RGBA,
			32,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			32,
			0, 0,
			PFD_MAIN_PLANE, 
			0, 0, 0, 0 };


float				fadeout=1.0f, rotate=70.0f;
float				mix_buf[BUFFER_SIZE]={0}, osc=0.0f, bombo=0.0f, rotacion=0.0f, ruido=0.0f, current_time=0.0f;
int					cur_pos=0, rows_played=0, fin=0, last=0, num_particles = 0, cur_row=0;
Uint8				buf_scanline[128*128];
Uint8				buf_tex[128*128];
Uint8				tex_particle[128*128];
float				pos[MAX_PARTICLES*2];
DEVMODE				dmScreenSettings;
float				chanvols[NUM_CHANNELS]={0};
Voice				voices[NUM_VOICES*2]={0};

#ifndef __PREGENERATE_TRACK__
	DXUSER_CALLBACK		m_pUserCallback;
	LPDIRECTSOUNDBUFFER	m_pBuffer;
	DWORD				m_writePos;
#endif

int					seed = 0;	// Random number generator seed

// Ripped from VC libs :)
int __fastcall rand_4k(void) 
{
	__asm 
	{
		mov		eax, dword ptr [seed]
		imul	eax, 0x000343FD
		add		eax, 0x00269EC3
		mov		dword ptr [seed], eax
		sar		eax, 10
		and		eax, 0x00007FFF
	};
}

// Fmod as seen in http://www.xyzw.de, a bit modified to use floats
float __fastcall fmod_4k(float a,float b)
{
	__asm
	{
		fld			dword ptr [b];
		fld			dword ptr [a];
		fprem;

		fstp		st(1);
		fstp		dword ptr [a];
	}

	return a;
}

// Slowest pow ever
float __fastcall pow_4k (float a, float b)
{
	__asm
	{
		fld			dword ptr [b];
		fld			dword ptr [a];
		fyl2x
		fld			st
		frndint
		fsub		st(1),st
		fxch		st(1)
		f2xm1
		fld1
		fadd
		fscale
		fstp		st(1)
		fstp		dword ptr [a]
	}

	return a;
} 

#ifndef __PREGENERATE_TRACK__

// Update routine for the synth
__inline void _fastcall update(void)
{
	DWORD	playPos=0;
	DWORD	writeLen;
	LPVOID	p1,p2;
	DWORD	l1,l2;
	
	m_pBuffer->GetCurrentPosition(&playPos,NULL); // Posible pete, yo molo :: Posible bug XD
	
	if (m_writePos < playPos)
		writeLen = playPos - m_writePos;
	else
		writeLen = DXREPLAY_BUFFERLEN - (m_writePos - playPos);
	
	m_pBuffer->Lock(m_writePos,writeLen,&p1,&l1,&p2,&l2,0);
	
	if ((p1) && (l1>0)) m_pUserCallback(p1,l1);
	if ((p2) && (l2>0)) m_pUserCallback(p2,l2);
	
	m_pBuffer->Unlock(p1,l1,p2,l2);
	m_writePos += writeLen;
	
	if (m_writePos >= DXREPLAY_BUFFERLEN) m_writePos -= DXREPLAY_BUFFERLEN;
}


// Synth thread loop
void WINAPI threadRout(void)
{
	while (1)
	{
		update();
		Sleep(25);
	}

    //return 0;
}

// DSound setup and thread init
void _fastcall open(HWND hWnd, DXUSER_CALLBACK pUserCallback)
{
	LPDIRECTSOUND		m_pDS;
	LPDIRECTSOUNDBUFFER	m_pPrimary;

	m_writePos = 0;
	m_pUserCallback = pUserCallback;
	::DirectSoundCreate(0, &m_pDS, 0);
				
	m_pDS->SetCooperativeLevel(hWnd,DSSCL_EXCLUSIVE);
	m_pDS->CreateSoundBuffer(&bufferDesc,&m_pPrimary, NULL);
	m_pPrimary->SetFormat(&format);

	bufferDesc.dwFlags = DSBCAPS_GETCURRENTPOSITION2;
	bufferDesc.dwBufferBytes = DXREPLAY_BUFFERLEN;
	bufferDesc.lpwfxFormat = &format;
	m_pDS->CreateSoundBuffer(&bufferDesc,&m_pBuffer,NULL);
		
	m_pBuffer->Play(0, 0, DSBPLAY_LOOPING);
		
	CreateThread(NULL,0,(LPTHREAD_START_ROUTINE)threadRout,0,0,0);
}

#endif


// Main synth routine
void play (void *stream, long len)
{	
	int num_samples=len>>1;
	int i;

#ifndef __REORDERED_PATTERNS__
	Pattern *cur_ptn;
#endif

	Track *cur_trk;
	Voice *vc;

	current_time += num_samples/SAMPLE_RATE;

	memset(mix_buf, 0, BUFFER_SIZE*sizeof(float));

	if ((current_time - rows_played*0.1515151f) > 0.1515151f)
	{
		++rows_played;

		if (cur_row == TRACK_LENGTH) // Pattern end, next pattern
		{
			cur_row = 0;

			if (++cur_pos==14) // Track end
			{
				fin=1; 
				ruido=0.0f;
			}
		}		

#ifdef __REORDERED_PATTERNS__
		int pos = song.ptn_list[cur_pos]; // With reordered patterns
#else
		cur_ptn=&song.ptns[song.ptn_list[cur_pos]];
#endif

		for (i=0; i<NUM_CHANNELS; ++i)
		{
			char note, vol;

#ifdef __REORDERED_PATTERNS__
			cur_trk = &song.tracks[song.ptns[i].tracks[pos]];
#else
			cur_trk = &song.tracks[cur_ptn->tracks[i]];
#endif

			note = cur_trk->note[cur_row];
			
			vol = cur_trk->vol[cur_row];

			if (vol)
			{
				// If we change the value to 512.0f, it sounds like the original, but too low, imho
				//
				// A 512.0f (como la original) comprime mas, pero suena uber-bajo imho (slack es un mamon)
				chanvols[i] = vol/220.0f;
			}

			if (note)
			{
				if (!cur_row)
				{
					osc = 1.0f;
					rotacion += 90.0f;
				}
				if (!i)
				{
					bombo = 0.0f;
				}
				if (i==1 && !fin)
				{
					ruido = 0.3f;			
				}

#ifdef __REORDERED_PATTERNS__
				note += song.ptns[i].transpose[pos];
#else
				note += cur_ptn->transpose[i];
#endif

				vc = &voices[(++last)%NUM_VOICES];
				vc->ins = &song.insts[i];
				vc->chnvol = chanvols[i];
				vc->pitch = 440.0f*pow_4k(2.0f, (note-45.0f)/12.0f);
				vc->active = 1;
				vc->pos = 0;
			}
		}

		++cur_row;
	}

	// Now, we synthetize the voices
	for (i=0; i<NUM_VOICES; ++i)
	{
		if (voices[i].active)
		{
			voices[i].active=synth(&voices[i], num_samples, mix_buf);
		}
	}

	// Convert the sound to 16bit
	for (i=0; i<num_samples; ++i)
	{
		((Sint16 *)stream)[i]=(Sint16)(mix_buf[i]*fadeout*32767.0f);
	}

	if (!fin) 
	{
		ruido -= num_samples/SAMPLE_RATE;
	}
	else 
	{
		ruido += 0.006f;
	}
}

void __fastcall fullscreenquad()
{
	glBegin(GL_QUADS);
		glTexCoord2f(0.0f,0.0f);
		glVertex2f(-1.0f,-1.0f);
		glTexCoord2f(1.0f,0.0f);
		glVertex2f(1.0f,-1.0f);
		glTexCoord2f(1.0f,1.0f);
		glVertex2f(1.0f,1.0f);
		glTexCoord2f(0.0f,1.0f);
		glVertex2f(-1.0f,1.0f);
	glEnd();
}

void __fastcall draw_particles(void)
{
	int i;
	float PARTICLE_SCALE = 1.0f+2.0f/(bombo*bombo);

	glBegin(GL_QUADS);
	for(i = 0; i < num_particles; i++)
	{
		float x = pos[i*2] + 0.75f + 0.05f*sinf(i+rotate * 0.1f);
		float y = pos[i*2+1];

		glTexCoord2f(0, 0);
		glVertex2f(x, y);
		glTexCoord2f(1, 0);
		glVertex2f(x + PARTICLE_SCALE*0.075f, 0 + y);
		glTexCoord2f(1, 1);
		glVertex2f(x + PARTICLE_SCALE*0.075f, PARTICLE_SCALE*0.1f + y);
		glTexCoord2f(0, 1);
		glVertex2f(x, PARTICLE_SCALE*0.1f + y);

		pos[i*2+1]+=0.01f+(i%3)*0.0015f;
	}
	glEnd();
}

#define NUMTEXTURES 3
#define SQR(x) ((x)*(x))

// Oscilloscope of the first sequence
void __fastcall oscilloscope()
{
	//glDisable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, 0); // == glDisable(GL_TEXTURE_2D);, compresses better

	glBegin(GL_POINTS);
	for (int i=0; i<BUFFER_SIZE; ++i)
	{
		float x,y;
		float amp = abs(mix_buf[i]*4.0f);
		int ix=i-HALF_BS;

		y=0.8f*mix_buf[i];

		if (cur_pos<6)
		{
			if (cur_pos<2)
			{
				x=ix/(float)HALF_BS;
			}			
			else
			{
				y -= 1.0f;
				x = (ix/30*30)/(float)HALF_BS; 
			}
			
			glColor4f(amp, 0.3f, 1.0f-amp,1.0f); 
			glVertex2f(x, y);	
			glVertex2f(x, y+2.0f);	
		}
	}
	glEnd();
	//glEnable(GL_TEXTURE_2D);
}

#ifdef __PREGENERATE_TRACK__

// Wave header
PLAYERWAVE mywave;
PLAYHEADER header = {'R','I','F','F',
					sizeof(PLAYERWAVE)+NUMSAMPLES*NUMLOOPS*2,
					'W','A','V','E','f','m','t',' ',
					0x10,1,1,
					PLAYFREQ,
					PLAYFREQ*2,
					2,16,'d','a','t','a',
					SAMPLESIZE*NUMLOOPS};

// Worst hack ever to get better compression
//short			datawave[NUMSAMPLES*NUMLOOPS*2];
#endif

#ifdef _DEBUG
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
#else
extern "C" __declspec(noreturn) void WinMainCRTStartup()
#endif
{
	HWND	hWnd;
	HDC		hDC;
	GLuint	texturas[NUMTEXTURES];
	float	cosphi, costheta, sinphi, sintheta,
			cosphi2, sinphi2,
			x1,y1,osc_inicial;
	int		i,j;

#ifdef __FULLSCREEN__
	dmScreenSettings.dmSize			=	sizeof(dmScreenSettings);
	dmScreenSettings.dmPelsWidth	=	w_screen;
	dmScreenSettings.dmPelsHeight	=	h_screen;
	dmScreenSettings.dmBitsPerPel	=	32;
	dmScreenSettings.dmFields		=	DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;

	// We set fullscreen mode
	ChangeDisplaySettings	(&dmScreenSettings,CDS_FULLSCREEN);

	// We hide the cursor
	ShowCursor(FALSE);
#endif

	// We create a window with the "EDIT" trick
	hWnd = CreateWindow("EDIT","EDIT",WS_POPUP|WS_VISIBLE, 0,0, w_screen, h_screen,0,0,0,0);
	hDC = GetDC(hWnd);
	SetPixelFormat(hDC, ChoosePixelFormat(hDC, &pfd), &pfd);

	// Opengl context bind
	wglMakeCurrent(hDC,wglCreateContext(hDC));

	// here, we create the flare texture
	// and the noise+flare texture (for the background)
	for (i=0; i<128; ++i)
	{
		for (j=0;j<128;++j)
		{
			int d = SQR(i - 64) + SQR(j - 64);
			unsigned char c = 0;
			
			if(d < 64*64)
				c = 255 - (unsigned char)(255.0f * sqrtf((float)d)/64.0f);

			tex_particle[128*j+i] = c;

			c=((Uint8)( 128 + 127 * sinf(  (float)i/(74+90*cosf((float)j)))
                                  * cosf(3*(float)j/(62+35*sinf((float)i)))) * c) >>7;
			buf_tex[128*j+i]=255-c;
		}
	}

	glGenTextures(NUMTEXTURES, texturas);	
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND); // All the colors have correct alphas, so we will use blending for everything

	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);

	glBindTexture(GL_TEXTURE_2D, texturas[1]);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE8, 128, 128, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, buf_tex);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	glBindTexture(GL_TEXTURE_2D, texturas[2]);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE8, 128, 128, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, tex_particle);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

#ifdef __PREGENERATE_TRACK__

	//mywave = (PLAYERWAVE*) GlobalAlloc (GPTR, sizeof (PLAYERWAVE));
	memcpy (&mywave, &header, sizeof (PLAYERWAVE) - NUMSAMPLES*NUMLOOPS*2);

	for (i = 0; i < 2048; i++)
	{
		//play (&mywave.datawave[1024*i], 2048);
		play (&mywave.datawave[1024*i], 2048);
	}

	current_time = rows_played = cur_pos = cur_row = 0;

	PlaySound((char*)&mywave,NULL,SND_ASYNC|SND_MEMORY);

#else

	open (hWnd, play);

#endif

	//cur_pos = 6;
	glPointSize(10);
	while(!GetAsyncKeyState(VK_ESCAPE))
	{
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		oscilloscope();
		
		if (cur_pos<2) goto nextframe;

		glColor4f(0.4f,0.4f,0.4f,1.0f);

		glBindTexture(GL_TEXTURE_2D, texturas[1]);
		
		fullscreenquad();

		oscilloscope();

		glBindTexture(GL_TEXTURE_2D, texturas[1]);
		glEnable(GL_COLOR_MATERIAL);
		glEnable(GL_DEPTH_TEST);
		
		glMatrixMode(GL_PROJECTION);
		gluPerspective (70,1.33f,1.0f,220.0f);

		glMatrixMode(GL_MODELVIEW);
		gluLookAt(0,0,7.5f,0,0,0,0,1.0f,0);

		rotate += 1.0f;

		glColor4f(0.8f,0.9f,1.0f,1.0f);
		
        glEnable(GL_TEXTURE_GEN_S);
		glEnable(GL_TEXTURE_GEN_T);

		osc+=0.45f;

		if (cur_pos < 6)
		{
			bombo+=0.5f;
			goto no_bola;
		}
		else
		{
			bombo=1.0f;
		}

		cosphi=1;
		sinphi=0;	

		glRotatef(5.0f*rotate, 1.0f, 1.0f, 1.0f);
		osc_inicial=(cur_pos == 6 ? 0.5f : 1.0f);
		glTranslatef((1.0f/osc_inicial)*2.5f*sinf(osc*osc_inicial)/(0.5f*osc), 0.0f, 0.3f);

		#define RESOLUCION 0.1f
		for (float phi = 0; phi < DOSPI; phi += RESOLUCION)
		{
			sinphi2=sinf(phi+RESOLUCION);
			cosphi2=cosf(phi+RESOLUCION);
			glBegin(GL_QUAD_STRIP);
			for (float theta = -PI/2.0f; theta <= PI/2.0f+RESOLUCION; theta+=RESOLUCION)
			{
				costheta = cos(theta);
				sintheta = sin(theta);
				
				float _rad1=2.5f+0.3f*sin(3.0f*sinf(0.1f*rotate)*(cur_pos%4+0.6f)*theta+rotate);

				x1=costheta*cosphi;
				y1=costheta*sinphi;
				glNormal3f(x1, y1, sintheta); 
				glVertex3f(x1*_rad1, y1*_rad1, sintheta*_rad1); 

				x1=costheta*cosphi2;
				y1=costheta*sinphi2;
				glNormal3f(x1, y1, sintheta); 
				glVertex3f(x1*_rad1, y1*_rad1, sintheta*_rad1); 
			}
			glEnd();
			cosphi=cosphi2;
			sinphi=sinphi2;
		}
no_bola:

		glDisable(GL_TEXTURE_GEN_S);
		glDisable(GL_TEXTURE_GEN_T);

		glLoadIdentity();
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();

		glDisable(GL_DEPTH_TEST);
		
		for (i=0; i<128; ++i)
		{
			for (j=0; j<128; ++j)
			{
				buf_scanline[128*i+j]=((i&1) && (!fin)?0x00:0xFF)+rand_4k()%30-15;
			}
		}

		glBlendFunc(GL_SRC_COLOR, GL_ONE);//GL_ONE_MINUS_SRC_COLOR);
		glBindTexture(GL_TEXTURE_2D, texturas[2]);

		glColor4f(0.7f, 0.7f, 1.0f, 1.0f);
		draw_particles();//0.75f); Original parameter, converted to fixed value
						// (que no servia para una mierda al final, vaya)
		glRotatef(180.0f+rotacion,0.0f,0.0f,1.0f);
		draw_particles();//0.75f); Original parameter, converted to fixed value
						// (que no servia para una mierda al final, vaya)					
		glRotatef(180.0f-rotacion,0.0f,0.0f,1.0f);

		if(num_particles < MAX_PARTICLES)
		{
			pos[num_particles*2] = (float)(rand_4k()%100)*0.001f;
			pos[num_particles*2+1] = -1.2f;
			num_particles++;
		}

		glBindTexture(GL_TEXTURE_2D, texturas[0]);

		glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE8, 128, 128, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, buf_scanline);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		glColor4f(fadeout, fadeout, fadeout,1.5f*ruido);

		if (cur_pos>14) 
		{
			fadeout	/= 1.1f;
			if (fadeout < 0.00001f) 
				break;
		}

		fullscreenquad();

nextframe:
		SwapBuffers(hDC);
		Sleep(40);

#ifdef __PREGENERATE_TRACK__
		play (mywave.datawave, 4096);
#endif
	}

	ExitProcess(0);
}