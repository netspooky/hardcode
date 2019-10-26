/********************************************************************************
                    glparam.h (C) 2002 By Adam "Grizzly" Medveczky

             gl commands' parameters' displayer for Microsoft Visual C++ 6.0


            Usage: **** ADD TO THE PROJECT!!!! **** it's not important to #include,
            ^^^^^  but you *MUST* add it with Project->Add To Project->Files !!!

                   Type a GL/GLU/gl extension function and the parameters will show up!
            Tested on MSVC++ 6.0/7.0 beta 2, but maybe it works on other versions, too...
            Feel free to give it to anybody, but this comment must be remained.

            On MSVC 7.0, the parameters for regular gl/glu functions are now showed,
            so you can remove them below, maybe it would be faster.

                                                Contact me at grizzly_@freemail.hu
*********************************************************************************/


#ifndef __GLPARAM_H_
#define __GLPARAM_H_

#include <gl/gl.h>
#include <gl/glu.h>

#ifdef this_is_needed_so_dont_modify_it

// gl.h -->

void glAccum (GLenum op, GLfloat value){}
void glAlphaFunc (GLenum func, GLclampf ref){}
GLboolean glAreTexturesResident (GLsizei n, const GLuint *textures, GLboolean *residences){ return 0; }
void glArrayElement (GLint i){}
void glBegin (GLenum mode){}
void glBindTexture (GLenum target, GLuint texture){}
void glBitmap (GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove, const GLubyte *bitmap){}
void glBlendFunc (GLenum sfactor, GLenum dfactor){}
void glCallList (GLuint list){}
void glCallLists (GLsizei n, GLenum type, const GLvoid *lists){}
void glClear (GLbitfield mask){}
void glClearAccum (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha){}
void glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha){}
void glClearDepth (GLclampd depth){}
void glClearIndex (GLfloat c){}
void glClearStencil (GLint s){}
void glClipPlane (GLenum plane, const GLdouble *equation){}
void glColor3b (GLbyte red, GLbyte green, GLbyte blue){}
void glColor3bv (const GLbyte *v){}
void glColor3d (GLdouble red, GLdouble green, GLdouble blue){}
void glColor3dv (const GLdouble *v){}
void glColor3f (GLfloat red, GLfloat green, GLfloat blue){}
void glColor3fv (const GLfloat *v){}
void glColor3i (GLint red, GLint green, GLint blue){}
void glColor3iv (const GLint *v){}
void glColor3s (GLshort red, GLshort green, GLshort blue){}
void glColor3sv (const GLshort *v){}
void glColor3ub (GLubyte red, GLubyte green, GLubyte blue){}
void glColor3ubv (const GLubyte *v){}
void glColor3ui (GLuint red, GLuint green, GLuint blue){}
void glColor3uiv (const GLuint *v){}
void glColor3us (GLushort red, GLushort green, GLushort blue){}
void glColor3usv (const GLushort *v){}
void glColor4b (GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha){}
void glColor4bv (const GLbyte *v){}
void glColor4d (GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha){}
void glColor4dv (const GLdouble *v){}
void glColor4f (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha){}
void glColor4fv (const GLfloat *v){}
void glColor4i (GLint red, GLint green, GLint blue, GLint alpha){}
void glColor4iv (const GLint *v){}
void glColor4s (GLshort red, GLshort green, GLshort blue, GLshort alpha){}
void glColor4sv (const GLshort *v){}
void glColor4ub (GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha){}
void glColor4ubv (const GLubyte *v){}
void glColor4ui (GLuint red, GLuint green, GLuint blue, GLuint alpha){}
void glColor4uiv (const GLuint *v){}
void glColor4us (GLushort red, GLushort green, GLushort blue, GLushort alpha){}
void glColor4usv (const GLushort *v){}
void glColorMask (GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha){}
void glColorMaterial (GLenum face, GLenum mode){}
void glColorPointer (GLint size, GLenum type, GLsizei stride, const GLvoid *pointer){}
void glCopyPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum type){}
void glCopyTexImage1D (GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLint border){}
void glCopyTexImage2D (GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border){}
void glCopyTexSubImage1D (GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width){}
void glCopyTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height){}
void glCullFace (GLenum mode){}
void glDeleteLists (GLuint list, GLsizei range){}
void glDeleteTextures (GLsizei n, const GLuint *textures){}
void glDepthFunc (GLenum func){}
void glDepthMask (GLboolean flag){}
void glDepthRange (GLclampd zNear, GLclampd zFar){}
void glDisable (GLenum cap){}
void glDisableClientState (GLenum array){}
void glDrawArrays (GLenum mode, GLint first, GLsizei count){}
void glDrawBuffer (GLenum mode){}
void glDrawElements (GLenum mode, GLsizei count, GLenum type, const GLvoid *indices){}
void glDrawPixels (GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels){}
void glEdgeFlag (GLboolean flag){}
void glEdgeFlagPointer (GLsizei stride, const GLvoid *pointer){}
void glEdgeFlagv (const GLboolean *flag){}
void glEnable (GLenum cap){}
void glEnableClientState (GLenum array){}
void glEnd (void){}
void glEndList (void){}
void glEvalCoord1d (GLdouble u){}
void glEvalCoord1dv (const GLdouble *u){}
void glEvalCoord1f (GLfloat u){}
void glEvalCoord1fv (const GLfloat *u){}
void glEvalCoord2d (GLdouble u, GLdouble v){}
void glEvalCoord2dv (const GLdouble *u){}
void glEvalCoord2f (GLfloat u, GLfloat v){}
void glEvalCoord2fv (const GLfloat *u){}
void glEvalMesh1 (GLenum mode, GLint i1, GLint i2){}
void glEvalMesh2 (GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2){}
void glEvalPoint1 (GLint i){}
void glEvalPoint2 (GLint i, GLint j){}
void glFeedbackBuffer (GLsizei size, GLenum type, GLfloat *buffer){}
void glFinish (void){}
void glFlush (void){}
void glFogf (GLenum pname, GLfloat param){}
void glFogfv (GLenum pname, const GLfloat *params){}
void glFogi (GLenum pname, GLint param){}
void glFogiv (GLenum pname, const GLint *params){}
void glFrontFace (GLenum mode){}
void glFrustum (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar){}
GLuint glGenLists (GLsizei range){ return 0; }
void glGenTextures (GLsizei n, GLuint *textures){}
void glGetBooleanv (GLenum pname, GLboolean *params){}
void glGetClipPlane (GLenum plane, GLdouble *equation){}
void glGetDoublev (GLenum pname, GLdouble *params){}
GLenum glGetError (void){ return 0; }
void glGetFloatv (GLenum pname, GLfloat *params){}
void glGetIntegerv (GLenum pname, GLint *params){}
void glGetLightfv (GLenum light, GLenum pname, GLfloat *params){}
void glGetLightiv (GLenum light, GLenum pname, GLint *params){}
void glGetMapdv (GLenum target, GLenum query, GLdouble *v){}
void glGetMapfv (GLenum target, GLenum query, GLfloat *v){}
void glGetMapiv (GLenum target, GLenum query, GLint *v){}
void glGetMaterialfv (GLenum face, GLenum pname, GLfloat *params){}
void glGetMaterialiv (GLenum face, GLenum pname, GLint *params){}
void glGetPixelMapfv (GLenum map, GLfloat *values){}
void glGetPixelMapuiv (GLenum map, GLuint *values){}
void glGetPixelMapusv (GLenum map, GLushort *values){}
void glGetPointerv (GLenum pname, GLvoid* *params){}
void glGetPolygonStipple (GLubyte *mask){}
const GLubyte * glGetString (GLenum name){ return 0; }
void glGetTexEnvfv (GLenum target, GLenum pname, GLfloat *params){}
void glGetTexEnviv (GLenum target, GLenum pname, GLint *params){}
void glGetTexGendv (GLenum coord, GLenum pname, GLdouble *params){}
void glGetTexGenfv (GLenum coord, GLenum pname, GLfloat *params){}
void glGetTexGeniv (GLenum coord, GLenum pname, GLint *params){}
void glGetTexImage (GLenum target, GLint level, GLenum format, GLenum type, GLvoid *pixels){}
void glGetTexLevelParameterfv (GLenum target, GLint level, GLenum pname, GLfloat *params){}
void glGetTexLevelParameteriv (GLenum target, GLint level, GLenum pname, GLint *params){}
void glGetTexParameterfv (GLenum target, GLenum pname, GLfloat *params){}
void glGetTexParameteriv (GLenum target, GLenum pname, GLint *params){}
void glHint (GLenum target, GLenum mode){}
void glIndexMask (GLuint mask){}
void glIndexPointer (GLenum type, GLsizei stride, const GLvoid *pointer){}
void glIndexd (GLdouble c){}
void glIndexdv (const GLdouble *c){}
void glIndexf (GLfloat c){}
void glIndexfv (const GLfloat *c){}
void glIndexi (GLint c){}
void glIndexiv (const GLint *c){}
void glIndexs (GLshort c){}
void glIndexsv (const GLshort *c){}
void glIndexub (GLubyte c){}
void glIndexubv (const GLubyte *c){}
void glInitNames (void){}
void glInterleavedArrays (GLenum format, GLsizei stride, const GLvoid *pointer){}
GLboolean glIsEnabled (GLenum cap){ return 0; }
GLboolean glIsList (GLuint list){ return 0; }
GLboolean glIsTexture (GLuint texture){ return 0; }
void glLightModelf (GLenum pname, GLfloat param){}
void glLightModelfv (GLenum pname, const GLfloat *params){}
void glLightModeli (GLenum pname, GLint param){}
void glLightModeliv (GLenum pname, const GLint *params){}
void glLightf (GLenum light, GLenum pname, GLfloat param){}
void glLightfv (GLenum light, GLenum pname, const GLfloat *params){}
void glLighti (GLenum light, GLenum pname, GLint param){}
void glLightiv (GLenum light, GLenum pname, const GLint *params){}
void glLineStipple (GLint factor, GLushort pattern){}
void glLineWidth (GLfloat width){}
void glListBase (GLuint base){}
void glLoadIdentity (void){}
void glLoadMatrixd (const GLdouble *m){}
void glLoadMatrixf (const GLfloat *m){}
void glLoadName (GLuint name){}
void glLogicOp (GLenum opcode){}
void glMap1d (GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order, const GLdouble *points){}
void glMap1f (GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order, const GLfloat *points){}
void glMap2d (GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, const GLdouble *points){}
void glMap2f (GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, const GLfloat *points){}
void glMapGrid1d (GLint un, GLdouble u1, GLdouble u2){}
void glMapGrid1f (GLint un, GLfloat u1, GLfloat u2){}
void glMapGrid2d (GLint un, GLdouble u1, GLdouble u2, GLint vn, GLdouble v1, GLdouble v2){}
void glMapGrid2f (GLint un, GLfloat u1, GLfloat u2, GLint vn, GLfloat v1, GLfloat v2){}
void glMaterialf (GLenum face, GLenum pname, GLfloat param){}
void glMaterialfv (GLenum face, GLenum pname, const GLfloat *params){}
void glMateriali (GLenum face, GLenum pname, GLint param){}
void glMaterialiv (GLenum face, GLenum pname, const GLint *params){}
void glMatrixMode (GLenum mode){}
void glMultMatrixd (const GLdouble *m){}
void glMultMatrixf (const GLfloat *m){}
void glNewList (GLuint list, GLenum mode){}
void glNormal3b (GLbyte nx, GLbyte ny, GLbyte nz){}
void glNormal3bv (const GLbyte *v){}
void glNormal3d (GLdouble nx, GLdouble ny, GLdouble nz){}
void glNormal3dv (const GLdouble *v){}
void glNormal3f (GLfloat nx, GLfloat ny, GLfloat nz){}
void glNormal3fv (const GLfloat *v){}
void glNormal3i (GLint nx, GLint ny, GLint nz){}
void glNormal3iv (const GLint *v){}
void glNormal3s (GLshort nx, GLshort ny, GLshort nz){}
void glNormal3sv (const GLshort *v){}
void glNormalPointer (GLenum type, GLsizei stride, const GLvoid *pointer){}
void glOrtho (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar){}
void glPassThrough (GLfloat token){}
void glPixelMapfv (GLenum map, GLsizei mapsize, const GLfloat *values){}
void glPixelMapuiv (GLenum map, GLsizei mapsize, const GLuint *values){}
void glPixelMapusv (GLenum map, GLsizei mapsize, const GLushort *values){}
void glPixelStoref (GLenum pname, GLfloat param){}
void glPixelStorei (GLenum pname, GLint param){}
void glPixelTransferf (GLenum pname, GLfloat param){}
void glPixelTransferi (GLenum pname, GLint param){}
void glPixelZoom (GLfloat xfactor, GLfloat yfactor){}
void glPointSize (GLfloat size){}
void glPolygonMode (GLenum face, GLenum mode){}
void glPolygonOffset (GLfloat factor, GLfloat units){}
void glPolygonStipple (const GLubyte *mask){}
void glPopAttrib (void){}
void glPopClientAttrib (void){}
void glPopMatrix (void){}
void glPopName (void){}
void glPrioritizeTextures (GLsizei n, const GLuint *textures, const GLclampf *priorities){}
void glPushAttrib (GLbitfield mask){}
void glPushClientAttrib (GLbitfield mask){}
void glPushMatrix (void){}
void glPushName (GLuint name){}
void glRasterPos2d (GLdouble x, GLdouble y){}
void glRasterPos2dv (const GLdouble *v){}
void glRasterPos2f (GLfloat x, GLfloat y){}
void glRasterPos2fv (const GLfloat *v){}
void glRasterPos2i (GLint x, GLint y){}
void glRasterPos2iv (const GLint *v){}
void glRasterPos2s (GLshort x, GLshort y){}
void glRasterPos2sv (const GLshort *v){}
void glRasterPos3d (GLdouble x, GLdouble y, GLdouble z){}
void glRasterPos3dv (const GLdouble *v){}
void glRasterPos3f (GLfloat x, GLfloat y, GLfloat z){}
void glRasterPos3fv (const GLfloat *v){}
void glRasterPos3i (GLint x, GLint y, GLint z){}
void glRasterPos3iv (const GLint *v){}
void glRasterPos3s (GLshort x, GLshort y, GLshort z){}
void glRasterPos3sv (const GLshort *v){}
void glRasterPos4d (GLdouble x, GLdouble y, GLdouble z, GLdouble w){}
void glRasterPos4dv (const GLdouble *v){}
void glRasterPos4f (GLfloat x, GLfloat y, GLfloat z, GLfloat w){}
void glRasterPos4fv (const GLfloat *v){}
void glRasterPos4i (GLint x, GLint y, GLint z, GLint w){}
void glRasterPos4iv (const GLint *v){}
void glRasterPos4s (GLshort x, GLshort y, GLshort z, GLshort w){}
void glRasterPos4sv (const GLshort *v){}
void glReadBuffer (GLenum mode){}
void glReadPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels){}
void glRectd (GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2){}
void glRectdv (const GLdouble *v1, const GLdouble *v2){}
void glRectf (GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2){}
void glRectfv (const GLfloat *v1, const GLfloat *v2){}
void glRecti (GLint x1, GLint y1, GLint x2, GLint y2){}
void glRectiv (const GLint *v1, const GLint *v2){}
void glRects (GLshort x1, GLshort y1, GLshort x2, GLshort y2){}
void glRectsv (const GLshort *v1, const GLshort *v2){}
GLint glRenderMode (GLenum mode){ return 0; }
void glRotated (GLdouble angle, GLdouble x, GLdouble y, GLdouble z){}
void glRotatef (GLfloat angle, GLfloat x, GLfloat y, GLfloat z){}
void glScaled (GLdouble x, GLdouble y, GLdouble z){}
void glScalef (GLfloat x, GLfloat y, GLfloat z){}
void glScissor (GLint x, GLint y, GLsizei width, GLsizei height){}
void glSelectBuffer (GLsizei size, GLuint *buffer){}
void glShadeModel (GLenum mode){}
void glStencilFunc (GLenum func, GLint ref, GLuint mask){}
void glStencilMask (GLuint mask){}
void glStencilOp (GLenum fail, GLenum zfail, GLenum zpass){}
void glTexCoord1d (GLdouble s){}
void glTexCoord1dv (const GLdouble *v){}
void glTexCoord1f (GLfloat s){}
void glTexCoord1fv (const GLfloat *v){}
void glTexCoord1i (GLint s){}
void glTexCoord1iv (const GLint *v){}
void glTexCoord1s (GLshort s){}
void glTexCoord1sv (const GLshort *v){}
void glTexCoord2d (GLdouble s, GLdouble t){}
void glTexCoord2dv (const GLdouble *v){}
void glTexCoord2f (GLfloat s, GLfloat t){}
void glTexCoord2fv (const GLfloat *v){}
void glTexCoord2i (GLint s, GLint t){}
void glTexCoord2iv (const GLint *v){}
void glTexCoord2s (GLshort s, GLshort t){}
void glTexCoord2sv (const GLshort *v){}
void glTexCoord3d (GLdouble s, GLdouble t, GLdouble r){}
void glTexCoord3dv (const GLdouble *v){}
void glTexCoord3f (GLfloat s, GLfloat t, GLfloat r){}
void glTexCoord3fv (const GLfloat *v){}
void glTexCoord3i (GLint s, GLint t, GLint r){}
void glTexCoord3iv (const GLint *v){}
void glTexCoord3s (GLshort s, GLshort t, GLshort r){}
void glTexCoord3sv (const GLshort *v){}
void glTexCoord4d (GLdouble s, GLdouble t, GLdouble r, GLdouble q){}
void glTexCoord4dv (const GLdouble *v){}
void glTexCoord4f (GLfloat s, GLfloat t, GLfloat r, GLfloat q){}
void glTexCoord4fv (const GLfloat *v){}
void glTexCoord4i (GLint s, GLint t, GLint r, GLint q){}
void glTexCoord4iv (const GLint *v){}
void glTexCoord4s (GLshort s, GLshort t, GLshort r, GLshort q){}
void glTexCoord4sv (const GLshort *v){}
void glTexCoordPointer (GLint size, GLenum type, GLsizei stride, const GLvoid *pointer){}
void glTexEnvf (GLenum target, GLenum pname, GLfloat param){}
void glTexEnvfv (GLenum target, GLenum pname, const GLfloat *params){}
void glTexEnvi (GLenum target, GLenum pname, GLint param){}
void glTexEnviv (GLenum target, GLenum pname, const GLint *params){}
void glTexGend (GLenum coord, GLenum pname, GLdouble param){}
void glTexGendv (GLenum coord, GLenum pname, const GLdouble *params){}
void glTexGenf (GLenum coord, GLenum pname, GLfloat param){}
void glTexGenfv (GLenum coord, GLenum pname, const GLfloat *params){}
void glTexGeni (GLenum coord, GLenum pname, GLint param){}
void glTexGeniv (GLenum coord, GLenum pname, const GLint *params){}
void glTexImage1D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, const GLvoid *pixels){}
void glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels){}
void glTexParameterf (GLenum target, GLenum pname, GLfloat param){}
void glTexParameterfv (GLenum target, GLenum pname, const GLfloat *params){}
void glTexParameteri (GLenum target, GLenum pname, GLint param){}
void glTexParameteriv (GLenum target, GLenum pname, const GLint *params){}
void glTexSubImage1D (GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const GLvoid *pixels){}
void glTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels){}
void glTranslated (GLdouble x, GLdouble y, GLdouble z){}
void glTranslatef (GLfloat x, GLfloat y, GLfloat z){}
void glVertex2d (GLdouble x, GLdouble y){}
void glVertex2dv (const GLdouble *v){}
void glVertex2f (GLfloat x, GLfloat y){}
void glVertex2fv (const GLfloat *v){}
void glVertex2i (GLint x, GLint y){}
void glVertex2iv (const GLint *v){}
void glVertex2s (GLshort x, GLshort y){}
void glVertex2sv (const GLshort *v){}
void glVertex3d (GLdouble x, GLdouble y, GLdouble z){}
void glVertex3dv (const GLdouble *v){}
void glVertex3f (GLfloat x, GLfloat y, GLfloat z){}
void glVertex3fv (const GLfloat *v){}
void glVertex3i (GLint x, GLint y, GLint z){}
void glVertex3iv (const GLint *v){}
void glVertex3s (GLshort x, GLshort y, GLshort z){}
void glVertex3sv (const GLshort *v){}
void glVertex4d (GLdouble x, GLdouble y, GLdouble z, GLdouble w){}
void glVertex4dv (const GLdouble *v){}
void glVertex4f (GLfloat x, GLfloat y, GLfloat z, GLfloat w){}
void glVertex4fv (const GLfloat *v){}
void glVertex4i (GLint x, GLint y, GLint z, GLint w){}
void glVertex4iv (const GLint *v){}
void glVertex4s (GLshort x, GLshort y, GLshort z, GLshort w){}
void glVertex4sv (const GLshort *v){}
void glVertexPointer (GLint size, GLenum type, GLsizei stride, const GLvoid *pointer){}
void glViewport (GLint x, GLint y, GLsizei width, GLsizei height){}

