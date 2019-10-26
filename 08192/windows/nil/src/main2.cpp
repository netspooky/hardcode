// todo:
// fullscreen
// asm?
// texturing..

#include "stdinc.hpp"

#include <cstdlib>
#include <cmath>


#include <ctime>
#include <climits>

#include "Vertex.hpp"
#include "Section.hpp"

#include "Texture.hpp"


#include "ParticleEffect.hpp"
#include "FlareEffect.hpp"
#include "StarEffect.hpp"



LONGLONG timerLastTime=0;
double timerFreq;

void StartTimer()
{
	LARGE_INTEGER temp;

	QueryPerformanceFrequency( &temp );

	timerFreq= double( temp.QuadPart );

	QueryPerformanceCounter( &temp );

	timerLastTime= temp.QuadPart;
}


float TimerTick()
{
	LARGE_INTEGER temp;
	double currTime;
	float returnValue;

	QueryPerformanceCounter( &temp );
	currTime= temp.QuadPart;

	returnValue= (double(currTime-timerLastTime)/timerFreq );
	
	timerLastTime= currTime;

	return returnValue;
}













static char *winName = "o8k";
static int winX = 0, winY = 0;
const float natrualWinHeight= 240;
static int winWidth = 320, winHeight = 240;




bool doneDemo= false;


/*
void GenRing( Vertex* buf, int segments, double width, double radius )
{
	double segStep= 2.0*M_PI/double(segments);


	for( int i= 0; i<segments; i++ )
	{
		double 
			rp0= i*segStep;
		Vertex v;

		v.x= radius;
		v.y= 0;
		v.z= width/2.0;
		v.Rotate( 0, 0, 0 + rp0 );


		buf[ i*4 ]= v;

		v.x= radius;
		v.y= 0;
		v.z= -width/2.0;
		v.Rotate( 0, 0, 0 + rp0 );

		buf[ i*4 + 1 ]=v;

		v.x= radius;
		v.y= 0;
		v.z= -width/2.0;
		v.Rotate( 0, 0, 0 + rp0 + segStep );

		buf[ i*4 + 2 ]= v;

		v.x= radius;
		v.y= 0;
		v.z= width/2.0;
		v.Rotate( 0, 0, 0 + rp0 + segStep );

		buf[ i*4 + 3 ]= v;
	}
}

void RenderCircle( const double xPos, const double yPos,
	const double radius )
{
	const int segs= 20; // 10 + radius;
	const double stepSize= (2.0*M_PI)/double(segs);

	glBegin( GL_TRIANGLE_FAN );
//		glColor4f( 1.0, 1.0, 1.0, 0.5 );

		glVertex2f( xPos, yPos );

		double inc= 0;
		for( int i= 0; i< segs+1; i++ )
		{
			glVertex2d( xPos+sin( inc )*radius, yPos + cos( inc )*radius );
			inc+= stepSize;
		}
	glEnd();
}
*/
/*
double ftNewSize[]=
{ 
	0.5, 0.5, 0.5, 0.5 
};
double ftNewPos[]=
{ 
	0.25, -0.25, 
	-0.25, -0.25,
	-0.25, 0.25, 
	0.25, 0.25,
};


void DoFractalThingSub( const double xPos, const double yPos,
	const double size )
{
	if( size > 1.0 )
	{
		RenderCircle( xPos, yPos, size );

		DoFractalThingSub( 
			xPos + size*ftNewPos[ 0 ], yPos + size*ftNewPos[ 1 ],
			size*ftNewSize[ 0 ] );

		DoFractalThingSub( 
			xPos + size*ftNewPos[ 2 ], yPos + size*ftNewPos[ 3 ],
			size*ftNewSize[ 1 ] );

//		DoFractalThingSub( 
//			xPos + size*ftNewPos[ 4 ], yPos + size*ftNewPos[ 5 ],
//			size*ftNewSize[ 2 ] );
//		DoFractalThingSub( 
//			xPos + size*ftNewPos[ 6 ], yPos + size*ftNewPos[ 7 ],
//			size*ftNewSize[ 3 ] );

	}
}
*/
/*
void DoFractalThing( const double totalTime )
{

	double radius= 30.0;
	double cx= 0, cy= 0;
	double px= 9, py=0;

	double xOff= cx - px, yOff= cy - px;

	double dist= sqrt( xOff*xOff + yOff*yOff );

	ftNewSize[ 0 ]= sqrt( dist*radius )/radius;

	ftNewPos[ 0 ]= px/radius;
	ftNewPos[ 1 ]= py/radius;


	double radius= 30.0;
	double split= sin( totalTime/1000.0 )*10.0 + 15.0;
	{
		double newRadius= split;
		double angle= 0;
		double dx= sin( angle ), dy=cos( angle);
		double px= 0, py= 0;
		
		double dist= (radius - newRadius)/radius;
		
		ftNewSize[ 0 ]= newRadius/radius;
		
		ftNewPos[ 0 ]= dist*dx;
		ftNewPos[ 1 ]= dist*dy;
	}
	{
		double newRadius= radius - split;
		double angle= M_PI;
		double dx= sin( angle ), dy=cos( angle);
		double px= 0, py= 0;
		
		double dist= (radius - newRadius)/radius;
		
		ftNewSize[ 1 ]= newRadius/radius;
		
		ftNewPos[ 2 ]= dist*dx;
		ftNewPos[ 3 ]= dist*dy;
	}
	// 
	DoFractalThingSub( 0, 0, radius );
}
*/
/*
void DoSucky( const double totalTime )
{
	Section s;

	s.verts= vertexBuffer;
	s.start= 0;
	s.end= 0;
	
	s.GenLineCube( 10, 60.0 );
	
	vertexBufferSize= s.end;
	
	//		s.Rotate( 0, 0, r );
	
	s.SetColor( 1.0, 1.0, 1.0, 1.0 );

	{
		Vertex v;
		v.x= 60.0;
		v.y= 0;
		v.z= 0;

		v.Rotate( totalTime/100.0, totalTime/30.0, totalTime/20.0 );
		s.Suction( 10.0, v.x, v.y, v.z );

		v.x= 10.0;
		v.y= 0;
		v.z= 0;
		v.Rotate( totalTime/70.0, totalTime/25.0, totalTime/55.0 );
		s.Suction( 10.0, v.x, v.y, v.z );

		v.x= 0.0;
		v.y= 60;
		v.z= 0;

		v.Rotate( totalTime/89.0, totalTime/30.0, totalTime/20.0 );
		s.Suction( 10.0, v.x, v.y, v.z );
	}
	
	s.Render();
}
*/

