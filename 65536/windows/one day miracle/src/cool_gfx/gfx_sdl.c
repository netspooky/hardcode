/*
    Quick implementation of CoolAPI SDL-version.

    Created: 31.3.2000
    Updated: 31.3.2000

    -Marq
*/

#include "cool_gfx.h"
#include "gfx_sdl.h"
#include <stdio.h>
#include <string.h>

#include <SDL/SDL.h>

static SDL_Surface *screen;

static int  doubled,x_size,y_size;

int gfx_init(int mode,int special)
{
    switch(mode)
    {
        case GFX_320x200x32:    return(sdl_init(320,200,special));
        case GFX_320x240x32:    return(sdl_init(320,240,special));
        default:                return(GFX_ERR_MODE);
    }
}

int sdl_init(int x,int y,int special)
{
    int mode;

    doubled=0;

    if(special&GFX_NOASK)
    {
        mode=1;
    }
    else    /*  Prompt the user to select mode  */
    {
        printf("Internal window size: %dx%d\n",x,y);
        puts("1 - Normal pixels");
        puts("2 - Double pixels");
        puts("3 - Normal pixels fullscreen (if possible)");
        puts("4 - Double pixels fullscreen (if possible)");
        scanf("%d",&mode);
    }

    if(SDL_Init(SDL_INIT_VIDEO)<0)
                    return(GFX_ERR_MODE);

    x_size=x;
    y_size=y;

    switch(mode)
    {
        case 1: screen = SDL_SetVideoMode(x,y,32,SDL_HWSURFACE|SDL_DOUBLEBUF);
                if(!screen)
                    return(GFX_ERR_MODE);
                break;
        case 2: screen = SDL_SetVideoMode(x*2,y*2,32,SDL_HWSURFACE
                                          |SDL_DOUBLEBUF);
                if(!screen)
                    return(GFX_ERR_MODE);
                doubled=1;
                break;
        case 3: screen = SDL_SetVideoMode(x,y,32,SDL_HWSURFACE
                                          |SDL_FULLSCREEN|SDL_DOUBLEBUF);
                if(!screen)
                    return(GFX_ERR_MODE);
                break;
        case 4: screen = SDL_SetVideoMode(x*2,y*2,32,SDL_HWSURFACE
                                          |SDL_FULLSCREEN|SDL_DOUBLEBUF);
                if(!screen)
                    return(GFX_ERR_MODE);
                doubled=1;
                break;
        default: return(GFX_ERR_MODE);
    }
    SDL_ShowCursor(SDL_DISABLE);

    return(GFX_OK);
}

int gfx_blit(unsigned *buffer)
{
    int n,m;

    unsigned    *dest;

    SDL_LockSurface(screen);
    if(!doubled)
        memcpy(screen->pixels,buffer,x_size*y_size*4);
    else
    {
        dest=screen->pixels;
        for(m=0;m<y_size;m++)
        {
            for(n=0;n<x_size;n++)
            {
                *dest++=buffer[m*x_size+n];
                *dest++=buffer[m*x_size+n];
            }
            dest+=x_size*2;
        }
    }

    SDL_UnlockSurface(screen);
    SDL_Flip(screen);

    return(GFX_OK);
}

int gfx_exitevent(void)
{
    int tmp;

    Uint8   *keys;

    SDL_PumpEvents();
    if(SDL_QuitRequested())
        return(1);

    keys=SDL_GetKeyState(&tmp);
    if(keys[SDLK_ESCAPE])
        return(1);

    if(SDL_GetMouseState(NULL,NULL)&SDL_BUTTON(1))
        return(1);

    return(0);
}

void gfx_close(void)
{
    SDL_Quit();
}

/* EOS */

