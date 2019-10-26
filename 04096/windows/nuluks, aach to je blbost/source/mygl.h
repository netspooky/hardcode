#ifndef _MYGL_H_
#define _MYGL_H_

#include <GL/gl.h>

void (*_glClearColor)(GLfloat, GLfloat, GLfloat, GLfloat);
#define glClearColor _glClearColor

void (*_glClear)(GLenum);
#define glClear _glClear

void (*_glBegin)(GLint);
#define glBegin _glBegin

void (*_glEnd)();
#define glEnd _glEnd

void (*_glVertex3f)(GLfloat, GLfloat, GLfloat);
#define glVertex3f _glVertex3f

void (*_glMatrixMode)(GLenum);
#define glMatrixMode _glMatrixMode

void (*_glLoadIdentity)();
#define glLoadIdentity _glLoadIdentity

void (*_glFrustum)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble);
#define glFrustum _glFrustum

void (*_glColor4f)(GLfloat, GLfloat, GLfloat, GLfloat);
#define glColor4f _glColor4f

void (*_glTranslatef)(GLfloat, GLfloat, GLfloat);
#define glTranslatef _glTranslatef

void (*_glGenTextures)(GLint, GLuint *);
#define glGenTextures _glGenTextures

void (*_glBindTexture)(GLenum, GLuint);
#define glBindTexture _glBindTexture

void (*_glTexParameteri)(GLenum, GLenum, GLenum);
#define glTexParameteri _glTexParameteri

void (*_glTexImage2D)(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, const GLvoid *);
#define glTexImage2D _glTexImage2D

void (*_glTexGeni)(GLenum, GLenum, GLenum);
#define glTexGeni _glTexGeni

void (*_glEnable)(GLenum);
#define glEnable _glEnable

void (*_glRotatef)(GLfloat, GLfloat, GLfloat, GLfloat);
#define glRotatef _glRotatef

void (*_glTexCoord2f)(GLfloat, GLfloat);
#define glTexCoord2f _glTexCoord2f

void (*_glBlendFunc)(GLenum, GLenum);
#define glBlendFunc _glBlendFunc

void (*_glColor3ub)(GLubyte, GLubyte, GLubyte);
#define glColor3ub _glColor3ub

void (*_glScalef)(GLfloat, GLfloat, GLfloat);
#define glScalef _glScalef

void (*_glFogf)(GLenum, GLfloat);
#define glFogf _glFogf


#endif