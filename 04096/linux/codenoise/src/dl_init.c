 /* 
  *      Copyright (C) 2004 Jorge Gorbe Moya <slack@frikis.org>
  *
  *
  *      This program is free software; you can redistribute it and/or modify
  *      it under the terms of the GNU General Public License version 2, as 
  *      published by the Free Software Foundation.
  *
  *      This program is distributed in the hope that it will be useful,
  *      but WITHOUT ANY WARRANTY; without even the implied warranty of
  *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *      GNU General Public License for more details.
  *
  *      You should have received a copy of the GNU General Public License
  *      along with this program; if not, write to the
  *      Free Software Foundation, Inc.,
  *      59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */

#include "dl_init.h"
#include <dlfcn.h>

FN_STRUCT fn;

char *names="libSDL-1.2.so.0\0SDL_Init\0SDL_Quit\0SDL_OpenAudio\0"
	    "SDL_CloseAudio\0SDL_Delay\0SDL_PauseAudio\0SDL_PollEvent\0"
	    "SDL_GL_SwapBuffers\0SDL_GL_SetAttribute\0"
	    "SDL_SetVideoMode\0SDL_ShowCursor\0\0"
	    
	    "libm.so\0powf\0fmodf\0\0"
	    
	    "libc.so.6\0rand\0\0"
	    
	    "libGL.so\0glBegin\0glEnd\0glColor4f\0glVertex3f\0"
	    "glEnable\0glDisable\0glTexCoord2f\0glBindTexture\0"
	    "glTexImage2D\0glTexParameteri\0glGenTextures\0"
	    "glMatrixMode\0glLoadIdentity\0glClear\0glRotatef\0"
	    "glBlendFunc\0glTranslatef\0"
	    /*"glLightfv\0"*/"glNormal3f\0glTexGeni\0"//glDepthMask\0"
	    "glVertex2f\0glPointSize\0\0"
	    "libGLU.so\0gluPerspective\0gluLookAt\0\0"
	    "\0\0";

void dl_init(void)
{
	void **pfn=&fn;
	void *handle;
	unsigned char *p=names;

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