// <-- gl.h

// glu.h -->

const GLubyte* gluErrorString (
    GLenum   errCode){ return 0; }

const wchar_t* gluErrorUnicodeStringEXT (
    GLenum   errCode){ return 0; }

const GLubyte* gluGetString (
    GLenum   name){ return 0; }

void gluOrtho2D (
    GLdouble left, 
    GLdouble right, 
    GLdouble bottom, 
    GLdouble top){}

void gluPerspective (
    GLdouble fovy, 
    GLdouble aspect, 
    GLdouble zNear, 
    GLdouble zFar){}

void gluPickMatrix (
    GLdouble x, 
    GLdouble y, 
    GLdouble width, 
    GLdouble height, 
    GLint    viewport[4]){}

void gluLookAt (
    GLdouble eyex, 
    GLdouble eyey, 
    GLdouble eyez, 
    GLdouble centerx, 
    GLdouble centery, 
    GLdouble centerz, 
    GLdouble upx, 
    GLdouble upy, 
    GLdouble upz){}

int gluProject (
    GLdouble        objx, 
    GLdouble        objy, 
    GLdouble        objz,  
    const GLdouble  modelMatrix[16], 
    const GLdouble  projMatrix[16], 
    const GLint     viewport[4], 
    GLdouble        *winx, 
    GLdouble        *winy, 
    GLdouble        *winz){ return 0; }

