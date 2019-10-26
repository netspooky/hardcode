#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <math.h>
#include <stdlib.h>
#include <dsound.h>
extern float __fastcall pow_4k (float a, float b);
extern int __fastcall rand_4k(void);

#include "synth.h"
#include "play.cpp"

#define __FULLSCREEN__
DEVMODE dmScreenSettings;
// Pixel Format
PIXELFORMATDESCRIPTOR pfd = {
			sizeof(PIXELFORMATDESCRIPTOR),
			1,
			PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,
			PFD_TYPE_RGBA,
			32,				// Colour buffer bit depth
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			32,				// Depth buffer bit depth
			0, 0,
			PFD_MAIN_PLANE, 
			0, 0, 0, 0 };

#define sin(x) sinf(x)
#define cos(x) cosf(x)
#define sqrt(x) sqrtf(x)

// Codigo generado del caracter 65 al 90 ( 104 bytes).
static unsigned int fuente[]={
	// letras
	0x1297a526, 0x0e949d27, 0x0c908526, 0x0e94a527, 0x1e10bc2f, 
	0x02109c2f, 0x1d1e862e, 0x1294bd29, 0x0e210847, 0x0c94a108,
       	0x12928ca5, 0x1e108421, 0x231ad771, 0x231cd671, 0x1d18c62e,
       	0x0213a527, 0x20e6a526, 0x12949d27, 0x0c920926, 0x0842109f, 
	0x0c94a529, 0x08a54631, 0x23bad631, 0x23151151, 0x08422a31, 
	0x1e11110f,
	// numeros, ':', '"', "o", "\", "_", "/"
	0x1d1ad62e, 0x1c4210c4, 0x1e222126, 0x0c941126, 0x084794c4, // 95
       	0x0e841c2f, 0x1c938466, 0x0422110f, 0x0c949926, 0x0c843926, // 100
	0x08020000, 0x0000014a, 0x0c949800, 0x10821042, 0x3e000000, // 105
#ifdef RAYADA
	0x04221108, // 106
#endif

};

//static SDL_Surface *screen;

#define xres 800
#define yres 600

#define SQR(a) (a)*(a)

float speed=4.3f;

float t;

int seed = 0;

#ifndef _DEBUG
extern "C" int _fltused = 1;

// Float to integer cast
extern "C" int __cdecl _ftol2(float f)
{
	volatile int result;
	__asm fistp result;
	return result;
}

#endif


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

void fullscreenquad()
{
	glBegin(GL_QUADS);
	glTexCoord2f(0.0f,0.0f);
	glVertex2f(-1.5f,-1.5f);
	glTexCoord2f(1.0f,0.0f);
	glVertex2f(1.5f,-1.5f);
	glTexCoord2f(1.0f,1.0f);
	glVertex2f(1.5f,1.5f);
	glTexCoord2f(0.0f,1.0f);
	glVertex2f(-1.5f,1.5f);
	glEnd();

}

float text_size=0.01f;

void draw_text(char *cad, float x, float y)
{
	char ch;
	while ((ch=*cad++))
	{
		if (ch!=0x20)
		for (int f=0; f<6; ++f)
			for (int c=0; c<5; ++c)
			{
				//printf("x=%d, y=%d, z=%d\n", x+c, y-6+f, z);
				if (fuente[ch-'A']&(1<<(5*f+c)))
				{
					glBegin(GL_QUADS);
					glVertex2f(x+text_size*c, y-text_size*f);
					glVertex2f(x+text_size*c, y-text_size*(f+1));
					glVertex2f(x+text_size*(c+1), y-text_size*(f+1));
					glVertex2f(x+text_size*(c+1), y-text_size*f);
					glEnd();
				}
			}

		x+=6*text_size;
	}
}