void DoLetterDisplay( const byte *letter, float activity )
{
	glEnable( GL_TEXTURE_2D );

	gluLookAt( 
		0,0,100,
		0,0,0,
		0, 1.0, 0 );
	memset( letterTexture.data, 0, textureWidth*textureHeight );
	RenderLetter( letterTexture, letter );
	HorizontalBlur( letterTexture, frand()*activity + (1.0-activity) );
	VerticalBlur( letterTexture, frand()*activity + (1.0-activity) );

	glGenTextures(1, &letterTexture.name );
	glBindTexture(GL_TEXTURE_2D, letterTexture.name );
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glTexImage2D( 
		GL_TEXTURE_2D, 
		0, 1, textureWidth, textureHeight, 
		0, GL_LUMINANCE, GL_UNSIGNED_BYTE, letterTexture.data );

	glBegin( GL_QUADS );
		glColor3d( 1.0, 1.0, 1.0 );

		glTexCoord2f( 0, 1.0 );
		glVertex3d( -30.0, -30.0, 0.0 );

		glTexCoord2f( 0, 0 );
		glVertex3d( -30.0, 30.0, 0.0 );

		glTexCoord2f( 1.0, 0 );
		glVertex3d( 30.0, 30.0, 0.0 );

		glTexCoord2f( 1.0, 1.0 );
		glVertex3d( 30.0, -30.0, 0.0 );
	glEnd();

	glDisable( GL_TEXTURE_2D );	
}

void DoLotsOfLetters( const float frameTime )
{
	static float totalTime= 0;
	static int period= 0;

	totalTime+= frameTime;

	if( totalTime > 2.0 )
	{
		totalTime-= 2.0;
		period++;
	}

	const byte *letter;

	switch( period%3 )
	{
	case 0:
		letter= letterN;
		break;
	case 1:
		letter= letterI;
		break;
	case 2:
		letter= letterL;
		break;
	}

	DoLetterDisplay( letter, 1.0 );
}


