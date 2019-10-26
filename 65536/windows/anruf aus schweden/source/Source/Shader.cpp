
#include "Shader.h"
#include "Extensions.h"
//#include <iostream>

Shader::Shader( unsigned char const* shaderString, int length, ShaderType t ): loaded( false ), ID( 0 ) {

	if( t == VERTEX )
		type = GL_VERTEX_PROGRAM_ARB;
	if( t == PIXEL )
		type = GL_FRAGMENT_PROGRAM_ARB;

	uploadProgram( reinterpret_cast<char const*>( shaderString ), length );
}

bool Shader::loadedSuccessfully() const {
	return loaded;
}

void Shader::bindShader() const {
	glBindProgramARB( type, ID );
}

void Shader::specifyLocalParameters( int index, float x, float y, float z, float w ) const {
	glProgramLocalParameter4fARB( type, index, x, y, z, w );
}
void Shader::specifyLocalParameters( int index, float* params ) const {
	glProgramLocalParameter4fvARB( type, index, params );
}

void Shader::specifyEnvParameters( int index, float x, float y, float z, float w ) const {
	glProgramEnvParameter4fARB( type, index, x, y, z, w );
}

void Shader::specifyEnvParameters( int index, float* params ) const {
	glProgramEnvParameter4fvARB( type, index, params );
}

void Shader::uploadProgram( char const* shaderString, int length ) {

	glGenProgramsARB( 1, &ID );
	bindShader();
	glProgramStringARB( type, GL_PROGRAM_FORMAT_ASCII_ARB, length, shaderString );

	if( GL_INVALID_OPERATION == glGetError() ) {

		//GLubyte const* errorString = glGetString( GL_PROGRAM_ERROR_STRING_ARB );
		//std::cout << "error while loading shader" << std::endl << errorString << std::endl;

		loaded = false;
		return;

	} else {

		//std::cout << "ok" << std::endl;
	}

	loaded = true;
}

void Shader::deleteProgram() {

	glDeleteProgramsARB( 1, &ID );
}