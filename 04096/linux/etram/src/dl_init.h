/*
---------------------
This is the source of etram/Collapse, a 4k intro released at breakpoint'05
Copyright (C) 2005 by Bernat Muñoz García (aka shash/Collapse)
Linux port (C) 2005 by Jorge Gorbe Moya (aka slack/Necrostudios)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; version 2
of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
---------------------
*/
#include "SDL.h"
#include "stdcall.h"
#include <GL/gl.h>
#include <GL/glu.h>
#include <X11/Xlib.h>
#include <stdlib.h>

typedef struct
{
	// libSDL
	int	(*SDL_Init)(Uint32);
	void	(*SDL_Quit)(void);
	int	(*SDL_OpenAudio)(SDL_AudioSpec*, SDL_AudioSpec*);
	//void	(*SDL_CloseAudio)(void);
	//void	(*SDL_Delay)(Uint32);
	void	(*SDL_PauseAudio)(int);
	int	(*SDL_PollEvent)(SDL_Event*);
	int	(*SDL_GL_SwapBuffers)(void);
	int	(*SDL_GL_SetAttribute)(SDL_GLattr, int);
	Uint32	(*SDL_GetTicks)(void);
	SDL_Surface* (*SDL_SetVideoMode)(int, int, int, Uint32);
	int	(*SDL_ShowCursor)(int);

	// libc
	int	(*rand)(void);
	void*	(*malloc)(size_t);


	// libGL
	void	(*glBegin)(GLenum);
	void	(*glEnd)(void);
	void	(*glColor3f)(GLfloat, GLfloat, GLfloat);
	void	(*glEnable)(GLenum);
	void	(*glDisable)(GLenum);
	void	(*glTexCoord2f)(GLfloat, GLfloat);
	//void	(*glBindTexture)(GLenum, GLuint);
	void	(*glTexImage2D)(GLenum, GLint, GLint, GLsizei, GLsizei,
			GLint, GLenum, GLenum, const GLvoid *);
	void	(*glTexParameteri)(GLenum, GLenum, GLint);
	//void	(*glGenTextures)(GLsizei, GLuint*);
	void	(*glMatrixMode)(GLenum);
	void	(*glLoadIdentity)(void);
	void	(*glClear)(GLbitfield);
	void	(*glRotatef)(GLfloat, GLfloat, GLfloat, GLfloat);
	void	(*glBlendFunc)(GLenum, GLenum);
	void	(*glClearColor)(GLclampf, GLclampf, GLclampf, GLclampf);
	//void	(*glPolygonMode)(GLenum, GLenum);
	void	(*glTranslatef)(GLfloat, GLfloat, GLfloat);
	void	(*glLightfv)(GLenum, GLenum, const GLfloat*);
	void	(*glDepthMask)(GLboolean);
	void	(*glVertex2f)(GLfloat, GLfloat);
	void	(*glScalef)(GLfloat, GLfloat, GLfloat);

	void	(*glPushMatrix)(void);
	void	(*glPopMatrix)(void);
	void	(*glGetFloatv)(GLenum, GLfloat *);
	void	(*glLoadMatrixf)(const GLfloat *);

	// libGLU
	void	(*gluPerspective)(GLdouble, GLdouble, GLdouble, GLdouble);
	void	(*gluLookAt)(GLdouble, GLdouble, GLdouble,
			GLdouble, GLdouble, GLdouble,
			GLdouble, GLdouble, GLdouble);
	
	GLUquadric* (*gluNewQuadric)(void);
	void 	(*gluQuadricTexture)(GLUquadric*, GLboolean);
	void 	(*gluDisk)(GLUquadric*, GLdouble, GLdouble, GLint, GLint);
	void 	(*gluCylinder)(GLUquadric*, GLdouble, GLdouble, GLdouble,
			GLint, GLint);
	void 	(*gluQuadricOrientation)(GLUquadric*, GLenum);



} FN_STRUCT;

//extern STDCALL void dl_init(void);
extern FN_STRUCT fn;
