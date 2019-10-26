/*
   Voxel Bukkake - A 4k intro for BCNparty'101.
   Copyright (C) 2005 Jorge Gorbe (aka slack/Necrostudios)

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License version 2
   as published by the Free Software Foundation.
*/

#include "dl_init.h"
#include <dlfcn.h>

FN_STRUCT fn;

char *names="libSDL-1.2.so.0\0SDL_Init\0SDL_Quit\0SDL_OpenAudio\0"
	    "SDL_PauseAudio\0SDL_PollEvent\0"
	    "SDL_GL_SwapBuffers\0"
	    "SDL_SetVideoMode\0SDL_ShowCursor\0\0"
	    
	    "libm.so\0powf\0fmodf\0expf\0\0"
	    
	    "libc.so.6\0rand\0srand\0\0"
	    
	    "libGL.so\0glBegin\0glEnd\0glColor4f\0glVertex3f\0glRotatef\0"
	    "glEnable\0glDisable\0"
	    "glMatrixMode\0glLoadIdentity\0glClear\0"
	    "glBlendFunc\0glClearColor\0glGetFloatv\0glPushMatrix\0"
	    "glPopMatrix\0\0"
	    "libGLU.so\0gluPerspective\0gluLookAt\0\0"
	    
	    "\0";


void dl_init(void)
{
	char *p=names;
	void **pfn=(void **)&fn;
	void *handle;

	while(*p)
	{
		handle=dlopen(p, RTLD_LAZY);
		while(*p++); // Avanzamos p hasta la siguiente
		while(*p)
		{
			*pfn=dlsym(handle, p);
#ifdef DEBUG
			__builtin_printf("%s = %p\n", p, *pfn);
#endif
			++pfn;
			while(*p++);
		}
		++p;
	}
}


