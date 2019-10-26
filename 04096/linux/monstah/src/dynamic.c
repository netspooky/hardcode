#include "SDL_opengl.h"
#include <GL/glut.h>
#include <dlfcn.h>

#ifndef DEBUG

/* IMPORTANT: function pointers and function symbol names must be in the same
 * order */

static struct {
// void (*my_glBegin)( GLenum mode );
#if 0
 void (*my_glBlendFunc)( GLenum sfactor, GLenum dfactor );
#endif
 void (*my_glClear)( GLbitfield mask );
 void (*my_glClearColor)( GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha );
 void (*my_glColor3fv)( const GLfloat * );
 void (*my_glDisable)( GLenum cap );
 void (*my_glDrawElements)( GLenum mode, GLsizei count, GLenum type, const GLvoid *indices );
 void (*my_glEnable)( GLenum cap );
 void (*my_glEnableClientState)( GLenum cap);
// void (*my_glEnd)( void );
 void (*my_glFogfv)(GLenum pname, const GLfloat *params);
//static void (*my_glFrustum)( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble near_val, GLdouble far_val );
 void (*my_glLightfv)(GLenum light, GLenum pname, const GLfloat *params);
 void (*my_glLineWidth)(GLfloat);
 void (*my_glLoadIdentity)( void );
 void (*my_glMatrixMode)( GLenum mode );
// void (*my_glNormal3fv)( const GLfloat *v );
 void (*my_glNormalPointer)(GLenum type, GLsizei stride, const GLvoid *ptr);
//static void (*my_glPointSize)( GLfloat size );
 void (*my_glPopMatrix)();
 void (*my_glPushMatrix)();
// void (*my_glRotatef)( GLfloat angle, GLfloat x, GLfloat y, GLfloat z );
 void (*my_glScalef)(GLfloat, GLfloat, GLfloat);
 void (*my_glTranslatef)( GLfloat x, GLfloat y, GLfloat z );
// void (*my_glVertex3fv)( const GLfloat *v );
 void (*my_glVertexPointer)( GLint size, GLenum type, GLsizei stride, const GLvoid *ptr);
 void (*my_gluPerspective)(GLdouble, GLdouble, GLdouble, GLdouble);
 void (*my_gluLookAt)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble);

// void (*my_glutSolidTorus)(GLdouble, GLdouble, GLint, GLint);
 void *my_glutStrokeRoman;
 void (*my_glutStrokeCharacter)(void *, int);

 int (*my_SDL_Init)(Uint32 flags);
 SDL_Surface *(*my_SDL_SetVideoMode)(int width, int height, int bpp, Uint32 flags);
 void (*my_SDL_GL_SwapBuffers)(void);
 int (*my_SDL_PollEvent)(SDL_Event *);
 Uint32 (*my_SDL_GetTicks)();
 int (*my_SDL_ShowCursor)(int toggle);
// void (*my_SDL_Delay)(unsigned int);
#ifndef USE_STDOUT_AUDIO
 int (*my_SDL_OpenAudio)(SDL_AudioSpec *, SDL_AudioSpec *);
 void (*my_SDL_PauseAudio)(int);
#endif
 void *(*my_calloc)(size_t, size_t);
#ifdef USE_STDOUT_AUDIO
 int (*my_fork)();
#endif
 void (*my_free)(void *);
 float (*my_powf)(float x, float y);
#ifdef USE_STDOUT_AUDIO
 int (*my_putchar)(int c);
#endif
 int (*my_rand)();
// void *(*my_memset)(void *s, int c, size_t n);
} dynfuncs;

static const char func_names[] =
//"glBegin\0"
#if 0
"glBlendFunc\0"
#endif
"glClear\0"
"glClearColor\0"
"glColor3fv\0"
"glDisable\0"
"glDrawElements\0"
"glEnable\0"
"glEnableClientState\0"
//"glEnd\0"
"glFogfv\0"
//"glFrustum\0"
"glLightfv\0"
"glLineWidth\0"
"glLoadIdentity\0"
"glMatrixMode\0"
//"glNormal3fv\0"
"glNormalPointer\0"
//"glPointSize\0"
"glPopMatrix\0"
"glPushMatrix\0"
//"glRotatef\0"
"glScalef\0"
"glTranslatef\0"
//"glVertex3fv\0"
"glVertexPointer\0"

"gluPerspective\0"
"gluLookAt\0"

