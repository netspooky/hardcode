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

#define whitenoise() rand_4k()/(float)RAND_MAX

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
//#define expf(x) __builtin_expf(x)

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

//static SDL_Surface *screen;

#define xres 800
#define yres 600

#define SQR(a) (a)*(a)

#define t (current_time)

#define GRIDSIZE 1500.0f
#define GRIDSTEP 50.0f

#define HALFARRAY (int)(GRIDSIZE/GRIDSTEP)
#define ARRAYSIZE 2*HALFARRAY

float grid_state[ARRAYSIZE][ARRAYSIZE][ARRAYSIZE];

#ifdef TEXTOS
float grid_text[ARRAYSIZE][ARRAYSIZE][ARRAYSIZE];
#endif

int seed = 0;

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

__inline void fullscreenquad()
{
        glBegin(GL_QUADS);
			glVertex3f(-1.0f,-1.0f, 0.0f);
			glVertex3f(1.0f,-1.0f, 0.0f);
			glVertex3f(1.0f,1.0f, 0.0f);
			glVertex3f(-1.0f,1.0f, 0.0f);
        glEnd();
}


void __fastcall activa(int a, int b, int c, float val)
{
		grid_state[a][b][c] += val;
		if (grid_state[a][b][c] > 1.0f)
			grid_state[a][b][c]=1.0f;
		//printf("%f\n",grid_state[a][b][c]);
}

#ifdef TEXTOS
void draw_text(char *cad, int x, int y, int z)
{
	char ch;
	while ((ch=*cad++))
	{
		for (int f=0; f<6; ++f)
			for (int c=0; c<5; ++c)
			{
				//printf("x=%d, y=%d, z=%d\n", x+c, y-6+f, z);
				if (fuente[ch-'A']&(1<<(5*f+c)))
					grid_text[x+c][y-f][z]=1.0f;

			}

		x+=6;
	}
}
#endif


float cube_r, cube_g, cube_b;
Uint8 negativo;

float fade;

// x,y,z -> esquina inf. izq.
// size -> lado
// alpha -> ...ejem...
void draw_cube(float x, float y, float z, float size, float alpha)
{
	float Dy=y-size;
	float Dz=z-size;
	float Dx=x+size;

	glColor4f(cube_r, cube_g, cube_b,alpha);

        glBegin(GL_TRIANGLE_FAN);
        glVertex3f(x,y,z);
        glVertex3f(x,Dy,z);//y-tam,z);
        glVertex3f(Dx,Dy,z);//x+tam,y-tam,z);
        glVertex3f(Dx,y,z); //x+tam,y,z);               // Cara frontal
        glVertex3f(Dx,y,Dz );//x+tam,y,z-tam);
        glVertex3f(x,y,Dz);//z-tam);            // Cara superior
        glVertex3f(x,Dy,Dz);//y-tam,z-tam);
        glVertex3f(x,Dy,z);//y-tam,z);          // Cara izquierda
        glEnd();

        glBegin(GL_TRIANGLE_FAN);
        glVertex3f(Dx,Dy,Dz);//x+tam,y-tam,z-tam);
        glVertex3f(Dx,y,Dz);//x+tam,y,z-tam);
        glVertex3f(x,y,Dz);//z-tam);
        glVertex3f(x,Dy,Dz);//y-tam,z-tam);     // Cara trasera
        glVertex3f(Dx,Dy,z); //x+tam,y-tam,z);
        glVertex3f(Dx,Dy,z);//x+tam,y-tam,z);   // Cara inferior
        glVertex3f(Dx,y,z);//x+tam,y,z);
        glVertex3f(Dx,y,Dz);//x+tam,y,z-tam);   // Cara derecha
        glEnd();

}

static float rotated_angle, rotated_x, rotated_y, rotated_z;

static void rotated_cube(int i, int j, int k)
{
	int l=1;
	int res_i, res_j, res_k, res_l;
	float rot[16];
	glPushMatrix();
	glLoadIdentity();
	glRotatef(rotated_angle,rotated_x,rotated_y,rotated_z);
	glGetFloatv(GL_MODELVIEW_MATRIX, rot);
	glPopMatrix();
	res_i=(int)(i*rot[0]+j*rot[4]+k*rot[8]+l*rot[12]);
	res_j=(int)(i*rot[1]+j*rot[5]+k*rot[9]+l*rot[13]);
	res_k=(int)(i*rot[2]+j*rot[6]+k*rot[10]+l*rot[14]);
	res_l=(int)(i*rot[3]+j*rot[7]+k*rot[11]+l*rot[15]);

	grid_state[res_i+HALFARRAY]
		[res_j+HALFARRAY]
		[res_k+HALFARRAY]=0.5;

}

