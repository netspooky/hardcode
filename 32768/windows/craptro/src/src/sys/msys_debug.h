//--------------------------------------------------------------------------//
// iq . 2003/2008 . code for 64 kb intros by RGBA                           //
//--------------------------------------------------------------------------//

#ifndef _MSYS_DEBUG_H_
#define _MSYS_DEBUG_H_

#ifdef DEBUG

int  msys_debugInit( void );
void msys_debugEnd( void );
void msys_debugPrintf( char *format, ... );
void msys_debugCheckfor( bool expression, char *format, ... );
void msys_debugHaltProgram( char *str );

#endif

#endif

