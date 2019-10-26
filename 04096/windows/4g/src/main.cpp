// 4g by JuhoAP 2011

#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include "windows.h"
#include "mmsystem.h"
#include "mmreg.h"
#include <gl\GL.h>
#include <gl\GLU.h>

// define this if you have a multicore cpu and can spare ~10 bytes for realtime playback
// undef for sound precalc
#define USE_SOUND_THREAD

////////////////////////////////////////////////
// sound
////////////////////////////////////////////////

// some song information
#include "4klang.h"

// MAX_SAMPLES gives you the number of samples for the whole song. we always produce stereo samples, so times 2 for the buffer
SAMPLE_TYPE	lpSoundBuffer[MAX_SAMPLES*2];  
HWAVEOUT	hWaveOut;

/////////////////////////////////////////////////////////////////////////////////
// initialized data
/////////////////////////////////////////////////////////////////////////////////

#pragma data_seg(".wavefmt")
WAVEFORMATEX WaveFMT =
{
#ifdef FLOAT_32BIT	
	WAVE_FORMAT_IEEE_FLOAT,
#else
	WAVE_FORMAT_PCM,
#endif		
    2, // channels
    SAMPLE_RATE, // samples per sec
    SAMPLE_RATE*sizeof(SAMPLE_TYPE)*2, // bytes per sec
    sizeof(SAMPLE_TYPE)*2, // block alignment;
    sizeof(SAMPLE_TYPE)*8, // bits per sample
    0 // extension not needed
};

#pragma data_seg(".wavehdr")
WAVEHDR WaveHDR = 
{
	(LPSTR)lpSoundBuffer, 
	MAX_SAMPLES*sizeof(SAMPLE_TYPE)*2,			// MAX_SAMPLES*sizeof(float)*2(stereo)
	0, 
	0, 
	0, 
	0, 
	0, 
	0
};

MMTIME MMTime = 
{ 
	TIME_SAMPLES,
	0
};

/////////////////////////////////////////////////////////////////////////////////
// crt emulation
/////////////////////////////////////////////////////////////////////////////////

extern "C" 
{
	int _fltused = 1;
}

/////////////////////////////////////////////////////////////////////////////////
// Initialization
/////////////////////////////////////////////////////////////////////////////////

#pragma code_seg(".initsnd")
void  InitSound()
{
#ifdef USE_SOUND_THREAD
	// thx to xTr1m/blu-flame for providing a smarter and smaller way to create the thread :)
	CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0);
#else
	_4klang_render(lpSoundBuffer);
#endif
	waveOutOpen			( &hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
	waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
	waveOutWrite		( hWaveOut, &WaveHDR, sizeof(WaveHDR) );	
}

HDC			hDC=NULL;
HGLRC		hRC=NULL;
HWND		hWnd=NULL;
HINSTANCE	hInstance;

//LRESULT	CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);	// Declaration For WndProc

float	zoom=-100.0f;
GLuint	loop;

#define	MAX_PARTICLES	81920
typedef struct						// Create A Structure For Particle
{
	float	life;					// Particle Life
	float	fade;					// Fade Speed
	float	r;						// Red Value
	float	g;						// Green Value
	float	b;						// Blue Value
	float	x;						// X Position
	float	y;						// Y Position
	float	z;						// Z Position
	float	xi;						// X Direction
	float	yi;						// Y Direction
	float	zi;						// Z Direction
	float	xg;						// X Gravity
	float	yg;						// Y Gravity
	float	zg;						// Z Gravity
	int    smp;						// trigger area
}
particles;							// Particles Structure
particles particle[MAX_PARTICLES];
bool triggerit[5];

int m_w = 1;    /* must not be zero */
int m_z = 2;    /* must not be zero */
int rand()
{
    m_z = 36969 * (m_z & 65535) + (m_z >> 16);
    m_w = 18000 * (m_w & 65535) + (m_w >> 16);
    return (m_z << 16) + m_w;
}

