#include "dl_init.h"
#include <dlfcn.h>

FN_STRUCT fn;

char *names="libSDL-1.2.so.0\0SDL_Init\0SDL_Quit\0SDL_OpenAudio\0"
	    "SDL_PauseAudio\0SDL_PollEvent\0"
	    "SDL_GL_SwapBuffers\0"
	    "SDL_SetVideoMode\0SDL_ShowCursor\0SDL_GL_SetAttribute\0"
	    //"SDL_Delay\0"

	    "libm.so\0powf\0fmodf\0"//expf\0"
	    
	    "libc.so.6\0rand\0"//srand\0"
	    
	    "libGL.so\0glBegin\0glEnd\0glColor4f\0glVertex2f\0glRotatef\0"
	    "glEnable\0glDisable\0"
	    "glMatrixMode\0glLoadIdentity\0glClear\0"
	    "glBlendFunc\0glClearColor\0"//glTranslatef\0"
	    //"glGetFloatv\0glPushMatrix\0glPopMatrix\0"
	    "glTexCoord2f\0"
	    
	    "libGLU.so\0gluPerspective\0gluLookAt\0gluBuild2DMipmaps"
	    
	    "\0";


void dl_init(void)
{
	char *p=names;
	void **pfn=(void **)&fn;
	void *handle, *tmp;

	while(*p)
	{
		tmp = dlopen(p, RTLD_LAZY);
		if (tmp == NULL)
		{
			*pfn=dlsym(handle, p);
			#ifdef DEBUG
			__builtin_printf("%s = %p\n", p, *pfn);
			#endif
			++pfn;
		}
		else
		{
			handle=tmp;
		}
		while(*p++); // Avanzamos p hasta la siguiente
	}
}