float Noise (Uint32 x, Sint32 y)
{
        Sint32 n;
        float rtype;

        n = (x + y * 57);
        n = (n << 1) ^ n;

        rtype = (1.0f - ((n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0f);

        if (rtype < 0.0f)       {       rtype = -rtype;         }

        return rtype;
}

float fBm( float x, float y )
{
        float value=0.0f;//, remainder;
        int i;

        for (i=0; i<16; ++i) {
                value += Noise ((Uint32)x, (Uint32)y) * pow_4k( 0.3f, -0.1f*i );
                x *= 0.3f;
                y *= 0.3f;
        }
        /*
        remainder = octaves - (int)octaves;
        if ( remainder )
                value += remainder * Noise(x,y) * pow_4k(lacunarity,-H*i);
                */

        	return value;
}

#define TEX_WIDTH 512 
Uint8 tex_noise[TEX_WIDTH*TEX_WIDTH];


struct text_info
{
	char *texto;
	Uint8 btime, etime; // En 1/10 de segundo
	Uint8 x, y; // izq/abajo = 0, der/arriba=255
};

#define NTEXTOS 29 

struct text_info textos[]={
	{"GREETINGS TO\x65",92,134,5,55},
	{"ASYNKRO",94,95,35,40},
	{"BIXO",96,97,35,40},
	{"COLLAPSE",98,99,35,40},
	{"DREAMBYTES",100,101,35,40},
	{"DUST INC",102,103,35,40},
	{"FUZZION",104,105,35,40},
	{"GUM",106,107,35,40},
	{"HARDNULL",108,109,35,40},
	{"IP",110,111,35,40},
	{"NETWORK",112,113,35,40},
	{"RGBA",114,115,35,40},
	{"SECTOR OMEGA",116,117,35,40},
	{"SPONTZ",118,119,35,40},
	{"STRAVAGANZA",120,121,35,40},
	{"TDR",122,123,35,40},
	{"TLOTB",124,125,35,40},
	{"TPM",126,127,35,40},
	{"TPOLM",128,129,35,40},
	{"XPLSV",130,131,35,40},
	{"YOMIZMO",132,133,35,40},
	{"ZONA NEUTRA",134,135,35,40},
	{"SLACK      NECROSTUDIOS",144,156, 45, 150},
	{"\x66WE  ARE  NOT  ARTISTS\x66",145,156, 45, 130},
	{"BGPARTY \x5b\x60",148,156,93,100},
	{"ENJOY THE REST OF THIS INTRO", 165, 175, 5, 200},
	{"LONG AND BORING NOISEPRODS",169,179,5,30},
	{"CAN FIT IN \x5FK",169,179,30,20},
	{"\x68\x67\x69 AIIIIIIIIIIIIIIIIIIII",550,570,30,150},
};

#define INTRO_LENGTH 156.0f

char cont_buf[6];
float fade=0.0f;
float t0;

#ifdef RAYADA
char smiley_buf[4];
int last_smiley_row=1;
float smiley_x, smiley_y;
#endif

#define	DXREPLAY_RATE				44100
#define	DXREPLAY_BUFFERLEN			(1024*8)

typedef void (*DXUSER_CALLBACK) (void *pBuffer,long bufferLen);
// Structs for sound init
DSBUFFERDESC		bufferDesc={sizeof(DSBUFFERDESC), DSBCAPS_PRIMARYBUFFER};
WAVEFORMATEX		format={WAVE_FORMAT_PCM, 1, 44100, 44100*2, 2, 16};
DXUSER_CALLBACK		m_pUserCallback;
LPDIRECTSOUNDBUFFER	m_pBuffer;
DWORD				m_writePos;

__inline void _fastcall update(void)
{
	DWORD	playPos=0;
	DWORD	writeLen;
	LPVOID	p1,p2;
	DWORD	l1,l2;
	
	m_pBuffer->GetCurrentPosition(&playPos,NULL); // Posible pete, yo molo
	
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

void WINAPI threadRout(void)
{
	while (1)
	{
		update();
		Sleep(25);
	}

    //return 0;
}

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
		
	SetThreadPriority(CreateThread(NULL,0,(LPTHREAD_START_ROUTINE)threadRout,0,0,0),THREAD_PRIORITY_TIME_CRITICAL);
}

#ifdef _DEBUG
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
#else
extern "C" __declspec(noreturn) void WinMainCRTStartup()
#endif
{
	HWND	hWnd;
	HDC		hDC;

	for (Uint32 y = 0; y < TEX_WIDTH; ++y)
        for (Uint32 x = 0; x < TEX_WIDTH; ++x)
                tex_noise[x+y*TEX_WIDTH] = 32.0f*whitenoise()+224.0f*(fBm (x*.5f,y*.5f)-11.5f)/(17.5f-11.5f);

#ifdef __FULLSCREEN__
	dmScreenSettings.dmSize			=	sizeof(dmScreenSettings);
	dmScreenSettings.dmPelsWidth	=	xres;
	dmScreenSettings.dmPelsHeight	=	yres;
	dmScreenSettings.dmBitsPerPel	=	32;
	dmScreenSettings.dmFields		=	DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;

	// We set fullscreen mode
	ChangeDisplaySettings	(&dmScreenSettings,CDS_FULLSCREEN);

	// We hide the cursor
	ShowCursor(FALSE);
#endif

	// We create a window with the "EDIT" trick
	hWnd = CreateWindow("EDIT","EDIT",WS_POPUP|WS_VISIBLE, 0,0, xres, yres,0,0,0,0);
	hDC = GetDC(hWnd);
	SetPixelFormat(hDC, ChoosePixelFormat(hDC, &pfd), &pfd);

	// Opengl context bind
	wglMakeCurrent(hDC,wglCreateContext(hDC));

	open (hWnd, play);	

	glClearColor(0,0,0,0);
	glClear(GL_COLOR_BUFFER_BIT);
	SwapBuffers(hDC);
	glClear(GL_COLOR_BUFFER_BIT);
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	//GLuint textura;
	//glGenTextures(1, &textura);
	//glBindTexture(GL_TEXTURE_2D, textura);
	gluBuild2DMipmaps(GL_TEXTURE_2D, GL_LUMINANCE8, 
			TEX_WIDTH, TEX_WIDTH, GL_LUMINANCE, GL_UNSIGNED_BYTE,
			tex_noise);
	do	
	{ 
		t = current_time/speed;
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(70+40*sin(t), 1.33, 0.01,10);
		glMatrixMode(GL_MODELVIEW);	
		glLoadIdentity();
		gluLookAt(0.2f*sin(0.1f*t),0.2f*cos(0.4f*t),-1.0f,
				0.0f,0.0f,0.0f,
				0.0f,1.0f,0.0f);
		if (t-t0 > 0.030f)
		{
			for (Uint32 y = 0; y < TEX_WIDTH; ++y)
			for (Uint32 x = 0; x < TEX_WIDTH; ++x)
				tex_noise[x+y*TEX_WIDTH] -= (rand_4k()%3)-2;
			t0=t;
		}
		
		gluBuild2DMipmaps(GL_TEXTURE_2D, GL_LUMINANCE8, 
				TEX_WIDTH, TEX_WIDTH, GL_LUMINANCE, GL_UNSIGNED_BYTE,
				tex_noise);
			
		//glClear(GL_COLOR_BUFFER_BIT);
		glColor4f(0.5f*(sin(0.4f*t)+1.3f),0.5f*(sin(0.6f*t)*cos(0.3f*t)+1.3f),0.5f*(cos(0.5f*t)+1.3f),0.01f);	
		glEnable(GL_TEXTURE_2D);
		glRotatef(98.0f*cos(0.62f*t), 0.0f,0.0f,1.0f);
		fullscreenquad();	
	
		// Preparamos las matrices para dibujar texto	
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glMatrixMode(GL_MODELVIEW);	
		glLoadIdentity();
		
		// textos "programados"
		glDisable(GL_TEXTURE_2D);
		glColor4f(1.0,1.0,1.0,1.0);
		for (int i=0; i<NTEXTOS; ++i)
		{
			if ( ((rows_played-1)*song.row_duration >= textos[i].btime) &&
				((rows_played-1)*song.row_duration < textos[i].etime) )
			{
				draw_text(textos[i].texto,
					textos[i].x/128.0f-1.0f,
					textos[i].y/128.0f-1.0f);
			}
		}
		
		// Contador de tiempo
		int total_secs=599.0f-current_time;
		int mins=total_secs/60;
		int secs=total_secs%60;
		
		cont_buf[0]=91; // nuestro '0' particular
		cont_buf[1]=91+mins;
		cont_buf[2]=101;
		cont_buf[3]=91+secs/10;
		cont_buf[4]=91+secs%10;
		
		draw_text(cont_buf, -0.95f, 0.95f);	

		#ifdef RAYADA	
		if (rows_played - last_smiley_row == 16)
		{
			smiley_buf[0]=0x68+fn.rand()%2;
			smiley_buf[1]='\x67'; // 'o'
			smiley_buf[2]=0x69+fn.rand()%2;
			last_smiley_row = rows_played;
		}

		draw_text(smiley_buf, -0.76f, 0.171875f);	
		#endif
		
		if (fabsf(current_time-INTRO_LENGTH)<10.0f)
		{
			glColor4f(0.0f,0.0f,0.0f,fade);
			fullscreenquad();
			fade = 0.15f-(INTRO_LENGTH-current_time)/50.0f;
			global_vol = (INTRO_LENGTH-current_time)/10.0f;
		}
		
		
		//SDL_Delay(30);
		SwapBuffers(hDC);
	} while(current_time < 599.0f && !GetAsyncKeyState(VK_ESCAPE));

	ExitProcess (0);
}
