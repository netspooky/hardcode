#include <windows.h>
#include <gl\gl.h>
#include <gl\glu.h>

#include "tool.h"
#include "audio.h"
#include "scene.h"
#include "define.h"
#include "glwindow.h"


float startscene;

//-----------------------------------------------------------------------------
// main
//-----------------------------------------------------------------------------
#ifdef SAFE

int main(void)
{
    //Init
  	InitMusic();
	glwindow glw;
    glwindow_create(&glw, RESX, RESY, 1, "");
    InitScene();
    startscene = GetTickCount();


		while( !(GetAsyncKeyState(VK_ESCAPE)&0x8000) && GetTickCount()-startscene<END_TIME)
	    {
            DrawScene();
            glwindow_swap_buffers(&glw);
	    }

    glwindow_destroy(&glw);
}


#else
int mainCRTStartup(void ){

	//API Win32
	PIXELFORMATDESCRIPTOR pfd = {
		sizeof(PIXELFORMATDESCRIPTOR), 1, PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,
		PFD_TYPE_RGBA, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, PFD_MAIN_PLANE, 0, 0, 0, 0
	};

	HWND	hwnd;
	HDC		device;
		hwnd = CreateWindow(	"EDIT", "", WS_POPUP | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_VISIBLE,
								0, 0, RESX, RESY, 0, 0, 0, 0	);

		device = GetDC(hwnd);

		SetPixelFormat(device, ChoosePixelFormat(device, &pfd), &pfd);
		wglMakeCurrent(device, wglCreateContext(device));

		ShowCursor(0);



    //Init
  	InitMusic();
    InitScene();

    startscene = GetTickCount();

    //Main Loop
	while(!(GetAsyncKeyState(VK_ESCAPE)&0x8000) && GetTickCount()-startscene<END_TIME )
	{
        DrawScene();
        SwapBuffers(device);
	}

    //Exit 
    ExitProcess(0);

}
#endif
