//--------------------------------------------------------------------------//
// iq . 2003/2008 . code for 64 kb intros by RGBA                           //
//--------------------------------------------------------------------------//

#ifdef DEBUG

#include <windows.h>
#include <stdio.h>
#include <stdarg.h>
#include "../msys_debug.h"

static FILE *fp;

int msys_debugInit( void )
{
    fp = fopen( "debug.txt", "wt" );
    if( !fp )
        return( 0 );

    fprintf( fp, "debug file\n" );
    fprintf( fp, "-------------------------\n" );
    fflush( fp );

    return( 1 );
}

void msys_debugEnd( void )
{
    fprintf( fp, "-------------------------\n" );
    fflush( fp );
    fclose( fp );
}

void msys_debugPrintf( char *format, ... )
{
    va_list arglist;
    va_start( arglist, format );
    vfprintf( fp, format, arglist );
    fflush( fp );
	va_end( arglist );
}


void msys_debugCheckfor( bool expression, char *format, ... )
{
    char    str[1024];

    if( !expression )
        {
        va_list arglist;
        va_start( arglist, format );
        vsprintf( str, format, arglist );
	    va_end( arglist );
        msys_debugHaltProgram( str );
        }
}

void msys_debugHaltProgram( char *str )
{
    MessageBox( 0, str, "error", MB_OK );
    DebugBreak();
}

#endif
