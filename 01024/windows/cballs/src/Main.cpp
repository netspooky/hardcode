/*
* Code by Aha / Holograms for Function 2007 party.
* 2007.09.20 1:07
*/

#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>

#if defined(__cplusplus)
    extern "C" {
#endif
	int _fltused;
#if defined(__cplusplus)
    };
#endif

__forceinline static __declspec(naked) float __fastcall fsin(float a)
{
    __asm {
        fld        DWORD PTR [esp+4]
        fsin
        ret 4
    }
}

#define cw 24
#define ch 6

static char chars[ch][cw] =
	{
	 //                   10                  20
	 // 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,
		1,1,1,1,0,0,1,1,0,0,0,1,1,0,0,0,1,1,0,0,1,1,1,1,
		1,0,0,0,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,0,0,0,1,
		1,0,0,0,0,0,0,0,1,0,1,0,0,1,0,1,0,0,1,0,0,0,1,0,
		1,1,1,0,0,0,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0,0,1,0,
		1,0,0,0,0,0,1,0,0,0,1,0,0,1,0,1,0,0,1,0,0,1,0,0,
		1,0,0,0,0,1,1,1,1,0,0,1,1,0,0,0,1,1,0,0,1,0,0,0
	};

int WINAPI WinMain (HINSTANCE hThisInstance,HINSTANCE hPrevInstance,LPSTR lpszArgument,int nFunsterStil)
{
	PIXELFORMATDESCRIPTOR pfd;

//	critical size optimization
//	pfd.cColorBits = pfd.cDepthBits = 32;

	pfd.dwFlags    = PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
	HDC hDC = GetDC ( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, 0 , 0, 0, 0, 0, 0) );

//	window or fs mode
//	HDC hDC = GetDC( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE, 0, 0,640,480,0, 0, 0, 0));

	SetPixelFormat ( hDC, ChoosePixelFormat ( hDC, &pfd) , &pfd );
	wglMakeCurrent ( hDC, wglCreateContext(hDC) );
	ShowCursor(FALSE);
	glEnable(GL_LIGHT0);
	glEnable(GL_LIGHTING);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_COLOR_MATERIAL);

	GLUquadricObj * q = gluNewQuadric();

	do
	{
		float time = GetTickCount()/50.0f;
		glClear( GL_COLOR_BUFFER_BIT  | GL_DEPTH_BUFFER_BIT );
		glLoadIdentity();

		glMatrixMode(GL_PROJECTION);
//		critical size optimization
//		glLoadIdentity();
		gluPerspective(45.0, 1.333333f, 1.0, 30.0);

		glPushMatrix();
		glTranslatef(0.0f,0.0f,-13.0f);
		glRotatef(-45.0f,1.0f,0.0f,0.0f);
		glRotatef(time,0,0,1);
		glColor3ub(125,64,0);

		int i,j;
		for( i = 0; i<17; i++)
			for ( j = 0; j<17; j++)
			{
				glPushMatrix();
				glTranslatef(
					(i-8) * 2,
					(j-8) * 2,
					fsin(i+time/10.0f) + fsin(j+time/10.0f)
				);
				gluSphere(q,1.0,20,20);
				glPopMatrix();
			}
		glPopMatrix();
		
		glColor3ub(0,128,0);

		for( i = 0; i<ch; i++)
		{
			for ( j = 0; j<cw; j++)
			{
				float pos = j % 5 == 0 ? fsin(j+time/10) / 4.0f : pos;
				if ( chars[i][j] ) 
				{
					glPushMatrix();
					glTranslatef(
						j / 6.0f - 1.4,
						( ( 6 - i  )/ 6.0f ) +  pos,
						- 5.0f + fsin(i+j+time/10) / 10.0f
					);
					gluSphere(q,0.15,20,20);
					glPopMatrix();
				}
			}
		}

		SwapBuffers(hDC);
	} while ( !GetAsyncKeyState(VK_ESCAPE) );

	ExitProcess(0);
	return 0;
}