static void fill_ball(int x, int y, int z, int radio)
{
	int i,j,k;
	for (i=x-radio; i<=x+radio; ++i)
	{
		for (j=y-radio; j<=y+radio; ++j)
		{
			for (k=z-radio; k<=z+radio; ++k)
			{
				float dist=sqrtf((float)(SQR(i-x)+SQR(j-y)+SQR(k-z)));
				float val=1.0f-dist/radio;
				if (val<0.0f) val=0.0f;
				activa(i+HALFARRAY,j+HALFARRAY,k+HALFARRAY,val/6.0f);
			}
		}
	}
}

static void do_metaballs()
{
	int sin_t =(int)(20.0f*sin(t));
	int sin_2t=(int)(20.0f*sin(2.1f*t));
	int sin_3t=(int)(20.0f*sin(0.4f*t));
	fill_ball(sin_t,	sin_2t,		sin_3t, 8);	
	fill_ball(sin_t,	sin_3t,		sin_2t, 8);	
	fill_ball(sin_2t,	sin_t,		sin_3t, 8);
	fill_ball(sin_2t,	sin_3t,		sin_t, 8);
	fill_ball(sin_3t, 	sin_t,		sin_2t, 8);	
	fill_ball(sin_3t, 	sin_2t,		sin_t, 8);	
}


static void do_snake()
{
	// "Shadebob"
	
	int a,b,c;

	a=HALFARRAY+(int)(20.0f*sin(2.0f*t));
	b=HALFARRAY+(int)(20.0f*sin(3.0f*t));
	c=HALFARRAY+(int)(20.0f*cos(4.0f*t));

	//activa(a,b,c,1.0);
	float factor=0.5f;
	int dist=5;
	for (int i=-dist; i<dist; ++i)
		for (int j=-dist; j<dist;++j)
			for (int k=-dist; k<dist; ++k)
			{
				float x=sqrtf((float)(i*i+j*j+k*k));
				if (x!=0)
					activa(a+i,b+j,c+k,factor*whitenoise()/x);
			}

}

static void do_bigcube(int size, float rx, float ry, float rz, float angle)
{
	int i;
	rotated_x=rx;
	rotated_y=ry;
	rotated_z=rz;
	rotated_angle=angle;
	for (i=-size; i<=size; ++i)
	{
		rotated_cube(i,size,size);
		rotated_cube(i,-size,size);
		rotated_cube(i,-size,-size);
		rotated_cube(i,size,-size);
		rotated_cube(size,i,size);
		rotated_cube(-size,i,size);
		rotated_cube(-size,i,-size);
		rotated_cube(size,i,-size);
		rotated_cube(size,size,i);
		rotated_cube(-size,size,i);
		rotated_cube(-size,-size,i);
		rotated_cube(size,-size,i);
	}
	
	
}

#ifdef TEXTOS
struct text
{
	char *texto;
	int px,py,pz;
	float rx,ry,rz,angle;
};
#endif

#define NTEXTOS 6

float GRID_DECAY=0.1f;
float GRID_THRESHOLD=0.01f;
int cube_size=5;
int current_effect;

#ifdef TEXTOS
struct text textos[]={ 
	{"DELANTE", 10,20,0, 0,0,0,0}, 
	{"IZQUIERDA", 4,20,0,0,1,0,90},
	{"DETRAS", 10,20,0,0,1,0,180},
	{"DERECHA", 10,20,0,0,1,0,270},
	{"ARRIBA",10,20,0,1,0,0,90},
	{"ABAJO",10,20,0,1,0,0,270},
};
#endif

//Uint8 end;

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

#ifdef OUTFILE
	fout = fopen(OUTFILE, "wb");
