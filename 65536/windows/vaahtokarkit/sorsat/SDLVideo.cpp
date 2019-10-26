#include "Video.h"
#include "Error.h"

#include "SDL/SDL.h"
#include <string.h>
#include <stdlib.h>

Bitmap *screen=0;
int quitrequest=0;
int mousex = 0, mousey = 0, mousebutton = 0;
int videoxsize,videoysize;
int keydown=0;

SDL_Surface *sdlscreen;

void videoInit(int w,int h)
{
  if(SDL_Init(SDL_INIT_VIDEO) < 0)
  {
    error("Can't init SDL (%s)",SDL_GetError());
  }
  atexit(SDL_Quit);


  if((sdlscreen=SDL_SetVideoMode(w,h,32,SDL_HWSURFACE | SDL_FULLSCREEN))==0)
  {
    error("Can't set mode %dx%dx32 (%s)",w,h,SDL_GetError());
  }

  screen = new Bitmap(w,h);
  videoxsize = w;
  videoysize = h;
}

void videoDeinit()
{
//  SDL_FreeSurface(bitmap);
}

void videoRefresh()
{
  if(SDL_LockSurface(sdlscreen)<0)
  {
    error("Can't lock SDL surface (%s)",SDL_GetError());
  }

  int *dest = (int *) sdlscreen->pixels;

  for(int i=0; i<screen->height; i++)
  {
    memcpy(dest,screen->data[i],screen->width*4);
    dest += sdlscreen->pitch/4;
  }

  SDL_WM_SetCaption("Hipo's Graphics Editor",0);

  SDL_UnlockSurface(sdlscreen);
  SDL_UpdateRect(sdlscreen,0,0,0,0);
  videoSync();
}

void videoSync()
{
  SDL_Event event;
  mousebutton = 0;
  int b = SDL_GetMouseState(&mousex,&mousey);

  if(b&SDL_BUTTON_LMASK) mousebutton |= 1;
  if(b&SDL_BUTTON_RMASK) mousebutton |= 2;

  while(SDL_PollEvent(&event))
  {
    switch (event.type)
    {
      case SDL_KEYDOWN:
        if(event.key.keysym.unicode<80)
        {
          keydown = event.key.keysym.unicode&0xEF;
        }
        break;

      case SDL_QUIT:
        quitrequest = 1;
        break;
     }
   }
}
