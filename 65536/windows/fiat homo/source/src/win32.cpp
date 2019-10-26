/* Window setup */

#include <SDL/SDL.h>
#include "win32.hpp"

extern int OPENGL_XRES;
extern int OPENGL_YRES;
extern bool OPENGL_FULLSCREEN;

Window::Window()
{
}

Window::~Window()
{
}

bool Window::create(bool bflag)
{
	SDL_Init(SDL_INIT_VIDEO);

#ifdef FULLSCREEN
    int SDL_flags = SDL_OPENGL|SDL_FULLSCREEN;
#else
	int SDL_flags = SDL_OPENGL;
#endif

	SDL_ShowCursor(0);

	SDL_SetVideoMode(WINDOW_WIDTH, WINDOW_HEIGHT, 0, SDL_flags);
	SDL_WM_SetCaption("Fiat Homo",0);

	SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );

	return true;
}

void Window::shut()
{
}
