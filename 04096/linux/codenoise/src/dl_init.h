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



#include "SDL.h"
#include <GL/gl.h>

typedef struct
{
	// libSDL
	int	(*SDL_Init)(Uint32);
	void	(*SDL_Quit)(void);
	int	(*SDL_OpenAudio)(SDL_AudioSpec*, SDL_AudioSpec*);
	void	(*SDL_CloseAudio)(void);
	void	(*SDL_Delay)(Uint32);
	void	(*SDL_PauseAudio)(int);
	int	(*SDL_PollEvent)(SDL_Event*);
	int	(*SDL_GL_SwapBuffers)(void);
	int	(*SDL_GL_SetAttribute)(SDL_GLattr, int);
	SDL_Surface* (*SDL_SetVideoMode)(int, int, int, Uint32);
	int	(*SDL_ShowCursor)(int);

	// libm
	float	(*powf)(float, float);
	float	(*fmodf)(float, float);
	
	// libc
	int	(*rand)(void);

	// libGL
	void	(*glBegin)(GLenum);
	void	(*glEnd)(void);
	//void	(*glColor3f)(GLfloat, GLfloat, GLfloat);
	void	(*glColor4f)(GLfloat, GLfloat, GLfloat, GLfloat);
	void	(*glVertex3f)(GLfloat, GLfloat, GLfloat);
	void	(*glEnable)(GLenum);
	void	(*glDisable)(GLenum);
	void	(*glTexCoord2f)(GLfloat, GLfloat);
	void	(*glBindTexture)(GLenum, GLuint);
	void	(*glTexImage2D)(GLenum, GLint, GLint, GLsizei, GLsizei,
			GLint, GLenum, GLenum, const GLvoid *);
	void	(*glTexParameteri)(GLenum, GLenum, GLint);
	void	(*glGenTextures)(GLsizei, GLuint*);
	void	(*glMatrixMode)(GLenum);
	void	(*glLoadIdentity)(void);
	void	(*glClear)(GLbitfield);
	void	(*glRotatef)(GLfloat, GLfloat, GLfloat, GLfloat);
	void	(*glBlendFunc)(GLenum, GLenum);
	//void	(*glClearColor)(GLclampf, GLclampf, GLclampf, GLclampf);
	//void	(*glPolygonMode)(GLenum, GLenum);
	void	(*glTranslatef)(GLfloat, GLfloat, GLfloat);
	//void	(*glLightfv)(GLenum, GLenum, const GLfloat*);
	void	(*glNormal3f)(GLfloat, GLfloat, GLfloat);
	void	(*glTexGeni)(GLenum, GLenum, GLint);
	//void	(*glDepthMask)(GLboolean);
	void	(*glVertex2f)(GLfloat, GLfloat);
	void	(*glPointSize)(GLfloat);

	// libGLU
	void	(*gluPerspective)(GLdouble, GLdouble, GLdouble, GLdouble);
	void	(*gluLookAt)(GLdouble, GLdouble, GLdouble,
			GLdouble, GLdouble, GLdouble,
			GLdouble, GLdouble, GLdouble);

} FN_STRUCT;

extern void dl_init(void);
extern FN_STRUCT fn;
