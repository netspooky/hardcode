#include "dl_init.h"
#include <dlfcn.h>

FN_STRUCT fn;

char *names="libSDL-1.2.so.0\0"
	    "libm.so\0"
	    "libc.so.6\0"
	    "SDL_Init\0SDL_Quit\0SDL_OpenAudio\0"
	    "SDL_PauseAudio\0SDL_PollEvent\0"
	    "SDL_Flip\0"
	    "SDL_SetVideoMode\0SDL_ShowCursor\0"
	    "powf\0fmodf\0expf\0"
	    "rand\0"
	    "\0";


void dl_init(void)
{
	unsigned char *p=names;
	void **pfn=(void **)&fn;

	while(*p)
	{
		if (!dlopen(p, RTLD_NOW | RTLD_GLOBAL))
		{
			*pfn=dlsym(NULL,p);
			++pfn;
		}
		while(*p++);
	}
}


