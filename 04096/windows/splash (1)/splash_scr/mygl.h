#ifndef _MYGL_H_
#define _MYGL_H_

#ifdef _TINYEXE11

#define GL_MODELVIEW                      0x1700
#define GL_PROJECTION                     0x1701
#define GL_TEXTURE                        0x1702
#define GL_GREATER                        0x0204

#define GL_ZERO                           0
#define GL_ONE                            1
#define GL_SRC_COLOR                      0x0300
#define GL_ONE_MINUS_SRC_COLOR            0x0301
#define GL_SRC_ALPHA                      0x0302
#define GL_ONE_MINUS_SRC_ALPHA            0x0303
#define GL_DST_ALPHA                      0x0304
#define GL_ONE_MINUS_DST_ALPHA            0x0305
#define GL_DST_COLOR                      0x0306
#define GL_ONE_MINUS_DST_COLOR            0x0307
#define GL_SRC_ALPHA_SATURATE             0x0308

#define GL_QUADS                          0x0007
#define GL_BLEND                          0x0BE2
#define GL_RGBA                           0x1908
#define GL_MODULATE                       0x2100
#define GL_DEPTH_TEST                     0x0B71
#define GL_ALPHA_TEST                     0x0BC0
#define GL_UNPACK_ALIGNMENT               0x0CF5
#define GL_PACK_ALIGNMENT                 0x0D05
#define GL_UNSIGNED_BYTE                  0x1401
#define GL_TEXTURE_ENV                    0x2300
#define GL_TEXTURE_ENV_MODE               0x2200
#define GL_TEXTURE_2D                     0x0DE1
#define GL_RGB                            0x1907
#define GL_COLOR_BUFFER_BIT               0x00004000
#define GL_DEPTH_BUFFER_BIT               0x00000100
#define GL_TEXTURE_MAG_FILTER             0x2800
#define GL_TEXTURE_MIN_FILTER             0x2801
#define GL_TEXTURE_WRAP_S                 0x2802
#define GL_TEXTURE_WRAP_T                 0x2803
#define GL_NEAREST                        0x2600
#define GL_LINEAR                         0x2601
#define GL_CLAMP                          0x2900
#define GL_REPEAT                         0x2901
#define GL_SPHERE_MAP                     0x2402
#define GL_S                              0x2000
#define GL_T                              0x2001
#define GL_TEXTURE_GEN_MODE               0x2500
#define GL_TEXTURE_GEN_S                  0x0C60
#define GL_TEXTURE_GEN_T                  0x0C61

typedef float GLfloat;
typedef int GLint;
typedef unsigned int GLenum;
typedef unsigned int GLuint;
typedef void GLvoid;
typedef int GLsizei;
typedef float GLclampf;
typedef unsigned int GLbitfield;

extern void ( __cdecl *glBegin) (unsigned int);
extern void ( __cdecl *glViewport) (int x,int y,int width,int height);
extern void ( __cdecl *glMatrixMode) (unsigned int mode);
extern void ( __cdecl *glLoadIdentity) (void);
extern void ( __cdecl *glMultMatrixf) (const float *m);
extern void ( __cdecl *glTexCoord2f) (float s,float t);
extern void ( __cdecl *glEnd) (void);
extern void ( __cdecl *glRotatef) (float angle,float x,float y,float z);
extern void ( __cdecl *glTexImage2D) (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels);
extern void ( __cdecl *glPixelStorei) (GLenum pname, GLint param);
extern void ( __cdecl *glBindTexture) (GLenum target, GLuint texture);
extern void ( __cdecl *glGenTextures) (GLsizei n, GLuint *textures);
extern void ( __cdecl *glTexParameteri) (GLenum target, GLenum pname, GLint param);
extern void ( __cdecl *glDeleteTextures) (GLsizei n, const GLuint *textures);
extern void ( __cdecl *glEnable) (GLenum cap);
extern void ( __cdecl *glDisable) (GLenum cap);
extern void ( __cdecl *glAlphaFunc) (GLenum func, GLclampf ref);
extern void ( __cdecl *glVertex2f) (GLfloat x, GLfloat y);
extern void ( __cdecl *glTexSubImage2D) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels);
extern void ( __cdecl *glBlendFunc) (GLenum sfactor, GLenum dfactor);
extern void ( __cdecl *glTexEnvf) (GLenum target, GLenum pname, GLfloat param);
extern void ( __cdecl *glClearColor) (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
extern void ( __cdecl *glTranslatef) (GLfloat x, GLfloat y, GLfloat z);
extern void ( __cdecl *glColor3f) (GLfloat red, GLfloat green, GLfloat blue);
extern void ( __cdecl *glNormal3f) (GLfloat nx, GLfloat ny, GLfloat nz);
extern void ( __cdecl *glVertex3f) (GLfloat x, GLfloat y, GLfloat z);
extern void ( __cdecl *glTexGeni) (GLenum coord, GLenum pname, GLint param);
extern void ( __cdecl *glScalef) (GLfloat x, GLfloat y, GLfloat z);
extern void ( __cdecl *glClear) (GLbitfield mask);
extern void ( __cdecl *glColor4f) (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);


extern void loadFuncs(void);


#else
#include <GL/gl.h>
#endif



#endif