int gluUnProject (
    GLdouble       winx, 
    GLdouble       winy, 
    GLdouble       winz, 
    const GLdouble modelMatrix[16], 
    const GLdouble projMatrix[16], 
    const GLint    viewport[4], 
    GLdouble       *objx, 
    GLdouble       *objy, 
    GLdouble       *objz){ return 0; }

int gluScaleImage (
    GLenum      format, 
    GLint       widthin, 
    GLint       heightin, 
    GLenum      typein, 
    const void  *datain, 
    GLint       widthout, 
    GLint       heightout, 
    GLenum      typeout, 
    void        *dataout){ return 0; }

int gluBuild1DMipmaps (
    GLenum      target, 
    GLint       components, 
    GLint       width, 
    GLenum      format, 
    GLenum      type, 
    const void  *data){ return 0; }

int gluBuild2DMipmaps (
    GLenum      target, 
    GLint       components, 
    GLint       width, 
    GLint       height, 
    GLenum      format, 
    GLenum      type, 
    const void  *data){ return 0; }

GLUquadric* gluNewQuadric (void){ return 0; }

void gluDeleteQuadric (
    GLUquadric          *state){}

void gluQuadricNormals (
    GLUquadric          *quadObject, 
    GLenum              normals){}

void gluQuadricTexture (
    GLUquadric          *quadObject, 
    GLboolean           textureCoords){}

void gluQuadricOrientation (
    GLUquadric          *quadObject, 
    GLenum              orientation){}

void gluQuadricDrawStyle (
    GLUquadric          *quadObject, 
    GLenum              drawStyle){}

void gluCylinder (
    GLUquadric          *qobj, 
    GLdouble            baseRadius, 
    GLdouble            topRadius, 
    GLdouble            height, 
    GLint               slices, 
    GLint               stacks){}

void gluDisk (
    GLUquadric          *qobj, 
    GLdouble            innerRadius, 
    GLdouble            outerRadius, 
    GLint               slices, 
    GLint               loops){}

void gluPartialDisk (
    GLUquadric          *qobj, 
    GLdouble            innerRadius, 
    GLdouble            outerRadius, 
    GLint               slices, 
    GLint               loops, 
    GLdouble            startAngle, 
    GLdouble            sweepAngle){}

void gluSphere (
    GLUquadric          *qobj, 
    GLdouble            radius, 
    GLint               slices, 
    GLint               stacks){}

void gluQuadricCallback (
    GLUquadric          *qobj, 
    GLenum              which, 
    void                (CALLBACK* fn)()){}

GLUtesselator*  gluNewTess(          
    void ){ return 0; }

void  gluDeleteTess(       
    GLUtesselator       *tess ){}

void  gluTessBeginPolygon( 
    GLUtesselator       *tess,
    void                *polygon_data ){}

void  gluTessBeginContour( 
    GLUtesselator       *tess ){}

void  gluTessVertex(       
    GLUtesselator       *tess,
    GLdouble            coords[3], 
    void                *data ){}

void  gluTessEndContour(   
    GLUtesselator       *tess ){}

void  gluTessEndPolygon(   
    GLUtesselator       *tess ){}

void  gluTessProperty(     
    GLUtesselator       *tess,
    GLenum              which, 
    GLdouble            value ){}

void  gluTessNormal(       
    GLUtesselator       *tess, 
    GLdouble            x,
    GLdouble            y, 
    GLdouble            z ){}

void  gluTessCallback(     
    GLUtesselator       *tess,
    GLenum              which, 
    void                (CALLBACK *fn)()){}

void  gluGetTessProperty(  
    GLUtesselator       *tess,
    GLenum              which, 
    GLdouble            *value ){}

GLUnurbs* gluNewNurbsRenderer (void){ return 0; }

void gluDeleteNurbsRenderer (
    GLUnurbs            *nobj){}

void gluBeginSurface (
    GLUnurbs            *nobj){}

void gluBeginCurve (
    GLUnurbs            *nobj){}

void gluEndCurve (
    GLUnurbs            *nobj){}

void gluEndSurface (
    GLUnurbs            *nobj){}

void gluBeginTrim (
    GLUnurbs            *nobj){}

void gluEndTrim (
    GLUnurbs            *nobj){}

void gluPwlCurve (
    GLUnurbs            *nobj, 
    GLint               count, 
    GLfloat             *array, 
    GLint               stride, 
    GLenum              type){}

void gluNurbsCurve (
    GLUnurbs            *nobj, 
    GLint               nknots, 
    GLfloat             *knot, 
    GLint               stride, 
    GLfloat             *ctlarray, 
    GLint               order, 
    GLenum              type){}

void 
gluNurbsSurface(     
    GLUnurbs            *nobj, 
    GLint               sknot_count, 
    float               *sknot, 
    GLint               tknot_count, 
    GLfloat             *tknot, 
    GLint               s_stride, 
    GLint               t_stride, 
    GLfloat             *ctlarray, 
    GLint               sorder, 
    GLint               torder, 
    GLenum              type){}

void 
gluLoadSamplingMatrices (
    GLUnurbs            *nobj, 
    const GLfloat       modelMatrix[16], 
    const GLfloat       projMatrix[16], 
    const GLint         viewport[4] ){}

void 
gluNurbsProperty (
    GLUnurbs            *nobj, 
    GLenum              property, 
    GLfloat             value ){}

void 
gluGetNurbsProperty (
    GLUnurbs            *nobj, 
    GLenum              property, 
    GLfloat             *value ){}

void 
gluNurbsCallback (
    GLUnurbs            *nobj, 
    GLenum              which, 
    void                (CALLBACK* fn)() ){}

void   gluBeginPolygon( GLUtesselator *tess ){}

void   gluNextContour(  GLUtesselator *tess, 
                                 GLenum        type ){}

void   gluEndPolygon(   GLUtesselator *tess ){}


// <-- glu.h

// extensions with postfix -->

