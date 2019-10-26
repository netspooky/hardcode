#ifndef _OGL_
#define _OGL_

extern HDC			hDC;
extern i8			full;
extern HGLRC		hRC;
extern HWND			hWnd;
extern int			PixelFormat;
extern HINSTANCE	hInstance;

int		initGL(void);
int		deinitGL(void);
void	flip(void);

#endif