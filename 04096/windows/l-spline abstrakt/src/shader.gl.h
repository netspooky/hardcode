#pragma once

#include <gl\gl.h>
#include <gl\glu.h>
#define GL_GLEXT_PROTOTYPES
#include "glext.h"



void compile_shader(GLuint p, const GLchar*const* sstr, GLenum type)
{
	GLuint s = ((PFNGLCREATESHADERPROC)(wglGetProcAddress("glCreateShader")))(type);
		((PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource")) (s, 1, (const char **)sstr, NULL);
	    ((PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader"))(s);
	    ((PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader")) (p,s);
}

GLuint make_shader(const GLchar*const* vsstr, const GLchar*const* fsstr)
{
	GLuint p = ((PFNGLCREATEPROGRAMPROC)wglGetProcAddress("glCreateProgram"))();
	compile_shader(p, vsstr, GL_VERTEX_SHADER);
	compile_shader(p, fsstr, GL_FRAGMENT_SHADER);
	((PFNGLLINKPROGRAMPROC)wglGetProcAddress("glLinkProgram"))(p);
	return p;
}

#ifdef RESTART_ENABLED
void delete_shader(GLuint p)
{
	((PFNGLDELETEPROGRAMPROC)wglGetProcAddress("glDeleteProgram"))(p);
}
#endif
GLuint mshader__;

void use_shader(GLuint p)
{
	mshader__ = p;
	((PFNGLUSEPROGRAMPROC) wglGetProcAddress("glUseProgram"))(p);
}

int shader_varloc(char const* name)
{
	return ((PFNGLGETUNIFORMLOCATIONPROC) wglGetProcAddress("glGetUniformLocation")) (mshader__, name);
}
