#define _ISOC99_SOURCE
#define __USE_ISOC99

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <fcntl.h>
#include "sdl.h"

#include "sdlframework.h"

// Size of buffers to hold keyboard and mouse events until processed and cleared
#define ENV_KEYBOARD_BUFFER_SIZE (32)
#define ENV_CURSOR_BUFFER_SIZE (32)

#define ENV_KEYS (340)

unsigned char envKey[ENV_KEYS];

int envKeyboardEvents;
int envKeyboardBuffer[ENV_KEYBOARD_BUFFER_SIZE];

int envCursorX, envCursorY;

int envCursorState;

int envCursorEvents;
unsigned char envCursorBuffer[ENV_CURSOR_BUFFER_SIZE];


void envKeyboardClearBuffer()
{
  envKeyboardEvents = 0;
  return;
}

void envCursorClearBuffer()
{
  envCursorEvents = 0;
  return;
}

SDL_PixelFormat *env_format;
SDL_Surface *env_surface;
SDL_VideoInfo *env_videoinfo;

int envFormatBytes;
int envFormatBits;
int envFormatRmask, envFormatGmask, envFormatBmask;
int envFormatRshift, envFormatGshift, envFormatBshift;
int envFormatRloss, envFormatGloss, envFormatBloss;
static unsigned char envFormatPalette[768];

static int env_time_last;

int envCreateWindow( char *title, int width, int height, int colourbits, int fullscreen, int anyformat )
{
  int flags;
  if( SDL_Init( SDL_INIT_VIDEO ) != 0 )
    return 0;
  atexit( SDL_Quit );
  flags = SDL_SWSURFACE;
  flags |= SDL_ASYNCBLIT | SDL_HWACCEL;
  if( anyformat )
    flags |= SDL_ANYFORMAT;
  if( fullscreen )
    flags |= SDL_FULLSCREEN;
  if( colourbits == 8 )
    flags |= SDL_HWPALETTE;
  if( !( env_surface = SDL_SetVideoMode( width, height, colourbits, flags ) ) )
    return 0;
  SDL_PumpEvents();
  SDL_WM_SetCaption( title, 0 );
  env_format = env_surface->format;
  env_videoinfo = (SDL_VideoInfo *)SDL_GetVideoInfo();
  envFormatBytes = env_format->BytesPerPixel;
  envFormatBits = env_format->BitsPerPixel;
  envFormatRmask = env_format->Rmask;
  envFormatGmask = env_format->Gmask;
  envFormatBmask = env_format->Bmask;
  envFormatRshift = env_format->Rshift;
  envFormatGshift = env_format->Gshift;
  envFormatBshift = env_format->Bshift;
  envFormatRloss = env_format->Rloss;
  envFormatGloss = env_format->Gloss;
  envFormatBloss = env_format->Bloss;
  env_time_last = SDL_GetTicks();
  return 1;
}

void envDestroyWindow()
{
  SDL_FreeSurface( env_surface );
  SDL_Quit();
  return;
}

