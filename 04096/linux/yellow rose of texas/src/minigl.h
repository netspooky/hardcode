/*
    Dynamically loaded OpenGL functions
*/

#ifndef MINIGL_H
#define MINIGL_H

#include <GL/gl.h>

extern void (*mlBegin)(GLenum);
extern void (*mlEnd)(void);
extern void (*mlVertex3f)(GLfloat,GLfloat,GLfloat);
extern void (*mlMatrixMode)(GLenum);

extern void (*mlLoadIdentity)(void);
extern void (*mlClearColor)(GLfloat,GLfloat,GLfloat,GLfloat);
extern void (*mlClear)(GLenum);
extern void (*mlColor3f)(GLfloat,GLfloat,GLfloat);
extern void (*mlRotatef)(GLfloat,GLfloat,GLfloat,GLfloat);

extern void (*mlTranslatef)(GLfloat,GLfloat,GLfloat);
extern void (*mlEnable)(GLenum);
extern void (*mlDisable)(GLenum);
extern void (*mlLightfv)(GLenum,GLenum,GLfloat *);

extern void (*mlNormal3fv)(GLfloat *);
extern void (*mlLineWidth)(GLfloat);
extern void (*mlFrustum)(GLdouble,GLdouble,GLdouble,GLdouble,GLdouble,GLdouble);

void ml_init(void);

#endif