void
initialize(void)
{
    /* set the projection transformation */
    glMatrixMode(GL_PROJECTION);
    glFrustum(-0.5F, 0.5F, -0.5F, 0.5F, 1.0F, 200.0F);
	glScalef( 1.0, float(winWidth)/float(winHeight), 1.0 );


	glClearColor( 0.0, 0.0, 0.0, 0.0 );

 //   glEnable( GL_DEPTH_TEST );
    glEnable( GL_POINT_SMOOTH );

	glEnable( GL_BLEND );
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

	InitTextures();
	InitParticleEffect();
	InitStarEffect();
	InitFlareEffect();

	StartTimer();
	TimerTick();
}

void
resize(void)
{
    /* set the viewport to cover the window */
    glViewport(0, 0, winWidth, winHeight);
}




void redraw(void)
{
//	glRotatef( 1.4, 0, 1.0, 0.3 );


/*
	vertexBufferSize= 40*4;
	GenRing( &vertexBuffer[0], 40, 6.0, 50.0 );


	{
		Section s;
		s.verts= vertexBuffer;
		s.type= GL_QUADS;
		s.size= 40*4;

		s.Rotate( 0, 0, r );
		s.SetColor( 1.0, 0.0, 0.0, 1.0 );
		s.Render();
	}
*/
/*
	{
		Section s;
		s.verts= vertexBuffer;
		s.start= 0;
		s.end= 0;

		s.GenLineCube( 10, 60.0 );

		vertexBufferSize= s.end;

		cout << vertexBufferSize << endl;

//		s.Rotate( 0, 0, r );

		s.SetColor( 1.0, 1.0, 1.0, 1.0 );

		s.Suction( totalTime/10.0 );

		glPushMatrix();
			glRotated( totalTime/10.0, .2, .5, .8 );
			s.Render();
		glPopMatrix();
	}
*/

//	DoSucky( totalTime );
	float frameTime= TimerTick();
	static float totalTime= 0;

	totalTime+= frameTime;

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	float timing[]= { 3.0, 15.0, 3.0, 15.0, 3.0, 15.0, 6.0, 0 };

	static int part= 0;
	static float partTime= 0;

	partTime+= frameTime;

	if( partTime > timing[ part ] )
	{
		partTime-= timing[ part ];
		part++;
	}

	glPushMatrix();
	glMatrixMode( GL_MODELVIEW );
	glPushMatrix();
	glMatrixMode( GL_PROJECTION );

//	DoFlareEffect( frameTime );

	switch( part )
	{
	case 0:
		DoLetterDisplay( letterN, 0.4 );
		glClearColor( 0.0, 0.0, 0.0, 0.0 );
		break;
	case 1:
		DoParticleEffect( frameTime );
		glClearColor( 0.5, 0.5, 0.5, 0.5 );
		break;
	case 2:
		DoLetterDisplay( letterI, 0.8 );
		glClearColor( 0.0, 0.0, 0.0, 0.0 );
		break;
	case 3:
		DoFlareEffect( frameTime );
		break;
	case 4:
		DoLetterDisplay( letterL, 1.0 );
		break;
	case 5:
		DoStarEffect( frameTime );
		break;
	case 6:
		DoLotsOfLetters( frameTime );
		break;
	case 7:
		exit( -1 );
		break;
	};
	
	glPopMatrix();
	glMatrixMode( GL_MODELVIEW );
	glPopMatrix();
	glMatrixMode( GL_PROJECTION );
}

/************************************************************/

/*
** Win32 Window System Specific Code
*/

static char *className = "OpenGL";
static HDC hDC;
static HGLRC hGLRC;
static HPALETTE hPalette;
static BOOL needsRedisplay = TRUE;

void
doRedisplay(void)
{
//    if (needsRedisplay) 
//	{
		redraw();
		SwapBuffers(hDC);
		needsRedisplay = FALSE;
//    }
}

void
redisplay(void)
{
    needsRedisplay = TRUE;
}


