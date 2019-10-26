
#ifndef __EXTENSIONS_H__
#define __EXTENSIONS_H__

#include <windows.h>
#include <gl/gl.h>

/////////////////////////////////////////////////// ARB_vertex_program + ARB_fragment_program
#define GL_VERTEX_PROGRAM_ARB				0x8620
#define GL_FRAGMENT_PROGRAM_ARB				0x8804
#define GL_PROGRAM_FORMAT_ASCII_ARB			0x8875
#define GL_PROGRAM_ERROR_STRING_ARB			0x8874
#define GL_PROGRAM_ERROR_POSITION_ARB		0x864B

typedef void (APIENTRY *PFNGLPROGRAMSTRINGARB)(GLenum target, GLenum format, GLsizei len, const void *string);
typedef void (APIENTRY *PFNGLBINDPROGRAMARB)(GLenum target, GLuint program);
typedef void (APIENTRY *PFNGLDELETEPROGRAMSARB)(GLsizei n, const GLuint *programs);
typedef void (APIENTRY *PFNGLGENPROGRAMSARB)(GLsizei n, GLuint *programs);

typedef void (APIENTRY *PFNGLPROGRAMENVPARAMETER4DARB)(GLenum target, GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w);
typedef void (APIENTRY *PFNGLPROGRAMENVPARAMETER4DVARB)(GLenum target, GLuint index, const GLdouble * params);
typedef void (APIENTRY *PFNGLPROGRAMENVPARAMETER4FARB)(GLenum target, GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
typedef void (APIENTRY *PFNGLPROGRAMENVPARAMETER4FVARB)(GLenum target, GLuint index, const GLfloat * params);

typedef void (APIENTRY *PFNGLPROGRAMLOCALPARAMETER4DARB)(GLenum target, GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w);
typedef void (APIENTRY *PFNGLPROGRAMLOCALPARAMETER4DVARB)(GLenum target, GLuint index, const GLdouble * params);
typedef void (APIENTRY *PFNGLPROGRAMLOCALPARAMETER4FARB)(GLenum target, GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
typedef void (APIENTRY *PFNGLPROGRAMLOCALPARAMETER4FVARB)(GLenum target, GLuint index, const GLfloat * params);

extern PFNGLGENPROGRAMSARB					glGenProgramsARB;
extern PFNGLPROGRAMSTRINGARB				glProgramStringARB;
extern PFNGLBINDPROGRAMARB					glBindProgramARB;
extern PFNGLDELETEPROGRAMSARB				glDeleteProgramsARB;
extern PFNGLPROGRAMENVPARAMETER4FARB		glProgramEnvParameter4fARB;
extern PFNGLPROGRAMENVPARAMETER4FVARB		glProgramEnvParameter4fvARB;
extern PFNGLPROGRAMLOCALPARAMETER4FARB		glProgramLocalParameter4fARB;
extern PFNGLPROGRAMLOCALPARAMETER4FVARB		glProgramLocalParameter4fvARB;

/////////////////////////////////////////////////// ARB_vertex_buffer_object
#define GL_ARRAY_BUFFER_ARB					0x8892
#define GL_ELEMENT_ARRAY_BUFFER_ARB			0x8893
#define GL_STATIC_DRAW_ARB					0x88E4

typedef void (APIENTRY * PFNGLBINDBUFFERARB) (GLenum target, GLuint buffer);
typedef void (APIENTRY * PFNGLDELETEBUFFERSARB) (GLsizei n, const GLuint *buffers);
typedef void (APIENTRY * PFNGLGENBUFFERSARB) (GLsizei n, GLuint *buffers);
typedef void (APIENTRY * PFNGLBUFFERDATAARB) (GLenum target, int size, const GLvoid *data, GLenum usage);

extern PFNGLBINDBUFFERARB					glBindBufferARB;
extern PFNGLDELETEBUFFERSARB				glDeleteBuffersARB;
extern PFNGLGENBUFFERSARB					glGenBuffersARB;
extern PFNGLBUFFERDATAARB					glBufferDataARB;

/////////////////////////////////////////////////// vertex array
typedef void (APIENTRY *PFNGLDRAWRANGEELEMENTS)(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const GLvoid *indices);

extern PFNGLDRAWRANGEELEMENTS				glDrawRangeElements;

bool isExtensionSupported( const char *extension );
bool loadExtensions();

#endif