//"glutSolidTorus\0"
"glutStrokeRoman\0"
"glutStrokeCharacter\0"

"SDL_Init\0"
"SDL_SetVideoMode\0"
"SDL_GL_SwapBuffers\0"
"SDL_PollEvent\0"
"SDL_GetTicks\0"
"SDL_ShowCursor\0"
//"SDL_Delay\0"
#ifndef USE_STDOUT_AUDIO
"SDL_OpenAudio\0"
"SDL_PauseAudio\0"
#endif

"calloc\0"
#ifdef USE_STDOUT_AUDIO
"fork\0"
#endif
"free\0"
"powf\0"
#ifdef USE_STDOUT_AUDIO
"putchar\0"
#endif
"rand\0"
//"memset\0"
;

static const char libs[] =
  "libGL.so\0libGLU.so\0libglut.so\0libSDL.so\0libc.so.6\0";

AINLINE static inline void init_dynamic_functions() {
  void *h[5];
  void **f;
  const char *p;

  /* Open libraries */

  p = libs;

  f = h;
  do {
    *f++ = dlopen(p, RTLD_LAZY);
    while(*p++);
  } while(*p);

  /* Get function pointers */

  p = func_names;

  f = (void **) &dynfuncs;
  do {
    for(int i=0; i<5; i++) {
      void *a = dlsym(h[i], p);
      //fprintf(stderr, "%s %p %s\n", p, a, dlerror());
      if(a) {
        *f++ = a;
        break;
      }
    }

    while(*p++);
  } while(*p);
}

#define glBegin dynfuncs.my_glBegin
#define glBlendFunc dynfuncs.my_glBlendFunc
#define glClearColor dynfuncs.my_glClearColor
#define glClear dynfuncs.my_glClear
#define glColor3fv dynfuncs.my_glColor3fv
#define glDisable dynfuncs.my_glDisable
#define glDrawElements dynfuncs.my_glDrawElements
#define glEnable dynfuncs.my_glEnable
#define glEnableClientState dynfuncs.my_glEnableClientState
#define glEnd dynfuncs.my_glEnd
#define glFogfv dynfuncs.my_glFogfv
#define glFrustum dynfuncs.my_glFrustum
#define glLightfv dynfuncs.my_glLightfv
#define glLineWidth dynfuncs.my_glLineWidth
#define glLoadIdentity dynfuncs.my_glLoadIdentity
#define glMatrixMode dynfuncs.my_glMatrixMode
#define glNormal3fv dynfuncs.my_glNormal3fv
#define glNormalPointer dynfuncs.my_glNormalPointer
#define glPointSize dynfuncs.my_glPointSize
#define glPopMatrix dynfuncs.my_glPopMatrix
#define glPushMatrix dynfuncs.my_glPushMatrix
#define glRotatef dynfuncs.my_glRotatef
#define glScalef dynfuncs.my_glScalef
#define glTranslatef dynfuncs.my_glTranslatef
#define glVertex3fv dynfuncs.my_glVertex3fv
#define glVertexPointer dynfuncs.my_glVertexPointer

#define gluPerspective dynfuncs.my_gluPerspective
#define gluLookAt dynfuncs.my_gluLookAt

#define glutSolidTorus dynfuncs.my_glutSolidTorus
#define glutStrokeRoman dynfuncs.my_glutStrokeRoman
#define glutStrokeCharacter dynfuncs.my_glutStrokeCharacter

#define SDL_Init dynfuncs.my_SDL_Init
#define SDL_SetVideoMode dynfuncs.my_SDL_SetVideoMode
#define SDL_OpenAudio dynfuncs.my_SDL_OpenAudio
#define SDL_PauseAudio dynfuncs.my_SDL_PauseAudio
#define SDL_GL_SwapBuffers dynfuncs.my_SDL_GL_SwapBuffers
#define SDL_PollEvent dynfuncs.my_SDL_PollEvent
#define SDL_GetTicks dynfuncs.my_SDL_GetTicks
#define SDL_ShowCursor dynfuncs.my_SDL_ShowCursor
#define SDL_Delay dynfuncs.my_SDL_Delay

#define powf dynfuncs.my_powf
#define rand dynfuncs.my_rand
#define calloc dynfuncs.my_calloc
#define fork dynfuncs.my_fork
#define putchar dynfuncs.my_putchar
#define free dynfuncs.my_free
#define memset dynfuncs.my_memset

#endif