int InitGL(GLvoid)										// All Setup For OpenGL Goes Here
{
	glShadeModel(GL_SMOOTH);							// Enable Smooth Shading
	glClearColor(0.0f,0.0f,0.0f,0.0f);					// Black Background
	glClearDepth(1.0f);									// Depth Buffer Setup
	glDisable(GL_DEPTH_TEST);							// Disable Depth Testing
	glEnable(GL_BLEND);									// Enable Blending
	glBlendFunc(GL_SRC_ALPHA,GL_ONE);					// Type Of Blending To Perform
	glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);	// Really Nice Perspective Calculations
	glHint(GL_POINT_SMOOTH_HINT,GL_NICEST);				// Really Nice Point Smoothing

	float x1 = -75.0f;
	float y1 = -43.0f;
	float z1 = -30.0f;
	float x2 = -75.0f;
	float y2 = -43.0f;
	float z2 = -30.0f;
	for (loop=0;loop<MAX_PARTICLES;loop++)						// Initializes All The Textures
	{
		//particle[loop].life=1.0f;								// Give All The Particles Full Life
		particle[loop].fade=0.1f;								// fade
		//particle[loop].xi = float((rand()%50)-25.0f)*10.0f;
		//particle[loop].yi = float((rand()%50)-25.0f)*10.0f;
		//particle[loop].zi = float((rand()%50)-25.0f)*10.0f;
		//particle[loop].r = 0.0f;
		//particle[loop].g = 0.0f;
		//particle[loop].b = 0.0f;
		particle[loop].x=x1;									// Center On X Axis
		particle[loop].y=y1;									// Center On Y Axis
		particle[loop].z=z1;									// Center On Z Axis
		x1 += 1.0f;
		if (x1 > -x2) { x1 = x2; }
		y1 += 1.0f;
		if (y1 > -y2) { y1 = y2; }
		z1 += 1.0f;
		if (z1 > -z2) { z1 = z2; }

		// asetetaan sampleille alueet avaruudessa
		if ((x1>-9 && x1<9) && (y1>-7 && y1<7)) { particle[loop].smp = 1;}		// BD = keskusta
		else if ((x1>-22 && x1<22) && (y1>-16 && y1<16)) { particle[loop].smp = 3;}	// SD = keskustan ympärys
		else if (y1>17 || y1<-17) { particle[loop].smp = -1; }						// ylä- ja alareunat
		else { particle[loop].smp = 0; }
	}

	for (int i=0; i<5; i++) {
		triggerit[i] = false;
	}
	
	return TRUE;										// Initialization Went OK
}

