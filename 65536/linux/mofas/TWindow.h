#ifndef TINIT_WINDOW_H__
#define TINIT_WINDOW_H__

#include <GL/gl.h>
#include <GL/glu.h>

#include <SDL/SDL.h>

class TWindow
{
public:
	int		width,height,bpp;
	bool	fullscreen;
	bool	active;
	bool	done;
	TWindow()
	{
		done	= false;
		active	= false;
	};
	void InitWindow(char *title,int w,int h,int bit_depth,bool full);
	void ResizeWindow(int w,int h);
	void SetPerspectiveMode(void);
	void SetOrthoMode(int left,int top,int right,int bottom);
	void ToggleFullscreen(void)	
	{
		fullscreen = !fullscreen;
		SDL_WM_ToggleFullScreen(surface); 
	};
private:
	SDL_Surface *surface;
	int			videoFlags;
};

#endif
