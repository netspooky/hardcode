#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>

#include "glwindow.h"
#include "define.h"

#ifdef SAFE

int	key		= 0;
int	key_hit	= 0;

LRESULT WINAPI msgProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp);

void glwindow_create(glwindow* glw, int resx, int resy, int fullscreen, char* title) {

	PIXELFORMATDESCRIPTOR	pfd;
	HINSTANCE				hinst = GetModuleHandle(0);
	int						pixelFormat;
	WNDCLASS				wc = {	CS_HREDRAW|CS_VREDRAW|CS_OWNDC, msgProc, 0, 0, GetModuleHandle(0), 0, 0, 0, 0, "window" };

	glw->resx		= resx;
	glw->resy		= resy;
	glw->fullscreen	= fullscreen;

	if(!RegisterClass(&wc))
		return;

	RtlZeroMemory(&pfd, sizeof(PIXELFORMATDESCRIPTOR));
	
	pfd.nSize		= sizeof(PIXELFORMATDESCRIPTOR);
	pfd.nVersion	= 1;
	pfd.dwFlags		= PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
	pfd.iPixelType	= PFD_TYPE_RGBA;
	pfd.cColorBits	= 32;
	pfd.cDepthBits	= 16;
	pfd.iLayerType	= PFD_MAIN_PLANE;

	if(fullscreen) {

		DEVMODE	dmScreenSettings;

		RtlZeroMemory(&dmScreenSettings, sizeof(dmScreenSettings));

		dmScreenSettings.dmSize			= sizeof(dmScreenSettings);
		dmScreenSettings.dmPelsWidth	= resx;
		dmScreenSettings.dmPelsHeight	= resy;
		dmScreenSettings.dmBitsPerPel	= 32;
		dmScreenSettings.dmFields		= DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT;

		if(ChangeDisplaySettings(&dmScreenSettings, CDS_FULLSCREEN) != DISP_CHANGE_SUCCESSFUL)
			return;
	}

	if(fullscreen)
		glw->window_handle = CreateWindowEx(	WS_EX_TOOLWINDOW, "window", title,
												WS_POPUP | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_VISIBLE, 
												0, 0, resx, resy, 0, 0, hinst, 0);
	else
		glw->window_handle = CreateWindowEx(	WS_EX_TOOLWINDOW, "window", title,
												WS_CAPTION | WS_POPUP | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_VISIBLE, 
												0, 0, resx, resy, 0, 0, hinst, 0);

	glw->device_handle	= GetDC(glw->window_handle);
	pixelFormat			= ChoosePixelFormat(glw->device_handle, &pfd);	

	SetPixelFormat(glw->device_handle, pixelFormat, &pfd);
	glw->gl_render_context = wglCreateContext(glw->device_handle);
	wglMakeCurrent(glw->device_handle, glw->gl_render_context);

	ShowWindow(glw->window_handle, SW_SHOWNORMAL);
	UpdateWindow(glw->window_handle);
	SetFocus(glw->window_handle);
	SetCursor(0);
}

void glwindow_destroy(glwindow* glw) {

	if(glw->gl_render_context) {
		wglMakeCurrent(0, 0);
		wglDeleteContext(glw->gl_render_context);
	}

	if(glw->device_handle)
		ReleaseDC(glw->window_handle, glw->device_handle);

	if(glw->window_handle)
		DestroyWindow(glw->window_handle);

	if(glw->fullscreen) {
		ChangeDisplaySettings(0, 0);
		ShowCursor(1);
	}

	UnregisterClass("window", GetModuleHandle(0));
}

void glwindow_swap_buffers(glwindow* glw) {
	SwapBuffers(glw->device_handle);
}

LRESULT WINAPI msgProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {

	switch(msg) {
		case WM_DESTROY:
			PostQuitMessage(0);
			return 0;
		break;

		case WM_KEYDOWN:
			if(wp == VK_ESCAPE)
				PostQuitMessage(0);
			else {
				key_hit	= 1;
			    key		= (int)wp;
			}
		break;

		case WM_KEYUP:
			key_hit	= 0;
		break;
	}

	return DefWindowProc(hwnd, msg, wp, lp);
}

int glwindow_is_active(glwindow* glw) {

	MSG	msg;

	while(PeekMessage(&msg, 0, 0, 0, PM_NOREMOVE)) {

		if(msg.message == WM_QUIT)
			return 0;

		if(!GetMessage(&msg, 0, 0, 0))
			return 1;
		else {
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

	return 1;
}

int	glwindow_key_pressed() {
	return key_hit;
}

int	glwindow_get_key() {
	return key;
}

#endif

