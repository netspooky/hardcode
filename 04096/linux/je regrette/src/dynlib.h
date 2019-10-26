/*
    Dynamically loaded SDL & OpenGL functions
*/

#ifndef DYNLIB_H
#define DYNLIB_H

#include <SDL/SDL.h>
#include <SDL/SDL_opengl.h>

void dyn_init(void);

extern void (*mlBegin)(GLenum);
extern void (*mlEnd)(void);
extern void (*mlVertex3f)(GLfloat,GLfloat,GLfloat);
extern void (*mlMatrixMode)(GLenum);

extern void (*mlLoadIdentity)(void);
extern void (*mlClear)(GLenum);
extern void (*mlColor3f)(GLfloat,GLfloat,GLfloat);

extern void (*mlRotatef)(GLfloat,GLfloat,GLfloat,GLfloat);
extern void (*mlTranslatef)(GLfloat,GLfloat,GLfloat);
extern void (*mlEnable)(GLenum);
extern void (*mlDisable)(GLenum);

extern void (*mlLineWidth)(GLfloat);
extern void (*mlFrustum)(GLdouble,GLdouble,GLdouble,GLdouble,GLdouble,GLdouble);

extern void (*mlBindTexture)(GLenum,GLuint);
extern void (*mlTexParameteri)(GLenum, GLenum, GLint);
extern void (*mlTexImage2D)(GLenum,GLint,GLint,GLsizei,GLsizei,GLint,GLenum,GLenum,const GLvoid *);
extern void (*mlCopyTexSubImage2D)(GLenum,GLint,GLint,GLint,GLint,GLint,GLsizei,GLsizei);
extern void (*mlTexCoord2f)(GLfloat,GLfloat);
extern void (*mlBlendFunc)(GLenum,GLenum);

extern int (*MDL_Init)(int);
extern void (*MDL_Quit)(void);
extern int (*MDL_SetVideoMode)(int,int,int,int);
extern int (*MDL_OpenAudio)(SDL_AudioSpec *,SDL_AudioSpec *);

extern int (*MDL_ShowCursor)(int);
extern int (*MDL_PauseAudio)(int);
extern unsigned (*MDL_GetTicks)(void);
extern void (*MDL_GL_SwapBuffers)(void);

extern int (*MDL_PollEvent)(SDL_Event *);

#endif