#endif

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

	while(!GetAsyncKeyState(VK_ESCAPE))
	{		
		//cube_r=0.1f+0.05*sin(0.25f*t);
		//cube_g=0.5f+0.5*sin(t);
		//cube_b=0.5f+0.5*cos(0.5f*t);
		cube_r=cube_g=cube_b=0.20f;
		
		if (negativo)
		{
			cube_r=cube_g=cube_b=1.0f;
		}
		
		//glMatrixMode(GL_PROJECTION);
		//glLoadIdentity();
		if (negativo)
			gluPerspective(70.0f, 1.33f, 0.1f,10000.0f);
		else
			gluPerspective(115.0f+5.0f*sin(current_time),1.33f,0.1f,10000.0f);
		
		glMatrixMode(GL_MODELVIEW);
		//glLoadIdentity();
		gluLookAt(2000.0f*cos(0.5f*t)*sin(0.2f*t), 2000.0f*sin(0.5f*t)*sin(0.2f*t), 2000.0f*cos(0.2f*t), 0.0f,0.0f,0.0f,0.2f*sin(2.0f*t), 1.0f, 0.0f);
		
		if (negativo)
			glClearColor(0.1f,0.2f,0.3f,0.0f);
		else
			glClearColor(1.0f,1.0f,1.0f,1.0f);
		
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		if (negativo)
			glColor4f(1.0f,1.0f,1.0f,0.01f);
		else
			glColor4f(0.0f,0.0f,0.0f,0.01f);
		
		glDisable(GL_DEPTH_TEST);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		//glEnable(GL_LINE_SMOOTH);
		glBegin(GL_LINES);
		for (float j=-GRIDSIZE; j<GRIDSIZE; j+=GRIDSTEP)
			for (float i=-GRIDSIZE; i<GRIDSIZE; i+=GRIDSTEP)
			{
					glVertex3f(i, j, -GRIDSIZE);
					glVertex3f(i, j, GRIDSIZE);
					glVertex3f(-GRIDSIZE, j, i);
					glVertex3f(GRIDSIZE, j, i);
					glVertex3f(j, -GRIDSIZE, i);
					glVertex3f(j, GRIDSIZE, i);
			}

			glVertex3f(-10.0f,0.0f,0.0f);
			glVertex3f(10.0f,0.0f,0.0f);
		glEnd();

		
		
		if (current_effect==0)
		{
			GRID_DECAY=0.01f;
			GRID_THRESHOLD=0.01f;
			do_snake();
		}
		else if (current_effect==1)
		{
			GRID_DECAY=0.18f;
			GRID_THRESHOLD=0.01f;
			do_bigcube(12,sin(t),cos(t),sin(t)*cos(t),50.0f*t);
			do_bigcube(cube_size,cos(t),sin(t),sin(2*t)*cos(t),50.0f*t);
		}
		else
		
		{
			GRID_DECAY=0.1f;
			GRID_THRESHOLD=0.05f;
			do_metaballs();
		}	
		
#ifdef TEXTOS	
		if (cur_row == 0)
		{
			i=cur_pos%NTEXTOS;
			draw_text(textos[i].texto,
				textos[i].px, textos[i].py, textos[i].pz);
		}
#endif	
		
		for (int x=0; x<ARRAYSIZE; ++x)
			for (int y=0; y<ARRAYSIZE; ++y)
				for (int z=0; z<ARRAYSIZE; ++z)
				{
					float alpha=grid_state[x][y][z];
					if (alpha > GRID_THRESHOLD)
					{
						draw_cube(GRIDSTEP*(x-HALFARRAY),
								GRIDSTEP*(y-HALFARRAY),
								GRIDSTEP*(z-HALFARRAY), 
								GRIDSTEP, alpha);
					}
					grid_state[x][y][z] -= GRID_DECAY;
					if (grid_state[x][y][z] < 0.0f) grid_state[x][y][z]=0.0f;
				}

#ifdef TEXTOS
		glRotatef(textos[i].angle, textos[i].rx, textos[i].ry, textos[i].rz);
		for (int x=0; x<ARRAYSIZE; ++x)
			for (int y=0; y<ARRAYSIZE; ++y)
				for (int z=0; z<ARRAYSIZE; ++z)
				{
					float alpha=grid_text[x][y][z];
					if (alpha > 0.01f)
					{
						grid_text[x][y][z] -= 0.1f;
						draw_cube(GRIDSTEP*(x-HALFARRAY),
								GRIDSTEP*(y-HALFARRAY),
								GRIDSTEP*(z-HALFARRAY), 
								GRIDSTEP, alpha);
					}
				}
#endif
		glColor4f(0,0,0,fade);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();		
		fullscreenquad();

		//Sleep (10);

		SwapBuffers(hDC);
	}

	ExitProcess (0);

#ifdef OUTFILE
	fclose(fout);
#endif
}
