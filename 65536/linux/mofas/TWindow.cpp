#include "TWindow.h"

void TWindow::InitWindow(char *title,int w,int h,int bit_depth, bool full)
{
	const SDL_VideoInfo *videoInfo;

	if (SDL_Init(SDL_INIT_VIDEO) < 0)
	{
		fprintf(stderr, "Video initialization failed: %s\n",SDL_GetError());
	    SDL_Quit();
	}
    
    videoInfo = SDL_GetVideoInfo();

    if (!videoInfo)
	{
	    fprintf(stderr, "Video query failed: %s\n",SDL_GetError());
	    SDL_Quit();
	}

    videoFlags  = SDL_OPENGL;
    videoFlags |= SDL_GL_DOUBLEBUFFER;
    videoFlags |= SDL_HWPALETTE;
    videoFlags |= SDL_RESIZABLE;

    if(videoInfo->hw_available )
		videoFlags |= SDL_HWSURFACE;
    else
		videoFlags |= SDL_SWSURFACE;

    if(videoInfo->blit_hw)
		videoFlags |= SDL_HWACCEL;

    SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );

	width		= w;
	height		= h;
	bpp			= bit_depth;
	fullscreen	= full;

	if(full)
		videoFlags |= SDL_FULLSCREEN;

    surface = SDL_SetVideoMode(width,height,bpp,videoFlags);

    if(!surface)
	{
	    fprintf(stderr,  "Video mode set failed: %s\n", SDL_GetError());
	    SDL_Quit();
	}

	SDL_WM_SetCaption(title,NULL);

	/*
    SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );      // tell SDL that the GL drawing is going to be double buffered
    SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE,   SCREEN_DEPTH);         // size of depth buffer 
    SDL_GL_SetAttribute( SDL_GL_STENCIL_SIZE, 0);       // we aren't going to use the stencil buffer
    SDL_GL_SetAttribute( SDL_GL_ACCUM_RED_SIZE, 0);     // this and the next three lines set the bits allocated per pixel -
    SDL_GL_SetAttribute( SDL_GL_ACCUM_GREEN_SIZE, 0);   // - for the accumulation buffer to 0
    SDL_GL_SetAttribute( SDL_GL_ACCUM_BLUE_SIZE, 0);
    SDL_GL_SetAttribute( SDL_GL_ACCUM_ALPHA_SIZE, 0);
	*/
}

void TWindow::ResizeWindow(int w,int h)
{
    GLfloat ratio;

	surface = SDL_SetVideoMode(w,h,bpp,videoFlags);

    if(height == 0)
		height = 1;

	width	= w;
	height	= h;

    ratio = (GLfloat)width/(GLfloat)height;

    glViewport(0,0,(GLint)width,(GLint)height);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    gluPerspective(45.0f, ratio, 0.1f, 100.0f);

    glMatrixMode(GL_MODELVIEW);

    glLoadIdentity();
}

void TWindow::SetOrthoMode(int left,int top,int right,int bottom)
{
    glMatrixMode(GL_PROJECTION);                        
    glPushMatrix();                                    
    glLoadIdentity();                                

	gluOrtho2D(left,right,bottom,top);
    
    glMatrixMode(GL_MODELVIEW);                                
    glLoadIdentity();                                        
}

void TWindow::SetPerspectiveMode(void)
{
}
