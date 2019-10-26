/*
   Voxel Bukkake - A 4k intro for BCNparty'101.
   Copyright (C) 2005 Jorge Gorbe (aka slack/Necrostudios)

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License version 2
   as published by the Free Software Foundation.
*/

#ifndef DL_INIT_H
#define DL_INIT_H

#include "SDL.h"
#include <GL/gl.h>

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
	//int	(*SDL_Flip)(SDL_Surface*);
	int	(*SDL_GL_SwapBuffers)(void);
	SDL_Surface* (*SDL_SetVideoMode)(int, int, int, Uint32);
	int	(*SDL_ShowCursor)(int);
	//int	(*SDL_GL_SetAttribute)(SDL_GLattr, int);


	// libm
	float	(*powf)(float, float);
	float	(*fmodf)(float, float);
	float	(*expf)(float);
	
	// libc
	int	(*rand)(void);
	void	(*srand)(unsigned int);
	
	// libGL
	void	(*glBegin)(GLenum);
	void	(*glEnd)(void);
	void	(*glColor4f)(GLfloat, GLfloat, GLfloat, GLfloat);
	void	(*glVertex3f)(GLfloat, GLfloat, GLfloat);
	void	(*glRotatef)(GLfloat, GLfloat, GLfloat, GLfloat);
	void	(*glEnable)(GLenum);
	void	(*glDisable)(GLenum);
	//void	(*glTexCoord2f)(GLfloat, GLfloat);
	//void	(*glBindTexture)(GLenum, GLuint);
	//void	(*glTexImage2D)(GLenum, GLint, GLint, GLsizei, GLsizei,
	//		GLint, GLenum, GLenum, const GLvoid *);
	//void	(*glTexParameteri)(GLenum, GLenum, GLint);
	//void	(*glGenTextures)(GLsizei, GLuint*);
	void	(*glMatrixMode)(GLenum);
	void	(*glLoadIdentity)(void);
	void	(*glClear)(GLbitfield);
	//void	(*glRotatef)(GLfloat, GLfloat, GLfloat, GLfloat);
	void	(*glBlendFunc)(GLenum, GLenum);
	void	(*glClearColor)(GLfloat, GLfloat, GLfloat, GLfloat);
	//void	(*glTranslatef)(GLfloat, GLfloat, GLfloat);
	//void	(*glNormal3f)(GLfloat, GLfloat, GLfloat);
	//void	(*glTexGeni)(GLenum, GLenum, GLint);
	//void	(*glVertex2f)(GLfloat, GLfloat);
	void	(*glGetFloatv)(GLenum, GLfloat *);
	void	(*glPushMatrix)(void);
	void	(*glPopMatrix)(void);
		
	// libGLU
	void	(*gluPerspective)(GLdouble, GLdouble, GLdouble, GLdouble);
	void	(*gluLookAt)(GLdouble, GLdouble, GLdouble,
			GLdouble, GLdouble, GLdouble,
			GLdouble, GLdouble, GLdouble);

} FN_STRUCT;

extern void dl_init(void);
extern FN_STRUCT fn;

#endif//DL_INIT_H
