/*
	Framework by Auld
	Intro by Aha
	CRings - Holograms ( 2003 - 2007 )
	Created by Dev-C++ 4.9.9.2
*/
#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>

#define RINGS 32
#define SIDES 16
#define PI 3.1415926535897932384626433832795f
#define TIME GetTickCount()/50.0

PIXELFORMATDESCRIPTOR pfd;

static void CreateTorus(const float radius, const float tuberadius )
{
	float cosTheta = 1.0f;
	float sinTheta , theta = 0.0f;
	int i;
	for ( i = RINGS - 1; i >= 0; --i)
	{
		float pi2 = 2.0f * PI;
		float theta1 = theta + ( pi2 / RINGS);
		glBegin(GL_QUAD_STRIP);
			float phi = 0.0f;
			int j;
			for ( j = SIDES; j >= 0; --j )
			{
				phi    = phi + (pi2 / SIDES);
				float sinphi  = sin(phi);
				float cosphi  = cos(phi);
				float costube = radius + ( tuberadius * cosphi );
				float sintube = tuberadius * sinphi;
				glVertex3f(cos(theta1)*costube,-sin(theta1)*costube,sintube);
				glNormal3f(cosTheta			  ,-sinTheta		   ,sinphi );
				glVertex3f(cosTheta*costube	  ,-sinTheta   *costube,sintube);
			}
		cosTheta = cos(theta1);
		theta 	 = theta1;
		sinTheta = sin(theta1);
		glEnd();
	}
}

int WINAPI WinMainCRTStartup()
{
//	PVOID hDC = GetDC( CreateWindow("EDIT", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0,0,0,0, 0, 0, 0));   
	PVOID hDC = GetDC( CreateWindow("EDIT", 0, WS_POPUP|WS_VISIBLE, 0, 0,640,480,0, 0, 0, 0));   
	ShowCursor(FALSE);
	pfd.cColorBits = pfd.cDepthBits = 32; 
	pfd.dwFlags    = PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;			
	SetPixelFormat ( hDC, ChoosePixelFormat ( hDC, &pfd) , &pfd );
	wglMakeCurrent ( hDC, wglCreateContext(hDC) );
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(45.0, 1.333333f, 1.0f, 20.0f);
	glMatrixMode(GL_MODELVIEW);
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_DEPTH_TEST);
	glShadeModel(GL_FLAT);
	glEnable(GL_COLOR_MATERIAL);
	do 
	{
		glClear( GL_COLOR_BUFFER_BIT  | GL_DEPTH_BUFFER_BIT );
		glLoadIdentity();
		int j;
		glTranslatef(0,0,-10);
		for ( j = 0; j<15; j++)
		{
			glColor3f(j/15.f,.5,0);
			glRotatef(TIME,j*0.2f,1,1);
			CreateTorus(j/3.f,j/50.f);
		}
		SwapBuffers(hDC);
	} while ( !GetAsyncKeyState(VK_ESCAPE) );
	ExitProcess(0);
}