int envUpdate()
{
  SDL_Event event;
  while( SDL_PollEvent( &event ) )
  {
    if( event.type == SDL_QUIT )
      return 0;
    else if( event.type == SDL_MOUSEMOTION )
    {
      envCursorX = event.motion.x;
      envCursorY = event.motion.y;
    }
    else if( event.type == SDL_MOUSEBUTTONDOWN )
    {
      if( event.button.button == SDL_BUTTON_LEFT )
      {
        envCursorState |= 1;
        if( envCursorEvents < ENV_CURSOR_BUFFER_SIZE )
          envCursorBuffer[envCursorEvents++] = 1;
      }
      else if( event.button.button == SDL_BUTTON_RIGHT )
      {
        envCursorState |= 2;
        if( envCursorEvents < ENV_CURSOR_BUFFER_SIZE )
          envCursorBuffer[envCursorEvents++] = 2;
      }
      else if( event.button.button ==  SDL_BUTTON_MIDDLE )
      {
        envCursorState |= 4;
        if( envCursorEvents < ENV_CURSOR_BUFFER_SIZE )
          envCursorBuffer[envCursorEvents++] = 4;
      }
    }
    else if( event.type == SDL_MOUSEBUTTONUP )
    {
      if( event.button.button == SDL_BUTTON_LEFT )
      {
        envCursorState &= 7-1;
        if( envCursorEvents < ENV_CURSOR_BUFFER_SIZE )
          envCursorBuffer[envCursorEvents++] = 8;
      }
      else if( event.button.button == SDL_BUTTON_RIGHT )
      {
        envCursorState &= 7-2;
        if( envCursorEvents < ENV_CURSOR_BUFFER_SIZE )
          envCursorBuffer[envCursorEvents++] = 16;
      }
      else if( event.button.button ==  SDL_BUTTON_MIDDLE )
      {
        envCursorState &= 7-4;
        if( envCursorEvents < ENV_CURSOR_BUFFER_SIZE )
          envCursorBuffer[envCursorEvents++] = 32;
      }
    }
    else if( event.type == SDL_KEYDOWN )
    {
      if( (unsigned int)(event.key.keysym.sym) < ENV_KEYS )
        envKey[ event.key.keysym.sym ] = 1;
      if( envKeyboardEvents < ENV_KEYBOARD_BUFFER_SIZE )
        envKeyboardBuffer[envKeyboardEvents++] = event.key.keysym.scancode;
    }
    else if( event.type == SDL_KEYUP )
    {
      if( (unsigned int)(event.key.keysym.sym) < ENV_KEYS )
        envKey[ event.key.keysym.sym ] = 0;
    }
  }
  return 1;
}


int envTimeCount( int fps )
{
  int execs;
  execs = ( SDL_GetTicks() - env_time_last ) / ( 1000 / fps );
  env_time_last += execs * ( 1000 / fps );
  return execs;
}


void envCursorPos( int x, int y )
{
  SDL_WarpMouse( x, y );
  return;
}


void *envLock2D()
{
  SDL_LockSurface( env_surface );
  return env_surface->pixels;
}

void envUnlock2D()
{
  SDL_UnlockSurface( env_surface );
  return;
}


void envUpdate2D()
{
  SDL_UpdateRect(env_surface, 0, 0, 0, 0);
  SDL_Flip( env_surface );
  return;
}
//
//int envPixelColor2D( int red, int green, int blue )
//{
//  int a, b, dif, maxdif, current, pixel;
//
//  // We got 8 bits rendering, find the best colour match in the current palette ( slow! )
//  if( envFormatBytes == 1 )
//  {
//    current = 0;
//    maxdif = 0xFFF;
//    for( a = b = 0 ; a < 256 ; a++, b += 3 )
//    {
//      dif = abs( red - envFormatPalette[b+0] );
//      dif += abs( green - envFormatPalette[b+1] );
//      dif += abs( blue - envFormatPalette[b+2] );
//      if( dif > maxdif )
//        continue;
//      maxdif = dif;
//      current = a;
//    }
//    return current;
//  }
//
//  // 16-24-32 bits rendering, calculate the pixel value from the red, green and blue components
//  pixel = ( red >> envFormatRloss ) << envFormatRshift;
//  pixel |= ( green >> envFormatGloss ) << envFormatGshift;
//  pixel |= ( blue >> envFormatBloss ) << envFormatBshift;
//  return pixel;
//}

//void envPalette2D( unsigned char *pal )
//{
//  int a;
//  SDL_Color colors[256];
//  memcpy( envFormatPalette, pal, 768*sizeof(unsigned char) );
//  for( a = 0 ; a < 256 ; a++, pal += 3 )
//  {
//    colors[a].r = pal[0];
//    colors[a].g = pal[1];
//    colors[a].b = pal[2];
//  }
//  SDL_SetColors( env_surface, colors, 0, 256 );
//  return;
//}

void envDrawImage( SDL_Surface *image, SDL_Rect *srcrect, SDL_Rect *destrect)
{
	//todo: check succeed and return true or false
	SDL_BlitSurface(image, srcrect, env_surface, destrect);
	return;
}