void DrawGLScene(void)										// Here's Where We Do All The Drawing
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);		// Clear Screen And Depth Buffer
	//glLoadIdentity();										// Reset The ModelView Matrix

	float x;
	float y;
	float z;

	for (loop=0;loop<MAX_PARTICLES;loop++)
	{
		x=particle[loop].x + particle[loop].xi/100;
		y=particle[loop].y + particle[loop].yi/100;
		z=particle[loop].z+zoom;

		glColor4f(particle[loop].r,particle[loop].g,particle[loop].b,particle[loop].life);
		glBegin(GL_TRIANGLE_STRIP);
			glTexCoord2d(1,1); glVertex3f(x+0.5f,y+0.5f,z);
			glTexCoord2d(0,1); glVertex3f(x-0.5f,y+0.5f,z);
			glTexCoord2d(1,0); glVertex3f(x+0.5f,y-0.5f,z);
			glTexCoord2d(0,0); glVertex3f(x-0.5f,y-0.5f,z);
		glEnd();

		particle[loop].xi+=particle[loop].xg;			// Take Pull On X Axis Into Account
		particle[loop].yi+=particle[loop].yg;			// Take Pull On Y Axis Into Account
		particle[loop].zi+=particle[loop].zg;			// Take Pull On Z Axis Into Account

		particle[loop].life-=particle[loop].fade;		// Reduce Particles Life By 'Fade'

		if (triggerit[0] && particle[loop].smp == 1)
		{
			particle[loop].life=0.4f;							// Give It New Life
			particle[loop].r=1.0f;			// Select Red From Color Table
			particle[loop].g=1.0f;			// Select Green From Color Table
			particle[loop].b=1.0f;			// Select Blue From Color Table
			particle[loop].xi=0.0f;	// Random Speed On X Axis
			particle[loop].yi=0.0f;	// Random Speed On Y Axis
			particle[loop].zi=0.0f;	// Random Speed On Z Axis
			particle[loop].xg=0.0f;				// Set Horizontal Pull To Zero
			particle[loop].yg=0.0f;				// Set Vertical Pull To Zero
			particle[loop].zg=0.0f;				// Set Pull On Z Axis To Zero
		}

		if (triggerit[1] && particle[loop].smp == 3)
		{
			particle[loop].life=1.0f;							// Give It New Life
			particle[loop].r=0.0f;			// Select Red From Color Table
			particle[loop].g=1.0f;			// Select Green From Color Table
			particle[loop].b=0.0f;			// Select Blue From Color Table
			particle[loop].xi=float((rand()%50)-25.0f);	// Random Speed On X Axis
			particle[loop].yi=float((rand()%50)-25.0f);	// Random Speed On Y Axis
			particle[loop].zi=float((rand()%50)-25.0f);	// Random Speed On Z Axis
			particle[loop].xg=float(rand()%32)-16;				// Set Horizontal Pull To Zero
			particle[loop].yg=float(rand()%32)-16;				// Set Vertical Pull To Zero
			particle[loop].zg=float(rand()%32)-16;				// Set Pull On Z Axis To Zero
			zoom=-100.0f+rand()%75;
		}

		if (triggerit[2] && particle[loop].smp == 0)
		{
			particle[loop].life=0.3f;							// Give It New Life
			particle[loop].r=0.0f;			// Select Red From Color Table
			particle[loop].g=0.0f;			// Select Green From Color Table
			particle[loop].b=1.0f;			// Select Blue From Color Table
			particle[loop].xi=float((rand()%50)-25.0f)*10.0f;	// Random Speed On X Axis
			particle[loop].yi=float((rand()%50)-25.0f)*10.0f;	// Random Speed On Y Axis
			particle[loop].zi=float((rand()%50)-25.0f)*10.0f;	// Random Speed On Z Axis
			particle[loop].xg=float(rand()%64)-32;				// Set Horizontal Pull To Zero
			particle[loop].yg=float(rand()%64)-32;				// Set Vertical Pull To Zero
			particle[loop].zg=float(rand()%64)-32;				// Set Pull On Z Axis To Zero
		}

		if (triggerit[3] && particle[loop].smp == -1)
		{
			particle[loop].life=0.5f;							// Give It New Life
			particle[loop].r=0.5f;			// Select Red From Color Table
			particle[loop].g=0.0f;			// Select Green From Color Table
			particle[loop].b=0.5f;			// Select Blue From Color Table
			particle[loop].xi=float((rand()%50)-25.0f)*10.0f;	// Random Speed On X Axis
			particle[loop].yi=float((rand()%50)-25.0f)*10.0f;	// Random Speed On Y Axis
			particle[loop].zi=float((rand()%50)-25.0f)*10.0f;	// Random Speed On Z Axis
			particle[loop].xg=float(rand()%32)-16;				// Set Horizontal Pull To Zero
			particle[loop].yg=float(rand()%32)-16;				// Set Vertical Pull To Zero
			particle[loop].zg=float(rand()%32)-16;				// Set Pull On Z Axis To Zero
		}

		if (triggerit[4] && particle[loop].smp == -1)
		{
			particle[loop].life=1.0f;							// Give It New Life
			particle[loop].r=0.5f;			// Select Red From Color Table
			particle[loop].g=0.0f;			// Select Green From Color Table
			particle[loop].b=0.0f;			// Select Blue From Color Table
			particle[loop].xi=float((rand()%50)-25.0f)*10.0f;	// Random Speed On X Axis
			particle[loop].yi=float((rand()%50)-25.0f)*10.0f;	// Random Speed On Y Axis
			particle[loop].zi=float((rand()%50)-25.0f)*10.0f;	// Random Speed On Z Axis
			particle[loop].xg=float(rand()%128)-64;				// Set Horizontal Pull To Zero
			particle[loop].yg=float(rand()%128)-64;				// Set Vertical Pull To Zero
			particle[loop].zg=float(rand()%128)-64;				// Set Pull On Z Axis To Zero
			zoom=-100.0f+rand()%90;
		}
	}
}

