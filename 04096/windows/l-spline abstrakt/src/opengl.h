#pragma once

#include <gl\gl.h>
#include <gl\glu.h>

static DEVMODE dmScreenSettings;

PIXELFORMATDESCRIPTOR pfd = {
			sizeof(PIXELFORMATDESCRIPTOR),
			1,
			PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,
			PFD_TYPE_RGBA,
			32,				// Colour buffer bit depth
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			32,				// Depth buffer bit depth
			0, 0,			// stencilbuffer bit detph, auxbuffer bit depth
			PFD_MAIN_PLANE, 
			0, 0, 0, 0 };


void InitGraphics(HDC hDC)
{
	dmScreenSettings.dmSize			=	sizeof(dmScreenSettings);
	dmScreenSettings.dmPelsWidth	=	XRES;
	dmScreenSettings.dmPelsHeight	=	YRES;
	dmScreenSettings.dmBitsPerPel	=	32;
	// disable this?
	dmScreenSettings.dmDisplayFrequency = 60;
	dmScreenSettings.dmFields		=	DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT|DM_DISPLAYFREQUENCY;

#ifdef FULLSCREEN
	ChangeDisplaySettings	(&dmScreenSettings,CDS_FULLSCREEN | CDS_SET_PRIMARY);
#endif

	SetPixelFormat(hDC, ChoosePixelFormat(hDC, &pfd), &pfd);
	wglMakeCurrent(hDC, wglCreateContext(hDC));

	//glEnable(GL_BLEND);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE);

	//glEnable(GL_DEPTH_TEST);
}