void
setupPixelFormat(HDC hDC)
{
    PIXELFORMATDESCRIPTOR pfd = {
	sizeof(PIXELFORMATDESCRIPTOR),	/* size */
	1,				/* version */
	PFD_SUPPORT_OPENGL |
	PFD_DRAW_TO_WINDOW |
	PFD_DOUBLEBUFFER,		/* support double-buffering */
	PFD_TYPE_RGBA,			/* color type */
	32,				/* prefered color depth */
	0, 0, 0, 0, 0, 0,		/* color bits (ignored) */
	0,				/* no alpha buffer */
	0,				/* alpha bits (ignored) */
	0,				/* no accumulation buffer */
	0, 0, 0, 0,			/* accum bits (ignored) */
	16,				/* depth buffer */
	1,				/* no stencil buffer */
	0,				/* no auxiliary buffers */
	PFD_MAIN_PLANE,			/* main layer */
	0,				/* reserved */
	0, 0, 0,			/* no layer, visible, damage masks */
    };
    int pixelFormat;

    pixelFormat = ChoosePixelFormat(hDC, &pfd);
    if (pixelFormat == 0) {
	MessageBox(WindowFromDC(hDC), "ChoosePixelFormat failed.", "Error",
		MB_ICONERROR | MB_OK);
	exit(1);
    }

    if (SetPixelFormat(hDC, pixelFormat, &pfd) != TRUE) {
	MessageBox(WindowFromDC(hDC), "SetPixelFormat failed.", "Error",
		MB_ICONERROR | MB_OK);
	exit(1);
    }
}


LRESULT APIENTRY
WndProc(
    HWND hWnd,
    UINT message,
    WPARAM wParam,
    LPARAM lParam)
{
    static GLint x0, x1, y0, y1;

    switch (message) 
	{
    case WM_CREATE:
		return 0;
    case WM_DESTROY:
		PostQuitMessage(0);
		doneDemo= true;
		return 0;
    case WM_SIZE:
		/* track window size changes */
		if (hGLRC) {
			winWidth = (int) LOWORD(lParam);
			winHeight = (int) HIWORD(lParam);
			screenRatio= winHeight/natrualWinHeight;
			resize();
			return 0;
		}
    case WM_PAINT:
		{
			PAINTSTRUCT ps;
			BeginPaint(hWnd, &ps);
			if (hGLRC) {
				redisplay();
			}
			EndPaint(hWnd, &ps);
			return 0;
		}
		break;
    case WM_CHAR:
		/* handle keyboard input */
		if( (int)wParam == VK_ESCAPE )
		{
			DestroyWindow(hWnd);
			doneDemo= true;
			return 0;
		}
		break;
	default:
		break;
    }
    return DefWindowProc(hWnd, message, wParam, lParam);
}


int APIENTRY WinMain(
    HINSTANCE hCurrentInst,
    HINSTANCE hPreviousInst,
    LPSTR lpszCmdLine,
    int nCmdShow)
{
    WNDCLASS wndClass;
    HWND hWnd;
    MSG msg;

	srand( time( 0 ) );


    /* register window class */
    wndClass.style = CS_HREDRAW | CS_VREDRAW;
    wndClass.lpfnWndProc = WndProc;
    wndClass.cbClsExtra = 0;
    wndClass.cbWndExtra = 0;
    wndClass.hInstance = hCurrentInst;
    wndClass.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    wndClass.hCursor = LoadCursor(NULL, IDC_ARROW);
    wndClass.hbrBackground = NULL; 
    wndClass.lpszMenuName = NULL;
    wndClass.lpszClassName = className;
    RegisterClass(&wndClass);

	/* create window */
    hWnd = CreateWindow(
		className, winName,
		WS_POPUP,
		winX, winY, winWidth, winHeight,
		NULL, NULL, hCurrentInst, NULL);

    /* display window */
    ShowWindow(hWnd, SW_SHOWMAXIMIZED);
    UpdateWindow(hWnd);
	BringWindowToTop(hWnd);

    /* initialize OpenGL rendering */  
    hDC = GetDC(hWnd);
    setupPixelFormat(hDC);
    hGLRC = wglCreateContext(hDC);
    wglMakeCurrent(hDC, hGLRC);
    initialize();

    /* process messages */
    while (!doneDemo) {
		while( PeekMessage(&msg, NULL, 0, 0, PM_REMOVE) != FALSE )
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		doRedisplay();
    }

    /* finish OpenGL rendering */
    wglMakeCurrent(NULL, NULL);
    wglDeleteContext(hGLRC);
    if (hPalette) {
	DeleteObject(hPalette);
    }
    ReleaseDC(hWnd, hDC);

	DeInitTextures();
    return msg.wParam;
}


/*
// What is this?? :) I hope just an int will do, compiler required.
int _fltused;

// Entrypoint. Windows required.
void WinMainCRTStartup(void)
{
	WinMain(GetModuleHandle(NULL),NULL,NULL,SW_SHOW);
	ExitProcess(0);
}
*/