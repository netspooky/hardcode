
#ifndef __SHADER_H__
#define __SHADER_H__

#include <vector>
#include <windows.h>
#include <gl/gl.h>

enum ShaderType {
	VERTEX,
	PIXEL
};

class Shader {
	public:
		explicit Shader( unsigned char const* shaderString, int length, ShaderType t );

		bool			loadedSuccessfully() const;
		void			bindShader() const;
		void			specifyLocalParameters( int index, float x, float y, float z, float w ) const;
		void			specifyLocalParameters( int index, float* params ) const;
		void			specifyEnvParameters( int index, float x, float y, float z, float w ) const;
		void			specifyEnvParameters( int index, float* params ) const;
		void			deleteProgram();

	private:

		void			uploadProgram( char const* shaderString, int length );

		GLuint			ID;
		bool			loaded;
		GLenum			type;
};

typedef std::vector<Shader>		ShaderList;

#endif