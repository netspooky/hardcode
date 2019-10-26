#include "contrib.h"

#if !defined(PUBLISH)
const char* g_glFuncNames[GL_FUNC_COUNT] =
{
	"glGenFramebuffers",
	"glBindFramebuffer",
	"glFramebufferTexture",
	"glGenBuffers",
	"glBindBuffer",
	"glBufferData",
	"glBindVertexArray",
	"glGenVertexArrays",
	"glEnableVertexAttribArray",
	"glVertexAttribPointer",
	"glAttachShader",
	"glCompileShader",
	"glCreateProgram",
	"glCreateShader",
	"glLinkProgram",
	"glUseProgram",
	"glShaderSource",
	"glBindAttribLocation",
	"glBindFragDataLocation",
	"glGetUniformLocation",
	"glUniform1i",
	"glUniform2i",
	"glUniform1iv",
	"glTexImage3D",
	"glFramebufferTextureLayer",
	"glActiveTexture",
	"glDrawBuffers",
};

const char* g_glCleanupNames[GL_CLEANUP_FUNC_COUNT] =
{
	"glDeleteFramebuffers",
	"glDeleteBuffers",
	"glDeleteVertexArrays",
	"glDeleteProgram",
	"glDeleteShader",
};

#if defined(_DEBUG)
const char* g_glDebugFuncNames[GL_DEBUG_FUNC_COUNT] =
{
	"glGetShaderiv",
	"glGetProgramiv",
	"glProgramParameteri",
	"glGetShaderInfoLog",
	"glGetProgramInfoLog",
	"glCheckFramebufferStatus",
};

void ShaderInfoLog(GLuint id)
{
	GLsizei maxLogLength, logLength;
	GLchar *log;

	glDebug.GetShaderiv(id, GL_INFO_LOG_LENGTH, (GLint*)&maxLogLength);

	log = (GLchar*)malloc(sizeof(GLchar) * maxLogLength);	

	glDebug.GetShaderInfoLog(id, maxLogLength, &logLength, log);
	
	fprintf(stderr,"%s", log);

	free(log);
}

void ProgramInfoLog(GLuint id)
{
	GLsizei maxLogLength, logLength;
	GLchar *log;

	glDebug.GetProgramiv(id, GL_INFO_LOG_LENGTH, (GLint*)&maxLogLength);	
	log = (GLchar*)malloc(sizeof(GLchar) * maxLogLength);
	
	glDebug.GetProgramInfoLog(id, maxLogLength, &logLength, log);

	fprintf(stderr,"%s", log);
	
	free(log);
}
	
void ShowGLErrors()
{
	GLenum err = glGetError();
	fprintf(stderr, "%s\n", gluErrorString(err));
}

void ShowCompilationErrors(GLuint i)
{
	GLint result;
	glDebug.GetShaderiv((i), GL_COMPILE_STATUS, &result);
	if (result == GL_FALSE)
	{
		ShaderInfoLog(i);
	}
}

void ShowLinkErrors(GLuint i) 
{
	GLint result;
	glDebug.GetProgramiv((i), GL_LINK_STATUS, &result);
	if (result == GL_FALSE)
	{
		ProgramInfoLog(i);
	}
}
#endif // _DEBUG
#endif // !PUBLISH