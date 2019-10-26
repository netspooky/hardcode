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
	int	(*SDL_GL_SetAttribute)(SDL_GLattr, int);
	//void	(*SDL_Delay)(Uint32);

	// libm
	float	(*powf)(float, float);
	float	(*fmodf)(float, float);
	//float	(*expf)(float);
	
	// libc
	int	(*rand)(void);
	//void	(*srand)(unsigned int);
	
	// libGL
	void	(*glBegin)(GLenum);
	void	(*glEnd)(void);
	void	(*glColor4f)(GLfloat, GLfloat, GLfloat, GLfloat);
	void	(*glVertex2f)(GLfloat, GLfloat);
	void	(*glRotatef)(GLfloat, GLfloat, GLfloat, GLfloat);
	void	(*glEnable)(GLenum);
	void	(*glDisable)(GLenum);
	void	(*glMatrixMode)(GLenum);
	void	(*glLoadIdentity)(void);
	void	(*glClear)(GLbitfield);
	//void	(*glRotatef)(GLfloat, GLfloat, GLfloat, GLfloat);
	void	(*glBlendFunc)(GLenum, GLenum);
	void	(*glClearColor)(GLfloat, GLfloat, GLfloat, GLfloat);
	//void	(*glTranslatef)(GLfloat, GLfloat, GLfloat);
	//void	(*glNormal3f)(GLfloat, GLfloat, GLfloat);
	//void	(*glTexGeni)(GLenum, GLenum, GLint);
	//void	(*glGetFloatv)(GLenum, GLfloat *);
	//void	(*glPushMatrix)(void);
	//void	(*glPopMatrix)(void);
	void	(*glTexCoord2f)(GLfloat, GLfloat);
	//void	(*glBindTexture)(GLenum, GLuint);
	//void	(*glGenTextures)(GLsizei, GLuint *);
		
	// libGLU
	void	(*gluPerspective)(GLdouble, GLdouble, GLdouble, GLdouble);
	void	(*gluLookAt)(GLdouble, GLdouble, GLdouble,
			GLdouble, GLdouble, GLdouble,
			GLdouble, GLdouble, GLdouble);
	GLint	(*gluBuild2DMipmaps)(GLenum, GLint, GLsizei, GLsizei,
				GLenum, GLenum, const void *);

} FN_STRUCT;

extern void dl_init(void);
extern FN_STRUCT fn;

#endif//DL_INIT_H