void glLockArraysEXT(GLint first, GLsizei count) {}
void glUnlockArraysEXT() {}
void glSecondaryColor3bEXT(GLbyte red, GLbyte green, GLbyte blue) {}
void glSecondaryColor3bvEXT(const GLbyte *v) {}
void glSecondaryColor3dEXT(GLdouble red, GLdouble green, GLdouble blue) {}
void glSecondaryColor3dvEXT(const GLdouble *v) {}
void glSecondaryColor3fEXT(GLfloat red, GLfloat green, GLfloat blue) {}
void glSecondaryColor3fvEXT(const GLfloat *v) {}
void glSecondaryColor3iEXT(GLint red, GLint green, GLint blue) {}
void glSecondaryColor3ivEXT(const GLint *v) {}
void glSecondaryColor3sEXT(GLshort red, GLshort green, GLshort blue) {}
void glSecondaryColor3svEXT(const GLshort *v) {}
void glSecondaryColor3ubEXT(GLubyte red, GLubyte green, GLubyte blue) {}
void glSecondaryColor3ubvEXT(const GLubyte *v) {}
void glSecondaryColor3uiEXT(GLuint red, GLuint green, GLuint blue) {}
void glSecondaryColor3uivEXT(const GLuint *v) {}
void glSecondaryColor3usEXT(GLushort red, GLushort green, GLushort blue) {}
void glSecondaryColor3usvEXT(const GLushort *v) {}
void glSecondaryColorPointerEXT(GLint size, GLenum type, GLsizei stride, GLvoid *pointer) {}
void glFogCoordfEXT(GLfloat coord) {}
void glFogCoordfvEXT(const GLfloat *coord) {}
void glFogCoorddEXT(GLdouble coord) {}
void glFogCoorddvEXT(const GLdouble *coord) {}
void glFogCoordPointerEXT(GLenum type, GLsizei stride, const GLvoid *pointer) {}
void glFlushVertexArrayRangeNV(void) {}
void glVertexArrayRangeNV(GLsizei size, const GLvoid *pointer) {}
void wglAllocateMemoryNV(GLsizei size, GLfloat readFrequency, GLfloat writeFrequency, GLfloat priority) {}
void wglFreeMemoryNV(void *pointer) {}
void glPointParameterfEXT(GLenum pname, GLfloat param) {}
void glPointParameterfvEXT(GLenum pname, const GLfloat *params) {}
void glCombinerParameterfvNV(GLenum pname, const GLfloat *params) {}
void glCombinerParameterfNV(GLenum pname, GLfloat param) {}
void glCombinerParameterivNV(GLenum pname, const GLint *params) {}
void glCombinerParameteriNV(GLenum pname, GLint param) {}
void glCombinerInputNV(GLenum stage, GLenum portion, GLenum variable, GLenum input, GLenum mapping, GLenum componentUsage) {}
void glCombinerOutputNV(GLenum stage, GLenum portion, GLenum abOutput, GLenum cdOutput, GLenum sumOutput, GLenum scale, GLenum bias, GLboolean abDotProduct, GLboolean cdDotProduct, GLboolean muxSum) {}
void glFinalCombinerInputNV(GLenum variable, GLenum input, GLenum mapping, GLenum componentUsage) {}
void glGetCombinerInputParameterfvNV(GLenum stage, GLenum portion, GLenum variable, GLenum pname, GLfloat *params) {}
void glGetCombinerInputParameterivNV(GLenum stage, GLenum portion, GLenum variable, GLenum pname, GLint *params) {}
void glGetCombinerOutputParameterfvNV(GLenum stage, GLenum portion, GLenum pname, GLfloat *params) {}
void glGetCombinerOutputParameterivNV(GLenum stage, GLenum portion, GLenum pname, GLint *params) {}
void glGetFinalCombinerInputParameterfvNV(GLenum variable, GLenum pname, GLfloat *params) {}
void glGetFinalCombinerInputParameterivNV(GLenum variable, GLenum pname, GLint *params) {}
void glVertexWeightfEXT(GLfloat weight) {}
void glVertexWeightfvEXT(const GLfloat *weight) {}
void glVertexWeightPointerEXT(GLsizei size, GLenum type, GLsizei stride, const GLvoid *pointer) {}
void glBindProgramNV(GLenum target, GLuint id) {}
void glDeleteProgramsNV(GLsizei n, const GLuint *ids) {}
void glExecuteProgramNV(GLenum target, GLuint id, const GLfloat *params) {}
void glGenProgramsNV(GLsizei n, GLuint *ids) {}
GLboolean glAreProgramsResidentNV(GLsizei n, const GLuint *ids, GLboolean *residences) { return 0;}
void glRequestResidentProgramsNV(GLsizei n, GLuint *ids) {}
void glGetProgramParameterfvNV(GLenum target, GLuint index, GLenum pname, GLfloat *params) {}
void glGetProgramParameterdvNV(GLenum target, GLuint index, GLenum pname, GLdouble *params) {}
void glGetProgramivNV(GLuint id, GLenum pname, GLint *params) {}
void glGetProgramStringNV(GLuint id, GLenum pname, GLubyte *program) {}
void glGetTrackMatrixivNV(GLenum target, GLuint address, GLenum pname, GLint *params) {}
void glGetVertexAttribdvNV(GLuint index, GLenum pname, GLdouble *params) {}
void glGetVertexAttribfvNV(GLuint index, GLenum pname, GLfloat *params) {}
void glGetVertexAttribivNV(GLuint index, GLenum pname, GLint *params) {}
void glGetVertexAttribPointervNV(GLuint index, GLenum pname, GLvoid **pointer) {}
GLboolean glIsProgramNV(GLuint id) { return 0;}
void glLoadProgramNV(GLenum target, GLuint id, GLsizei len, const GLubyte *program) {}
void glProgramParameter4fNV(GLenum target, GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}
void glProgramParameter4dNV(GLenum target, GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}
void glProgramParameter4dvNV(GLenum target, GLuint index, const GLdouble *params) {}
void glProgramParameter4fvNV(GLenum target, GLuint index, const GLfloat *params) {}
void glProgramParameters4dvNV(GLenum target, GLuint index, GLuint num, const GLdouble *params) {}
void glProgramParameters4fvNV(GLenum target, GLuint index, GLuint num, const GLfloat *params) {}
void glTrackMatrixNV(GLenum target, GLuint address, GLenum matrix, GLenum transform) {}
void glVertexAttribPointerNV(GLuint index, GLint size, GLenum type, GLsizei stride, const GLvoid *pointer) {}
void glVertexAttrib1sNV(GLuint index, GLshort x) {}
void glVertexAttrib1fNV(GLuint index, GLfloat x) {}
void glVertexAttrib1dNV(GLuint index, GLdouble x) {}
void glVertexAttrib2sNV(GLuint index, GLshort x, GLshort y) {}
void glVertexAttrib2fNV(GLuint index, GLfloat x, GLfloat y) {}
void glVertexAttrib2dNV(GLuint index, GLdouble x, GLdouble y) {}
void glVertexAttrib3sNV(GLuint index, GLshort x, GLshort y, GLshort z) {}
void glVertexAttrib3fNV(GLuint index, GLfloat x, GLfloat y, GLfloat z) {}
void glVertexAttrib3dNV(GLuint index, GLdouble x, GLdouble y, GLdouble z) {}
void glVertexAttrib4sNV(GLuint index, GLshort x, GLshort y, GLshort z, GLshort w) {}
void glVertexAttrib4fNV(GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}
void glVertexAttrib4dNV(GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}
void glVertexAttrib4ubNV(GLuint index, GLubyte x, GLubyte y, GLubyte z, GLubyte w) {}
void glVertexAttrib1svNV(GLuint index, const GLshort *v) {}
void glVertexAttrib1fvNV(GLuint index, const GLfloat *v) {}
void glVertexAttrib1dvNV(GLuint index, const GLdouble *v) {}
void glVertexAttrib2svNV(GLuint index, const GLshort *v) {}
void glVertexAttrib2fvNV(GLuint index, const GLfloat *v) {}
void glVertexAttrib2dvNV(GLuint index, const GLdouble *v) {}
void glVertexAttrib3svNV(GLuint index, const GLshort *v) {}
void glVertexAttrib3fvNV(GLuint index, const GLfloat *v) {}
void glVertexAttrib3dvNV(GLuint index, const GLdouble *v) {}
void glVertexAttrib4svNV(GLuint index, const GLshort *v) {}
void glVertexAttrib4fvNV(GLuint index, const GLfloat *v) {}
void glVertexAttrib4dvNV(GLuint index, const GLdouble *v) {}
void glVertexAttrib4ubvNV(GLuint index, const GLubyte *v) {}
void glVertexAttribs1svNV(GLuint index, GLsizei n, const GLshort *v) {}
void glVertexAttribs1fvNV(GLuint index, GLsizei n, const GLfloat *v) {}
void glVertexAttribs1dvNV(GLuint index, GLsizei n, const GLdouble *v) {}
void glVertexAttribs2svNV(GLuint index, GLsizei n, const GLshort *v) {}
void glVertexAttribs2fvNV(GLuint index, GLsizei n, const GLfloat *v) {}
void glVertexAttribs2dvNV(GLuint index, GLsizei n, const GLdouble *v) {}
void glVertexAttribs3svNV(GLuint index, GLsizei n, const GLshort *v) {}
void glVertexAttribs3fvNV(GLuint index, GLsizei n, const GLfloat *v) {}
void glVertexAttribs3dvNV(GLuint index, GLsizei n, const GLdouble *v) {}
void glVertexAttribs4svNV(GLuint index, GLsizei n, const GLshort *v) {}
void glVertexAttribs4fvNV(GLuint index, GLsizei n, const GLfloat *v) {}
void glVertexAttribs4dvNV(GLuint index, GLsizei n, const GLdouble *v) {}
void glVertexAttribs4ubvNV(GLuint index, GLsizei n, const GLubyte *v) {}
void glGenFencesNV(GLsizei n, GLuint *fences) {}
void glDeleteFencesNV(GLsizei n, const GLuint *fences) {}
void glSetFenceNV(GLuint fence, GLenum condition) {}
GLboolean glTestFenceNV(GLuint fence) { return 0;}
void glFinishFenceNV(GLuint fence) {}
GLboolean glIsFenceNV(GLuint fence) { return 0;}
void glGetFenceivNV(GLuint fence, GLenum pname, GLint *params) {}
void glCombinerStageParameterfvNV(GLenum stage, GLenum pname, const GLfloat *params) {}
void glGetCombinerStageParameterfvNV(GLenum stage, GLenum pname, GLfloat *params) {}
void glMapControlPointsNV(GLenum target, GLuint index, GLenum type, GLsizei ustride, GLsizei vstride, GLint uorder, GLint vorder, GLboolean packed, const GLvoid *points) {}
void glMapParameterivNV(GLenum target, GLenum pname, const GLint *params) {}
void glMapParameterfvNV(GLenum target, GLenum pname, const GLfloat *params) {}
void glGetMapControlPointsNV(GLenum target, GLuint index, GLenum type, GLsizei ustride, GLsizei vstride, GLboolean packed, GLvoid *points) {}
void glGetMapParameterivNV(GLenum target, GLenum pname, GLint *params) {}
void glGetMapParameterfvNV(GLenum target, GLenum pname, GLfloat *params) {}
void glGetMapAttribParameterivNV(GLenum target, GLuint index, GLenum pname, GLint *params) {}
void glGetMapAttribParameterfvNV(GLenum target, GLuint index, GLenum pname, GLfloat *params) {}
void glEvalMapsNV(GLenum target, GLenum mode) {}
void glPNTrianglesiATI(GLenum pname, GLint param) {}
void glPNTrianglesfATI(GLenum pname, GLfloat param) {}
void glPointParameterfARB(GLenum pname, GLfloat param) {}
void glPointParameterfvARB(GLenum pname, GLfloat *params) {}
void glWeightbvARB(GLint size, GLbyte *weights) {}
void glWeightsvARB(GLint size, GLshort *weights) {}
void glWeightivARB(GLint size, GLint *weights) {}
void glWeightfvARB(GLint size, GLfloat *weights) {}
void glWeightdvARB(GLint size, GLdouble *weights) {}
void glWeightubvARB(GLint size, GLubyte *weights) {}
void glWeightusvARB(GLint size, GLushort *weights) {}
void glWeightuivARB(GLint size, GLuint *weights) {}
void glWeightPointerARB(GLint size, GLenum type, GLsizei stride, GLvoid *pointer) {}
void glVertexBlendARB(GLint count) {}
void glMultiDrawArraysEXT(GLenum mode, GLint *first, GLsizei *count, GLsizei primcount) {}
void glMultiDrawElementsEXT(GLenum mode, GLsizei *count, GLenum type, const GLvoid **indices, GLsizei primcount) {}
void glCurrentPaletteMatrixARB(GLint index) {}
void glMatrixIndexubvARB(GLint size, GLubyte *indices) {}
void glMatrixIndexusvARB(GLint size, GLushort *indices) {}
void glMatrixIndexuivARB(GLint size, GLuint *indices) {}
void glMatrixIndexPointerARB(GLint size, GLenum type, GLsizei stride, GLvoid *pointer) {}
void glBeginVertexShaderEXT() {}
void glEndVertexShaderEXT() {}
void glBindVertexShaderEXT(GLuint id) {}
GLuint glGenVertexShadersEXT(GLuint range) { return 0;}
void glDeleteVertexShaderEXT(GLuint id) {}
void glShaderOp1EXT(GLenum op, GLuint res, GLuint arg1) {}
void glShaderOp2EXT(GLenum op, GLuint res, GLuint arg1, GLuint arg2) {}
void glShaderOp3EXT(GLenum op, GLuint res, GLuint arg1, GLuint arg2, GLuint arg3) {}
void glSwizzleEXT(GLuint res, GLuint in, GLenum outX, GLenum outY, GLenum outZ, GLenum outW) {}
void glWriteMaskEXT(GLuint res, GLuint in, GLenum outX, GLenum outY, GLenum outZ, GLenum outW) {}
void glInsertComponentEXT(GLuint res, GLuint src, GLuint num) {}
void glExtractComponentEXT(GLuint res, GLuint src, GLuint num) {}
GLuint glGenSymbolsEXT(GLenum dataType, GLenum storageType, GLenum range, GLuint components) { return 0;}
void glSetInvariantEXT(GLuint id, GLenum type, GLvoid *addr) {}
void glSetLocalConstantEXT(GLuint id, GLenum type, GLvoid *addr) {}
void glVariantbvEXT(GLuint id, GLbyte *addr) {}
void glVariantsvEXT(GLuint id, GLshort *addr) {}
void glVariantivEXT(GLuint id, GLint *addr) {}
void glVariantfvEXT(GLuint id, GLfloat *addr) {}
void glVariantdvEXT(GLuint id, GLdouble *addr) {}
void glVariantubvEXT(GLuint id, GLubyte *addr) {}
void glVariantusvEXT(GLuint id, GLushort *addr) {}
void glVariantuivEXT(GLuint id, GLuint *addr) {}
void glVariantPointerEXT(GLuint id, GLenum type, GLuint stride, GLvoid *addr) {}
void glEnableVariantClientStateEXT(GLuint id) {}
void glDisableVariantClientStateEXT(GLuint id) {}
GLuint glBindLightParameterEXT(GLenum light, GLenum value) { return 0;}
GLuint glBindMaterialParameterEXT(GLenum face, GLenum value) { return 0;}
GLuint glBindTexGenParameterEXT(GLenum unit, GLenum coord, GLenum value) { return 0;}
GLuint glBindTextureUnitParameterEXT(GLenum unit, GLenum value) { return 0;}
GLuint glBindParameterEXT(GLenum value) { return 0;}
GLboolean glIsVariantEnabledEXT(GLuint id, GLenum cap) { return 0;}
void glGetVariantBooleanvEXT(GLuint id, GLenum value, GLboolean *data) {}
void glGetVariantIntegervEXT(GLuint id, GLenum value, GLint *data) {}
void glGetVariantFloatvEXT(GLuint id, GLenum value, GLfloat *data) {}
void glGetVariantPointervEXT(GLuint id, GLenum value, GLvoid **data) {}
void glGetInvariantBooleanvEXT(GLuint id, GLenum value, GLboolean *data) {}
void glGetInvariantIntegervEXT(GLuint id, GLenum value, GLint *data) {}
void glGetInvariantFloatvEXT(GLuint id, GLenum value, GLfloat *data) {}
void glGetLocalConstantBooleanvEXT(GLuint id, GLenum value, GLboolean *data) {}
void glGetLocalConstantIntegervEXT(GLuint id, GLenum value, GLint *data) {}
void glGetLocalConstantFloatvEXT(GLuint id, GLenum value, GLfloat *data) {}
void glTexBumpParameterivATI(GLenum pname, GLint *param) {}
void glTexBumpParameterfvATI(GLenum pname, GLfloat *param) {}
void glGetTexBumpParameterivATI(GLenum pname, GLint *param) {}
void glGetTexBumpParameterfvATI(GLenum pname, GLfloat *param) {}
GLuint glGenFragmentShadersATI(GLuint range) { return 0;}
void glBindFragmentShaderATI(GLuint id) {}
void glDeleteFragmentShaderATI(GLuint id) {}
void glBeginFragmentShaderATI(GLvoid) {}
void glEndFragmentShaderATI(GLvoid) {}
void glPassTexCoordATI(GLuint dst, GLuint coord, GLenum swizzle) {}
void glSampleMapATI(GLuint dst, GLuint interp, GLenum swizzle) {}
void glColorFragmentOp1ATI(GLenum op, GLuint dst, GLuint dstMask, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod) {}
void glColorFragmentOp2ATI(GLenum op, GLuint dst, GLuint dstMask, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod) {}
void glColorFragmentOp3ATI(GLenum op, GLuint dst, GLuint dstMask, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod, GLuint arg3, GLuint arg3Rep, GLuint arg3Mod) {}
void glAlphaFragmentOp1ATI(GLenum op, GLuint dst, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod) {}
void glAlphaFragmentOp2ATI(GLenum op, GLuint dst, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod) {}
void glAlphaFragmentOp3ATI(GLenum op, GLuint dst, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod, GLuint arg3, GLuint arg3Rep, GLuint arg3Mod) {}
void glSetFragmentShaderConstantATI(GLuint dst, const GLfloat *value) {}
void glElementPointerATI(GLenum type, const GLvoid *pointer) {}
void glDrawElementArrayATI(GLenum mode, GLsizei count) {}
void glDrawRangeElementArrayATI(GLenum mode, GLuint start, GLuint end, GLsizei count) {}
void glClientActiveVertexStreamATI(GLenum stream) {}
void glVertexBlendEnviATI(GLenum pname, GLint param) {}
void glVertexBlendEnvfATI(GLenum pname, GLfloat param) {}
void glVertexStream2sATI(GLenum stream, GLshort x, GLshort y) {}
void glVertexStream2svATI(GLenum stream, const GLshort *v) {}
void glVertexStream2iATI(GLenum stream, GLint x, GLint y) {}
void glVertexStream2ivATI(GLenum stream, const GLint *v) {}
void glVertexStream2fATI(GLenum stream, GLfloat x, GLfloat y) {}
void glVertexStream2fvATI(GLenum stream, const GLfloat *v) {}
void glVertexStream2dATI(GLenum stream, GLdouble x, GLdouble y) {}
void glVertexStream2dvATI(GLenum stream, const GLdouble *v) {}
void glVertexStream3sATI(GLenum stream, GLshort x, GLshort y, GLshort z) {}
void glVertexStream3svATI(GLenum stream, const GLshort *v) {}
void glVertexStream3iATI(GLenum stream, GLint x, GLint y, GLint z) {}
void glVertexStream3ivATI(GLenum stream, const GLint *v) {}
void glVertexStream3fATI(GLenum stream, GLfloat x, GLfloat y, GLfloat z) {}
void glVertexStream3fvATI(GLenum stream, const GLfloat *v) {}
void glVertexStream3dATI(GLenum stream, GLdouble x, GLdouble y, GLdouble z) {}
void glVertexStream3dvATI(GLenum stream, const GLdouble *v) {}
void glVertexStream4sATI(GLenum stream, GLshort x, GLshort y, GLshort z, GLshort w) {}
void glVertexStream4svATI(GLenum stream, const GLshort *v) {}
void glVertexStream4iATI(GLenum stream, GLint x, GLint y, GLint z, GLint w) {}
void glVertexStream4ivATI(GLenum stream, const GLint *v) {}
void glVertexStream4fATI(GLenum stream, GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}
void glVertexStream4fvATI(GLenum stream, const GLfloat *v) {}
void glVertexStream4dATI(GLenum stream, GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}
void glVertexStream4dvATI(GLenum stream, const GLdouble *v) {}
void glNormalStream3bATI(GLenum stream, GLbyte x, GLbyte y, GLbyte z) {}
void glNormalStream3bvATI(GLenum stream, const GLbyte *v) {}
void glNormalStream3sATI(GLenum stream, GLshort x, GLshort y, GLshort z) {}
void glNormalStream3svATI(GLenum stream, const GLshort *v) {}
void glNormalStream3iATI(GLenum stream, GLint x, GLint y, GLint z) {}
void glNormalStream3ivATI(GLenum stream, const GLint *v) {}
void glNormalStream3fATI(GLenum stream, GLfloat x, GLfloat y, GLfloat z) {}
void glNormalStream3fvATI(GLenum stream, const GLfloat *v) {}
void glNormalStream3dATI(GLenum stream, GLdouble x, GLdouble y, GLdouble z) {}
void glNormalStream3dvATI(GLenum stream, const GLdouble *v) {}
GLuint glNewObjectBufferATI(GLsizei size, const GLvoid *pointer, GLenum usage) { return 0;}
GLboolean glIsObjectBufferATI(GLuint buffer) { return 0;}
void glUpdateObjectBufferATI(GLuint buffer, GLuint offset, GLsizei size, const GLvoid *pointer, GLenum preserve) {}
void glGetObjectBufferfvATI(GLuint buffer, GLenum pname, GLfloat *params) {}
void glGetObjectBufferivATI(GLuint buffer, GLenum pname, GLint *params) {}
void glFreeObjectBufferATI(GLuint buffer) {}
void glArrayObjectATI(GLenum array, GLint size, GLenum type, GLsizei stride, GLuint buffer, GLuint offset) {}
void glGetArrayObjectfvATI(GLenum array, GLenum pname, GLfloat *params) {}
void glGetArrayObjectivATI(GLenum array, GLenum pname, GLint *params) {}
void glVariantArrayObjectATI(GLuint id, GLenum type, GLsizei stride, GLuint buffer, GLuint offset) {}
void glGetVariantArrayObjectfvATI(GLuint id, GLenum pname, GLfloat *params) {}
void glGetVariantArrayObjectivATI(GLuint id, GLenum pname, GLint *params) {}
void glGenOcclusionQueriesNV(GLsizei n, GLuint *ids) {}
void glDeleteOcclusionQueriesNV(GLsizei n, const GLuint *ids) {}
GLboolean glIsOcclusionQueryNV(GLuint id) { return 0;}
void glBeginOcclusionQueryNV(GLuint id) {}
void glEndOcclusionQueryNV(void) {}
void glGetOcclusionQueryivNV(GLuint id, GLenum pname, GLint *params) {}
void glGetOcclusionQueryuivNV(GLuint id, GLenum pname, GLuint *params) {}
void glPointParameteriNV(GLenum pname, GLint param) {}
void glPointParameterivNV(GLenum pname, const GLint *params) {}
void glWindowPos2dARB(GLdouble x, GLdouble y) {}
void glWindowPos2fARB(GLfloat x, GLfloat y) {}
void glWindowPos2iARB(GLint x, GLint y) {}
void glWindowPos2sARB(GLshort x, GLshort y) {}
void glWindowPos2dvARB(const GLdouble *p) {}
void glWindowPos2fvARB(const GLfloat *p) {}
void glWindowPos2ivARB(const GLint *p) {}
void glWindowPos2svARB(const GLshort *p) {}
void glWindowPos3dARB(GLdouble x, GLdouble y, GLdouble z) {}
void glWindowPos3fARB(GLfloat x, GLfloat y, GLfloat z) {}
void glWindowPos3iARB(GLint x, GLint y, GLint z) {}
void glWindowPos3sARB(GLshort x, GLshort y, GLshort z) {}
void glWindowPos3dvARB(const GLdouble *p) {}
void glWindowPos3fvARB(const GLfloat *p) {}
void glWindowPos3ivARB(const GLint *p) {}
void glWindowPos3svARB(const GLshort *p) {}
const wglGetExtensionsStringEXT() { return 0;}
HANDLE wglCreateBufferRegionARB(HDC hDC, int iLayerPlane, UINT uType) { return 0;}
VOID wglDeleteBufferRegionARB(HANDLE hRegion) { return 0;}
BOOL wglSaveBufferRegionARB(HANDLE hRegion, int x, int y, int width, int height) { return 0;}
BOOL wglRestoreBufferRegionARB(HANDLE hRegion, int x, int y, int width, int height, int xSrc, int ySrc) { return 0;}
const wglGetExtensionsStringARB(HDC hdc) { return 0;}
HPBUFFERARB wglCreatePbufferARB(HDC hDC, int iPixelFormat, int iWidth, int iHeight, const int *piAttribList) { return 0;}
HDC wglGetPbufferDCARB(HPBUFFERARB hPbuffer) { return 0;}
int wglReleasePbufferDCARB(HPBUFFERARB hPbuffer, HDC hDC) { return 0;}
BOOL wglDestroyPbufferARB(HPBUFFERARB hPbuffer) { return 0;}
BOOL wglQueryPbufferARB(HPBUFFERARB hPbuffer, int iAttribute, int *piValue) { return 0;}
BOOL wglGetPixelFormatAttribivARB(HDC hdc, int iPixelFormat, int iLayerPlane, UINT nAttributes, const int *piAttributes, int *piValues) { return 0;}
BOOL wglGetPixelFormatAttribfvARB(HDC hdc, int iPixelFormat, int iLayerPlane, UINT nAttributes, const int *piAttributes, FLOAT *pfValues) { return 0;}
BOOL wglChoosePixelFormatARB(HDC hdc, const int *piAttribIList, const FLOAT *pfAttribFList, UINT nMaxFormats, int *piFormats, UINT *nNumFormats) { return 0;}
BOOL wglBindTexImageARB(HPBUFFERARB hPbuffer, int iBuffer) { return 0;}
BOOL wglReleaseTexImageARB(HPBUFFERARB hPbuffer, int iBuffer) { return 0;}
BOOL wglSetPbufferAttribARB(HPBUFFERARB hPbuffer, const int *piAttribList) { return 0;}
BOOL wglSwapIntervalEXT(int interval) { return 0;}
int wglGetSwapIntervalEXT(void) { return 0;}
BOOL wglMakeContextCurrentARB(HDC hDrawDC, HDC hReadDC, HGLRC hglrc) { return 0;}
HDC wglGetCurrentReadDCARB(void) { return 0;}
// <-- extensions with postfix

