//--------------------------------------------------------------------------//
// iq / rgba  .  tiny codes  .  2008                                        //
//--------------------------------------------------------------------------//

#ifndef _EXTENSIONES_H_
#define _EXTENSIONES_H_

#ifdef WINDOWS
#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include <windows.h>
#endif
#include <GL/gl.h>
#include "glext.h"


#ifdef DEBUG
#define NUMFUNCIONES 12
#else
#define NUMFUNCIONES 10
#endif

extern void *myglfunc[NUMFUNCIONES];


#define oglCreateProgram	            ((PFNGLCREATEPROGRAMPROC)myglfunc[0])
#define oglCreateShader		            ((PFNGLCREATESHADERPROC)myglfunc[1])
#define oglShaderSource                 ((PFNGLSHADERSOURCEPROC)myglfunc[2])
#define oglCompileShader                ((PFNGLCOMPILESHADERPROC)myglfunc[3])
#define oglAttachShader                 ((PFNGLATTACHSHADERPROC)myglfunc[4])
#define oglLinkProgram                  ((PFNGLLINKPROGRAMPROC)myglfunc[5])
#define oglUseProgram                   ((PFNGLUSEPROGRAMPROC)myglfunc[6])
#define oglUniform4fv                   ((PFNGLUNIFORM4FVPROC)myglfunc[7])
#define oglUniform1i                    ((PFNGLUNIFORM1IPROC)myglfunc[8])
#define oglGetUniformLocation           ((PFNGLGETUNIFORMLOCATIONARBPROC)myglfunc[9])

#ifdef DEBUG
#define oglGetObjectParameteriv         ((PFNGLGETOBJECTPARAMETERIVARBPROC)myglfunc[10])
#define oglGetInfoLog                   ((PFNGLGETINFOLOGARBPROC)myglfunc[11])
#endif

// init
int EXT_Init( void );

#endif