BOOL CreateGLWindow(char* title, int width, int height, int bits, bool fullscreenflag)
{
	WNDCLASS	wc;						// Windows Class Structure
	RECT		WindowRect;				// Grabs Rectangle Upper Left / Lower Right Values
	WindowRect.left=(long)0;			// Set Left Value To 0
	WindowRect.right=(long)width;		// Set Right Value To Requested Width
	WindowRect.top=(long)0;				// Set Top Value To 0
	WindowRect.bottom=(long)height;		// Set Bottom Value To Requested Height

	hInstance			= GetModuleHandle(NULL);				// Grab An Instance For Our Window
	wc.style			= CS_HREDRAW | CS_VREDRAW | CS_OWNDC;	// Redraw On Size, And Own DC For Window.
	wc.lpfnWndProc		= DefWindowProc;
	wc.cbClsExtra		= 0;									// No Extra Window Data
	wc.cbWndExtra		= 0;									// No Extra Window Data
	wc.hInstance		= hInstance;							// Set The Instance
	wc.hIcon			= 0;//LoadIcon(NULL, IDI_WINLOGO);			// Load The Default Icon
	wc.hCursor			= 0;//LoadCursor(NULL, IDC_ARROW);			// Load The Arrow Pointer
	wc.hbrBackground	= NULL;									// No Background Required For GL
	wc.lpszMenuName		= NULL;									// We Don't Want A Menu
	wc.lpszClassName	= "OpenGL";								// Set The Class Name

	RegisterClass(&wc);

	DEVMODE dmScreenSettings;								// Device Mode
	//memset(&dmScreenSettings,0,sizeof(dmScreenSettings));	// Makes Sure Memory's Cleared
	dmScreenSettings.dmSize=sizeof(dmScreenSettings);		// Size Of The Devmode Structure
	dmScreenSettings.dmPelsWidth	= width;				// Selected Screen Width
	dmScreenSettings.dmPelsHeight	= height;				// Selected Screen Height
	dmScreenSettings.dmBitsPerPel	= bits;					// Selected Bits Per Pixel
	dmScreenSettings.dmFields=DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;

	ChangeDisplaySettings(&dmScreenSettings,CDS_FULLSCREEN);

	AdjustWindowRectEx(&WindowRect, WS_POPUP, FALSE, WS_EX_APPWINDOW);		// Adjust Window To True Requested Size

	// Create The Window
	hWnd=CreateWindowEx(	WS_EX_APPWINDOW,							// Extended Style For The Window
								"OpenGL",							// Class Name
								title,								// Window Title
								WS_POPUP |							// Defined Window Style
								WS_CLIPSIBLINGS |					// Required Window Style
								WS_CLIPCHILDREN,					// Required Window Style
								0, 0,								// Window Position
								WindowRect.right-WindowRect.left,	// Calculate Window Width
								WindowRect.bottom-WindowRect.top,	// Calculate Window Height
								NULL,								// No Parent Window
								NULL,								// No Menu
								hInstance,							// Instance
								NULL);

	
	static	PIXELFORMATDESCRIPTOR pfd=				// pfd Tells Windows How We Want Things To Be
	{
		sizeof(PIXELFORMATDESCRIPTOR),				// Size Of This Pixel Format Descriptor
		1,											// Version Number
		PFD_DRAW_TO_WINDOW |						// Format Must Support Window
		PFD_SUPPORT_OPENGL |						// Format Must Support OpenGL
		PFD_DOUBLEBUFFER,							// Must Support Double Buffering
		PFD_TYPE_RGBA,								// Request An RGBA Format
		bits,										// Select Our Color Depth
		0, 0, 0, 0, 0, 0,							// Color Bits Ignored
		0,											// No Alpha Buffer
		0,											// Shift Bit Ignored
		0,											// No Accumulation Buffer
		0, 0, 0, 0,									// Accumulation Bits Ignored
		16,											// 16Bit Z-Buffer (Depth Buffer)  
		0,											// No Stencil Buffer
		0,											// No Auxiliary Buffer
		PFD_MAIN_PLANE,								// Main Drawing Layer
		0,											// Reserved
		0, 0, 0										// Layer Masks Ignored
	};
	
	hDC=GetDC(hWnd);
	SetPixelFormat(hDC,ChoosePixelFormat(hDC,&pfd),&pfd);
	wglMakeCurrent(hDC, wglCreateContext(hDC));

	ShowWindow(hWnd,SW_SHOW);						// Show The Window
	SetForegroundWindow(hWnd);						// Slightly Higher Priority
	SetFocus(hWnd);									// Sets Keyboard Focus To The Window

	glViewport(0,0,width,height);						// Reset The Current Viewport

	glMatrixMode(GL_PROJECTION);						// Select The Projection Matrix
	glLoadIdentity();									// Reset The Projection Matrix

	// Calculate The Aspect Ratio Of The Window
	gluPerspective(55.0f,(GLfloat)width/(GLfloat)height,0.1f,100.0f);

	glMatrixMode(GL_MODELVIEW);							// Select The Modelview Matrix
	glLoadIdentity();									// Reset The Modelview Matrix

	SetCursor(NULL);
	ShowCursor(FALSE);										// Hide Mouse Pointer

	return TRUE;									// Success
}