// extensions without postfix -->

void glDrawRangeElements(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const GLvoid *indices ) {}
void glTexImage3D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const GLvoid *pixels ) {}
void glTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const GLvoid *pixels) {}
void glCopyTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height ) {}
void glColorTable(GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum type, const GLvoid *table ) {}
void glColorSubTable(GLenum target, GLsizei start, GLsizei count, GLenum format, GLenum type, const GLvoid *data ) {}
void glColorTableParameteriv(GLenum target, GLenum pname, const GLint *params) {}
void glColorTableParameterfv(GLenum target, GLenum pname, const GLfloat *params) {}
void glCopyColorSubTable(GLenum target, GLsizei start, GLint x, GLint y, GLsizei width ) {}
void glCopyColorTable(GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width ) {}
void glGetColorTable(GLenum target, GLenum format, GLenum type, GLvoid *table ) {}
void glGetColorTableParameterfv(GLenum target, GLenum pname, GLfloat *params ) {}
void glGetColorTableParameteriv(GLenum target, GLenum pname, GLint *params ) {}
void glBlendEquation(GLenum mode ) {}
void glBlendColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha ) {}
void glHistogram(GLenum target, GLsizei width, GLenum internalformat, GLboolean sink ) {}
void glResetHistogram(GLenum target ) {}
void glGetHistogram(GLenum target, GLboolean reset, GLenum format, GLenum type, GLvoid *values ) {}
void glGetHistogramParameterfv(GLenum target, GLenum pname, GLfloat *params ) {}
void glGetHistogramParameteriv(GLenum target, GLenum pname, GLint *params ) {}
void glMinmax(GLenum target, GLenum internalformat, GLboolean sink ) {}
void glResetMinmax(GLenum target ) {}
void glGetMinmax(GLenum target, GLboolean reset, GLenum format, GLenum types, GLvoid *values ) {}
void glGetMinmaxParameterfv(GLenum target, GLenum pname, GLfloat *params ) {}
void glGetMinmaxParameteriv(GLenum target, GLenum pname, GLint *params ) {}
void glConvolutionFilter1D(GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum type, const GLvoid *image ) {}
void glConvolutionFilter2D(GLenum target, GLenum internalformat, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *image ) {}
void glConvolutionParameterf(GLenum target, GLenum pname, GLfloat params ) {}
void glConvolutionParameterfv(GLenum target, GLenum pname, const GLfloat *params ) {}
void glConvolutionParameteri(GLenum target, GLenum pname, GLint params ) {}
void glConvolutionParameteriv(GLenum target, GLenum pname, const GLint *params ) {}
void glCopyConvolutionFilter1D(GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width ) {}
void glCopyConvolutionFilter2D(GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height) {}
void glGetConvolutionFilter(GLenum target, GLenum format, GLenum type, GLvoid *image ) {}
void glGetConvolutionParameterfv(GLenum target, GLenum pname, GLfloat *params ) {}
void glGetConvolutionParameteriv(GLenum target, GLenum pname, GLint *params ) {}
void glSeparableFilter2D(GLenum target, GLenum internalformat, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *row, const GLvoid *column ) {}
void glGetSeparableFilter(GLenum target, GLenum format, GLenum type, GLvoid *row, GLvoid *column, GLvoid *span ) {}
void glActiveTexture(GLenum texture ) {}
void glClientActiveTexture(GLenum texture ) {}
void glCompressedTexImage1D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, const GLvoid *data ) {}
void glCompressedTexImage2D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const GLvoid *data ) {}
void glCompressedTexImage3D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, const GLvoid *data ) {}
void glCompressedTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const GLvoid *data ) {}
void glCompressedTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const GLvoid *data ) {}
void glCompressedTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const GLvoid *data ) {}
void glGetCompressedTexImage(GLenum target, GLint lod, GLvoid *img ) {}
void glMultiTexCoord1d(GLenum target, GLdouble s ) {}
void glMultiTexCoord1dv(GLenum target, const GLdouble *v ) {}
void glMultiTexCoord1f(GLenum target, GLfloat s ) {}
void glMultiTexCoord1fv(GLenum target, const GLfloat *v ) {}
void glMultiTexCoord1i(GLenum target, GLint s ) {}
void glMultiTexCoord1iv(GLenum target, const GLint *v ) {}
void glMultiTexCoord1s(GLenum target, GLshort s ) {}
void glMultiTexCoord1sv(GLenum target, const GLshort *v ) {}
void glMultiTexCoord2d(GLenum target, GLdouble s, GLdouble t ) {}
void glMultiTexCoord2dv(GLenum target, const GLdouble *v ) {}
void glMultiTexCoord2f(GLenum target, GLfloat s, GLfloat t ) {}
void glMultiTexCoord2fv(GLenum target, const GLfloat *v ) {}
void glMultiTexCoord2i(GLenum target, GLint s, GLint t ) {}
void glMultiTexCoord2iv(GLenum target, const GLint *v ) {}
void glMultiTexCoord2s(GLenum target, GLshort s, GLshort t ) {}
void glMultiTexCoord2sv(GLenum target, const GLshort *v ) {}
void glMultiTexCoord3d(GLenum target, GLdouble s, GLdouble t, GLdouble r ) {}
void glMultiTexCoord3dv(GLenum target, const GLdouble *v ) {}
void glMultiTexCoord3f(GLenum target, GLfloat s, GLfloat t, GLfloat r ) {}
void glMultiTexCoord3fv(GLenum target, const GLfloat *v ) {}
void glMultiTexCoord3i(GLenum target, GLint s, GLint t, GLint r ) {}
void glMultiTexCoord3iv(GLenum target, const GLint *v ) {}
void glMultiTexCoord3s(GLenum target, GLshort s, GLshort t, GLshort r ) {}
void glMultiTexCoord3sv(GLenum target, const GLshort *v ) {}
void glMultiTexCoord4d(GLenum target, GLdouble s, GLdouble t, GLdouble r, GLdouble q ) {}
void glMultiTexCoord4dv(GLenum target, const GLdouble *v ) {}
void glMultiTexCoord4f(GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q ) {}
void glMultiTexCoord4fv(GLenum target, const GLfloat *v ) {}
void glMultiTexCoord4i(GLenum target, GLint s, GLint t, GLint r, GLint q ) {}
void glMultiTexCoord4iv(GLenum target, const GLint *v ) {}
void glMultiTexCoord4s(GLenum target, GLshort s, GLshort t, GLshort r, GLshort q ) {}
void glMultiTexCoord4sv(GLenum target, const GLshort *v ) {}
void glLoadTransposeMatrixd(const GLdouble m[16] ) {}
void glLoadTransposeMatrixf(const GLfloat m[16] ) {}
void glMultTransposeMatrixd(const GLdouble m[16] ) {}
void glMultTransposeMatrixf(const GLfloat m[16] ) {}
void glSampleCoverage(GLclampf value, GLboolean invert ) {}
void glLockArrays(GLint first, GLsizei count) {}
void glUnlockArrays() {}
void glSecondaryColor3b(GLbyte red, GLbyte green, GLbyte blue) {}
void glSecondaryColor3bv(const GLbyte *v) {}
void glSecondaryColor3d(GLdouble red, GLdouble green, GLdouble blue) {}
void glSecondaryColor3dv(const GLdouble *v) {}
void glSecondaryColor3f(GLfloat red, GLfloat green, GLfloat blue) {}
void glSecondaryColor3fv(const GLfloat *v) {}
void glSecondaryColor3i(GLint red, GLint green, GLint blue) {}
void glSecondaryColor3iv(const GLint *v) {}
void glSecondaryColor3s(GLshort red, GLshort green, GLshort blue) {}
void glSecondaryColor3sv(const GLshort *v) {}
void glSecondaryColor3ub(GLubyte red, GLubyte green, GLubyte blue) {}
void glSecondaryColor3ubv(const GLubyte *v) {}
void glSecondaryColor3ui(GLuint red, GLuint green, GLuint blue) {}
void glSecondaryColor3uiv(const GLuint *v) {}
void glSecondaryColor3us(GLushort red, GLushort green, GLushort blue) {}
void glSecondaryColor3usv(const GLushort *v) {}
void glSecondaryColorPointer(GLint size, GLenum type, GLsizei stride, GLvoid *pointer) {}
void glFogCoordf(GLfloat coord) {}
void glFogCoordfv(const GLfloat *coord) {}
void glFogCoordd(GLdouble coord) {}
void glFogCoorddv(const GLdouble *coord) {}
void glFogCoordPointer(GLenum type, GLsizei stride, const GLvoid *pointer) {}
void glFlushVertexArrayRange(void) {}
void glVertexArrayRange(GLsizei size, const GLvoid *pointer) {}
void wglAllocateMemory(GLsizei size, GLfloat readFrequency, GLfloat writeFrequency, GLfloat priority) {}
void wglFreeMemory(void *pointer) {}
void glPointParameterf(GLenum pname, GLfloat param) {}
void glPointParameterfv(GLenum pname, const GLfloat *params) {}
void glCombinerParameterfv(GLenum pname, const GLfloat *params) {}
void glCombinerParameterf(GLenum pname, GLfloat param) {}
void glCombinerParameteriv(GLenum pname, const GLint *params) {}
void glCombinerParameteri(GLenum pname, GLint param) {}
void glCombinerInput(GLenum stage, GLenum portion, GLenum variable, GLenum input, GLenum mapping, GLenum componentUsage) {}
void glCombinerOutput(GLenum stage, GLenum portion, GLenum abOutput, GLenum cdOutput, GLenum sumOutput, GLenum scale, GLenum bias, GLboolean abDotProduct, GLboolean cdDotProduct, GLboolean muxSum) {}
void glFinalCombinerInput(GLenum variable, GLenum input, GLenum mapping, GLenum componentUsage) {}
void glGetCombinerInputParameterfv(GLenum stage, GLenum portion, GLenum variable, GLenum pname, GLfloat *params) {}
void glGetCombinerInputParameteriv(GLenum stage, GLenum portion, GLenum variable, GLenum pname, GLint *params) {}
void glGetCombinerOutputParameterfv(GLenum stage, GLenum portion, GLenum pname, GLfloat *params) {}
void glGetCombinerOutputParameteriv(GLenum stage, GLenum portion, GLenum pname, GLint *params) {}
void glGetFinalCombinerInputParameterfv(GLenum variable, GLenum pname, GLfloat *params) {}
void glGetFinalCombinerInputParameteriv(GLenum variable, GLenum pname, GLint *params) {}
void glVertexWeightf(GLfloat weight) {}
void glVertexWeightfv(const GLfloat *weight) {}
void glVertexWeightPointer(GLsizei size, GLenum type, GLsizei stride, const GLvoid *pointer) {}
void glBindProgram(GLenum target, GLuint id) {}
void glDeletePrograms(GLsizei n, const GLuint *ids) {}
void glExecuteProgram(GLenum target, GLuint id, const GLfloat *params) {}
void glGenPrograms(GLsizei n, GLuint *ids) {}
GLboolean glAreProgramsResident(GLsizei n, const GLuint *ids, GLboolean *residences) { return 0;}
void glRequestResidentPrograms(GLsizei n, GLuint *ids) {}
void glGetProgramParameterfv(GLenum target, GLuint index, GLenum pname, GLfloat *params) {}
void glGetProgramParameterdv(GLenum target, GLuint index, GLenum pname, GLdouble *params) {}
void glGetProgramiv(GLuint id, GLenum pname, GLint *params) {}
void glGetProgramString(GLuint id, GLenum pname, GLubyte *program) {}
void glGetTrackMatrixiv(GLenum target, GLuint address, GLenum pname, GLint *params) {}
void glGetVertexAttribdv(GLuint index, GLenum pname, GLdouble *params) {}
void glGetVertexAttribfv(GLuint index, GLenum pname, GLfloat *params) {}
void glGetVertexAttribiv(GLuint index, GLenum pname, GLint *params) {}
void glGetVertexAttribPointerv(GLuint index, GLenum pname, GLvoid **pointer) {}
GLboolean glIsProgram(GLuint id) { return 0;}
void glLoadProgram(GLenum target, GLuint id, GLsizei len, const GLubyte *program) {}
void glProgramParameter4f(GLenum target, GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}
void glProgramParameter4d(GLenum target, GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}
void glProgramParameter4dv(GLenum target, GLuint index, const GLdouble *params) {}
void glProgramParameter4fv(GLenum target, GLuint index, const GLfloat *params) {}
void glProgramParameters4dv(GLenum target, GLuint index, GLuint num, const GLdouble *params) {}
void glProgramParameters4fv(GLenum target, GLuint index, GLuint num, const GLfloat *params) {}
void glTrackMatrix(GLenum target, GLuint address, GLenum matrix, GLenum transform) {}
void glVertexAttribPointer(GLuint index, GLint size, GLenum type, GLsizei stride, const GLvoid *pointer) {}
void glVertexAttrib1s(GLuint index, GLshort x) {}
void glVertexAttrib1f(GLuint index, GLfloat x) {}
void glVertexAttrib1d(GLuint index, GLdouble x) {}
void glVertexAttrib2s(GLuint index, GLshort x, GLshort y) {}
void glVertexAttrib2f(GLuint index, GLfloat x, GLfloat y) {}
void glVertexAttrib2d(GLuint index, GLdouble x, GLdouble y) {}
void glVertexAttrib3s(GLuint index, GLshort x, GLshort y, GLshort z) {}
void glVertexAttrib3f(GLuint index, GLfloat x, GLfloat y, GLfloat z) {}
void glVertexAttrib3d(GLuint index, GLdouble x, GLdouble y, GLdouble z) {}
void glVertexAttrib4s(GLuint index, GLshort x, GLshort y, GLshort z, GLshort w) {}
void glVertexAttrib4f(GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}
void glVertexAttrib4d(GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}
void glVertexAttrib4ub(GLuint index, GLubyte x, GLubyte y, GLubyte z, GLubyte w) {}
void glVertexAttrib1sv(GLuint index, const GLshort *v) {}
void glVertexAttrib1fv(GLuint index, const GLfloat *v) {}
void glVertexAttrib1dv(GLuint index, const GLdouble *v) {}
void glVertexAttrib2sv(GLuint index, const GLshort *v) {}
void glVertexAttrib2fv(GLuint index, const GLfloat *v) {}
void glVertexAttrib2dv(GLuint index, const GLdouble *v) {}
void glVertexAttrib3sv(GLuint index, const GLshort *v) {}
void glVertexAttrib3fv(GLuint index, const GLfloat *v) {}
void glVertexAttrib3dv(GLuint index, const GLdouble *v) {}
void glVertexAttrib4sv(GLuint index, const GLshort *v) {}
void glVertexAttrib4fv(GLuint index, const GLfloat *v) {}
void glVertexAttrib4dv(GLuint index, const GLdouble *v) {}
void glVertexAttrib4ubv(GLuint index, const GLubyte *v) {}
void glVertexAttribs1sv(GLuint index, GLsizei n, const GLshort *v) {}
void glVertexAttribs1fv(GLuint index, GLsizei n, const GLfloat *v) {}
void glVertexAttribs1dv(GLuint index, GLsizei n, const GLdouble *v) {}
void glVertexAttribs2sv(GLuint index, GLsizei n, const GLshort *v) {}
void glVertexAttribs2fv(GLuint index, GLsizei n, const GLfloat *v) {}
void glVertexAttribs2dv(GLuint index, GLsizei n, const GLdouble *v) {}
void glVertexAttribs3sv(GLuint index, GLsizei n, const GLshort *v) {}
void glVertexAttribs3fv(GLuint index, GLsizei n, const GLfloat *v) {}
void glVertexAttribs3dv(GLuint index, GLsizei n, const GLdouble *v) {}
void glVertexAttribs4sv(GLuint index, GLsizei n, const GLshort *v) {}
void glVertexAttribs4fv(GLuint index, GLsizei n, const GLfloat *v) {}
void glVertexAttribs4dv(GLuint index, GLsizei n, const GLdouble *v) {}
void glVertexAttribs4ubv(GLuint index, GLsizei n, const GLubyte *v) {}
void glGenFences(GLsizei n, GLuint *fences) {}
void glDeleteFences(GLsizei n, const GLuint *fences) {}
void glSetFence(GLuint fence, GLenum condition) {}
GLboolean glTestFence(GLuint fence) { return 0;}
void glFinishFence(GLuint fence) {}
GLboolean glIsFence(GLuint fence) { return 0;}
void glGetFenceiv(GLuint fence, GLenum pname, GLint *params) {}
void glCombinerStageParameterfv(GLenum stage, GLenum pname, const GLfloat *params) {}
void glGetCombinerStageParameterfv(GLenum stage, GLenum pname, GLfloat *params) {}
void glMapControlPoints(GLenum target, GLuint index, GLenum type, GLsizei ustride, GLsizei vstride, GLint uorder, GLint vorder, GLboolean packed, const GLvoid *points) {}
void glMapParameteriv(GLenum target, GLenum pname, const GLint *params) {}
void glMapParameterfv(GLenum target, GLenum pname, const GLfloat *params) {}
void glGetMapControlPoints(GLenum target, GLuint index, GLenum type, GLsizei ustride, GLsizei vstride, GLboolean packed, GLvoid *points) {}
void glGetMapParameteriv(GLenum target, GLenum pname, GLint *params) {}
void glGetMapParameterfv(GLenum target, GLenum pname, GLfloat *params) {}
void glGetMapAttribParameteriv(GLenum target, GLuint index, GLenum pname, GLint *params) {}
void glGetMapAttribParameterfv(GLenum target, GLuint index, GLenum pname, GLfloat *params) {}
void glEvalMaps(GLenum target, GLenum mode) {}
void glPNTrianglesi(GLenum pname, GLint param) {}
void glPNTrianglesf(GLenum pname, GLfloat param) {}
void glPointParameterf(GLenum pname, GLfloat param) {}
void glPointParameterfv(GLenum pname, GLfloat *params) {}
void glWeightbv(GLint size, GLbyte *weights) {}
void glWeightsv(GLint size, GLshort *weights) {}
void glWeightiv(GLint size, GLint *weights) {}
void glWeightfv(GLint size, GLfloat *weights) {}
void glWeightdv(GLint size, GLdouble *weights) {}
void glWeightubv(GLint size, GLubyte *weights) {}
void glWeightusv(GLint size, GLushort *weights) {}
void glWeightuiv(GLint size, GLuint *weights) {}
void glWeightPointer(GLint size, GLenum type, GLsizei stride, GLvoid *pointer) {}
void glVertexBlend(GLint count) {}
void glMultiDrawArrays(GLenum mode, GLint *first, GLsizei *count, GLsizei primcount) {}
void glMultiDrawElements(GLenum mode, GLsizei *count, GLenum type, const GLvoid **indices, GLsizei primcount) {}
void glCurrentPaletteMatrix(GLint index) {}
void glMatrixIndexubv(GLint size, GLubyte *indices) {}
void glMatrixIndexusv(GLint size, GLushort *indices) {}
void glMatrixIndexuiv(GLint size, GLuint *indices) {}
void glMatrixIndexPointer(GLint size, GLenum type, GLsizei stride, GLvoid *pointer) {}
void glBeginVertexShader() {}
void glEndVertexShader() {}
void glBindVertexShader(GLuint id) {}
GLuint glGenVertexShaders(GLuint range) { return 0;}
void glDeleteVertexShader(GLuint id) {}
void glShaderOp1(GLenum op, GLuint res, GLuint arg1) {}
void glShaderOp2(GLenum op, GLuint res, GLuint arg1, GLuint arg2) {}
void glShaderOp3(GLenum op, GLuint res, GLuint arg1, GLuint arg2, GLuint arg3) {}
void glSwizzle(GLuint res, GLuint in, GLenum outX, GLenum outY, GLenum outZ, GLenum outW) {}
void glWriteMask(GLuint res, GLuint in, GLenum outX, GLenum outY, GLenum outZ, GLenum outW) {}
void glInsertComponent(GLuint res, GLuint src, GLuint num) {}
void glExtractComponent(GLuint res, GLuint src, GLuint num) {}
GLuint glGenSymbols(GLenum dataType, GLenum storageType, GLenum range, GLuint components) { return 0;}
void glSetInvariant(GLuint id, GLenum type, GLvoid *addr) {}
void glSetLocalConstant(GLuint id, GLenum type, GLvoid *addr) {}
void glVariantbv(GLuint id, GLbyte *addr) {}
void glVariantsv(GLuint id, GLshort *addr) {}
void glVariantiv(GLuint id, GLint *addr) {}
void glVariantfv(GLuint id, GLfloat *addr) {}
void glVariantdv(GLuint id, GLdouble *addr) {}
void glVariantubv(GLuint id, GLubyte *addr) {}
void glVariantusv(GLuint id, GLushort *addr) {}
void glVariantuiv(GLuint id, GLuint *addr) {}
void glVariantPointer(GLuint id, GLenum type, GLuint stride, GLvoid *addr) {}
void glEnableVariantClientState(GLuint id) {}
void glDisableVariantClientState(GLuint id) {}
GLuint glBindLightParameter(GLenum light, GLenum value) { return 0;}
GLuint glBindMaterialParameter(GLenum face, GLenum value) { return 0;}
GLuint glBindTexGenParameter(GLenum unit, GLenum coord, GLenum value) { return 0;}
GLuint glBindTextureUnitParameter(GLenum unit, GLenum value) { return 0;}
GLuint glBindParameter(GLenum value) { return 0;}
GLboolean glIsVariantEnabled(GLuint id, GLenum cap) { return 0;}
void glGetVariantBooleanv(GLuint id, GLenum value, GLboolean *data) {}
void glGetVariantIntegerv(GLuint id, GLenum value, GLint *data) {}
void glGetVariantFloatv(GLuint id, GLenum value, GLfloat *data) {}
void glGetVariantPointerv(GLuint id, GLenum value, GLvoid **data) {}
void glGetInvariantBooleanv(GLuint id, GLenum value, GLboolean *data) {}
void glGetInvariantIntegerv(GLuint id, GLenum value, GLint *data) {}
void glGetInvariantFloatv(GLuint id, GLenum value, GLfloat *data) {}
void glGetLocalConstantBooleanv(GLuint id, GLenum value, GLboolean *data) {}
void glGetLocalConstantIntegerv(GLuint id, GLenum value, GLint *data) {}
void glGetLocalConstantFloatv(GLuint id, GLenum value, GLfloat *data) {}
void glTexBumpParameteriv(GLenum pname, GLint *param) {}
void glTexBumpParameterfv(GLenum pname, GLfloat *param) {}
void glGetTexBumpParameteriv(GLenum pname, GLint *param) {}
void glGetTexBumpParameterfv(GLenum pname, GLfloat *param) {}
GLuint glGenFragmentShaders(GLuint range) { return 0;}
void glBindFragmentShader(GLuint id) {}
void glDeleteFragmentShader(GLuint id) {}
void glBeginFragmentShader(GLvoid) {}
void glEndFragmentShader(GLvoid) {}
void glPassTexCoord(GLuint dst, GLuint coord, GLenum swizzle) {}
void glSampleMap(GLuint dst, GLuint interp, GLenum swizzle) {}
void glColorFragmentOp1(GLenum op, GLuint dst, GLuint dstMask, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod) {}
void glColorFragmentOp2(GLenum op, GLuint dst, GLuint dstMask, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod) {}
void glColorFragmentOp3(GLenum op, GLuint dst, GLuint dstMask, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod, GLuint arg3, GLuint arg3Rep, GLuint arg3Mod) {}
void glAlphaFragmentOp1(GLenum op, GLuint dst, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod) {}
void glAlphaFragmentOp2(GLenum op, GLuint dst, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod) {}
void glAlphaFragmentOp3(GLenum op, GLuint dst, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod, GLuint arg3, GLuint arg3Rep, GLuint arg3Mod) {}
void glSetFragmentShaderConstant(GLuint dst, const GLfloat *value) {}
void glElementPointer(GLenum type, const GLvoid *pointer) {}
void glDrawElementArray(GLenum mode, GLsizei count) {}
void glDrawRangeElementArray(GLenum mode, GLuint start, GLuint end, GLsizei count) {}
void glClientActiveVertexStream(GLenum stream) {}
void glVertexBlendEnvi(GLenum pname, GLint param) {}
void glVertexBlendEnvf(GLenum pname, GLfloat param) {}
void glVertexStream2s(GLenum stream, GLshort x, GLshort y) {}
void glVertexStream2sv(GLenum stream, const GLshort *v) {}
void glVertexStream2i(GLenum stream, GLint x, GLint y) {}
void glVertexStream2iv(GLenum stream, const GLint *v) {}
void glVertexStream2f(GLenum stream, GLfloat x, GLfloat y) {}
void glVertexStream2fv(GLenum stream, const GLfloat *v) {}
void glVertexStream2d(GLenum stream, GLdouble x, GLdouble y) {}
void glVertexStream2dv(GLenum stream, const GLdouble *v) {}
void glVertexStream3s(GLenum stream, GLshort x, GLshort y, GLshort z) {}
void glVertexStream3sv(GLenum stream, const GLshort *v) {}
void glVertexStream3i(GLenum stream, GLint x, GLint y, GLint z) {}
void glVertexStream3iv(GLenum stream, const GLint *v) {}
void glVertexStream3f(GLenum stream, GLfloat x, GLfloat y, GLfloat z) {}
void glVertexStream3fv(GLenum stream, const GLfloat *v) {}
void glVertexStream3d(GLenum stream, GLdouble x, GLdouble y, GLdouble z) {}
void glVertexStream3dv(GLenum stream, const GLdouble *v) {}
void glVertexStream4s(GLenum stream, GLshort x, GLshort y, GLshort z, GLshort w) {}
void glVertexStream4sv(GLenum stream, const GLshort *v) {}
void glVertexStream4i(GLenum stream, GLint x, GLint y, GLint z, GLint w) {}
void glVertexStream4iv(GLenum stream, const GLint *v) {}
void glVertexStream4f(GLenum stream, GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}
void glVertexStream4fv(GLenum stream, const GLfloat *v) {}
void glVertexStream4d(GLenum stream, GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}
void glVertexStream4dv(GLenum stream, const GLdouble *v) {}
void glNormalStream3b(GLenum stream, GLbyte x, GLbyte y, GLbyte z) {}
void glNormalStream3bv(GLenum stream, const GLbyte *v) {}
void glNormalStream3s(GLenum stream, GLshort x, GLshort y, GLshort z) {}
void glNormalStream3sv(GLenum stream, const GLshort *v) {}
void glNormalStream3i(GLenum stream, GLint x, GLint y, GLint z) {}
void glNormalStream3iv(GLenum stream, const GLint *v) {}
void glNormalStream3f(GLenum stream, GLfloat x, GLfloat y, GLfloat z) {}
void glNormalStream3fv(GLenum stream, const GLfloat *v) {}
void glNormalStream3d(GLenum stream, GLdouble x, GLdouble y, GLdouble z) {}
void glNormalStream3dv(GLenum stream, const GLdouble *v) {}
GLuint glNewObjectBuffer(GLsizei size, const GLvoid *pointer, GLenum usage) { return 0;}
GLboolean glIsObjectBuffer(GLuint buffer) { return 0;}
void glUpdateObjectBuffer(GLuint buffer, GLuint offset, GLsizei size, const GLvoid *pointer, GLenum preserve) {}
void glGetObjectBufferfv(GLuint buffer, GLenum pname, GLfloat *params) {}
void glGetObjectBufferiv(GLuint buffer, GLenum pname, GLint *params) {}
void glFreeObjectBuffer(GLuint buffer) {}
void glArrayObject(GLenum array, GLint size, GLenum type, GLsizei stride, GLuint buffer, GLuint offset) {}
void glGetArrayObjectfv(GLenum array, GLenum pname, GLfloat *params) {}
void glGetArrayObjectiv(GLenum array, GLenum pname, GLint *params) {}
void glVariantArrayObject(GLuint id, GLenum type, GLsizei stride, GLuint buffer, GLuint offset) {}
void glGetVariantArrayObjectfv(GLuint id, GLenum pname, GLfloat *params) {}
void glGetVariantArrayObjectiv(GLuint id, GLenum pname, GLint *params) {}
void glGenOcclusionQueries(GLsizei n, GLuint *ids) {}
void glDeleteOcclusionQueries(GLsizei n, const GLuint *ids) {}
GLboolean glIsOcclusionQuery(GLuint id) { return 0;}
void glBeginOcclusionQuery(GLuint id) {}
void glEndOcclusionQuery(void) {}
void glGetOcclusionQueryiv(GLuint id, GLenum pname, GLint *params) {}
void glGetOcclusionQueryuiv(GLuint id, GLenum pname, GLuint *params) {}
void glPointParameteri(GLenum pname, GLint param) {}
void glPointParameteriv(GLenum pname, const GLint *params) {}
void glWindowPos2d(GLdouble x, GLdouble y) {}
void glWindowPos2f(GLfloat x, GLfloat y) {}
void glWindowPos2i(GLint x, GLint y) {}
void glWindowPos2s(GLshort x, GLshort y) {}
void glWindowPos2dv(const GLdouble *p) {}
void glWindowPos2fv(const GLfloat *p) {}
void glWindowPos2iv(const GLint *p) {}
void glWindowPos2sv(const GLshort *p) {}
void glWindowPos3d(GLdouble x, GLdouble y, GLdouble z) {}
void glWindowPos3f(GLfloat x, GLfloat y, GLfloat z) {}
void glWindowPos3i(GLint x, GLint y, GLint z) {}
void glWindowPos3s(GLshort x, GLshort y, GLshort z) {}
void glWindowPos3dv(const GLdouble *p) {}
void glWindowPos3fv(const GLfloat *p) {}
void glWindowPos3iv(const GLint *p) {}
void glWindowPos3sv(const GLshort *p) {}
const wglGetExtensionsString() { return 0;}
HANDLE wglCreateBufferRegion(HDC hDC, int iLayerPlane, UINT uType) { return 0;}
VOID wglDeleteBufferRegion(HANDLE hRegion) { return 0;}
BOOL wglSaveBufferRegion(HANDLE hRegion, int x, int y, int width, int height) { return 0;}
BOOL wglRestoreBufferRegion(HANDLE hRegion, int x, int y, int width, int height, int xSrc, int ySrc) { return 0;}
const wglGetExtensionsString(HDC hdc) { return 0;}
HPBUFFER wglCreatePbufferARB(HDC hDC, int iPixelFormat, int iWidth, int iHeight, const int *piAttribList) { return 0;}
HDC wglGetPbufferDC(HPBUFFERARB hPbuffer) { return 0;}
int wglReleasePbufferDC(HPBUFFERARB hPbuffer, HDC hDC) { return 0;}
BOOL wglDestroyPbuffer(HPBUFFERARB hPbuffer) { return 0;}
BOOL wglQueryPbuffer(HPBUFFERARB hPbuffer, int iAttribute, int *piValue) { return 0;}
BOOL wglGetPixelFormatAttribiv(HDC hdc, int iPixelFormat, int iLayerPlane, UINT nAttributes, const int *piAttributes, int *piValues) { return 0;}
BOOL wglGetPixelFormatAttribfv(HDC hdc, int iPixelFormat, int iLayerPlane, UINT nAttributes, const int *piAttributes, FLOAT *pfValues) { return 0;}
BOOL wglChoosePixelFormat(HDC hdc, const int *piAttribIList, const FLOAT *pfAttribFList, UINT nMaxFormats, int *piFormats, UINT *nNumFormats) { return 0;}
BOOL wglBindTexImage(HPBUFFERARB hPbuffer, int iBuffer) { return 0;}
BOOL wglReleaseTexImage(HPBUFFERARB hPbuffer, int iBuffer) { return 0;}
BOOL wglSetPbufferAttrib(HPBUFFERARB hPbuffer, const int *piAttribList) { return 0;}
BOOL wglSwapInterval(int interval) { return 0;}
int wglGetSwapInterval(void) { return 0;}
BOOL wglMakeContextCurrent(HDC hDrawDC, HDC hReadDC, HGLRC hglrc) { return 0;}
HDC wglGetCurrentReadDC(void) { return 0;}
// <-- extensions without postfix

#endif
#endif
