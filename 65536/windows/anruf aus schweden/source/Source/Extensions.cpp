
#include "Extensions.h"

// ARB_vertex_program + ARB_fragment_program
PFNGLGENPROGRAMSARB					glGenProgramsARB					= 0;
PFNGLBINDPROGRAMARB					glBindProgramARB					= 0;
PFNGLPROGRAMSTRINGARB				glProgramStringARB					= 0;
PFNGLDELETEPROGRAMSARB				glDeleteProgramsARB					= 0;
PFNGLPROGRAMENVPARAMETER4FARB		glProgramEnvParameter4fARB			= 0;
PFNGLPROGRAMENVPARAMETER4FVARB		glProgramEnvParameter4fvARB			= 0;
PFNGLPROGRAMLOCALPARAMETER4FARB		glProgramLocalParameter4fARB		= 0;
PFNGLPROGRAMLOCALPARAMETER4FVARB	glProgramLocalParameter4fvARB		= 0;

// ARB_vertex_buffer_object
PFNGLBINDBUFFERARB					glBindBufferARB						= 0;
PFNGLDELETEBUFFERSARB				glDeleteBuffersARB					= 0;
PFNGLGENBUFFERSARB					glGenBuffersARB						= 0;
PFNGLBUFFERDATAARB					glBufferDataARB						= 0;

// vertex array
PFNGLDRAWRANGEELEMENTS				glDrawRangeElements					= 0;


// ripped from opengl.org :)
bool isExtensionSupported( const char *extension )
{
	const GLubyte		*extensions = NULL;
	const GLubyte		*start;
	GLubyte				*where, *terminator;

	/* Extension names should not have spaces. */
	where = ( GLubyte* )strchr( extension, ' ' );
	if( where || *extension == '\0' )
		return false;

	extensions = glGetString( GL_EXTENSIONS );

	/* It takes a bit of care to be fool-proof about parsing the
	OpenGL extensions string. Don't be fooled by sub-strings,
	etc. */
	start = extensions;

	for (;;) {
		where = ( GLubyte* )strstr( ( const char* ) start, extension );
		if( !where )
			break;

		terminator = where + strlen( extension );

		if( where == start || *( where - 1 ) == ' ' )
		if( *terminator == ' ' || *terminator == '\0' )
			return true;

		start = terminator;
	}

	return false;
}

bool loadExtensions() {

	if( isExtensionSupported( "GL_ARB_vertex_program" ) && isExtensionSupported( "GL_ARB_fragment_program" ) ) {

		glGenProgramsARB				= reinterpret_cast<PFNGLGENPROGRAMSARB>( wglGetProcAddress( "glGenProgramsARB" ) );
		glBindProgramARB				= reinterpret_cast<PFNGLBINDPROGRAMARB>( wglGetProcAddress( "glBindProgramARB" ) );
		glProgramStringARB				= reinterpret_cast<PFNGLPROGRAMSTRINGARB>( wglGetProcAddress( "glProgramStringARB" ) );
		glDeleteProgramsARB				= reinterpret_cast<PFNGLDELETEPROGRAMSARB>( wglGetProcAddress( "glDeleteProgramsARB" ) );
		glProgramLocalParameter4fARB	= reinterpret_cast<PFNGLPROGRAMLOCALPARAMETER4FARB>( wglGetProcAddress( "glProgramLocalParameter4fARB" ) );
		glProgramLocalParameter4fvARB	= reinterpret_cast<PFNGLPROGRAMLOCALPARAMETER4FVARB>( wglGetProcAddress( "glProgramLocalParameter4fvARB" ) );
		glProgramEnvParameter4fARB		= reinterpret_cast<PFNGLPROGRAMENVPARAMETER4FARB>( wglGetProcAddress( "glProgramEnvParameter4fARB" ) );
		glProgramEnvParameter4fvARB		= reinterpret_cast<PFNGLPROGRAMENVPARAMETER4FVARB>( wglGetProcAddress( "glProgramEnvParameter4fvARB" ) );

	} else {

		MessageBox( 0, "vertex and/or fragment shader extensions not supported", "she-male detected!", MB_OK );
		return false;
	}

	if( isExtensionSupported( "GL_ARB_vertex_buffer_object" ) ) {

		glGenBuffersARB					= reinterpret_cast<PFNGLGENBUFFERSARB>( wglGetProcAddress( "glGenBuffersARB" ) );
		glBindBufferARB					= reinterpret_cast<PFNGLBINDBUFFERARB>( wglGetProcAddress( "glBindBufferARB" ) );
		glBufferDataARB					= reinterpret_cast<PFNGLBUFFERDATAARB>( wglGetProcAddress( "glBufferDataARB" ) );
		glDeleteBuffersARB				= reinterpret_cast<PFNGLDELETEBUFFERSARB>( wglGetProcAddress( "glDeleteBuffersARB" ) );

	} else {

		MessageBox( 0, "vertex buffer extension not supported", "she-male detected!", MB_OK );
		return false;
	}

	if( isExtensionSupported( "GL_EXT_draw_range_elements" ) ) {

		 glDrawRangeElements			= reinterpret_cast<PFNGLDRAWRANGEELEMENTS>( wglGetProcAddress( "glDrawRangeElements" ) );

	} else {

		MessageBox( 0, "vertex array range extension not supported", "she-male detected!", MB_OK );
		return false;
	 }

	return true;
}