/////////////////////////////////////////////////////////////////////////////////
// entry point for the executable if msvcrt is not used
/////////////////////////////////////////////////////////////////////////////////
#pragma code_seg(".main")
void WINAPI WinMainCRTStartup(void)

{
	MSG		msg;
	CreateGLWindow("4g",1280,720,32,TRUE);

	InitGL();
	InitSound();

	float trig_bd;
	float trig_sd;
	float trig_rp;
	float trig_mp;
	float trig_lp;

	do
	{
		if (PeekMessage(&msg,NULL,0,0,PM_REMOVE))	// Is There A Message Waiting?
		{
			if (msg.message==WM_QUIT)				// Have We Received A Quit Message?
			{
				ExitProcess(0);							// If So done=TRUE
			}
			else									// If Not, Deal With Window Messages
			{
				TranslateMessage(&msg);				// Translate The Message
				DispatchMessage(&msg);				// Dispatch The Message
			}
		}
		else										// If There Are No Messages
		{
			// get sample position for timing
			waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
		
			trig_bd = (&_4klang_envelope_buffer)[((MMTime.u.sample >> 8) << 5) + 2*4+0];
			trig_sd = (&_4klang_envelope_buffer)[((MMTime.u.sample >> 8) << 5) + 2*12+0];
			trig_rp = (&_4klang_envelope_buffer)[((MMTime.u.sample >> 8) << 5) + 2*1+0];
			trig_mp = (&_4klang_envelope_buffer)[((MMTime.u.sample >> 8) << 5) + 2*0+0];
			trig_lp = (&_4klang_envelope_buffer)[((MMTime.u.sample >> 8) << 5) + 2*10+0];
		
			if (!triggerit[0] && trig_bd > 0.7f)
			{
				triggerit[0] = true;
			}
			if (trig_bd < 0.7f)
			{
				triggerit[0] = false;
			}

			if (!triggerit[1] && trig_sd > 0.7f)
			{
				triggerit[1] = true;
			}
			if (trig_sd < 0.7f)
			{
				triggerit[1] = false;
			}

			if (!triggerit[2] && trig_rp > 0.8f)
			{
				triggerit[2] = true;
			}
			if (trig_rp < 0.8f)
			{
				triggerit[2] = false;
			}

			if (!triggerit[3] && trig_mp > 0.7f)
			{
				triggerit[3] = true;
			}
			if (trig_mp < 0.7f)
			{
				triggerit[3] = false;
			}

			if (!triggerit[4] && trig_lp > 0.8f)
			{
				triggerit[4] = true;
			}
			if (trig_lp < 0.8f)
			{
				triggerit[4] = false;
			}


			// do your intro mainloop here
			DrawGLScene();
			SwapBuffers(hDC);
		}
	} while (MMTime.u.sample < MAX_SAMPLES && !GetAsyncKeyState(VK_ESCAPE));
	ExitProcess(0);
}
